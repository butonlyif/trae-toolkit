---
name: "verilog-code-check"
description: "Reviews Verilog/SystemVerilog code for syntax issues, best practices, synthesis optimizations, and common bugs."
---

> **路径说明**: `~/.trae/` = macOS/Linux `$HOME/.trae/` = Windows `%USERPROFILE%\.trae\`。Agent 会自动根据平台解析。

# Verilog Code Checker

## 用途

审查 Verilog / SystemVerilog 代码，检查以下方面：

## 检查项

### 1. 语法检查
- 模块声明完整性（端口列表、参数化）
- `always_ff` / `always_comb` / `always_latch` 使用是否正确
- `wire` / `reg` / `logic` 声明是否完整
- `generate` 块语法正确性

### 2. 综合检查
- 是否所有代码路径都可综合
- `initial` 块（仅仿真，不可综合）
- 跨时钟域（CDC）信号处理是否有同步器
- 异步复位释放是否处理
- 锁存器推断风险（`case` 缺 `default`、`if` 缺 `else`）

### 3. 最佳实践
- 命名规范一致性
- 参数化 vs 硬编码
- FSM 编码风格（推荐三段式）
- `define` 宏 vs `localparam` 选择
- 复位策略（同步 vs 异步）一致性

### 4. 常见 Bug
- 位宽不匹配导致隐式截断
- 有符号/无符号运算混淆
- 阻塞赋值 `=` vs 非阻塞赋值 `<=` 混用
- `casex` / `casez` 的陷阱
- `for` 循环在综合中的展开合理性

### 5. 代码质量
- 模块长度（建议 < 500 行）
- 端口数量（建议 < 20）
- 注释覆盖率（关键逻辑必须有注释）
- 信号命名可读性

## 输出格式

```
## Verilog 代码检查报告

### 📊 概览
- 文件名: xxx.v / xxx.sv
- 行数: N
- 模块数: N

### 🔴 严重问题
- [行号] 问题描述 → 修复建议

### 🟡 建议改进
- [行号] 问题描述 → 改进建议

### 🟢 通过的检查
- [检查项]: ✅

### 📊 综合评分: [A/B/C/D]
```
