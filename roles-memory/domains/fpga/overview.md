# FPGA 领域

## 定位

FPGA 开发领域，涵盖 RTL 设计、综合、布局布线、时序收敛。

## 核心概念

- **HDL 语言**: Verilog, SystemVerilog, VHDL
- **综合工具**: 各厂商综合引擎
- **约束**: SDC/XDC 时序约束、引脚约束
- **仿真**: 功能仿真、时序仿真、Gate-Level 仿真
- **时序收敛**: setup/hold, 时钟域交叉(CDC)

## 连接

- → soc: RTL 改动影响 BSP 驱动
- → vendor: 不同厂商工具链、约束格式
- → debug: 上板调试、SignalTap/ILA
- → aichip: 硬件加速器设计

## 知识索引

- 设计模式: `patterns.md`
- 踩过的坑: `traps.md`
- 全局经验: `../patterns/verified-solutions.md`
