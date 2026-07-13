# 任务文档：加固皮特的环境检测——自动初始化

## 目标

修改 `trae-pm` SKILL.md 第一步，当检测到 `.trae/roles/memory/` 缺失时，**强制调用 trae-init Skill 完成初始化**，不再只是"提示"。

## 背景

video_sim 项目中"初始化 .trae"又失败了——trae-init Skill 没被 Agent 匹配。兜底机制（皮特发现缺失后自动补）需要更强制：当前写的是"执行 trae-init 逻辑"，太模糊，Agent 可能理解成口头提示而不是实际行动。

## 改动

`skills/trae-pm/SKILL.md` 第一步改为：

```
1. 回复「收到，皮特启动全流程开发」
2. 检查 `.trae/roles/memory/` 存在性：
   - 不存在/不完整 → 立即调用 trae-init Skill，等初始化完成后继续
   - 完整 → 继续
```

## 领域

sdk

## 涉及文件

- `skills/trae-pm/SKILL.md`

## 验收标准

- [ ] 第一步明确写「调用 trae-init Skill」
- [ ] 旧项目的 CLAUDE.md / rules.md 不会被覆盖
- [ ] Optimizer 审查通过
- [ ] 部署到 `~/.trae-cn/skills/trae-pm/`
