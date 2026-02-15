@echo off
REM ============================================================================
REM SubScrub v1.0 - Batch File Launcher
REM This file launches the PowerShell script with proper execution policy
REM Use this if the .exe version is blocked by your antivirus software
REM ============================================================================

setlocal
title SubScrub v1.0 - Subtitle Management Utility

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"

REM Check if PowerShell script exists
if not exist "%SCRIPT_DIR%SubScrub-v1.0.ps1" (
    echo ERROR: SubScrub-v1.0.ps1 not found!
    echo.
    echo This batch file must be in the same folder as SubScrub-v1.0.ps1
    echo.
    pause
    exit /b 1
)

REM Launch PowerShell script with bypass execution policy
echo Starting SubScrub...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%SubScrub-v1.0.ps1"

REM Return to batch when PowerShell script exits
echo.
echo SubScrub has finished.
pause
