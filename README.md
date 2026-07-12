# Trae Toolkit

基于角色协作的 Trae Agent 工具箱，提供 Skill 定义、User Rules 和共享 Memory。

## 目录结构

```
trae-toolkit/
├── skills/                  # 角色 Skill 定义
│   ├── trae-builder/        # 构建者（写代码）
│   ├── trae-optimizer/      # 优化分析师（审代码）
│   ├── trae-tester/         # 测试验证
│   ├── trae-docs/           # 文档工程师
│   ├── trae-research/       # 研究员
│   └── verilog-code-check/  # Verilog 代码检查
├── user_rules/              # 全局规则
│   ├── team-framework.md    # 角色协作框架
│   ├── coding-principles.md # 通用编码原则
│   └── output-constraints.md # Agent 输出约束
├── roles-memory/            # 共享知识库
│   ├── DOMAIN-MATRIX.md     # 领域-角色能力矩阵
│   ├── domains/             # 6 大领域知识
│   └── patterns/            # 已验证方案
├── project-template/        # 新项目模板
├── deploy.sh                # 一键部署脚本
└── README.md
```

## 快速开始

### 一键部署

```bash
cd <Toolkit目录>
bash deploy.sh
```

### 在新项目中使用

```bash
cp -r <Toolkit目录>/project-template/.trae-template .trae
```

## Skill 角色

| Skill | 角色 | 职责 |
|-------|------|------|
| trae-builder | Builder | 唯一写代码的人 |
| trae-optimizer | Optimizer | 代码审查、优化建议 |
| trae-tester | Tester | 设计验证方案、执行验证 |
| trae-docs | Docs | 写任务文档、更新项目文档 |
| trae-research | Researcher | 信息收集、技术调研 |
| verilog-code-check | - | Verilog/SystemVerilog 代码检查 |

## L3 任务流水线

```
Builder → Optimizer → Tester → Docs → PM 验收
```

## Memory 架构

- `~/.trae/roles-memory/domains/<领域>/` — 跨项目共享知识
- `~/.trae/roles-memory/patterns/` — 已验证方案
- `${WORKSPACE}/.trae/roles/memory/` — 项目本地记忆

## 更新日志

### 2026-07-12 — v1.0 初始版本
- 将 5 个角色（Builder/Optimizer/Tester/Docs/Research）注册为全局 Skill
- Agent 默认担任 PM 角色，不需额外调用
- 全局编码原则 (coding-principles.md) 和输出约束 (output-constraints.md) 部署到 ~/.trae/user_rules/
- 团队协作框架 (team-framework.md) 定义 L1/L2/L3 任务分级
- 共享 Memory 架构: ~/.trae/roles-memory/ = 跨项目积累，${WORKSPACE}/.trae/roles/memory/ = 项目本地
- deploy.sh 一键部署: Skills → ~/.trae-cn/skills/，Rules → ~/.trae/user_rules/，Memory → ~/.trae/roles-memory/
- 附带 verilog-code-check Skill + 项目模板 (project-template/)

