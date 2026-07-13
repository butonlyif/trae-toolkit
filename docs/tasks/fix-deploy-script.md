# 任务文档：完善 deploy.sh——兼容 Windows + 修复更新缺失

## 目标

修复 `deploy.sh` 的三个问题，确保一键部署在 macOS / Linux / Windows(Git Bash) 上都能可靠运行。

## 问题分析

### 问题 1: `cp -n` 阻止更新

```bash
# 第 42 行: Skills 已存在时
cp -n "$skill_dir/SKILL.md" "$dest/"   # -n = no-clobber, 已有文件不覆盖!

# 第 58 行: Rules 同理
cp -n "$rule_file" "$TRAE_USER_RULES/"

# 第 67 行: Memory 同理
cp -rn "$SCRIPT_DIR"/roles-memory/* "$TRAE_ROLES_MEMORY/"
```

**后果**: 今天修改的所有 SKILL.md、team-framework.md 在重跑 deploy.sh 时**不会被更新**。`-n` 语义与预期相反——应该更新已存在的文件，但不删除目标目录下用户自己加的文件。

### 问题 2: Windows 路径兼容

当前全部硬编码为 Unix 路径（`$HOME/.trae-cn/...`）。在 Windows Git Bash 中 `$HOME` 可以工作，但对于未装 Git Bash 的用户需要在 PowerShell/CMD 中运行。

### 问题 3: 统计命令不跨平台

```bash
find ... | wc -l | tr -d ' '
```
`tr -d ' '` 在 Windows 不可用。

## 改动方案

### 1. `cp -n` → 混合策略

| 目录 | 策略 | 原因 |
|------|------|------|
| `skills/*/SKILL.md` | 直接覆盖（不加 `-n`） | Skill 迭代必须生效 |
| `user_rules/*.md` | 直接覆盖（不加 `-n`） | 规则更新必须生效 |
| `roles-memory/*` | 保留 `-rn` | 用户可能在全局知识库里自己加了文件 |

### 2. Windows 路径兼容

```bash
# 统一路径检测
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    TRAE_BASE="$HOME"  # Git Bash 中 HOME=/c/Users/xxx
else
    TRAE_BASE="$HOME"
fi
TRAE_CN_SKILLS="$TRAE_BASE/.trae-cn/skills"
TRAE_USER_RULES="$TRAE_BASE/.trae/user_rules"
TRAE_ROLES_MEMORY="$TRAE_BASE/.trae/roles-memory"
```

实际上在 Git Bash 中 `$HOME` 已经正确，关键是在脚本开头加 Windows 检测提示。

### 3. 统计兼容

```bash
# Unix
ls "$TRAE_CN_SKILLS" | grep -c 'trae-' 2>/dev/null || echo "0"
```

使用 `ls | grep -c` 替代 `find | wc | tr`。

## 领域

sdk

## 涉及文件

- `deploy.sh`：主要改动

## 验收标准

- [ ] Skills 更新时 SKILL.md 被覆盖（不是跳过）
- [ ] Rules 更新时 .md 被覆盖
- [ ] roles-memory 已有内容不被删除
- [ ] Windows Git Bash 中路径正确
- [ ] 统计命令跨平台可运行
- [ ] 在 macOS 上实际运行通过
