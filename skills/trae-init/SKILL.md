---
name: "trae-init"
description: "初始化项目的 Trae 协作环境。当用户说\"初始化 .trae\"、\"部署 .trae\"、\"setup .trae\"、\"初始化项目配置\"、\"init .trae\" 时调用。检查 .trae/ 目录完整性，按合并策略部署角色记忆骨架。"
---

> **路径说明**: `~/.trae/` = macOS/Linux `$HOME/.trae/` = Windows `%USERPROFILE%\.trae\`。Agent 会自动根据平台解析。

# Trae 项目初始化

当用户说"初始化 .trae"等触发词时，你被调用。你的工作是检查当前项目的 `.trae/` 环境并确保它完整。

**本操作是创建项目根目录下的 `.trae/` 文件夹及其子文件，不是安装 VS Code 扩展。**

## 第一步：状态检测

先检查项目根目录下 `.trae/roles/memory/` 是否存在：

```bash
test -d .trae/roles/memory && echo "EXISTS" || echo "NOT_EXISTS"
```

| 状态 | 行为 |
|------|------|
| **NOT_EXISTS**（无 `.trae/` 或只有 IDE 空壳如 `config.json`/`tasks.json`） | 进入第二步，启动完整初始化 |
| **EXISTS 但不完整**（缺 journal 或 tasks） | 进入第二步，启动补全 |
| **完整**（6 个 journal + tasks + rules + project） | 回复"Trae 环境已就绪，无需初始化" |

## 第二步：启动 L3 流水线

你作为 PM，启动以下流水线：

### 2.1 写任务文档

调用 `trae-docs` Skill，写任务单，填入以下信息：
- 目标：初始化/补全 `.trae/` 目录
- 当前状态：[从第一步检测中得到]
- 验收标准：同下方 Builder 验收标准

### 2.2 派发 Builder

调用 `trae-builder` Skill，附上任务文档和以下执行规格。

**Builder 执行规格**：

**目标**：在项目根目录创建/补全 `.trae/` 目录结构。

**合并规则（只增不盖）**：

| 文件/目录 | 已存在时 | 不存在时 |
|----------|---------|---------|
| `.trae/rules.md` | **跳过** | 从模板复制 |
| `.trae/roles/memory/project.md` | **跳过** | 从模板复制 |
| `.trae/roles/memory/<角色>/journal.md` | **跳过** | 创建空文件 |
| `.trae/roles/memory/tasks/` | **跳过** | 创建空目录 |

需要创建的 journal.md 角色：`builder`, `optimizer`, `tester`, `docs`, `research`, `pm`

**执行**：
1. 检查 `.trae/` 是否存在
2. 如果**不存在**：从模板源复制：
   ```
   cp -r ~/Documents/trae_projects/trae-toolkit/project-template/.trae-template .trae
   ```
3. 如果**已存在**：逐个检查上述文件/目录，仅创建缺失项
4. 列出：新增了哪些、跳过了哪些（因为已存在）

**Builder 验收标准**：
- [ ] 所有 6 个 journal.md 文件存在（`builder/`, `optimizer/`, `tester/`, `docs/`, `research/`, `pm/`）
- [ ] `tasks/` 目录存在
- [ ] `rules.md` 和 `roles/memory/project.md` 存在
- [ ] 已有内容未被覆盖

### 2.3 流水线后续

Builder 完成后，依次经过：
```
Builder 创建完毕
  → Optimizer: 审查目录结构
  → Tester: 验证文件完整性
  → Docs: 填写 project.md 项目概览
  → 汇报用户：初始化完成
```
