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
set "DEFAULT_THEME=visonic-streamer-nebula"
set "DEFAULT_BRIDGE=%THEME_DIR%\github.user.css"

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

if not exist "%SCRIPT_DIR%visonic-fonts" (
    echo [ERROR] 未找到字体文件夹：%SCRIPT_DIR%visonic-fonts
    echo        请从完整 Release 包或仓库根目录运行本脚本。
    pause
    exit /b 1
)

echo 请选择安装方式：
echo.
echo   [1] 清空并替换主题目录
echo       - 先备份当前 Typora themes 文件夹
echo       - 清空 themes 下所有文件/文件夹
echo       - 只安装 Visonic 主题和字体依赖
echo.
echo   [2] 保留现有主题，新增/覆盖 Visonic 主题（推荐）
echo       - 不删除原有主题
echo       - 复制 Visonic 主题和字体依赖
echo.
choice /c 12 /n /m "请输入 1 或 2："
if errorlevel 2 (
    set "INSTALL_MODE=KEEP"
) else (
    set "INSTALL_MODE=CLEAN"
)

echo.
if /i "%INSTALL_MODE%"=="CLEAN" (
    echo [模式] 清空并替换主题目录
    echo.
    echo [WARN] 即将清空：%THEME_DIR%
    echo        脚本会先备份到 APPDATA\Typora\themes-visonic-backup-时间戳
    echo.
    choice /c YN /n /m "确认继续？[Y/N]："
    if errorlevel 2 (
        echo 已取消。
        pause
        exit /b 0
    )

    call :MakeStamp
    set "BACKUP_DIR=%APPDATA%\Typora\themes-visonic-backup-!STAMP!"
    echo [1/5] 正在备份当前主题目录...
    mkdir "!BACKUP_DIR!" >nul 2>&1
    xcopy /e /i /y /q "%THEME_DIR%\*" "!BACKUP_DIR!\" >nul 2>&1
    echo      √ 已备份到：!BACKUP_DIR!

    echo.
    echo [2/5] 正在清空 Typora 主题目录...
    del /f /q "%THEME_DIR%\*" >nul 2>&1
    for /d %%d in ("%THEME_DIR%\*") do rmdir /s /q "%%d" >nul 2>&1
    echo      √ 主题目录已清空
) else (
    echo [模式] 保留现有主题，新增/覆盖 Visonic 主题
    call :MakeStamp
    set "BACKUP_DIR=%APPDATA%\Typora\themes-visonic-backup-!STAMP!"
)

echo.
echo [3/5] 正在安装字体依赖...
if not exist "%THEME_DIR%\visonic-fonts" mkdir "%THEME_DIR%\visonic-fonts" >nul 2>&1
xcopy /e /i /y /q "%SCRIPT_DIR%visonic-fonts\*" "%THEME_DIR%\visonic-fonts\" >nul
if errorlevel 1 (
    echo [ERROR] 字体依赖复制失败。
    pause
    exit /b 1
)
echo      √ 字体依赖安装完成

echo.
echo [4/5] 正在安装主题文件...
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
echo [5/5] 正在设置默认主题桥接...
if exist "%THEME_DIR%\%DEFAULT_THEME%.css" (
    if exist "%DEFAULT_BRIDGE%" (
        if not exist "!BACKUP_DIR!" mkdir "!BACKUP_DIR!" >nul 2>&1
        copy /y "%DEFAULT_BRIDGE%" "!BACKUP_DIR!\github.user.css.bak" >nul 2>&1
    )
    > "%DEFAULT_BRIDGE%" echo /* Visonic Themes auto default bridge. Delete this file to restore Typora GitHub default style. */
    >> "%DEFAULT_BRIDGE%" echo @import url("./%DEFAULT_THEME%.css");
    echo      √ 已将 GitHub 默认主题桥接为：%DEFAULT_THEME%
    echo        重启 Typora 后，即使仍停留在默认 GitHub 主题，也会显示 Visonic 样式。
) else (
    echo      [WARN] 未找到默认主题文件：%DEFAULT_THEME%.css，已跳过默认主题桥接。
)

echo.
echo 正在验证...
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
echo  已安装模式：%INSTALL_MODE%
echo  默认桥接主题：%DEFAULT_THEME%
echo  主题目录：%THEME_DIR%
echo.
echo  请重启 Typora。
echo  如需手动切换，可在「主题」菜单中选择任意 Visonic 主题。
echo.
pause
endlocal
exit /b 0

:MakeStamp
for /f "tokens=1-3 delims=/.- " %%a in ("%date%") do set "D1=%%a"&set "D2=%%b"&set "D3=%%c"
for /f "tokens=1-3 delims=:., " %%a in ("%time%") do set "T1=%%a"&set "T2=%%b"&set "T3=%%c"
set "T1=%T1: =0%"
set "STAMP=%D1%%D2%%D3%-%T1%%T2%%T3%"
exit /b 0
