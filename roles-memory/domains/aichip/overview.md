# AI 芯片领域

## 定位

AI 加速芯片设计、神经网络编译器、算子开发。

## 核心概念

- **加速器架构**: systolic array, SIMD, VLIW
- **编译器栈**: MLIR, ONNX, TVM, 自定义 IR
- **算子**: Conv, MatMul, Attention, Activation
- **数据流**: bandwidth, tiling, DMA
- **量化**: INT8, FP16, BF16, 混合精度

## 连接

- ← fpga: 硬件加速器原型和部署
- → sdk: 编译器 SDK 和 API
- → vendor: NPU/TPU 厂商工具

## 知识索引

- 设计模式: `patterns.md`
- 踩过的坑: `traps.md`
- 全局经验: `../patterns/verified-solutions.md`
