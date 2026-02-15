<div align="center">

# SubScrub ✨

**The easiest way to keep your media library subtitle-clean.**
```
  ____        _     ____                  _     
 / ___| _   _| |__ / ___|  ___ _ __ _   _| |__  
 \___ \| | | | '_ \\___ \ / __| '__| | | | '_ \ 
  ___) | |_| | |_) |___) | (__| |  | |_| | |_) |
 |____/ \__,_|_.__/|____/ \___|_|   \__,_|_.__/ 

    Subtitle Management Utility v1.1
```

*Made by SaaS-Hole-Solutions*

</div>

---

## "Wait, why do I need this?" 🤔

If you run a Plex, Jellyfin, or Emby server, you know the struggle. Your movie folders end up cluttered with 50 different subtitle files for languages you don't speak, or three different versions of "English CC."

I built SubScrub to handle the dirty work. It's a simple tool that dives into your library, keeps the languages you actually want, and moves the rest into a backup folder so your main folders stay clean. 🧹

# IMPORTANT
**⚠️ USE AT YOUR OWN RISK ⚠️**
> 
> SubScrub moves files within your file system. While it is designed with multiple safety layers, the author is not responsible for any data loss or misplaced files.
> 
> **BACKUP RECOMMENDATIONS:**
> 1. ALWAYS perform a "DRY RUN" (Option 4 in the script) before committing to a live run.
> 2. If you are processing a massive library for the first time, consider cloning your subtitle directory to a separate drive first.
> 3. Keep your media server's metadata backup current.

## 🚀 What it actually does

* **Keeps your favorites:** By default, it keeps English (`.en`, `.eng`, etc.), but you can tell it to keep whatever you want. 🌍
* **Picks the best file:** If you have `movie.en.srt` and `movie.eng.srt`, it compares them and keeps the bigger (usually better quality) one. 📂
* **Archives, never deletes:** I'm paranoid about losing files, so SubScrub moves unwanted subs to a backup vault. It never hits "delete" on your subtitles. 🛡️
* **Cleans up the trash:** After moving files, it hunts down those annoying empty folders left behind and poofs them. ✨
* **Safety First:** There's a Dry Run mode. Use it to see exactly what would happen before actually moving a single byte. 🚦

## 🛠️ How to get going

### The Easy Way (EXE) ⚡

1. Head over to the [Releases](../../releases) page.
2. Grab `SubScrub.exe`.
3. Double-click it, point it at your media folder, and let it rip.

### The "I Like Code" Way (PowerShell) 💻

1. Download the `SubScrub-v1.1.ps1` and `SubScrub.bat` files.
2. Drop them in a folder and run the `.bat` file.
3. (The batch file is just a shortcut that gets around those annoying Windows "script blocked" errors).

## 📝 A few quick tips

* **Mapped Drives:** Works great with `Z:\` or other network drives. Just type the path when it asks.
* **SmartScreen:** Since I'm just a person making scripts and not a multi-billion dollar company, Windows might say the EXE is "unrecognized." Just click "More Info" → "Run Anyway." It's safe, I promise! 🤝
* **Logs:** It saves a log of everything it moved in the backup folder, and it can even toss a CSV report on your desktop if you're into that kind of thing. 📈

---

<div align="center">

## ⚖️ License

Distributed under the MIT License.

Made by **SaaS-Hole-Solutions** for the self-hosted community. Enjoy! 🎬

</div>
