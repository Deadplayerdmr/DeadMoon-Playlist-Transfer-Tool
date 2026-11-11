<div align="center">

# 🌕 DeadMoon-Playlist-Transfer-Tool 🌙

**Zero-Setup Single-File Windows Polyglot Utility for Migrating Deezer Favorites (Artists, Albums & Playlists) Between Accounts via CSV**

[![DeadMoon Suite](https://img.shields.io/badge/🌕_DeadMoon-Tool_Suite-111827?style=for-the-badge&labelColor=000000)](https://github.com/Deadplayerdmr/)
[![Platform](https://img.shields.io/badge/Platform-Windows_10_%7C_11-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![Python 3.8+](https://img.shields.io/badge/Python-3.8+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Deezer API](https://img.shields.io/badge/Deezer-gw--light_API-A238FF?style=for-the-badge)](https://www.deezer.com/)
[![License](https://img.shields.io/badge/License-MIT-10B981?style=for-the-badge)](LICENSE)

*Part of the [DeadMoon Tool Suite](https://github.com/Deadplayerdmr/) by [@Deadplayerdmr](https://github.com/Deadplayerdmr)*

</div>

---

## 🖥️ Terminal Preview

```text
          .       +        .================.        *        .
       +    d~~b      .==='  .------------.  '===.      d~~b     .
          . d  b    /   .-'    .      o    '-.   \     d  b   +
                   /  .'   o       .      .   '.  \        .
        *         [===]  .    /        \    .  [===]   +       *
             .--- [===]     \____/    \____/   [===] ---.
            (     [===]   o      .----.      O [===]     )   d~b
        .    '--- [===]    .    /      \   .   [===] ---'    d b
           +       \  '.     .            o  .'  /       *
        .           '.  '-.    o   .   .  .-'  .'     .       +
             *        '===='--------------'===='          .
```

---

## 🌙 Overview

**DeadMoon-Playlist-Transfer-Tool** is a zero-setup, single-file Windows polyglot (`Batch` + `Python`) utility for backing up and migrating **Deezer Favorites** (Artists, Albums, and Playlists) between Deezer accounts via a portable `.CSV` archive, powered by the kinetic **DeadMoon ASCII Animation & HUD Progress Engine**.

---

## ✨ Key Features

- **📦 Single-File Polyglot Architecture**: Everything runs out of `DeadMoon-Playlist-Transfer-Tool.cmd` — no separate `.py` or `.bat` files required.
- **🚀 Portable Auto-Dependency Bootstrapper**: Automatically installs `requests` into a local `./libs` folder on first launch without polluting your global Python environment.
- **🔄 Private Profile & Personal Playlist Cloning Fallback**: Uses Deezer's internal `gw-light.php` gateway with automatic playlist-cloning (`playlist.create`) fallback when a personal or private playlist cannot be directly favorited.
- **⏱️ Chronological Order Preservation**: Automatically reverses import order so your most recently favorited items on your source account stay at the very top of your destination account.
- **🌕 Kinetic HUD Progress Engine**: Live in-place terminal dashboard displaying the pulsing DeadMoon crest, percentage progress bar, and rolling status log during export and import runs.

---

## 🚀 Quick Start (Windows 10 / 11)

1. Ensure [Python 3.8+](https://www.python.org/) is installed with **"Add python.exe to PATH"** checked.
2. Download **`DeadMoon-Playlist-Transfer-Tool.cmd`** into any folder.
3. Double-click **`DeadMoon-Playlist-Transfer-Tool.cmd`**.
4. Grab your `arl` cookie from your browser (`F12` → **Application** → **Cookies** → `https://www.deezer.com` → copy the value of `arl`).
5. Choose **Option `1`** to export your source account to `deezer_favorites.csv`, then **Option `2`** to import into your destination account.

---

## 🎛️ Interactive Menu Options

| Option | Action | Description |
| :---: | :--- | :--- |
| **`1`** | **Export Favorites to `.CSV`** | Scans your source Deezer account via ARL and exports all favorited Artists, Albums, and Playlists to `deezer_favorites.csv` |
| **`2`** | **Import Favorites from `.CSV`** | Reads `deezer_favorites.csv` and syncs all items into your destination Deezer account in chronological order |
| **`3`** | **Replay Kinetic Splash** | Replays the 12-frame `[Moonlight Engine]` boot animation |
| **`4`** | **Exit** | Cleanly closes the session |

---

## 📄 License

Distributed under the [MIT License](LICENSE).

---

## 🌌 The DeadMoon Tool Suite

| Repository | Role in the Ecosystem |
| :--- | :--- |
| 🌕 **[DeadMoon-Download-Bot](https://github.com/Deadplayerdmr/DeadMoon-Download-Bot)** | Whitelisted 8-platform Telegram audio acquisition bot with direct lossless engines, lock-free scheduler & 477 offline tests |
| 📻 **[DeadMoon-Telegram-Broadcaster-Bot](https://github.com/Deadplayerdmr/DeadMoon-Telegram-Broadcaster-Bot)** | 24/7 automated Telegram-to-Icecast radio broadcaster with smooth 22% audio-ducked ads, `/replaytrack` & fallback rotation |
| 🌾 **[DeadMoon-Credential-Harvester](https://github.com/Deadplayerdmr/DeadMoon-Credential-Harvester)** | Local Tampermonkey userscript (`2.3v`) for harvesting streaming ARLs, OAuth tokens, Netscape cookies & Widevine `.wvd` bundles |
| 🔐 **[DeadMoon-Unified-Spotify-Provisioner](https://github.com/Deadplayerdmr/DeadMoon-Unified-Spotify-Provisioner)** | Automated Windows polyglot provisioner for Spotify Premium `sp_dc` cookies & Android Widevine L3 `device.wvd` CDMs |
| 🎶 **[DeadMoon-Playlist-Transfer-Tool](https://github.com/Deadplayerdmr/DeadMoon-Playlist-Transfer-Tool)** | Single-file Windows polyglot tool for migrating Deezer Favorites (Artists, Albums & Playlists) via CSV |
| 🤖 **[DeadMoon-OpenHands-Launcher](https://github.com/Deadplayerdmr/DeadMoon-OpenHands-Launcher)** | Zero-friction Windows launcher & installer for OpenHands with kinetic ASCII UI & automatic `winnat` port recovery |
| 🔍 **[DeadMoon-Universal-API-Verify-Script](https://github.com/Deadplayerdmr/DeadMoon-Universal-API-Verify-Script)** | Self-contained Windows LLM statistical fingerprint verifier (`lmfpd`) with Smart Auto-Heal & catalog scanner |

---

<div align="center">

**🌕 DeadMoon-Playlist-Transfer-Tool 🌙** — Crafted by [@Deadplayerdmr](https://github.com/Deadplayerdmr/)

</div>
