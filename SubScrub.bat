@echo off
REM ============================================================================
REM SubScrub v1.1 - Batch File Launcher
REM This file launches the PowerShell script with proper execution policy
REM Use this if the .exe version is blocked by your antivirus software
REM 
REM Usage:
REM   SubScrub.bat           - Run with default settings (interactive)
REM   SubScrub.bat spa       - Run with Spanish as primary language
REM   SubScrub.bat fre       - Run with French as primary language
REM ============================================================================

setlocal
title SubScrub v1.1 - Subtitle Management Utility

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"

REM Check if PowerShell script exists
if not exist "%SCRIPT_DIR%SubScrub-v1.1.ps1" (
    echo ERROR: SubScrub-v1.1.ps1 not found!
    echo.
    echo This batch file must be in the same folder as SubScrub-v1.1.ps1
    echo.
    pause
    exit /b 1
)

REM Launch PowerShell script with error handling
echo Starting SubScrub...
echo.

REM Check if language parameter was provided
if "%~1"=="" (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%SubScrub-v1.1.ps1"
) else (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%SubScrub-v1.1.ps1" -Language "%~1"
)

REM Check if script had an error
if errorlevel 1 (
    echo.
    echo ========================================
    echo An error occurred. Check messages above.
    echo ========================================
    pause
)
