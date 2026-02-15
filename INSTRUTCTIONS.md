============================================================
SUB SCRUB - USER INSTRUCTIONS

Depending on how you like to work, there are three ways to get SubScrub running on your machine.

*** IMPORTANT: USE AT YOUR OWN RISK ***

SubScrub moves files within your file system. While it is
designed with multiple safety layers, the author is not
responsible for any data loss or misplaced files.

BACKUP RECOMMENDATIONS:

1. ALWAYS perform a "DRY RUN" (Option 4 in the script)
before committing to a live run.

2. If you are processing a massive library for the first
time, consider cloning your subtitle directory to a
separate drive first.

3. Keep your media server's metadata backup current.

***** OPTION 1: THE STANDALONE EXE (Easiest) *****

This is a single file that has everything bundled together.
No extra files or scripts are needed to run it.

1. DOWNLOAD: Grab "SubScrub.exe" from the latest Release.

2. RUN: Double-click the file.

3. WINDOWS WARNING: Because I'm an independent developer,
Windows might show a "SmartScreen" popup.

	a.Click "More Info"
	b. Click "Run Anyway"

4.FOLLOW THE PROMPTS: The tool will guide you through picking
your media folder and your backup spot.

***** OPTION 2: THE .BAT LAUNCHER (Best for Script Users) 8888

If your antivirus is being grumpy about the EXE, or you just
prefer using the script, use the Batch launcher.

1. SETUP: Make sure "SubScrub.bat" and "SubScrub-v1.1.ps1"
are in the SAME FOLDER.

2. RUN: Double-click "SubScrub.bat".

3. WHY USE THIS?: This batch file automatically tells Windows
to let the PowerShell script run without you having to
change any system security settings manually.

**** OPTION 3: RAW POWERSHELL (.ps1) ****

For the power users who want to run the code directly in their
terminal.

1. Open PowerShell as Administrator.

2. Navigate to your folder: cd "C:\path\to\SubScrub"

3. Run the script: .\SubScrub-v1.1.ps1

	Note: If you get an error saying "scripts are disabled on
	this system," use Option 2 or run:
	Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

============================================================
COMMON QUESTIONS & TROUBLESHOOTING

"Windows says this file is dangerous!"
That's just Windows being overprotective. Since this script
moves files around, Windows flags it. You can audit the code
in the .ps1 file yourself—it's all transparent! Just click
"More Info" followed by "Run Anyway" to bypass the warning.

"It's asking for a 'NuGet provider'?"
If you are running specific PowerShell commands for the first
time, Windows might ask to install NuGet. Just type "Y" and
hit Enter. It's a standard Microsoft tool.

"Can I use network drives?"
Yes! When the tool asks for a path, just type your mapped
drive letter like Z:\Media.

Questions? Issues? Open a ticket on GitHub!
Made by SaaS-Hole-Solutions