# 任务文档：创建 trae-pm Skill（皮特）

## 目标

创建 `trae-pm` Skill，用户说「皮特，做XXX」时触发，强制走完整 L3 流水线。

## 背景

当前 PM 靠 `team-framework.md` 规则文件驱动，Agent 不一定执行。改为 Skill 后确定性更强：
- 用户说「皮特，修XX bug」→ Agent 匹配 Skill → PM 启动 L3
- 普通对话不带「皮特」→ L1/L2，不影响日常使用

## 方案

创建 `skills/trae-pm/SKILL.md`：

### 触发方式

用户说「皮特」开头的开发任务：
- 「皮特，修复XX bug」
- 「皮特，给YY加个功能」
- 「皮特，重构ZZ」

### Skill 行为

1. **确认意图** — 回复「收到，启动全流程开发」
2. **状态检测** — 检查 `.trae/roles/memory/` 存在性（未初始化则先调 trae-init）
3. **派 Docs 写任务文档** — 调用 `trae-docs`
4. **派 Builder** — 调用 `trae-builder`，附任务文档
5. **监督流水线** — Builder → Optimizer → Tester → Docs → 汇报用户

### 注意

不带「皮特」的普通开发请求（如「帮我写个函数」「这段代码什么意思」）不走 Skill，保持自然。

## 领域

sdk

## 涉及文件

- `skills/trae-pm/SKILL.md`：新建
- `~/.trae-cn/skills/trae-pm/SKILL.md`：部署目标

## 验收标准

- [ ] `skills/trae-pm/SKILL.md` 文件存在
- [ ] description 包含「皮特」触发词
- [ ] 包含完整 L3 流水线：Docs → Builder → Optimizer → Tester → Docs
- [ ] 包含状态检测（调 trae-init 如果未初始化）
- [ ] Optimizer 审查通过
- [ ] Tester 验证通过
- [ ] 部署到 `~/.trae-cn/skills/trae-pm/SKILL.md`
