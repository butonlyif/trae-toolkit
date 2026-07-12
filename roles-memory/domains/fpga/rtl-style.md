# RTL 编码规范

> 涉及 FPGA RTL 开发时参考此文件。包含 Verilog/SystemVerilog 编写风格、Efinix 特有约束、常见反模式和检查清单。

## 1. 文件命名与组织

- 一个模块一个文件。文件名 = 模块名：`mipi_csi_rx.sv`
- 小写 + 下划线（不用 kebab-case）：`ddr3_controller.sv` ✅, `ddr3-controller.sv` ❌
- 扩展名：新代码优先 `.sv`，Verilog 用 `.v`
- 顶层：`_top` 后缀 → `awesom_golden_top.v`
- 目录：`rtl/top/`, `rtl/clk_rst/`, `rtl/data_path/`, `rtl/ctrl/`, `rtl/cdc/`, `rtl/ip_wrappers/`

## 2. 模块模板

```systemverilog
`default_nettype none
`timescale 1ns / 1ps

//============================================================================
// 模块名称: <module_name>
// 功能描述: <one-line description>
// 接口说明: <AXI-Stream / Avalon-MM / custom handshake>
// 设计约束: <clock freq, latency, throughput>
//============================================================================
module module_name #(
    parameter DATA_WIDTH = 16
)(
    input  wire                    clk_i,
    input  wire                    rst_n_i,
    input  wire [DATA_WIDTH-1:0]   data_i,
    input  wire                    valid_i,
    output wire                    ready_o,
    output wire [DATA_WIDTH-1:0]   data_o,
    output wire                    valid_o,
    input  wire                    ready_i
);
    // ... implementation ...
endmodule

`default_nettype wire
```

## 3. 端口与信号命名

| 方向 | 后缀 | 示例 |
|------|------|------|
| Input | `_i` | `clk_i`, `data_i`, `valid_i` |
| Output | `_o` | `data_o`, `valid_o`, `led_o` |
| Bidir | `_io` | `sda_io` |
| Active-low | `_n` | `rst_n_i`, `cs_n_o` |

内部信号：`cnt_r`, `fifo_full`, `ST_IDLE`, localparam `DATA_WIDTH` / `MAX_BURST`。

❌ 禁止：`inout` 出现在设计内部（仅顶层 IO）。用 `_i`/`_o`/`_oe` 三元组替代。
❌ 禁止：`.*` 通配端口连接。始终显式：`.clk_i(clk_i)`。
❌ 禁止：顶层模块中写复杂逻辑（仅例化 + 连线）。

## 4. 时钟与复位

### 异步复位、同步释放（强制）

```systemverilog
// 3 级同步释放 — 始终使用此模式
reg [2:0] rst_sync;
always @(posedge clk or negedge rst_n_i) begin
    if (!rst_n_i)
        rst_sync <= 3'b000;
    else
        rst_sync <= {rst_sync[1:0], 1'b1};
end
wire rst_n = rst_sync[2];
```

- 顶层提供一个 `rst_n_i`（异步、低有效）
- 每个时钟域有自己独立的同步释放 `rst_n`
- 复位仅用于控制逻辑。数据通路寄存器用 valid 门控。
- ❌ 禁止：异步复位无同步释放 → 解断言时产生亚稳态。

### 时钟使能，禁止分频时钟

❌ 禁止用分频时钟驱动逻辑：
```systemverilog
always @(posedge clk_div2) cnt <= cnt + 1;  // ❌ 错误
```

✅ 始终使用时钟使能：
```systemverilog
reg clk_en;
always @(posedge sys_clk) clk_en <= ~clk_en;
always @(posedge sys_clk) if (clk_en) cnt <= cnt + 1;  // ✅ 正确
```

时钟命名：`clk_50m_i`（输入），`sys_clk`（系统），`video_clk`（域），`pll_200m`（PLL）。

## 5. 时序友好编码

### 寄存器输出（强烈推荐）

```systemverilog
always @(posedge clk) begin
    data_o  <= data_next;
    valid_o <= valid_next;
end
```

- data 和 control（valid/last/user）必须在**同一个 always 块**中。
- 跨模块有时序违规时，在发送方加输出寄存器。

### 流水线插入

连续 ≥3 级 LUT 无寄存器且逻辑延迟 > 60% 周期时：
```systemverilog
// ❌ assign result = stage3(stage2(stage1(data)));
// ✅
reg [W-1:0] pipe1, pipe2;
always @(posedge clk) pipe1 <= stage1(data);
always @(posedge clk) pipe2 <= stage2(pipe1);
assign result = stage3(pipe2);
```

### 高扇出（>200）

```systemverilog
(* max_fanout = 100 *) reg shared_enable;
// 或手动复制：
reg [3:0] en_replica;
always @(posedge clk) en_replica <= {4{en_src}};
```

## 6. 综合友好编码

### FSM：独热码

```systemverilog
(* fsm_encoding = "one-hot" *)
reg [3:0] state, state_next;
localparam ST_IDLE  = 4'b0001;
localparam ST_READ  = 4'b0010;
```

### 防 Latch（关键）

每个 `case` 必须有 `default`。每个 `if-else` 链必须有最终 `else`。

✅ 组合逻辑 `always @(*)`：在块**顶部**给所有输出赋默认值：
```systemverilog
always @(*) begin
    next_state = state;   // default
    out_valid = 1'b0;     // default
    case (state)
        ST_IDLE: if (start) next_state = ST_RUN;
        ST_RUN:  if (done)  begin next_state = ST_IDLE; out_valid = 1'b1; end
        default: next_state = ST_IDLE;
    endcase
end
```

Latch 成因：缺 `else`、缺 `default`、组合块中用 `<=`。

## 7. CDC（跨时钟域）

### 单比特：2/3 级同步器

```systemverilog
(* ASYNC_REG = "TRUE" *) reg [2:0] sync_ff;
always @(posedge clk_dst)
    sync_ff <= {sync_ff[1:0], src_signal};
wire signal_synced = sync_ff[2];
```

### 多比特总线：Toggle-Valid MUX Sync

```systemverilog
// 发送端 (clk_src)
always @(posedge clk_src)
    if (send) begin data_bus <= new_data; valid_toggle <= ~valid_toggle; end

// 接收端 (clk_dst)
(* ASYNC_REG = "TRUE" *) reg [2:0] toggle_sync;
reg toggle_prev;
always @(posedge clk_dst) begin
    toggle_sync <= {toggle_sync[1:0], valid_toggle};
    toggle_prev <= toggle_sync[2];
    if (toggle_sync[2] != toggle_prev)
        captured_data <= data_bus;  // 此时数据已稳定
end
```

CDC 规则：
- **任何**跨时钟信号都必须经过同步器。
- ❌ 禁止：在 SDC 中对整个 CDC 路径设 `set_false_path`。
- 使用 `set_clock_groups -asynchronous` + 仅对同步链设 `set_false_path`。
- 快→慢单周期脉冲：先展宽再同步。

## 8. 资源推断

### BRAM

```systemverilog
(* ram_style = "block" *)
reg [DATA_W-1:0] mem [0:DEPTH-1];
reg [DATA_W-1:0] mem_rd;
always @(posedge clk) begin
    if (wr_en) mem[wr_addr] <= wr_data;
    mem_rd <= mem[rd_addr];  // 输出寄存器 — BRAM 内免费
end
```

### DSP

```systemverilog
(* use_dsp = "yes" *)
reg [17:0] mult_result;
always @(posedge clk)
    mult_result <= $signed(a) * $signed(b);  // 寄存器化 I/O
```

### PLL

在 Interface Designer 中配置（硬 IP）。RTL 中仅声明时钟端口：
```systemverilog
input wire pll_clk_out,   // PLL 输出时钟
input wire pll_locked,     // PLL 锁定指示
```

## 9. Efinix 特有属性

| 属性 | 用途 |
|------|------|
| `(* ASYNC_REG = "TRUE" *)` | CDC 同步链标记 |
| `(* max_fanout = N *)` | 扇出控制 |
| `(* ram_style = "block" *)` | 强制推断 BRAM |
| `(* use_dsp = "yes" *)` | 强制推断 DSP |
| `(* syn_keep = "true" *)` | 阻止优化移除 |
| `(* fsm_encoding = "one-hot" *)` | FSM 编码提示 |

## 10. 反模式 — 绝对禁止

1. 组合逻辑 `always @(*)` 无默认值 → Latch
2. `case` 无 `default` / `if` 无 `else` → Latch
3. 分频时钟驱动逻辑 → 用时钟使能
4. CDC 无同步器 → 亚稳态
5. 异步复位无同步释放 → 解断言亚稳态
6. data 和 valid 放在**不同** always 块 → 错位
7. 同一 always 块混用 `=` 和 `<=` → 仿真/综合不匹配
8. `inout` 端口出现在设计内部 → 仅顶层 IO
9. BRAM 读取不用输出寄存器 → 浪费免费寄存器
10. 乘法器不寄存器化 I/O → 长组合路径
11. 信号名与 Verilog 关键字冲突 → 编译错误
12. 高扇出信号（>200）不复制的 → 布线拥塞

## 11. RTL 改动检查清单（提交前验证）

**结构：**
- [ ] 文件名 = 模块名，小写 + 下划线
- [ ] 模块头注释块存在
- [ ] `` `default_nettype none `` / `` `default_nettype wire `` 首尾配对
- [ ] 端口有 `_i` / `_o` / `_n` 方向后缀

**时序：**
- [ ] 模块输出已寄存器化
- [ ] data + valid/last/user 在同一 always 块
- [ ] 高扇出信号有 `max_fanout` 或复制
- [ ] CDC 信号有同步器 + `ASYNC_REG` 属性

**综合：**
- [ ] 每个 `case` 有 `default`
- [ ] 组合逻辑 `always @(*)` 顶部有默认值
- [ ] BRAM 读取使用输出寄存器
- [ ] 乘法器 I/O 已寄存器化
- [ ] FSM 使用 `(* fsm_encoding = "one-hot" *)`

**约束：**
- [ ] SDC 中每个时钟有 `create_clock`（与 RTL 端口名一致）
- [ ] 异步时钟域有 `set_clock_groups -asynchronous`
- [ ] IO 有 `set_input_delay` / `set_output_delay`
