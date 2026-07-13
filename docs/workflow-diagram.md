# Trae Toolkit 工作流示意图

```mermaid
flowchart TB
    subgraph 用户层[" "]
        USER["👤 用户"]
    end

    subgraph PM层["皮特 (PM)"]
        PM["🐻 皮特<br/><small>项目管理 · 任务调度</small>"]
        INIT{".trae 环境<br/>是否完整？"}
    end

    subgraph 流水线["L3 全流程流水线"]
        direction LR
        subgraph 角色组[" "]
            DOCS_P["📋 Docs<br/><small>Pre-task · 写任务文档</small>"]
            BUILDER["🔧 Builder<br/><small>唯一写代码的人</small>"]
            OPT["🔍 Optimizer<br/><small>代码审查 · 质量把关</small>"]
            TESTER["🧪 Tester<br/><small>功能验证 · 测试执行</small>"]
            DOCS_A["📝 Docs<br/><small>Post-task · 更新文档</small>"]
        end
    end

    subgraph 知识层[" "]
        MEMORY["🧠 知识库"]
        DOMAINS["📚 领域知识<br/><small>fpga · soc · sdk · debug · aichip · vendor</small>"]
        JOURNAL["📓 Journal<br/><small>项目本地记忆</small>"]
    end

    USER -->|"皮特，做XXX"| PM
    PM --> INIT
    INIT -->|"不完整"| TRAE_INIT{{"trae-init<br/><small>初始化 .trae 环境</small>"}}
    INIT -->|"完整"| DOCS_P
    TRAE_INIT --> DOCS_P

    DOCS_P -->|"任务文档"| BUILDER
    BUILDER -->|"代码改动"| OPT
    OPT -->|"审查通过"| TESTER
    OPT -->|"打回修复"| BUILDER
    TESTER -->|"验证通过"| DOCS_A
    TESTER -->|"发现Bug"| BUILDER
    DOCS_A -->|"任务完成"| PM
    PM -->|"汇报"| USER

    MEMORY -->|"读 · 写"| BUILDER
    MEMORY -->|"读 · 写"| OPT
    MEMORY -->|"读 · 写"| TESTER
    MEMORY -->|"读 · 写"| DOCS_A
    DOMAINS -->|"领域知识"| MEMORY
    JOURNAL -->|"项目经验"| MEMORY

    style PM fill:#4A90E2,color:#fff,stroke:#2c5aa0
    style USER fill:#27AE60,color:#fff,stroke:#1e8449
    style DOCS_P fill:#E67E22,color:#fff,stroke:#d35400
    style DOCS_A fill:#E67E22,color:#fff,stroke:#d35400
    style BUILDER fill:#9B59B6,color:#fff,stroke:#7d3c98
    style OPT fill:#E74C3C,color:#fff,stroke:#c0392b
    style TESTER fill:#1ABC9C,color:#fff,stroke:#16a085
    style TRAE_INIT fill:#8E44AD,color:#fff,stroke:#6c3483
    style INIT fill:#34495E,color:#fff,stroke:#2c3e50
    style MEMORY fill:#F39C12,color:#fff,stroke:#d68910
    style DOMAINS fill:#F1C40F,color:#333,stroke:#d4ac0d
    style JOURNAL fill:#D5DBDB,color:#333,stroke:#aeb6bf
```

## 角色职责速查

| 角色 | 一句话定位 | 核心能力 |
|------|----------|---------|
| 🐻 **皮特** | 项目总负责 | 任务调度 · 流程监督 · 验收汇报 |
| 📋 **Docs** | Pre-task + Post-task | 任务文档撰写 · 文档更新 · 知识归类 |
| 🔧 **Builder** | 唯一写代码的人 | 功能实现 · Bug修复 · 自我记录 |
| 🔍 **Optimizer** | 代码审查专家 | 三大检查（不必要/重复/效率） |
| 🧪 **Tester** | 功能验证 | 验证方案设计 · 真实行为测试 |
| 📚 **领域知识** | 跨项目共享 | overview · patterns · traps |
| 📓 **Journal** | 项目本地记忆 | builder/opt/tester/docs/research/pm |

## 知识流向

```
领域知识库 (全局 ~/.trae/roles-memory/domains/)
       ↓ 读
  各角色 ———→ 项目本地 Journal (项目 .trae/roles/memory/)
       ↓ 写
  通用知识 → 领域知识库（自我迭代）
  项目经验 → Journal（本地积累）
```

## 触发方式

| 触发词 | 匹配角色 | 行为 |
|--------|---------|------|
| 「皮特，做XXX」 | `trae-pm` | 强制走 L3 全流程 |
| 「初始化 .trae」 | `trae-init` | 初始化/补全协作环境 |
| 任意开发需求 | `trae-pm` | 协调各角色执行流水线 |
