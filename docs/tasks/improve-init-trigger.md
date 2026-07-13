# 任务文档：改进「初始化 .trae」触发可靠性

## 目标

改进 `team-framework.md` 中的「新项目初始化」触发机制，使 PM 能在新项目和已有项目两种场景下都可靠地识别并处理 `.trae/` 初始化。

## 背景

`new/` 项目中测试失败：用户说"初始化 .trae"，IDE 先拦截并创建了 `config.json`/`tasks.json`，PM 未正确触发流水线。根因是关键字匹配不可靠，需要改为「状态检测 + 关键字」双重保障。

## 改动设计

在 `team-framework.md` 的「新项目初始化」章节中，**在触发词之前插入一个状态检测步骤**：

```
PM 每次进入项目时，先检查 .trae/ 的状态：
- .trae/ 不存在 → 主动问用户"要不要初始化？"
- .trae/ 存在但缺少 roles/memory/ → 标记为不完整，收到触发词时立即启动
- .trae/ 存在且结构完整 → 无需操作
```

这样即使 IDE 先创建了 `.trae/config.json`，PM 也能识别出结构不完整，在用户说"初始化 .trae"时正确启动流水线。

## 领域

sdk

## 涉及文件

- `user_rules/team-framework.md`：修改「新项目初始化」章节
- `~/.trae/user_rules/team-framework.md`：部署目标

## 验收标准

- [ ] 「新项目初始化」章节开头新增「PM 状态检测」段落
- [ ] 新增三种场景的处理逻辑：不存在 / 不完整 / 完整
- [ ] 原有触发词和合并策略保持不变
- [ ] Builder→Optimizer→Tester→Docs 流水线验证通过
- [ ] 全局部署到 `~/.trae/user_rules/team-framework.md`
