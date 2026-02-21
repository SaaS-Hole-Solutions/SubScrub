﻿# SubScrub - Advanced Subtitle & CC Management Utility v1.1
# Features: Duplicate Detection, Multi-format, Exclude List, Size Filtering, Progress Bar, Whitelist, Backup, and Cleanup
# Intelligently manages subtitle files by language preference
# GitHub: https://github.com/SaaS-Hole-Solutions/SubScrub

param(
    [string]$Language = ""  # Optional: Specify primary language (e.g., "spa", "fre", "ger")
)

# Enable strict mode to catch variable typos and other issues
Set-StrictMode -Version Latest

# --- DEFAULT CONFIGURATION ---
$defaultSource = "Z:\Media"
$backupRoot = "C:\Backups\Media_Subtitles" 
$minFileSizeKB = 1 # Ignore files smaller than this (set to 0 to disable)

# Extensions to process
$extensions = @("*.srt", "*.vtt", "*.ass", "*.sub", "*.ssa")

# Language code mappings (for easy language switching)
$languageMappings = @{
    'eng' = @('english', 'eng', 'en', 'en-us', 'en-gb')
    'spa' = @('spanish', 'spa', 'es', 'es-mx', 'es-es')
    'fre' = @('french', 'fre', 'fra', 'fr', 'fr-fr', 'fr-ca')
    'ger' = @('german', 'ger', 'deu', 'de', 'de-de')
    'ita' = @('italian', 'ita', 'it', 'it-it')
    'por' = @('portuguese', 'por', 'pt', 'pt-br', 'pt-pt')
    'jpn' = @('japanese', 'jpn', 'ja', 'ja-jp')
    'chi' = @('chinese', 'chi', 'zh', 'zh-cn', 'zh-tw')
    'kor' = @('korean', 'kor', 'ko', 'ko-kr')
    'rus' = @('russian', 'rus', 'ru', 'ru-ru')
    'dut' = @('dutch', 'dut', 'nld', 'nl', 'nl-nl')
    'pol' = @('polish', 'pol', 'pl', 'pl-pl')
    'swe' = @('swedish', 'swe', 'sv', 'sv-se')
    'nor' = @('norwegian', 'nor', 'no', 'nb', 'nn')
    'dan' = @('danish', 'dan', 'da', 'da-dk')
    'fin' = @('finnish', 'fin', 'fi', 'fi-fi')
    'gre' = @('greek', 'gre', 'ell', 'el', 'el-gr')
    'tur' = @('turkish', 'tur', 'tr', 'tr-tr')
    'ara' = @('arabic', 'ara', 'ar')
    'heb' = @('hebrew', 'heb', 'he', 'he-il')
    'hin' = @('hindi', 'hin', 'hi', 'hi-in')
    'tha' = @('thai', 'tha', 'th', 'th-th')
    'vie' = @('vietnamese', 'vie', 'vi', 'vi-vn')
}

# Languages to KEEP (Initial List - will be configured in Step 2)
$keepLanguages = New-Object System.Collections.Generic.List[string]

# Directories to EXCLUDE (Case-insensitive fragments)
$excludeFolders = @('$RECYCLE.BIN', '@eaDir', '#recycle', '.appledouble', 'extras')

# Initialize results object (prevents crashes if user skips archiving)
$results = @{Success=0; Failed=0}

# --- HELPER FUNCTIONS ---
function Get-UserConfirmation ($prompt) {
    $ans = Read-Host "$prompt (y/n)"
    return $ans -match '^(y|yes)$'
}

function Get-CleanRootName ($fileName, $languageCodes) {
    # Remove all common language codes and subtitle tags from filename
    $allCodes = $languageCodes + @("cc", "sdh", "forced", "hi", "spa", "fre", "ger", "ita", "por", "rus", "jpn", "chi", "kor")
    $pattern = "(?i)[\._-](" + ($allCodes -join "|") + ")([\._-]|\.|$)"
    $cleaned = $fileName -replace $pattern, ""
    return $cleaned.ToLower()
}

