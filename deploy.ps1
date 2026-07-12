# Trae Toolkit 一键部署脚本 (Windows PowerShell)
# 用法: powershell -ExecutionPolicy Bypass -File deploy.ps1

$ErrorActionPreference = "Stop"

# 检测是否在 Trae 沙箱终端内运行
if ($env:TRAE_RUNTIME -or $env:ICUBE_APP_ROOT) {
    Write-Host "❌ 检测到 Trae IDE 内置终端。"
    Write-Host ""
    Write-Host "   Trae 内置终端有沙箱限制，无法写入 ~/.trae-cn/skills/"
    Write-Host "   请在系统 PowerShell 终端中运行此脚本："
    Write-Host ""
    Write-Host "   1. 打开 PowerShell（非 Trae 内置终端）"
    Write-Host "   2. cd $PSScriptRoot"
    Write-Host "   3. powershell -ExecutionPolicy Bypass -File deploy.ps1"
    Write-Host ""
    exit 1
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TraeCNSkills = "$env:USERPROFILE\.trae-cn\skills"
$TraeUserRules = "$env:USERPROFILE\.trae\user_rules"
$TraeRolesMemory = "$env:USERPROFILE\.trae\roles-memory"

Write-Host "=== Trae Toolkit 部署开始 ==="

# 1. 部署 Skills
Write-Host "[1/3] 部署 Skills 到 $TraeCNSkills ..."
New-Item -ItemType Directory -Force -Path $TraeCNSkills | Out-Null
Get-ChildItem -Path "$ScriptDir\skills" -Directory | ForEach-Object {
    $skillName = $_.Name
    $srcFile = Join-Path $_.FullName "SKILL.md"
    if (Test-Path $srcFile) {
        $destDir = Join-Path $TraeCNSkills $skillName
        if (-not (Test-Path $destDir)) {
            Copy-Item -Path $_.FullName -Destination $destDir -Recurse
            Write-Host "  ✅ $skillName"
        } else {
            Write-Host "  ⏭️ $skillName (已存在，跳过)"
        }
    }
}

# 2. 部署 User Rules
Write-Host "[2/3] 部署 Rules 到 $TraeUserRules ..."
New-Item -ItemType Directory -Force -Path $TraeUserRules | Out-Null
Get-ChildItem -Path "$ScriptDir\user_rules\*.md" | ForEach-Object {
    $destFile = Join-Path $TraeUserRules $_.Name
    if (-not (Test-Path $destFile)) {
        Copy-Item -Path $_.FullName -Destination $destFile
        Write-Host "  ✅ $($_.Name)"
    } else {
        Write-Host "  ⏭️ $($_.Name) (已存在，跳过)"
    }
}

# 3. 部署共享 Memory
Write-Host "[3/3] 部署共享 Memory 到 $TraeRolesMemory ..."
if (Test-Path $TraeRolesMemory) {
    Get-ChildItem -Path "$ScriptDir\roles-memory" | ForEach-Object {
        $destPath = Join-Path $TraeRolesMemory $_.Name
        if (-not (Test-Path $destPath)) {
            Copy-Item -Path $_.FullName -Destination $destPath -Recurse
        }
    }
    Write-Host "  ✅ roles-memory (已有内容保留)"
} else {
    Copy-Item -Path "$ScriptDir\roles-memory" -Destination $TraeRolesMemory -Recurse
    Write-Host "  ✅ roles-memory (全新安装)"
}

Write-Host ""
Write-Host "=== 部署完成 ==="
$skillCount = (Get-ChildItem -Path $TraeCNSkills -Directory -Filter "trae-*" | Measure-Object).Count
$ruleCount = (Get-ChildItem -Path "$TraeUserRules\*.md" | Measure-Object).Count
Write-Host "已安装:"
Write-Host "  Skills: $skillCount 个角色 + verilog-code-check"
Write-Host "  Rules:  $ruleCount 个"
Write-Host "  Memory: ~\.trae\roles-memory\"
Write-Host ""
Write-Host "在新项目中使用:"
Write-Host "  将 project-template\.trae-template 复制到你的项目:"
Write-Host "    macOS/Linux: cp -r <TOOLKIT_DIR>/project-template/.trae-template .trae"
Write-Host "    Windows:     xcopy /E /I <TOOLKIT_DIR>\project-template\.trae-template .trae"
