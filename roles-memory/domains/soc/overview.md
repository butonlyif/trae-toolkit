# SoC / 嵌入式领域

## 定位

嵌入式系统开发，涵盖 RISC-V/ARM 处理器上的固件、BSP、驱动开发。

## 核心概念

- **处理器架构**: RISC-V, ARM Cortex-M/A
- **BSP**: 板级支持包，寄存器映射，启动代码
- **RTOS**: FreeRTOS, RT-Thread, Zephyr
- **驱动**: UART, SPI, I2C, GPIO, DMA
- **工具链**: GCC, LLVM, OpenOCD, GDB

## 连接

- ← fpga: RTL 改变会影响寄存器地址和位定义
- → sdk: 固件工具和自动化脚本
- → debug: JTAG 调试，OpenOCD 配置
- → vendor: 厂商提供的 HAL/BSP

## 知识索引

- 设计模式: `patterns.md`
- 踩过的坑: `traps.md`
- 全局经验: `../patterns/verified-solutions.md`
