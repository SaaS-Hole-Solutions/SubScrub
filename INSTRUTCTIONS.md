╔═══════════════════════════════════════════════════════════════════════════╗
║                       SUB SCRUB - USER INSTRUCTIONS                       ║
║                Intelligent Subtitle & CC Management Utility               ║
╚═══════════════════════════════════════════════════════════════════════════╝

Depending on how you like to work, there are three ways to get SubScrub 
running on your machine.

[cite_start]*** IMPORTANT: USE AT YOUR OWN RISK *** [cite: 47]

SubScrub moves files within your file system. While it is designed with 
multiple safety layers, the author is not responsible for any data loss 
[cite_start]or misplaced files[cite: 47].

BACKUP RECOMMENDATIONS:

1. ALWAYS perform a "DRY RUN" (Step 4 in the script) before committing 
   [cite_start]to a live run[cite: 31, 43].
   
2. If you are processing a massive library for the first time, consider 
   cloning your subtitle directory to a separate drive first.
   
3. [cite_start]Keep your media server's metadata backup current[cite: 28].

[cite_start]***** OPTION 1: THE STANDALONE EXE (Easiest) ***** [cite: 29]

This is a single file that has everything bundled together. No extra 
[cite_start]files or scripts are needed to run it[cite: 29].

1. [cite_start]DOWNLOAD: Grab "SubScrub.exe" from the latest Release[cite: 29].
2. [cite_start]RUN: Double-click the file[cite: 29].
3. WINDOWS WARNING: Because I'm an independent developer, Windows might 
   [cite_start]show a "SmartScreen" popup[cite: 29].
    a. [cite_start]Click "More Info" [cite: 29]
    b. [cite_start]Click "Run Anyway" [cite: 29]
4. FOLLOW THE PROMPTS: The tool will guide you through picking your media 
   [cite_start]folder and your backup spot[cite: 30].

[cite_start]***** OPTION 2: THE .BAT LAUNCHER (Best for Script Users) ***** [cite: 29]

If your antivirus is being grumpy about the EXE, or you just prefer 
[cite_start]using the script, use the Batch launcher[cite: 42, 50].

1. SETUP: Make sure "SubScrub.bat" and "SubScrub-v1.1.ps1" are in the 
   [cite_start]SAME FOLDER[cite: 51].
2. [cite_start]RUN: Double-click "SubScrub.bat"[cite: 14].
3. POWER USERS: You can now pass a language code directly to the batch 
   [cite_start]file to skip interactive prompts (e.g., `SubScrub.bat spa`)[cite: 50, 52].
4. WHY USE THIS?: This batch file automatically tells Windows to let the 
   PowerShell script run without you having to change any system security 
   [cite_start]settings manually[cite: 30, 42].

[cite_start]***** OPTION 3: RAW POWERSHELL (.ps1) ***** [cite: 29]

[cite_start]For the power users who want to run the code directly in their terminal[cite: 30].

1. [cite_start]Open PowerShell[cite: 15].
2. [cite_start]Navigate to your folder: `cd "C:\path\to\SubScrub"` [cite: 15]
3. [cite_start]Run the script: `.\SubScrub-v1.1.ps1` [cite: 15]
   - NEW: Use `-Language` parameter for automation: 
     [cite_start]`.\SubScrub-v1.1.ps1 -Language eng` [cite: 19]

Note: If you get an "execution policy" error, use Option 2 or run: 
[cite_start]`Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`[cite: 42].

═════════════════════════════════════════════════════════════════════════════
COMMON QUESTIONS & TROUBLESHOOTING

[cite_start]"Windows says this file is dangerous!" [cite: 29]
That's just Windows being overprotective. Since this script moves files 
[cite_start]around, Windows flags it[cite: 29]. You can audit the code in the .ps1 
file yourself—it's all transparent! Just click "More Info" followed by 
[cite_start]"Run Anyway" to bypass the warning[cite: 29, 30].

[cite_start]"Can I use network drives?" [cite: 23]
Yes! SubScrub v1.1 includes a stability delay specifically for NAS/SMB 
[cite_start]shares to help Windows release file handles[cite: 46]. Just type your 
[cite_start]mapped drive letter like `Z:\Media`[cite: 23, 42].

[cite_start]"It's missing some of my languages!" [cite: 23]
[cite_start]We now support 23+ languages by default[cite: 2, 24]. If yours isn't 
listed, you can type in any custom code (like 'tgl' for Tagalog) during 
[cite_start]the interactive setup[cite: 35, 36].

Questions? Issues? [cite_start]Open a ticket on GitHub! [cite: 24]
[cite_start]Made by SaaS-Hole-Solutions [cite: 24]
