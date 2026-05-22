@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul 2>&1
title Visonic Themes 一键安装
color 0B

echo ============================================
echo       Visonic Themes for Typora 一键安装
echo ============================================
echo.

set "SCRIPT_DIR=%~dp0"
set "THEME_DIR=%APPDATA%\Typora\themes"
set "SOURCE_DIR=%SCRIPT_DIR%themes"

if not exist "%SOURCE_DIR%\visonic-*.css" (
    set "SOURCE_DIR=%SCRIPT_DIR%"
)

if not exist "%THEME_DIR%" (
    echo [INFO] 未找到 Typora 主题目录，正在创建：
    echo        %THEME_DIR%
    mkdir "%THEME_DIR%" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] 无法创建 Typora 主题目录，请检查权限或确认 Typora 已安装。
        pause
        exit /b 1
    )
)

echo [1/3] 正在安装字体依赖...
if not exist "%SCRIPT_DIR%visonic-fonts" (
    echo [ERROR] 未找到字体文件夹：%SCRIPT_DIR%visonic-fonts
    echo        请从完整 Release 包或仓库根目录运行本脚本。
    pause
    exit /b 1
)

if not exist "%THEME_DIR%\visonic-fonts" mkdir "%THEME_DIR%\visonic-fonts" >nul 2>&1
xcopy /e /i /y /q "%SCRIPT_DIR%visonic-fonts\*" "%THEME_DIR%\visonic-fonts\" >nul
if errorlevel 1 (
    echo [ERROR] 字体依赖复制失败。
    pause
    exit /b 1
)
echo      √ 字体依赖安装完成

echo.
echo [2/3] 正在安装主题文件...
set /a count=0
for %%f in ("%SOURCE_DIR%\visonic-*.css") do (
    copy /y "%%f" "%THEME_DIR%\" >nul
    if not errorlevel 1 set /a count+=1
)

if %count% lss 1 (
    echo [ERROR] 未找到主题 CSS 文件。
    echo        已检查：%SOURCE_DIR%
    pause
    exit /b 1
)
echo      √ 已安装 %count% 个主题

echo.
echo [3/3] 正在验证...
set /a ok=0
for %%f in ("%THEME_DIR%\visonic-*.css") do set /a ok+=1
if %ok% geq 13 (
    echo      √ 验证通过，共检测到 %ok% 个 Visonic 主题文件
) else (
    echo      [WARN] 仅检测到 %ok% 个 Visonic 主题文件，预期至少 13 个
)

echo.
echo ============================================
echo           安装完成！
echo ============================================
echo.
echo  请重启 Typora，在「主题」菜单中选择 Visonic 主题。
echo  主题目录：%THEME_DIR%
echo.
pause
endlocal