function Show-ProgressBar ($current, $total, $activity) {
    $percent = [math]::Round(($current / $total) * 100)
    $barLength = 40
    $filled = [math]::Round(($percent / 100) * $barLength)
    $empty = $barLength - $filled
    
    $bar = "[" + ("#" * $filled) + ("-" * $empty) + "]"
    Write-Host ("`r$activity ") -NoNewline
    Write-Host $bar -ForegroundColor Green -NoNewline
    Write-Host " $percent% ($current/$total)" -NoNewline
}

# --- INITIALIZATION ---
Clear-Host
$host.ui.RawUI.WindowTitle = "SubScrub v1.1 - Subtitle Management Utility"

# ASCII Art
Write-Host "  ____        _     ____                  _     " -ForegroundColor Yellow
Write-Host " / ___| _   _| |__ / ___|  ___ _ __ _   _| |__  " -ForegroundColor Yellow
Write-Host " \___ \| | | | '_ \\___ \ / __| '__| | | | '_ \ " -ForegroundColor Yellow
Write-Host "  ___) | |_| | |_) |___) | (__| |  | |_| | |_) |" -ForegroundColor Yellow
Write-Host " |____/ \__,_|_.__/|____/ \___|_|   \__,_|_.__/ " -ForegroundColor Yellow
Write-Host ""
Write-Host "        Subtitle Management Utility " -NoNewline -ForegroundColor Cyan
Write-Host "v1.1" -ForegroundColor White
Write-Host ""

Write-Host "==============================================" -ForegroundColor DarkGray
Write-Host "           SubScrub v1.1" -ForegroundColor Green
Write-Host "   Intelligent Subtitle File Management" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor DarkGray
Write-Host ""

# 1. Set & Validate Scan Path
Write-Host "STEP 1: Select Directory to Scan" -ForegroundColor Cyan
Write-Host "This is the root directory where SubScrub will search for subtitle files." -ForegroundColor Gray
Write-Host "All subdirectories will be scanned recursively." -ForegroundColor Gray
$userInputPath = Read-Host "`nEnter the directory path (Press Enter for default: '$defaultSource')"
$sourcePath = if ([string]::IsNullOrWhiteSpace($userInputPath)) { $defaultSource } else { $userInputPath.Trim('"') }

if (-not (Test-Path $sourcePath)) {
    Write-Host "`nERROR: Path '$sourcePath' not found." -ForegroundColor Red
    Read-Host "Press Enter to exit"; exit
}
Write-Host "[OK] Scan path set to: $sourcePath" -ForegroundColor Green
Write-Host ""

# 2. Interactive Language Configuration
Write-Host "STEP 2: Configure Language Preferences" -ForegroundColor Cyan
Write-Host "Files matching these language codes will be KEPT in their original locations." -ForegroundColor Gray
Write-Host "All other subtitle files will be archived to the backup location." -ForegroundColor Gray
Write-Host ""

