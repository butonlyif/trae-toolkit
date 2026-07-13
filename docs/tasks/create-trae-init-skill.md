# 任务文档：创建 trae-init Skill

## 目标

创建 `trae-init` Skill，替代 `team-framework.md` 中被动的触发词匹配，通过显式 Skill 调用可靠地初始化项目 `.trae/` 协作环境。

## 背景

`team-framework.md` 中的触发词机制不可靠：用户说"初始化 .trae"时，Agent 不一定执行 PM 规则。awesomsdk 项目的实践证明，Skill 是更可靠的触发方式——Agent 会根据 description 自动匹配并调用。

## 方案

创建 `skills/trae-init/SKILL.md`：

1. **description 中包含触发词**：`"初始化 .trae"、"部署 .trae"` 等，让 Agent 能自动匹配
2. **Skill 内部扮演 PM**：先做状态检测（是否存在 `.trae/roles/memory/`），然后启动 L3 流水线
3. **复用现有 Builder 规格**：合并策略、验收标准保持不变

## Skill 结构

```
skills/trae-init/SKILL.md
```

内部逻辑：
1. 检查 `.trae/roles/memory/` 状态（三种场景）
2. 如果完整 → 告知已就绪，结束
3. 如果不完整/不存在 → 扮演 PM，调用 Docs 写任务文档 → 调用 Builder 创建文件 → Optimizer → Tester → Docs → PM 验收

## 领域

sdk

## 涉及文件

- `skills/trae-init/SKILL.md`：新建
- `~/.trae-cn/skills/trae-init/SKILL.md`：部署目标

## 验收标准

- [ ] `skills/trae-init/SKILL.md` 文件存在
- [ ] description 包含关键触发词（初始化 .trae / 部署 .trae / setup .trae）
- [ ] 内部包含 PM 状态检测逻辑（三种场景）
- [ ] 内部包含 Builder 执行规格（合并策略 + 验收标准）
- [ ] Optimizer 审查通过
- [ ] Tester 验证三种场景
- [ ] 部署到 `~/.trae-cn/skills/trae-init/SKILL.md`
