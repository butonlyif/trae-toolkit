# 任务文档：修复 new 项目的 .trae/ 目录

## 目标

修复 `/Users/wangxin/Documents/trae_projects/new/.trae/` 目录，使其包含完整的角色协作骨架结构。

## 背景

`new/.trae/` 目前只有 IDE 自动生成的 `config.json` 和 `tasks.json`，缺失所有角色 journal 和项目配置。需要按合并策略，将 toolkit 模板补充进去，同时保留已有的 IDE 文件。

## 当前状态

```
new/.trae/
├── config.json    # IDE 生成 ← 保留
└── tasks.json     # IDE 生成 ← 保留
```

## 目标状态

```
new/.trae/
├── config.json                      # 已有，保留
├── tasks.json                       # 已有，保留
├── rules.md                         # 新增
└── roles/
    ├── project.md                   # 新增
    └── memory/
        ├── builder/journal.md       # 新增
        ├── optimizer/journal.md     # 新增
        ├── tester/journal.md        # 新增
        ├── docs/journal.md          # 新增
        ├── research/journal.md      # 新增
        ├── pm/journal.md            # 新增
        └── tasks/                   # 新增（空目录）
```

## 领域

sdk（工具链/项目配置类任务）

## 风险点

- 已有的 `config.json` 和 `tasks.json` 可能被模板覆盖 → 必须用合并策略，先复制模板到一个临时位置再移动
- 模板源的 cp 命令会覆盖整个目录 → 需要逐个创建文件而非直接 cp

## 验收标准

- [ ] `config.json` 和 `tasks.json` 内容未变（已被保留）
- [ ] 所有 6 个 `journal.md` 文件存在
- [ ] `rules.md` 存在
- [ ] `roles/project.md` 存在
- [ ] `roles/memory/tasks/` 目录存在
