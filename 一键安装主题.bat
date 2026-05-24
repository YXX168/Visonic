@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul 2>&1
title Visonic Themes Installer
color 0B

echo ============================================
echo       Visonic Themes for Typora Installer
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
    echo [INFO] Typora theme folder not found. Creating:
    echo        %THEME_DIR%
    mkdir "%THEME_DIR%" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Cannot create Typora theme folder. Please check permissions or Typora installation.
        pause
        exit /b 1
    )
)

if not exist "%SCRIPT_DIR%visonic-fonts" (
    echo [ERROR] Font folder not found: %SCRIPT_DIR%visonic-fonts
    echo        Please run this script from the full Release package or repository root.
    pause
    exit /b 1
)

echo Select install mode:
echo.
echo   [1] Clean install / replace theme folder
echo       - Backup current Typora themes folder first
echo       - Clear all files and folders under themes
echo       - Install only Visonic themes and font assets
echo.
echo   [2] Keep existing themes and add/update Visonic themes recommended
echo       - Do not delete existing themes
echo       - Copy Visonic themes and font assets
echo.
choice /c 12 /n /m "Type 1 or 2: "
if errorlevel 2 (
    set "INSTALL_MODE=KEEP"
) else (
    set "INSTALL_MODE=CLEAN"
)

echo.
if /i "%INSTALL_MODE%"=="CLEAN" (
    echo [MODE] Clean install / replace theme folder
    echo.
    echo [WARN] This will clear: %THEME_DIR%
    echo        A backup will be created under APPDATA\Typora\themes-visonic-backup-TIMESTAMP
    echo.
    choice /c YN /n /m "Continue? [Y/N]: "
    if errorlevel 2 (
        echo Cancelled.
        pause
        exit /b 0
    )

    call :MakeStamp
    set "BACKUP_DIR=%APPDATA%\Typora\themes-visonic-backup-!STAMP!"
    echo [1/5] Backing up current theme folder...
    mkdir "!BACKUP_DIR!" >nul 2>&1
    xcopy /e /i /y /q "%THEME_DIR%\*" "!BACKUP_DIR!\" >nul 2>&1
    echo      [OK] Backup saved to: !BACKUP_DIR!

    echo.
    echo [2/5] Clearing Typora theme folder...
    del /f /q "%THEME_DIR%\*" >nul 2>&1
    for /d %%d in ("%THEME_DIR%\*") do rmdir /s /q "%%d" >nul 2>&1
    echo      [OK] Theme folder cleared
) else (
    echo [MODE] Keep existing themes and add/update Visonic themes
    call :MakeStamp
    set "BACKUP_DIR=%APPDATA%\Typora\themes-visonic-backup-!STAMP!"
)

echo.
echo [3/5] Installing font assets...
if not exist "%THEME_DIR%\visonic-fonts" mkdir "%THEME_DIR%\visonic-fonts" >nul 2>&1
xcopy /e /i /y /q "%SCRIPT_DIR%visonic-fonts\*" "%THEME_DIR%\visonic-fonts\" >nul
if errorlevel 1 (
    echo [ERROR] Failed to copy font assets.
    pause
    exit /b 1
)
echo      [OK] Font assets installed

echo.
echo [4/5] Installing theme files...
set /a count=0
for %%f in ("%SOURCE_DIR%\visonic-*.css") do (
    copy /y "%%f" "%THEME_DIR%\" >nul
    if not errorlevel 1 set /a count+=1
)

if %count% lss 1 (
    echo [ERROR] No theme CSS files found.
    echo        Checked: %SOURCE_DIR%
    pause
    exit /b 1
)
echo      [OK] Installed %count% themes

echo.
echo [5/5] Setting default theme bridge...
if exist "%THEME_DIR%\%DEFAULT_THEME%.css" (
    if exist "%DEFAULT_BRIDGE%" (
        if not exist "!BACKUP_DIR!" mkdir "!BACKUP_DIR!" >nul 2>&1
        copy /y "%DEFAULT_BRIDGE%" "!BACKUP_DIR!\github.user.css.bak" >nul 2>&1
    )
    > "%DEFAULT_BRIDGE%" echo /* Visonic Themes auto default bridge. Delete this file to restore Typora GitHub default style. */
    >> "%DEFAULT_BRIDGE%" echo @import url("./%DEFAULT_THEME%.css");
    echo      [OK] GitHub default theme bridged to: %DEFAULT_THEME%
    echo           Restart Typora to load the Visonic default style.
) else (
    echo      [WARN] Default theme file not found: %DEFAULT_THEME%.css. Default bridge skipped.
)

echo.
echo Verifying...
set /a ok=0
for %%f in ("%THEME_DIR%\visonic-*.css") do set /a ok+=1
if %ok% geq 13 (
    echo      [OK] Verification passed. Detected %ok% Visonic theme files.
) else (
    echo      [WARN] Detected only %ok% Visonic theme files. Expected at least 13.
)

echo.
echo ============================================
echo           Installation completed
echo ============================================
echo.
echo  Install mode: %INSTALL_MODE%
echo  Default bridge theme: %DEFAULT_THEME%
echo  Theme folder: %THEME_DIR%
echo.
echo  Please restart Typora.
echo  You can also switch manually from Typora Theme menu.
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
