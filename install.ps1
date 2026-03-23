#!/usr/bin/env pwsh
# Luban Config Editor Skill 安装脚本 (Windows PowerShell)
# 用法: ./install.ps1 [-Target <project|user>] [-ProjectPath <path>]

param(
    [ValidateSet("project", "user")]
    [string]$Target = "project",
    
    [string]$ProjectPath = ""
)

$ErrorActionPreference = "Stop"

# 获取脚本所在目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillSource = Join-Path $ScriptDir ".qoder\skills\luban-config-editor"

# 显示帮助
function Show-Help {
    Write-Host @"
Luban Config Editor Skill 安装脚本

用法:
  ./install.ps1                           # 安装到当前项目
  ./install.ps1 -Target user              # 安装到用户目录（全局）
  ./install.ps1 -Target project           # 安装到指定项目
  ./install.ps1 -ProjectPath /path/to/proj

参数:
  -Target       安装目标: project (项目级) 或 user (用户级)
  -ProjectPath  项目路径（仅 -Target project 时有效）

示例:
  ./install.ps1                                    # 安装到当前项目
  ./install.ps1 -Target user                       # 安装到用户目录
  ./install.ps1 -Target project -ProjectPath D:\mygame  # 安装到指定项目

"@
}

# 检查 skill 源目录
if (-not (Test-Path $SkillSource)) {
    Write-Error "错误: 找不到 skill 源目录: $SkillSource"
    exit 1
}

# 确定目标路径
if ($Target -eq "user") {
    $DestPath = Join-Path $env:USERPROFILE ".qoder\skills\luban-config-editor"
    Write-Host "安装模式: 用户级（全局）"
} else {
    if ($ProjectPath) {
        $TargetProject = $ProjectPath
    } else {
        $TargetProject = $ScriptDir
    }
    $DestPath = Join-Path $TargetProject ".qoder\skills\luban-config-editor"
    Write-Host "安装模式: 项目级"
    Write-Host "目标项目: $TargetProject"
}

Write-Host "目标路径: $DestPath"
Write-Host ""

# 检查是否已存在
if (Test-Path $DestPath) {
    $Overwrite = Read-Host "Skill 已存在，是否覆盖? (y/N)"
    if ($Overwrite -ne "y" -and $Overwrite -ne "Y") {
        Write-Host "安装已取消"
        exit 0
    }
    Remove-Item -Path $DestPath -Recurse -Force
}

# 创建目标目录
$DestParent = Split-Path -Parent $DestPath
if (-not (Test-Path $DestParent)) {
    New-Item -ItemType Directory -Path $DestParent -Force | Out-Null
}

# 复制 skill
Write-Host "正在复制 skill 文件..."
Copy-Item -Path $SkillSource -Destination $DestPath -Recurse -Force

# 显示安装结果
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  安装成功!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Skill 路径: $DestPath"
Write-Host ""

# 检查 Python 依赖
Write-Host "检查依赖..."
$PythonVersion = python --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "Python: $PythonVersion"
    
    $Openpyxl = pip show openpyxl 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "openpyxl: 已安装"
    } else {
        Write-Host "openpyxl: 未安装" -ForegroundColor Yellow
        Write-Host "请运行: pip install openpyxl" -ForegroundColor Yellow
    }
} else {
    Write-Host "Python: 未安装" -ForegroundColor Yellow
    Write-Host "请安装 Python 3.8+ 后再使用此 skill" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "使用方式:"
Write-Host "  在 Qoder 中直接描述需求，AI 会自动调用此 skill"
Write-Host "  或手动执行: python $DestPath\scripts\luban_helper.py --help"
Write-Host ""