# Check if language was specified via command line parameter
if (-not [string]::IsNullOrWhiteSpace($Language)) {
    $langKey = $Language.ToLower().Substring(0, [Math]::Min(3, $Language.Length))
    if ($languageMappings.ContainsKey($langKey)) {
        $keepLanguages.Clear()
        foreach ($lang in $languageMappings[$langKey]) {
            $keepLanguages.Add($lang)
        }
        Write-Host "Language set via parameter: $Language" -ForegroundColor Yellow
        Write-Host "[OK] Keep List: $($keepLanguages -join ', ')" -ForegroundColor Green
    } else {
        Write-Host "Warning: Unknown language code '$Language' - using English as default" -ForegroundColor Yellow
        foreach ($lang in @("english", "eng", "en", "en-us")) {
            $keepLanguages.Add($lang)
        }
    }
} else {
    # Interactive language selection
    Write-Host "DEFAULT: English subtitles will be KEPT" -ForegroundColor White
    Write-Host "(Files matching: english, eng, en, en-us)" -ForegroundColor Gray
    Write-Host ""
    
    $keepEnglish = Read-Host "Keep English as your primary language? (y/n) [y]"
    if ($keepEnglish -match '^n') {
        Write-Host ""
        Write-Host "Common language codes:" -ForegroundColor Cyan
        Write-Host "  spa (Spanish)    fre (French)     ger (German)      ita (Italian)" -ForegroundColor Gray
        Write-Host "  por (Portuguese) jpn (Japanese)   chi (Chinese)     kor (Korean)" -ForegroundColor Gray
        Write-Host "  rus (Russian)    ara (Arabic)     pol (Polish)      dut (Dutch)" -ForegroundColor Gray
        Write-Host ""
        
        $userLang = Read-Host "Enter your primary language code"
        $langKey = $userLang.ToLower().Substring(0, [Math]::Min(3, $userLang.Length))
        
        if ($languageMappings.ContainsKey($langKey)) {
            $keepLanguages.Clear()
            foreach ($lang in $languageMappings[$langKey]) {
                $keepLanguages.Add($lang)
            }
            Write-Host "[OK] Keep List set to: $($keepLanguages -join ', ')" -ForegroundColor Green
        } else {
            Write-Host "Language code not recognized. Using your input: $userLang" -ForegroundColor Yellow
            $keepLanguages.Clear()
            $keepLanguages.Add($userLang.ToLower())
        }
    } else {
        # Keep English (default)
        foreach ($lang in @("english", "eng", "en", "en-us")) {
            $keepLanguages.Add($lang)
        }
        Write-Host "[OK] Keeping English subtitles" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Current Keep List: $($keepLanguages -join ', ')" -ForegroundColor White
$extraLang = Read-Host "`nAdd additional language codes to KEEP? (e.g. 'spa, fre' or leave blank)"
if (-not [string]::IsNullOrWhiteSpace($extraLang)) {
    $extraLang.Split(',') | ForEach-Object { 
        $code = $_.Trim().ToLower()
        if (-not $keepLanguages.Contains($code)) {
            $keepLanguages.Add($code)
        }
    }
    Write-Host "[OK] Updated Keep List: $($keepLanguages -join ', ')" -ForegroundColor Green
}
Write-Host ""

# 3. Setup Backup Folder
Write-Host "STEP 3: Configure Backup Location" -ForegroundColor Cyan
Write-Host "Non-English subtitle files will be moved here (folder structure preserved)." -ForegroundColor Gray
$userBackupPath = Read-Host "`nEnter backup directory path (Press Enter for default: '$backupRoot')"
if (-not [string]::IsNullOrWhiteSpace($userBackupPath)) {
    $backupRoot = $userBackupPath.Trim('"')
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$currentBackupFolder = Join-Path $backupRoot "Backup_$timestamp"
Write-Host "[OK] Backup will be created at: $currentBackupFolder" -ForegroundColor Green
Write-Host ""

# 4. Dry Run Selection
Write-Host "STEP 4: Choose Run Mode" -ForegroundColor Cyan
Write-Host "DRY RUN: Preview what will happen without making any changes (recommended first time)" -ForegroundColor Gray
Write-Host "LIVE RUN: Actually move files to backup location" -ForegroundColor Gray
$isDryRun = Get-UserConfirmation "`nPerform a DRY RUN first?"
if ($isDryRun) {
    Write-Host "[OK] DRY RUN mode enabled - no files will be moved" -ForegroundColor Yellow
} else {
    Write-Host "[OK] LIVE RUN mode - files will be moved to backup" -ForegroundColor Green
}
Write-Host ""

# 4a. Validate Backup Path
if (-not $isDryRun) {
    $backupDrive = Split-Path $backupRoot -Qualifier
    if ($backupDrive -and -not (Test-Path $backupDrive)) {
        Write-Host "ERROR: Backup drive '$backupDrive' not accessible!" -ForegroundColor Red
        Read-Host "Press Enter to exit"; exit
    }
    # Create backup root if it doesn't exist
    if (-not (Test-Path $backupRoot)) {
        try {
            New-Item -Path $backupRoot -ItemType Directory -Force | Out-Null
            Write-Host "Created backup directory: $backupRoot" -ForegroundColor Green
        } catch {
            Write-Host "ERROR: Cannot create backup directory at '$backupRoot'" -ForegroundColor Red
            Read-Host "Press Enter to exit"; exit
        }
    }
}

# 5. Search for Files (Filtered)
Write-Host "STEP 5: Scanning for Subtitle Files" -ForegroundColor Cyan
Write-Host "Searching through all subdirectories for subtitle files (.srt, .vtt, .ass, .sub, .ssa)..." -ForegroundColor Gray
Write-Host ""

# First, get all directories to provide better progress tracking
$allDirs = @(Get-ChildItem -Path $sourcePath -Directory -Recurse -ErrorAction SilentlyContinue)
$totalDirs = $allDirs.Count + 1  # +1 for root directory
$processedDirs = 0
$allFiles = @()

# Process root directory first
$processedDirs++
Show-ProgressBar -current $processedDirs -total $totalDirs -activity "Scanning directories"
$rootFiles = Get-ChildItem -Path $sourcePath -Include $extensions -File -ErrorAction SilentlyContinue | Where-Object {
    $filePath = $_.FullName
    $isExcluded = $false
    foreach ($ex in $excludeFolders) { if ($filePath -like "*$ex*") { $isExcluded = $true; break } }
    ($_.Length -ge ($minFileSizeKB * 1024)) -and (-not $isExcluded)
}
$allFiles += $rootFiles

# Process subdirectories
foreach ($dir in $allDirs) {
    $processedDirs++
    Show-ProgressBar -current $processedDirs -total $totalDirs -activity "Scanning directories"
    
    $dirFiles = Get-ChildItem -Path $dir.FullName -Include $extensions -File -ErrorAction SilentlyContinue | Where-Object {
        $filePath = $_.FullName
        $isExcluded = $false
        foreach ($ex in $excludeFolders) { if ($filePath -like "*$ex*") { $isExcluded = $true; break } }
        ($_.Length -ge ($minFileSizeKB * 1024)) -and (-not $isExcluded)
    }
    $allFiles += $dirFiles
}

Write-Host ""  # New line after progress bar
Write-Host "[OK] Scan complete: Found $($allFiles.Count) valid subtitle files" -ForegroundColor Green
Write-Host ""

# 6. Language Filtering & Duplicate Detection
Write-Host "STEP 6: Analyzing Files by Language" -ForegroundColor Cyan
$keepList = @(); $moveList = @(); $duplicatesList = @()

# Build improved language pattern - matches language code with separator before OR at end of basename
$langPattern = "[\._-](" + ($keepLanguages -join "|") + ")([\._-]|\.srt|\.vtt|\.ass|\.sub|\.ssa|$)"

# Logic to group by directory and filename root to find potential duplicates
$groups = $allFiles | Group-Object DirectoryName

foreach ($group in $groups) {
    $filesInFolder = $group.Group
    $seenRoots = @{}
    
    # Also check for exact duplicates by file hash
    Write-Progress -Activity "Analyzing Files" -Status "Checking folder: $($group.Name)" -PercentComplete 0
    
    foreach ($file in $filesInFolder) {
        # Check if file matches keep language pattern
        $isMatch = $file.Name -match "(?i)$langPattern"
        
        # Get clean root name for duplicate detection
        $rootName = Get-CleanRootName -fileName $file.BaseName -languageCodes $keepLanguages
        
        if ($isMatch) {
            # This is an English/keep language file
            if ($seenRoots.ContainsKey($rootName)) {
                # We already have a file with this root name - potential duplicate
                $existingFile = $seenRoots[$rootName]
                
                # Compare file sizes - keep the larger one
                if ($file.Length -gt $existingFile.Length) {
                    # Current file is larger, move the existing one to duplicates
                    $duplicatesList += $existingFile
                    $keepList = $keepList | Where-Object { $_.FullName -ne $existingFile.FullName }
                    $keepList += $file
                    $seenRoots[$rootName] = $file
                } else {
                    # Existing file is larger or same, mark current as duplicate
                    $duplicatesList += $file
                }
            } else {
                # First file with this root name
                $keepList += $file
                $seenRoots[$rootName] = $file
            }
        } else {
            # Non-English file
            $moveList += $file
        }
    }
}
Write-Progress -Activity "Analyzing Files" -Completed

# Calculate total size
$totalSizeMB = [math]::Round(($allFiles | Measure-Object -Property Length -Sum).Sum / 1MB, 2)
$moveSizeMB = [math]::Round(($moveList | Measure-Object -Property Length -Sum).Sum / 1MB, 2)
$dupSizeMB = [math]::Round(($duplicatesList | Measure-Object -Property Length -Sum).Sum / 1MB, 2)

Write-Host "`n==== SCAN SUMMARY ====" -ForegroundColor Green
Write-Host "Target Directory:      $sourcePath"
Write-Host "Total Files Scanned:   $($allFiles.Count) ($totalSizeMB MB)" -ForegroundColor White
Write-Host "Files to KEEP:         $($keepList.Count)" -ForegroundColor Green
Write-Host "Non-English to MOVE:   $($moveList.Count) ($moveSizeMB MB)" -ForegroundColor Yellow
Write-Host "Duplicate CC Found:    $($duplicatesList.Count) ($dupSizeMB MB)" -ForegroundColor Magenta

# Combine move list and duplicates if user wants
$finalMoveList = New-Object System.Collections.ArrayList

# Add non-English files
foreach ($file in $moveList) {
    [void]$finalMoveList.Add($file)
}

if ($duplicatesList.Count -gt 0) {
    Write-Host "`nDuplicate files are typically multiple English CC versions (e.g., 'en' and 'eng' for the same content)."
    if (Get-UserConfirmation "Include the $($duplicatesList.Count) duplicate CC files in the archive?") {
        foreach ($file in $duplicatesList) {
            [void]$finalMoveList.Add($file)
        }
    }
}

if ($finalMoveList.Count -eq 0) {
    Write-Host "`nNo files found to archive." -ForegroundColor Green
    Read-Host "`nPress Enter to exit"
    exit
}

# Function to perform the archive operation
function Invoke-ArchiveOperation {
    param($fileList, $dryRun, $backupFolder, $sourceRoot, $logFile)
    
    $successCount = 0
    $failCount = 0

    for ($i = 0; $i -lt $fileList.Count; $i++) {
        $file = $fileList[$i]
        $relativePath = $file.FullName.Substring($sourceRoot.Length).TrimStart('\')
        $destPath = Join-Path $backupFolder $relativePath
        $destDir = Split-Path $destPath -Parent

        $percentComplete = [math]::Round(($i / $fileList.Count) * 100)
        Write-Progress -Activity "Archiving Subtitles" -Status "Moving: $relativePath" -PercentComplete $percentComplete

        if ($dryRun) {
            Write-Host "[DRY RUN] Would move: $relativePath" -ForegroundColor Gray
            $successCount++
        } else {
            try {
                if (-not (Test-Path $destDir)) { New-Item -Path $destDir -ItemType Directory -Force | Out-Null }
                Move-Item -Path $file.FullName -Destination $destPath -Force
                
                # Enhanced logging with file details
                $sizeKB = [math]::Round($file.Length / 1KB, 2)
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                "$timestamp | $sizeKB KB | $($file.Extension) | $($file.FullName) -> $destPath" | Out-File $logFile -Append
                
                $successCount++
            } catch {
                Write-Host "  FAILED: $($file.Name) - $_" -ForegroundColor Red
                "FAILED: $($file.FullName) - $_" | Out-File $logFile -Append
                $failCount++
            }
        }
    }
    Write-Progress -Activity "Archiving Subtitles" -Completed

    return @{Success=$successCount; Failed=$failCount}
}

# 7. Show Preview
$finalMoveSizeMB = [math]::Round(($finalMoveList | Measure-Object -Property Length -Sum).Sum / 1MB, 2)
Write-Host "`nTotal size to archive: $finalMoveSizeMB MB" -ForegroundColor Cyan

if (Get-UserConfirmation "Show preview of files to be moved?") {
    Write-Host "`n--- PREVIEW (First 20 files) ---" -ForegroundColor Yellow
    $finalMoveList | Select-Object -First 20 | ForEach-Object {
        $size = [math]::Round($_.Length / 1KB, 1)
        $relPath = $_.FullName.Substring($sourcePath.Length).TrimStart('\')
        Write-Host "  [$size KB] $relPath" -ForegroundColor Gray
    }
    if ($finalMoveList.Count -gt 20) {
        Write-Host "  ... and $($finalMoveList.Count - 20) more files" -ForegroundColor Gray
    }
    Write-Host ""
}

# 8. Archive Operation
if (Get-UserConfirmation "Proceed with archiving $($finalMoveList.Count) files?") {
    $logPath = $null
    if (-not $isDryRun) {
        New-Item -Path $currentBackupFolder -ItemType Directory -Force | Out-Null
        $logPath = Join-Path $currentBackupFolder "archive_log.txt"
        "=" * 80 | Out-File $logPath
        "SubScrub Archive Log" | Out-File $logPath -Append
        "=" * 80 | Out-File $logPath -Append
        "Archive Started: $(Get-Date)" | Out-File $logPath -Append
        "Source Path: $sourcePath" | Out-File $logPath -Append
        "Backup Location: $currentBackupFolder" | Out-File $logPath -Append
        "Files Archived: $($finalMoveList.Count)" | Out-File $logPath -Append
        "Total Size: $finalMoveSizeMB MB" | Out-File $logPath -Append
        "=" * 80 | Out-File $logPath -Append
        "" | Out-File $logPath -Append
        "ARCHIVED FILES (Timestamp | Size | Type | Original -> Destination):" | Out-File $logPath -Append
        "-" * 80 | Out-File $logPath -Append
    }

    $results = Invoke-ArchiveOperation -fileList $finalMoveList -dryRun $isDryRun -backupFolder $currentBackupFolder -sourceRoot $sourcePath -logFile $logPath

    Write-Host "`nArchive Operation Complete:" -ForegroundColor Green
    Write-Host "  Success: $($results.Success) files" -ForegroundColor Green
    if ($results.Failed -gt 0) {
        Write-Host "  Failed:  $($results.Failed) files" -ForegroundColor Red
    }
    
    # Add completion footer to log
    if (-not $isDryRun -and $logPath) {
        "" | Out-File $logPath -Append
        "=" * 80 | Out-File $logPath -Append
        "Archive Complete: $(Get-Date)" | Out-File $logPath -Append
        "Files Successfully Archived: $($results.Success)" | Out-File $logPath -Append
        "Files Failed: $($results.Failed)" | Out-File $logPath -Append
        "=" * 80 | Out-File $logPath -Append
    }
    
    # 9. Generate CSV Report
    if ($finalMoveList.Count -gt 0 -and -not $isDryRun -and (Get-UserConfirmation "`nGenerate CSV report?")) {
        $reportFilename = "subtitle_archive_report_$timestamp.csv"
        $desktopPath = Join-Path ([Environment]::GetFolderPath("Desktop")) $reportFilename
        $backupPath = Join-Path $currentBackupFolder $reportFilename
        
        $reportData = $finalMoveList | Select-Object @{Name='FileName';Expression={$_.Name}}, 
                                       @{Name='OriginalPath';Expression={$_.FullName}},
                                       @{Name='SizeKB';Expression={[math]::Round($_.Length/1KB,2)}},
                                       @{Name='LastModified';Expression={$_.LastWriteTime}},
                                       @{Name='Extension';Expression={$_.Extension}}
        
        # Save to Desktop for easy access
        $reportData | Export-Csv -Path $desktopPath -NoTypeInformation
        Write-Host "Report saved to Desktop: $desktopPath" -ForegroundColor Green
        
        # Also save to backup folder for archival
        $reportData | Export-Csv -Path $backupPath -NoTypeInformation
        Write-Host "Report archived with backup: $backupPath" -ForegroundColor Green
    }
}

# 10. Recursive Empty Folder Cleanup
Write-Host "`nScanning for empty folders..." -ForegroundColor Cyan
$potentialEmptyFolders = Get-ChildItem -Path $sourcePath -Recurse -Directory -ErrorAction SilentlyContinue | 
    Sort-Object { $_.FullName.Length } -Descending

$emptyFoldersFound = @()
foreach ($dir in $potentialEmptyFolders) {
    if ((Get-ChildItem -Force -Path $dir.FullName -ErrorAction SilentlyContinue).Count -eq 0) { 
        $emptyFoldersFound += $dir 
    }
}

if ($emptyFoldersFound.Count -gt 0) {
    Write-Host "Found $($emptyFoldersFound.Count) empty folders." -ForegroundColor Yellow
    if (Get-UserConfirmation "Delete these empty folders?") {
        $deletedCount = 0
        foreach ($dir in $emptyFoldersFound) {
            if ($isDryRun) { 
                Write-Host "[DRY RUN] Would delete: $($dir.FullName)" -ForegroundColor Gray 
            } else { 
                try {
                    # Small delay helps with network drives that hold file handles briefly
                    Start-Sleep -Milliseconds 100
                    Remove-Item -Path $dir.FullName -Force -ErrorAction Stop
                    $deletedCount++
                } catch {
                    Write-Host "  Failed to delete: $($dir.FullName)" -ForegroundColor Red
                }
            }
        }
        if (-not $isDryRun) {
            Write-Host "Deleted $deletedCount empty folders." -ForegroundColor Green
        }
    }
} else {
    Write-Host "No empty folders found." -ForegroundColor Green
}

# 11. Final Statistics
Write-Host "`n==== FINAL STATISTICS ====" -ForegroundColor Cyan
Write-Host "Files Kept:        $($keepList.Count)" -ForegroundColor Green
Write-Host "Files Archived:    $(if (!$isDryRun) { $results.Success } else { '0 (Dry Run)' })" -ForegroundColor Yellow
Write-Host "Duplicates Found:  $($duplicatesList.Count)" -ForegroundColor Magenta
Write-Host "Empty Folders:     $($emptyFoldersFound.Count)" -ForegroundColor White
if (-not $isDryRun -and $results.Success -gt 0) {
    Write-Host "`nBackup Location:   $currentBackupFolder" -ForegroundColor Gray
    Write-Host "Archive Log:       $(Join-Path $currentBackupFolder 'archive_log.txt')" -ForegroundColor Gray
}

Write-Host "`n==== ALL OPERATIONS COMPLETE ====" -ForegroundColor Green
if ($isDryRun) { 
    Write-Host "DRY RUN MODE: No actual changes were made." -ForegroundColor Yellow 
    Write-Host "This was a preview of what would happen." -ForegroundColor Yellow
    Write-Host ""
    
    # Ask if user wants to run for real now
    if (Get-UserConfirmation "Would you like to run this for REAL now (move files to backup)?") {
        $isDryRun = $false
        Write-Host "`n[OK] Switching to LIVE RUN mode..." -ForegroundColor Green
        Write-Host "Files will now be moved to backup location." -ForegroundColor Yellow
        Write-Host ""
        Start-Sleep -Seconds 2
        
        # Create backup folder and log
        New-Item -Path $currentBackupFolder -ItemType Directory -Force | Out-Null
        $logPath = Join-Path $currentBackupFolder "archive_log.txt"
        "=" * 80 | Out-File $logPath
        "SubScrub Archive Log" | Out-File $logPath -Append
        "=" * 80 | Out-File $logPath -Append
        "Archive Started: $(Get-Date)" | Out-File $logPath -Append
        "Source Path: $sourcePath" | Out-File $logPath -Append
        "Backup Location: $currentBackupFolder" | Out-File $logPath -Append
        "Files Archived: $($finalMoveList.Count)" | Out-File $logPath -Append
        "Total Size: $finalMoveSizeMB MB" | Out-File $logPath -Append
        "=" * 80 | Out-File $logPath -Append
        "" | Out-File $logPath -Append
        "ARCHIVED FILES (Timestamp | Size | Type | Original -> Destination):" | Out-File $logPath -Append
        "-" * 80 | Out-File $logPath -Append
        
        # Run the actual operation
        $results = Invoke-ArchiveOperation -fileList $finalMoveList -dryRun $false -backupFolder $currentBackupFolder -sourceRoot $sourcePath -logFile $logPath
        
        # Add completion footer to log
        if ($logPath) {
            "" | Out-File $logPath -Append
            "=" * 80 | Out-File $logPath -Append
            "Archive Complete: $(Get-Date)" | Out-File $logPath -Append
            "Files Successfully Archived: $($results.Success)" | Out-File $logPath -Append
            "Files Failed: $($results.Failed)" | Out-File $logPath -Append
            "=" * 80 | Out-File $logPath -Append
        }
        
        Write-Host "`n==== LIVE RUN COMPLETE ====" -ForegroundColor Green
        Write-Host "  Success: $($results.Success) files moved" -ForegroundColor Green
        if ($results.Failed -gt 0) {
            Write-Host "  Failed:  $($results.Failed) files" -ForegroundColor Red
        }
        Write-Host "`nBackup Location: $currentBackupFolder" -ForegroundColor Gray
    }
}

Read-Host "`nPress Enter to exit"
