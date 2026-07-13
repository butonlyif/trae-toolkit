# Trae Toolkit 角色协作工作流规格说明

> 版本: v1.0  
> 更新: 2026-07-12

---

## 目录

1. [概述](#1-概述)
2. [系统架构](#2-系统架构)
3. [角色定义](#3-角色定义)
4. [触发机制](#4-触发机制)
5. [L3 全流程流水线](#5-l3-全流程流水线)
6. [打回与重试机制](#6-打回与重试机制)
7. [知识管理系统](#7-知识管理系统)
8. [角色自我迭代](#8-角色自我迭代)
9. [环境初始化](#9-环境初始化)
10. [文件结构总览](#10-文件结构总览)

---

## 1. 概述

### 1.1 是什么

Trae Toolkit 是一套基于 AI Agent 多角色协作的软件开发框架。它将传统软件工程中的角色分工（项目管理、文档编写、编码实现、代码审查、测试验证）转化为 6 个独立的 AI Skill，通过强制的流水线（Pipeline）保证开发质量。

### 1.2 解决的问题

| 问题 | 传统 AI 编码 | Trae Toolkit |
|------|------------|-------------|
| 需求理解偏差 | Assistant 直接开始写代码，可能偏题 | PM 先分析需求，Docs 先写任务单 |
| 没有代码审查 | 写完就算完成 | Optimizer 三大检查强制过 |
| 不测试就交付 | 改完直接说"完成" | Tester 必须做真实行为验证 |
| 文档与代码脱节 | 文档永远是 TODO | Docs Pre/Post 双环节 |
| 项目经验丢失 | 每次从零开始 | Journal + 领域知识库持续积累 |
| 不同项目规范混乱 | 靠 prompt 随机应变 | 领域 traps/patterns 统一指导 |

### 1.3 核心原则

> **简单优先。最少代码解决当前问题，不做假设性抽象。  
> 精准改动。只改需要改的地方，不美化周边代码。  
> 先想后写。不假设，不隐藏疑问，不跳过环节。**

---

## 2. 系统架构

```
用户 ("皮特，做XXX")
  │
  ▼
┌─────────────────────────────────────────────────┐
│  Skill: trae-pm  (皮特)                          │
│  ├─ 检测 .trae/roles/memory/ 是否完整              │
│  ├─ 分析需求，判定 L1 / L2 / L3 级别               │
│  └─ L3 → 启动流水线                               │
└──────────┬──────────────────────────────────────┘
           │
           ▼
┌──────────────────────────────────────────────────┐
│  L3 全流程流水线                                     │
│                                                     │
│  Docs (Pre)  →  Builder  →  Optimizer  →  Tester   │
│                                  │           │      │
│                                  ▼           ▼      │
│                              Builder      Builder   │
│                              (打回修复)    (修 Bug)  │
│                                                     │
│  Tester PASS  →  Docs (Post)  →  皮特验收  →  用户  │
└──────────────────────────────────────────────────┘
           │
           ▼
┌──────────────────────────────────────────────────┐
│  知识层                                             │
│                                                     │
│  全局领域知识库  ←→  各角色  ←→  项目本地 Journal     │
│  (跨项目共享)              (本项目积累)               │
└──────────────────────────────────────────────────┘
```

---

## 3. 角色定义

### 3.1 角色总览

| 角色 | 图标 | Skill 名称 | 一句话定位 | 触发方式 |
|------|------|-----------|----------|---------|
| 皮特 (PM) | 🐻 | `trae-pm` | 项目总负责，任务调度与质量监督 | 用户说「皮特，做XXX」 |
| Docs | 📋 | `trae-docs` | 文档工程师，Pre-task + Post-task | PM 内部调用 |
| Builder | 🔧 | `trae-builder` | 唯一写代码的人 | PM 内部调用 |
| Optimizer | 🔍 | `trae-optimizer` | 代码审查专家 | Builder 提交代码后 |
| Tester | 🧪 | `trae-tester` | 功能验证工程师 | Optimizer 审查通过后 |
| Researcher | 🔬 | `trae-research` | 技术研究员，不做决策不写代码 | PM 需要调研时 |
| trae-init | ⚙️ | `trae-init` | 环境初始化 + 补全 | 用户说「初始化 .trae」 |

### 3.2 皮特 (PM) — 项目总负责

**核心职责:**
- 分析用户需求，判定任务级别 (L1/L2/L3)
- L3 任务强制启动完整流水线
- 监督流水线中每个环节都被执行
- 检测 `.trae/roles/memory/` 环境完整性
- 最终验收，汇报用户

**禁止事项:**
- 不写代码
- 不审查代码
- 不测试代码
- 不代替任何角色执行其专属工作

**环境检测逻辑:**

| `.trae/roles/memory/` 状态 | PM 行为 |
|---------------------------|---------|
| **不存在**（完全无 `.trae/` 或只有 IDE 空壳） | 立即调用 `trae-init` 初始化 |
| **存在但不完整**（缺 journal 或 tasks） | 调用 `trae-init` 补全 |
| **完整**（6 journal + tasks + rules + project） | 继续正常任务调度 |

**任务级别判定:**

| 级别 | 定义 | PM 行为 |
|------|------|---------|
| L1 | 简单问答/信息查询 | 直接回答 |
| L2 | 单一文件修改、配置变更 | 轻量版：读文件 → 改代码 → 简要验证 |
| L3 | 多文件改动、新功能、架构调整 | **强制走 L3 全流程流水线** |

### 3.3 Docs — 文档工程师

Docs 在流水线中出现两次（Pre-task 和 Post-task），职责不同:

**Pre-task (任务启动时):**
1. 阅读皮特下发的需求
2. 明确任务目标（做什么，为什么）
3. 列出验收标准（什么算完成）
4. 标注涉及的领域标签（fpga / soc / sdk / debug / aichip / vendor / general）
5. 标注涉及的文件或模块
6. 列出潜在风险点
7. 将任务文档存入 `${WORKSPACE}/.trae/roles/memory/tasks/<task-name>.md`

**任务文档模板:**
```markdown
# 任务: <任务名>
> 创建: YYYY-MM-DD | 领域: xxx

## 目标
## 验收标准
## 涉及文件
## 风险点
```

**Post-task (流水线结束时):**
1. 读取 Builder/Optimizer/Tester 的所有改动清单
2. 检查哪些项目文档需要更新
3. 更新用户手册、API 文档等
4. 检查断链（文档间引用是否失效）
5. 汇报皮特：「任务完成」

### 3.4 Builder — 唯一写代码的人

**工作流:**
1. 阅读 Docs 的任务文档，理解目标和验收标准
2. 识别领域标签，通过领域知识库查询 traps（避坑）和 patterns（复用）
3. 阅读现有代码，理解上下文
4. 最小化改动，匹配现有代码风格
5. 自验证（编译检查、语法检查、逻辑推演）
6. 自问：「我的改动会影响其他领域吗？」
7. 将改动提交给 Optimizer 审查

**守则:**
- 只改需要改的地方，不顺手优化无关代码
- 200 行能完成的不写 500 行
- 一个地方用一次的不单独抽函数
- 风格不一致时跟随现有代码

**提交流水线:**
1. 代码改动 → 提交 Optimizer
2. Optimizer PASS → 转 Tester
3. Tester PASS → 通知 Docs
4. **任何环节打回 → 修复后从该环节重新走**

### 3.5 Optimizer — 代码审查专家

Optimizer 真正阅读代码逻辑，不是跑正则或静态检查。每次审查必须回答三个问题:

**三大检查:**

| # | 检查项 | 追问 |
|---|--------|------|
| 1 | 有没有做**不必要**的工作？ | 只改一行却改了一个函数？顺手优化了不相干代码？为尚未发生的未来写代码？ |
| 2 | 有没有**重复造轮子**？ | 项目中已有现成工具/函数？标准库或框架提供同样能力？knowledge base 有已验证方案？ |
| 3 | 写的代码**效率**够不够？ | 时间复杂度合理？不必要的内存分配？异常处理适量？是否引入不必要的依赖？ |

**评分:** A / B / C / D

**输出内容:**
- ✅ 打了 PASS，还是 ❌ 打了 REJECT
- 如果 REJECT: 具体哪里不满意、期望怎么改
- 评价改动的工作量是否合适
- 任何其他审查意见

**打回后:** Optimizer 打回后 Builder 修复完必须**再次提交 Optimizer** 重新审查，不得跳过。

### 3.6 Tester — 功能验证

Optimizer 审查通过后，Tester 负责验证代码实际行为是否正确。

**验证级别选择:**

| 级别 | 耗时 | 适用场景 | 验证内容 |
|------|------|---------|---------|
| quick | < 1 分钟 | 单行修复、配置变更、文档修改 | 语法检查 + 逻辑推演 + 验收标准确认 |
| standard | < 5 分钟 | 单文件函数修改、小功能添加 | 编译检查 + 手动验证关键路径 + 边界条件 |
| full | 按规模 | 多文件改动、API 变更、架构调整 | 全量测试 + 新功能完整用例 + 跨领域验证 |

**核心原则:** 功能测试 > 静态检查。不接受只跑 `bash -n` 就说 PASS。

**输出内容:**
- 验证方案: 做了哪些验证步骤（不仅仅是命令，而是步骤和目的）
- 验证结果: 所有验证是否通过
- ✅ PASS / ❌ FAIL
- FAIL 时: 什么条件下出的问题、期望什么、实际什么、如何复现

**部署级验证要求 (针对脚本/工具类改动):**
- 部署到临时目录验证幂等性（多次部署结果一致）
- 用真实目标环境验证，而非仅测开发环境
- 检查产生的副作用（文件位置、权限、覆盖行为等）

**打回后:** Tester 打回后 Builder 修复完必须提交 Optimizer → Tester **重新走**，不得跳过 Optimizer 直接让 Tester 重测。

### 3.7 Researcher — 研究员

Researcher 是纯信息收集角色:

- 收集信息、分析、结构化汇报
- 对比方案、查文档、查网页
- **不写代码、不做决策**
- 被皮特调用，不是流水线环节

### 3.8 trae-init — 环境初始化

独立 Skill，负责初始化或补全项目的 `.trae/` 协作环境。

**合并策略:**

| 文件/目录 | 已存在 | 不存在 |
|----------|--------|--------|
| `rules.md` | **跳过**（不覆盖已有规则） | 从模板复制 |
| `roles/project.md` | **跳过**（不覆盖项目信息） | 从模板复制 |
| `roles/memory/<角色>/journal.md` | **跳过**（不覆盖已有日志） | 创建空文件 |
| `roles/memory/tasks/` | **跳过** | 创建空目录 |

核心逻辑: **只补缺，不覆盖。**

---

## 4. 触发机制

### 4.1 触发方式

Trae Toolkit 通过 Skill 系统实现触发，而非依赖被动规则文件（如 `user_rules/`）。Skill 被 Agent 显式调用，可靠性远高于被动规则。

| 触发词 | Skill | 行为 |
|--------|-------|------|
| 「皮特，做XXX」 | `trae-pm` | 强制走 L3 全流程 |
| 「初始化 .trae」 | `trae-init` | 初始化/补全协作环境 |

### 4.2 为什么用 Skill 而非规则文件

之前的经验证明，`user_rules/` 中的规则文件是**被动加载**的，Agent 读不读、执不执行不完全可控。Skill 通过 `Skill` 工具显式调用，Agent 必然执行其中的流程。

6 个角色中: Builder / Optimizer / Tester / Docs / Researcher / trae-init 由皮特内部调用，不需要用户独立触发。皮特本身也作为一个 Skill 存在，由用户的自然语言「皮特」触发。

### 4.3 兜底机制

即使 `trae-init` 没有匹配上用户说「初始化 .trae」，皮特有兜底:

> 皮特启动时发现 `.trae/roles/memory/` 不完整 → 自动调用 `trae-init` 初始化环境

这样无论 trae-init 是否成功匹配，环境都能被正确初始化。

---

## 5. L3 全流程流水线

### 5.1 标准流程

```
皮特 ("皮特，做XXX")
  │
  ├─① 检测环境 → trae-init (如需要)
  │
  ├─② 派 Docs (Pre-task) → 任务文档
  │
  ├─③ 派 Builder (附任务文档) → 代码改动
  │
  ├─④ 派 Optimizer → 审查评分 (A/B/C/D)
  │     └─ REJECT → Builder 修复 → 重新④
  │
  ├─⑤ 派 Tester → 验证 (quick/standard/full)
  │     └─ FAIL → Builder 修复 → 重新④→⑤
  │
  ├─⑥ 派 Docs (Post-task) → 更新文档 → 汇报 PM
  │
  └─⑦ 皮特验收 → 汇报用户
```

### 5.2 环节说明

| # | 环节 | 执行者 | 输入 | 输出 |
|---|------|--------|------|------|
| ① | 环境检测 | 皮特 | 项目根目录 | .trae/ 完整性确认 |
| ② | Pre-task | Docs | 用户需求 | 任务文档 (tasks/<name>.md) |
| ③ | 编码 | Builder | 任务文档 | 代码改动 |
| ④ | 审查 | Optimizer | 代码改动 | 审查报告 + PASS/REJECT |
| ⑤ | 验证 | Tester | 代码改动 + 审查报告 | 验证报告 + PASS/FAIL |
| ⑥ | Post-task | Docs | 所有改动清单 | 更新的文档 |
| ⑦ | 验收 | 皮特 | 全流程报告 | 汇总汇报给用户 |

### 5.3 环节间通信

各环节间通过 `${WORKSPACE}/.trae/roles/memory/tasks/<task-name>.md` 传递上下文:

- Docs 写任务文档时写入
- Builder 读任务文档获取目标
- Optimizer / Tester 读取任务文档确认改动范围
- Docs (Post) 读取全流程结果更新文档

---

## 6. 打回与重试机制

### 6.1 Optimizer 打回

```
Builder 提交代码
  → Optimizer 审查
    → PASS ✅ → 转 Tester
    → REJECT ❌ → Builder 修复 → 重新提交 Optimizer
```

- REJECT 必须指明具体问题和期望的改法
- Builder 修复后从 Optimizer 重新开始，不得跳过

### 6.2 Tester 打回

```
Optimizer PASS
  → Tester 验证
    → PASS ✅ → 转 Docs (Post)
    → FAIL ❌ → Builder 修复 → 重新提交 Optimizer → Tester
```

- FAIL 必须指明: 什么条件下出的问题、期望值、实际值、复现方法
- Builder 修复后必须重走 Optimizer → Tester，不得只让 Tester 重测
- 这是工程纪律: 修复代码 = 新代码，必须再审

### 6.3 皮特的监督职责

- 检查 Optimizer 是否真正读了代码（而不是泛泛而谈）
- 检查 Tester 是否做了真实行为验证（而不是"看起来没问题"）
- 任何环节被跳过 → 皮特打断并要求补上

---

## 7. 知识管理系统

### 7.1 三层架构

```
Layer 1: 全局领域知识库  (跨项目共享)
  ├─ ~/.trae/roles-memory/domains/
  │   ├─ fpga/        (overview, patterns, traps, rtl-style)
  │   ├─ soc/         (overview, patterns, traps)
  │   ├─ sdk/         (overview, patterns, traps)
  │   ├─ debug/       (overview, patterns, traps)
  │   ├─ aichip/      (overview, patterns, traps)
  │   └─ vendor/      (overview, patterns, traps, tools)
  └─ ~/.trae/roles-memory/patterns/

Layer 2: 角色 Skill 定义  (全局共享)
  └─ ~/.trae-cn/skills/
      ├─ trae-pm/SKILL.md
      ├─ trae-builder/SKILL.md
      ├─ trae-optimizer/SKILL.md
      ├─ trae-tester/SKILL.md
      ├─ trae-docs/SKILL.md
      ├─ trae-research/SKILL.md
      └─ trae-init/SKILL.md

Layer 3: 项目本地记忆  (本项目积累)
  └─ ${WORKSPACE}/.trae/roles/memory/
      ├─ builder/journal.md
      ├─ optimizer/journal.md
      ├─ tester/journal.md
      ├─ docs/journal.md
      ├─ research/journal.md
      ├─ pm/journal.md
      └─ tasks/
```

### 7.2 知识写入规则

各角色在任务执行中产生知识时，按以下规则决定写入位置:

| 知识类型 | 去向 | 示例 |
|---------|------|------|
| 领域通用知识 | `~/.trae/roles-memory/domains/<领域>/` | "Efinix JTAG 时钟必须 ≤ 10MHz" |
| 角色能力缺陷 | 自己的 `SKILL.md` | "Builder 的工作流缺少自我验证步骤" |
| 本项目特定经验 | `${WORKSPACE}/.trae/roles/memory/<角色>/journal.md` | "本项目的 CI 环境需要额外设置 XYZ" |
| 跨项目通用方案 | `~/.trae/roles-memory/patterns/` | "Python 脚本跨平台路径处理方案" |

### 7.3 知识读取优先级

各角色在执行任务前:

1. **必读**: 所在领域的 `traps.md` → 避免已知坑
2. **建议读**: `patterns.md` → 复用已验证方案
3. **参考**: `overview.md` → 领域背景

---

## 8. 角色自我迭代

### 8.1 迭代原则

每个角色在发现**自身能力缺陷**时，有权更新自己的 `SKILL.md`，无需等人工手动修改。

### 8.2 触发条件

以下情况触发自我迭代:

| 触发条件 | 示例 |
|---------|------|
| 工作流缺少某步骤 | Builder 没有自动读领域 traps → 补充工作流 |
| 输出格式不够用 | Tester 报告缺少特定字段 → 新增输出要求 |
| 守则有遗漏 | Optimizer 应该检查某类问题但没有 → 追加检查项 |
| 多次 journal 指向同一缺口 | 三个项目的 journal 都记录同一问题 → 固化到 SKILL |

### 8.3 迭代纪律

- 迭代后必须通知皮特，记录在 journal 中
- 不能悄悄改 — 保证可追溯
- 改完 SKILL.md 后，部署到 `~/.trae-cn/skills/` 使全局生效

### 8.4 知识归属判断

| 学到的内容 | 去哪里 |
|-----------|--------|
| 领域技术知识（如"这个芯片的时钟有坑"） | `~/.trae/roles-memory/domains/` |
| **角色执行能力**（如"Builder 忘记做某步"） | **自己的 `SKILL.md`** |
| 项目特定经验（如"这个项目的 make 有特殊参数"） | `${WORKSPACE}/.trae/roles/memory/<角色>/journal.md` |

---

## 9. 环境初始化

### 9.1 触发

两种触发方式:

1. 用户在新项目中说 **「初始化 .trae」**
2. 用户在新项目中说 **「皮特，做XXX」** → 皮特检测到环境不完整 → 自动初始化

### 9.2 合并策略

初始化时遵循「只补缺，不覆盖」原则:

| 文件/目录 | 已存在时的行为 |
|----------|-------------|
| `rules.md` | 跳过，不覆盖已有规则 |
| `roles/project.md` | 跳过，不覆盖项目信息 |
| `roles/memory/<角色>/journal.md` | 跳过，不覆盖已有日志 |
| `roles/memory/tasks/` | 跳过，不删除已有任务 |

### 9.3 初始化后的结构

```
${WORKSPACE}/.trae/
├── rules.md                      # 项目规则（引用全局规则）
├── roles/
│   ├── project.md                # 项目概览
│   └── memory/
│       ├── builder/journal.md    # Builder 项目日志
│       ├── optimizer/journal.md  # Optimizer 项目日志
│       ├── tester/journal.md     # Tester 项目日志
│       ├── docs/journal.md       # Docs 项目日志
│       ├── research/journal.md   # Researcher 项目日志
│       ├── pm/journal.md         # PM 项目日志
│       └── tasks/                # L3 任务文档存档
```

---

## 10. 文件结构总览

### 10.1 Toolkit 仓库

```
trae-toolkit/
├── skills/                       # 角色 Skill 定义（6 个 + 1 辅助）
│   ├── trae-pm/SKILL.md          # 皮特 - 项目管理
│   ├── trae-builder/SKILL.md     # Builder - 编码实现
│   ├── trae-optimizer/SKILL.md   # Optimizer - 代码审查
│   ├── trae-tester/SKILL.md      # Tester - 功能验证
│   ├── trae-docs/SKILL.md        # Docs - 文档工程
│   ├── trae-research/SKILL.md    # Researcher - 技术调研
│   ├── trae-init/SKILL.md        # trae-init - 环境初始化
│   └── verilog-code-check/SKILL.md
├── user_rules/                   # 全局规则（部署到 ~/.trae/user_rules/）
│   ├── team-framework.md         # 角色协作框架
│   ├── coding-principles.md      # 通用编码原则
│   ├── output-constraints.md     # Agent 输出约束
│   └── daylog.md                 # DAYLOG 格式规范
├── roles-memory/                 # 全局共享知识库
│   ├── DOMAIN-MATRIX.md
│   ├── domains/
│   │   ├── fpga/                 # overview, patterns, traps, rtl-style
│   │   ├── soc/
│   │   ├── sdk/
│   │   ├── debug/
│   │   ├── aichip/
│   │   └── vendor/
│   └── patterns/
├── project-template/             # 新项目 .trae/ 模板
│   └── .trae-template/
│       └── roles/memory/
├── deploy.sh                     # 全局环境部署脚本
├── docs/                         # 项目文档
│   ├── trae-workflow.html        # 工作流 PPT 图
│   ├── workflow-diagram.md       # Mermaid 流程图
│   └── trae-workflow-spec.md     # 本文档
└── README.md
```

### 10.2 部署后的全局路径

```
~/.trae-cn/skills/               # Skill 定义（Agent 直接加载）
│
~/.trae/user_rules/              # 全局规则（所有项目自动适用）
│
~/.trae/roles-memory/            # 跨项目知识库
└── domains/
```

### 10.3 项目的 .trae 路径

```
${WORKSPACE}/.trae/              # 项目本地
├── rules.md                     # 引用全局规则
└── roles/
    ├── project.md               # 项目概览
    └── memory/
        ├── <角色>/journal.md    # 各角色项目日志
        └── tasks/               # 任务文档存档
```
