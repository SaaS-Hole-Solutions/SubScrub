╔═══════════════════════════════════════════════════════════════════════════╗
║                        SUBSCRUB - CHANGELOG v1.0                           ║
╚═══════════════════════════════════════════════════════════════════════════╝

VERSION 1.1 - February 14, 2024
═══════════════════════════════════════════════════════════════════════════

BUG FIXES:
─────────────────────────────────────────────────────────────────────────────
✓ Fixed PowerShell type conversion error with AddRange method
  - Replaced AddRange calls with foreach loops for better compatibility
  - Resolves "Cannot convert argument collection" error
  - Affects language list initialization

✓ Added Set-StrictMode for better error detection
  - Catches variable typos and undefined variables
  - Prevents silent failures in production
  - Improves code quality and debugging

NEW FEATURES:
─────────────────────────────────────────────────────────────────────────────
✓ Hybrid Language Selection System
  - Command line parameter support: -Language <code>
  - Interactive prompt: "Keep English? (y/n)"
  - Built-in language mappings for 23+ languages
  - Automatic variant detection (e.g., spa → spanish, spa, es, es-mx)
  - Common language codes displayed as helpful reference
  - Power users can bypass prompts with command line
  - Beginners get user-friendly interactive selection

✓ Enhanced Step 2 Clarity
  - Default language (English) now explicitly stated
  - Clear explanation of what files will be kept vs archived
  - Helpful language code reference displayed during selection

✓ GitHub Repository Integration
  - Project now hosted at: https://github.com/SaaS-Hole-Solutions/SubScrub
  - Link included in script header and all documentation

✓ Comprehensive Documentation Suite
  - New: USAGE_EXAMPLES.txt - Real-world scenarios and use cases
  - New: QUICK_REFERENCE.txt - One-page cheat sheet
  - Updated: README.txt - Enhanced language selection guide
  - Updated: All documentation with GitHub links


═══════════════════════════════════════════════════════════════════════════

VERSION 1.0 - February 14, 2024 (Initial Release)
═══════════════════════════════════════════════════════════════════════════

BUG FIXES (Critical - Verified by code review):
─────────────────────────────────────────────────────────────────────────────
✓ Fixed case-sensitive path handling
  - Changed from .Replace() to .Substring() for path manipulation
  - Prevents backup path errors when user enters different case than Windows
  - Affects: Archive operation (line 275) and file preview (line 316)
  - Example: User enters "z:\media" but Windows reports "Z:\Media" → now works

✓ Fixed uninitialized variable crash
  - Initialized $results variable at script start
  - Prevents crash when user skips archiving operation
  - Script now safely displays statistics regardless of user choices

✓ Added network drive stability improvement
  - 100ms delay before deleting empty folders
  - Allows Windows/SMB to release file handles on network storage
  - Significantly improves success rate on NAS/network shares

✓ Enhanced CSV report archival
  - CSV now saved to BOTH Desktop and Backup folder
  - Ensures long-term data retention with archived files
  - Professional best practice: metadata stays with data


ENCODING FIXES (Critical - Required for Windows PowerShell):
─────────────────────────────────────────────────────────────────────────────
✓ Added UTF-8 BOM (Byte Order Mark) to file header
  - Ensures PowerShell correctly interprets file as UTF-8
  - Prevents ANSI misinterpretation of Unicode characters

✓ Converted line endings from LF to CRLF
  - Changed from Unix (\n) to Windows (\r\n) format
  - Improves PowerShell parsing compatibility

✓ Replaced Unicode checkmarks with ASCII
  - Changed 7 instances of ✓ to [OK]
  - Ensures compatibility across all Windows locales
  - Prevents encoding corruption


VISUAL ENHANCEMENTS:
─────────────────────────────────────────────────────────────────────────────
✓ Progress bar hashes now display in GREEN
  - Before: [######----------] 45% (9/20)  [white/gray]
  - After:  [######----------] 45% (9/20)  [green hashes]
  - Improved visual feedback during scanning


LOGGING ENHANCEMENTS:
─────────────────────────────────────────────────────────────────────────────
✓ Enhanced archive log with detailed file information
  - Each entry now includes: Timestamp | File Size | File Type | Paths
  - Example: 2024-02-14 15:32:18 | 45.23 KB | .srt | Original -> Destination

✓ Improved log header with comprehensive metadata
  - Archive start time
  - Source path
  - Backup location
  - Total files and size
  - Column headers for clarity

✓ Added completion footer to log
  - Archive completion time
  - Success/failure counts
  - Professional log closure

✓ Log location displayed in console
  - Users are informed where to find the detailed log
  - Path: [BackupFolder]\archive_log.txt


LOG FILE FORMAT EXAMPLE:
─────────────────────────────────────────────────────────────────────────────
================================================================================
SubScrub Archive Log
================================================================================
Archive Started: 2024-02-14 15:32:17
Source Path: Z:\Media
Backup Location: C:\Backups\Media_Subtitles\Backup_20240214_153217
Files Archived: 47
Total Size: 12.45 MB
================================================================================

ARCHIVED FILES (Timestamp | Size | Type | Original -> Destination):
--------------------------------------------------------------------------------
2024-02-14 15:32:18 | 45.23 KB | .srt | Z:\Media\Movie1\movie.spa.srt -> ...
2024-02-14 15:32:18 | 38.91 KB | .srt | Z:\Media\Movie1\movie.fre.srt -> ...
... (all files listed with details)

================================================================================
Archive Complete: 2024-02-14 15:32:25
Files Successfully Archived: 47
Files Failed: 0
================================================================================


COMPATIBILITY:
─────────────────────────────────────────────────────────────────────────────
✓ Windows PowerShell 5.1
✓ PowerShell Core 7+
✓ All Windows locales/regions
✓ Works on systems with or without Unicode console support


NO FUNCTIONALITY CHANGES:
─────────────────────────────────────────────────────────────────────────────
All core features remain identical:
• Duplicate subtitle detection
• Multi-format support (.srt, .vtt, .ass, .sub, .ssa)
• Language-based filtering
• Backup with folder structure preservation
• Dry run mode for safe testing
• Progress tracking
• Empty folder cleanup
• CSV report generation


FILES IN THIS RELEASE:
─────────────────────────────────────────────────────────────────────────────
• SubScrub-v1.1.ps1     - Main executable script (ready to run)
• FINAL_FIX_SUMMARY.txt        - Technical details of encoding fixes
• SAMPLE_archive_log.txt       - Example of enhanced log output
• CHANGELOG.txt                - This file (version history)


═══════════════════════════════════════════════════════════════════════════
                                  END OF LOG
═══════════════════════════════════════════════════════════════════════════
