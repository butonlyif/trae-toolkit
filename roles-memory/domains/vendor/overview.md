# 厂商工具领域

## 定位

特定厂商（如 Efinix, Xilinx, Altera/Intel 等）的专有工具链、流程、兼容性问题。

## 核心概念

- **工具链**: 各厂商的综合/布局布线工具
- **版本兼容**: 不同版本的特性、Bug、迁移路径
- **专有格式**: 厂商特定的约束文件、项目文件
- **平台差异**: Windows/Linux 下的行为差异
- **授权**: License 管理

## 连接

- ← fpga: 工具链是 FPGA 开发的核心依赖
- → sdk: SDK 需要集成厂商工具调用
- → debug: 调试工具依赖厂商提供

## 知识索引

- 工具速查: `tools.md`
- 踩过的坑: `traps.md`
- 全局经验: `../patterns/verified-solutions.md`
