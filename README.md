# 🌙 DeadMoon-Playlist-Transfer-Tool

A zero-setup, single-file Windows polyglot (`Batch` + `Python`) utility for migrating **Deezer Favorites** (Artists, Albums, and Playlists) between accounts via `.CSV` backup, powered by the kinetic **DeadMoon ASCII Animation & Progress Engine**.

## ✨ Key Features
- **Single-File Polyglot Architecture:** Everything runs out of `DeadMoon-Playlist-Transfer-Tool.cmd` — no separate `.py` or `.bat` files required.
- **Portable Auto-Dependency Bootstrapper:** Automatically installs `requests` into a local `./libs` folder on first launch without polluting your global Python environment.
- **Private Profile & Personal Playlist Support:** Uses Deezer's internal `gw-light.php` gateway with automatic playlist-cloning fallback when a personal playlist cannot be directly favorited.
- **Chronological Order Preservation:** Reverses import order so your most recently favorited items stay at the top of your destination account.

## 🚀 Quick Start (Windows 10 / 11)
1. Ensure [Python 3.8+](https://www.python.org/) is installed with **"Add python.exe to PATH"** checked.
2. Download `DeadMoon-Playlist-Transfer-Tool.cmd` into any folder.
3. Double-click **`DeadMoon-Playlist-Transfer-Tool.cmd`**.
4. Grab your `arl` cookie from your browser (`F12` -> **Application** -> **Cookies** -> `https://www.deezer.com` -> copy the value of `arl`).
5. Choose **Option 1** to export your source account to `deezer_favorites.csv`, then **Option 2** to import into your destination account.

## 📜 License
MIT License
