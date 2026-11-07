rem = r"""
@echo off
setlocal EnableDelayedExpansion
title DeadMoon Playlist Transfer Tool
cd /d "%~dp0"
cls

:: Enable ANSI escape sequences in Windows Console
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"

echo.
echo   %ESC%[95m============================================================================%ESC%[0m
echo     %ESC%[1;97mD E A D M O O N   P L A Y L I S T   T R A N S F E R   T O O L%ESC%[0m
echo   %ESC%[95m============================================================================%ESC%[0m
echo.

:: 1. Verify Python is installed
echo   %ESC%[96m[Boot]%ESC%[0m Checking Python runtime environment...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo   %ESC%[91m[ERROR] Python is not installed or not added to your system PATH.%ESC%[0m
    echo   %ESC%[93mPlease install Python from https://www.python.org/ and check "Add python.exe to PATH".%ESC%[0m
    echo.
    pause
    exit /b 1
)

:: 2. Point Python to the local 'libs' folder next to this .cmd file
set "LOCAL_LIBS=%~dp0libs"
set "PYTHONPATH=%LOCAL_LIBS%"

:: 3. Auto-install 'requests' locally if missing
if not exist "%LOCAL_LIBS%\requests" (
    echo   %ESC%[93m[Setup]%ESC%[0m Downloading required 'requests' library into local 'libs' folder...
    python -m pip install --target "%LOCAL_LIBS%" --no-warn-script-location requests
    if !errorlevel! neq 0 (
        echo.
        echo   %ESC%[91m[ERROR] Failed to install 'requests'. Check your internet connection.%ESC%[0m
        pause
        exit /b 1
    )
    echo   %ESC%[92m[OK]%ESC%[0m Local dependencies ready.
)

:: 4. Hand off execution to the embedded Python engine in this same file
python "%~f0" %*

echo.
echo   %ESC%[90mSession terminated. Press any key to close this window...%ESC%[0m
pause >nul
exit /b 0
"""

import csv
import ctypes
import os
import sys
import time
from collections import deque

# Ensure local 'libs' directory is on sys.path even if invoked directly via python
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
LOCAL_LIBS = os.path.join(SCRIPT_DIR, "libs")
if os.path.isdir(LOCAL_LIBS) and LOCAL_LIBS not in sys.path:
    sys.path.insert(0, LOCAL_LIBS)

import requests

# ============================================================================
# ANSI COLOR PALETTE & WINDOWS VT100 INITIALIZATION
# ============================================================================
class C:
    reset  = "\x1b[0m"
    bold   = "\x1b[1m"
    dim    = "\x1b[2m"
    red    = "\x1b[91m"
    green  = "\x1b[92m"
    yellow = "\x1b[93m"
    blue   = "\x1b[94m"
    purple = "\x1b[95m"
    cyan   = "\x1b[96m"
    white  = "\x1b[97m"
    gray   = "\x1b[90m"


def enable_windows_ansi():
    """Enables VT100 escape sequences in Windows 10/11 Command Prompt."""
    if os.name == "nt":
        os.system("")
        try:
            kernel32 = ctypes.windll.kernel32
            handle = kernel32.GetStdHandle(-11)  # STD_OUTPUT_HANDLE
            mode = ctypes.c_ulong()
            if kernel32.GetConsoleMode(handle, ctypes.byref(mode)):
                kernel32.SetConsoleMode(handle, mode.value | 0x0004)
        except Exception:
            pass


# ============================================================================
# DEADMOON KINETIC ASCII ART & PROGRESS ENGINE
# ============================================================================
def get_moon_frame(frame_idx):
    """Generates one frame of the 4-phase pulsing DeadMoon ASCII animation."""
    f = frame_idx % 4

    n_col1 = C.yellow if f % 2 == 0 else C.cyan
    n_col2 = C.purple if f % 2 == 0 else C.yellow
    s1 = "*" if f == 0 else ("+" if f == 1 else ("." if f == 2 else "+"))
    s2 = "." if f == 0 else ("*" if f == 1 else ("+" if f == 2 else "."))

    top_note_l = f"{n_col1}d~~b{C.reset}" if f in (1, 2) else "    "
    mid_note_l = f"{n_col1}d  b{C.reset}" if f in (1, 2) else f"{n_col1}d~~b{C.reset}"
    bot_note_l = "    " if f in (1, 2) else f"{n_col1}d  b{C.reset}"

    top_note_r = f"{n_col2}d~~b{C.reset}" if f in (2, 3) else "    "
    mid_note_r = f"{n_col2}d  b{C.reset}" if f in (2, 3) else f"{n_col2}d~~b{C.reset}"
    bot_note_r = "    " if f in (2, 3) else f"{n_col2}d  b{C.reset}"

    low_note1 = f"{n_col1}d~b{C.reset}" if f in (0, 3) else "   "
    low_note2 = f"{n_col1}d b{C.reset}" if f in (0, 3) else f"{n_col2}d~b{C.reset}"
    low_note3 = "   " if f in (0, 3) else f"{n_col2}d b{C.reset}"

    wave_l = " .--- " if f == 0 else ("(( .--" if f == 1 else ("((( .-" if f == 2 else " ( .--"))
    wave_r = " ---. " if f == 0 else ("--. ))" if f == 1 else ("-. )))" if f == 2 else "--. ) "))
    mid_wave_l = "((    " if f in (1, 2) else " (    "
    mid_wave_r = "    ))" if f in (1, 2) else "    ) "

    eyes = r"\____/    \____/"
    mouth = " .----. " if f == 2 else "  .---. "

    lines = [
        f"      {C.cyan}{s1}   {top_note_l}  {s2}{C.reset}        {C.blue}.================.{C.reset}        {C.cyan}{s2}   {top_note_r}   {s1}{C.reset}",
        f"   {C.cyan}{s2}    {mid_note_l}{C.reset}      {C.blue}.==='  {C.yellow}.------------.{C.blue}  '===.{C.reset}      {mid_note_r}     {C.cyan}{s2}{C.reset}",
        f"      {C.cyan}{s1} {bot_note_l}{C.reset}    {C.blue}/   {C.yellow}.-'    .      o    '-'{C.blue}   \\{C.reset}     {bot_note_r}   {C.cyan}{s1}{C.reset}",
        f"               {C.blue}/  {C.yellow}.'   o       .      .   '.{C.blue}  \\{C.reset}        {C.cyan}{s2}{C.reset}",
        f"    {C.cyan}{s1}{C.reset}         {C.blue}[===]{C.yellow}  .    {C.white}/        \\{C.yellow}    .  {C.blue}[===]{C.reset}   {C.cyan}{s2}       {s1}{C.reset}",
        f"        {C.blue}{wave_l}[===]{C.yellow}     {C.white}{eyes}{C.yellow}   {C.blue}[===]{wave_r}{C.reset}   {low_note1}",
        f"        {C.blue}{mid_wave_l}[===]{C.yellow}   o     {C.white}{mouth}{C.yellow}     O {C.blue}[===]{mid_wave_r}{C.reset}   {low_note2}",
        f"    {C.cyan}{s2}{C.reset}   {C.blue} '--- [===]{C.yellow}    .    {C.white}/      \\{C.yellow}   .   {C.blue}[===] ---' {C.reset}   {low_note3}",
        f"       {C.cyan}{s1}{C.reset}       {C.blue}\\  {C.yellow}'.     .            o  .'{C.blue}  /{C.reset}       {C.cyan}{s1}{C.reset}",
        f"    {C.cyan}{s2}{C.reset}           {C.blue}'.  {C.yellow}'-.    o   .   .  .-'{C.blue}  .'{C.reset}     {C.cyan}{s2}       {s1}{C.reset}",
        f"         {C.cyan}{s1}{C.reset}        {C.blue}'===='{C.yellow}--------------{C.blue}'===='{C.reset}          {C.cyan}{s2}{C.reset}",
    ]
    return "\n".join(lines)


def render_header(frame_idx, subtitle="D E A D M O O N   P L A Y L I S T   T R A N S F E R   T O O L"):
    """Builds the top frame string with the animated moon and title banner."""
    return (
        "\x1b[H\n"
        + get_moon_frame(frame_idx)
        + "\n\n"
        + f"  {C.purple}============================================================================{C.reset}\n"
        + f"    {C.bold}{C.white}{subtitle}{C.reset}\n"
        + f"  {C.purple}============================================================================{C.reset}\n"
    )


def run_boot_animation():
    """Plays the 12-frame kinetic boot splash animation."""
    stages = [
        {"pct": 25,  "bar": "###---------", "color": C.yellow, "text": "Tuning frequencies...      "},
        {"pct": 50,  "bar": "######------", "color": C.cyan,   "text": "Loading probability bank..."},
        {"pct": 75,  "bar": "#########---", "color": C.purple, "text": "Syncing Deezer gateways... "},
        {"pct": 100, "bar": "############", "color": C.green,  "text": "Ready.                     "},
    ]

    sys.stdout.write("\x1b[2J\x1b[H\x1b[?25l")
    sys.stdout.flush()
    try:
        for i in range(12):
            st = stages[min(i // 3, 3)]
            frame = (
                render_header(i)
                + "\n"
                + f"    {st['color']}[Moonlight Engine] {C.white}{st['text']} "
                + f"{st['color']}[{st['bar']}] {st['pct']:>3}%{C.reset}   \n"
            )
            sys.stdout.write(frame)
            sys.stdout.flush()
            time.sleep(0.15)
    finally:
        sys.stdout.write("\x1b[?25h")
        sys.stdout.flush()


def draw_kinetic_hud(frame_idx, phase_title, current, total, status_line, log_buffer):
    """Redraws the pulsing DeadMoon art, progress bar, and rolling log in place."""
    pct = int((current / total) * 100) if total > 0 else 100
    filled = int((pct / 100) * 20)
    bar = ("#" * filled) + ("-" * (20 - filled))
    bar_color = C.green if pct == 100 else (C.cyan if frame_idx % 2 == 0 else C.purple)

    out = [
        render_header(frame_idx),
        f"  {C.bold}{C.cyan}>> {phase_title}{C.reset}\x1b[K",
        f"  {bar_color}[{bar}] {pct:>3}% ({current}/{total}){C.reset}  {C.white}{status_line[:42]:<42}{C.reset}\x1b[K",
        f"  {C.gray}----------------------------------------------------------------------------{C.reset}\x1b[K",
    ]
    for line in log_buffer:
        out.append(f"  {line}\x1b[K")
    for _ in range(max(0, 6 - len(log_buffer))):
        out.append("\x1b[K")

    sys.stdout.write("\n".join(out) + "\n")
    sys.stdout.flush()


# ============================================================================
# DEEZER API ENGINE
# ============================================================================
GW_URL = "https://www.deezer.com/ajax/gw-light.php"
PUBLIC_API_URL = "https://api.deezer.com"
DEFAULT_CSV = "deezer_favorites.csv"


def gw_call(session, method, api_token="null", payload=None):
    """Calls Deezer's internal gw-light.php endpoint."""
    params = {
        "method": method,
        "input": "3",
        "api_version": "1.0",
        "api_token": api_token,
    }
    resp = session.post(GW_URL, params=params, json=payload or {}, timeout=20)
    resp.raise_for_status()
    return resp.json()


def create_authenticated_session(arl):
    """Creates an authenticated session from a Deezer ARL cookie token."""
    session = requests.Session()
    session.cookies.set("arl", arl.strip(), domain=".deezer.com")
    session.headers.update({
        "User-Agent": (
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
            "AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/131.0.0.0 Safari/537.36"
        )
    })

    data = gw_call(session, "deezer.getUserData")
    results = data.get("results", {})
    user = results.get("USER", {})
    user_id = user.get("USER_ID", 0)

    if not user_id or int(user_id) == 0:
        raise ValueError("Invalid or expired ARL token. Check your cookie and try again.")

    username = user.get("BLOG_NAME", "DeezerUser")
    api_token = results.get("checkForm")
    return session, str(user_id), username, api_token


def fetch_tab_items(session, user_id, api_token, tab_name):
    """Fetches items from a profile tab ('artists', 'albums', or 'playlists')."""
    payload = {
        "USER_ID": user_id,
        "tab": tab_name,
        "nb": 10000,
    }
    res = gw_call(session, "deezer.pageProfile", api_token=api_token, payload=payload)
    tab_data = res.get("results", {}).get("TAB", {}).get(tab_name, {}).get("data", [])

    if tab_data:
        return tab_data, "gw"

    items = []
    url = f"{PUBLIC_API_URL}/user/{user_id}/{tab_name}?limit=100"
    while url:
        r = session.get(url, timeout=20).json()
        if "data" in r:
            items.extend(r["data"])
        url = r.get("next")
    return items, "public"


def clone_playlist_fallback(session, api_token, playlist_id, title):
    """Clones a playlist into a new playlist on the destination account if direct favoriting fails."""
    public_pl = session.get(f"{PUBLIC_API_URL}/playlist/{playlist_id}", timeout=20).json()
    tracks_data = public_pl.get("tracks", {}).get("data", [])
    track_ids = [str(t["id"]) for t in tracks_data if "id" in t]

    create_payload = {
        "title": title or f"Imported Playlist {playlist_id}",
        "description": f"Imported via DeadMoon Playlist Transfer Tool (Source ID: {playlist_id})",
        "status": 0,
        "songs": [[int(tid), 0] for tid in track_ids],
    }
    res = gw_call(session, "playlist.create", api_token=api_token, payload=create_payload)
    if res.get("error"):
        return False, str(res["error"])
    return True, f"Cloned ({len(track_ids)} tracks)"


# ============================================================================
# WORKFLOWS: EXPORT & IMPORT WITH KINETIC ANIMATION
# ============================================================================
def export_favorites():
    """Option 1: Export all favorited artists, albums, and playlists to CSV."""
    print(f"\n  {C.purple}--- EXPORT FAVORITES TO CSV ---{C.reset}")
    arl = input(f"  {C.cyan}Enter SOURCE Deezer ARL token:{C.reset} ").strip()
    if not arl:
        print(f"  {C.red}[!] ARL token cannot be empty.{C.reset}")
        return

    csv_path = input(f"  {C.cyan}Output CSV filename [{DEFAULT_CSV}]:{C.reset} ").strip() or DEFAULT_CSV
    if not csv_path.lower().endswith(".csv"):
        csv_path += ".csv"

    try:
        print(f"  {C.yellow}[*] Authenticating with Deezer...{C.reset}")
        session, user_id, username, api_token = create_authenticated_session(arl)
    except Exception as e:
        print(f"  {C.red}[ERROR] Authentication failed: {e}{C.reset}")
        return

    log_buffer = deque(maxlen=6)
    log_buffer.append(f"{C.green}[AUTH]{C.reset} Logged in as {C.bold}{username}{C.reset} (ID: {user_id})")
    rows = []
    frame = 0

    sys.stdout.write("\x1b[2J\x1b[H\x1b[?25l")
    try:
        # Step 1: Artists
        draw_kinetic_hud(frame, "EXPORTING DEEZER PROFILE", 1, 4, "Scanning favorited artists...", log_buffer)
        frame += 1
        artists, src = fetch_tab_items(session, user_id, api_token, "artists")
        for item in artists:
            art_id = item.get("ART_ID") if src == "gw" else item.get("id")
            name = item.get("ART_NAME") if src == "gw" else item.get("name")
            if art_id:
                rows.append(["artist", str(art_id), name or "", ""])
        log_buffer.append(f"{C.cyan}[ARTISTS]{C.reset} Pulled {C.bold}{len(artists)}{C.reset} favorited artists.")

        # Step 2: Albums
        draw_kinetic_hud(frame, "EXPORTING DEEZER PROFILE", 2, 4, "Scanning favorited albums...", log_buffer)
        frame += 1
        albums, src = fetch_tab_items(session, user_id, api_token, "albums")
        for item in albums:
            alb_id = item.get("ALB_ID") if src == "gw" else item.get("id")
            title = item.get("ALB_TITLE") if src == "gw" else item.get("title")
            artist = item.get("ART_NAME") if src == "gw" else item.get("artist", {}).get("name", "")
            if alb_id:
                rows.append(["album", str(alb_id), title or "", artist or ""])
        log_buffer.append(f"{C.yellow}[ALBUMS]{C.reset}  Pulled {C.bold}{len(albums)}{C.reset} favorited albums.")

        # Step 3: Playlists
        draw_kinetic_hud(frame, "EXPORTING DEEZER PROFILE", 3, 4, "Scanning playlists...", log_buffer)
        frame += 1
        playlists, src = fetch_tab_items(session, user_id, api_token, "playlists")
        playlist_count = 0
        for item in playlists:
            if src == "gw":
                if str(item.get("TYPE")) == "4":
                    continue
                pl_id = item.get("PLAYLIST_ID")
                title = item.get("TITLE")
                creator = item.get("PARENT_USERNAME", "")
            else:
                if item.get("is_loved_track"):
                    continue
                pl_id = item.get("id")
                title = item.get("title")
                creator = item.get("creator", {}).get("name", "")

            if pl_id:
                rows.append(["playlist", str(pl_id), title or "", creator or ""])
                playlist_count += 1
        log_buffer.append(f"{C.purple}[PLAYLISTS]{C.reset} Pulled {C.bold}{playlist_count}{C.reset} playlists.")

        # Step 4: Write CSV
        with open(csv_path, mode="w", newline="", encoding="utf-8-sig") as f:
            writer = csv.writer(f)
            writer.writerow(["type", "id", "name", "extra_info"])
            writer.writerows(rows)

        log_buffer.append(f"{C.green}[SAVED]{C.reset} Wrote {len(rows)} items -> {os.path.abspath(csv_path)}")
        for _ in range(4):
            draw_kinetic_hud(frame, "EXPORT COMPLETE", 4, 4, f"Saved {len(rows)} total items!", log_buffer)
            frame += 1
            time.sleep(0.15)
    except Exception as e:
        print(f"\n  {C.red}[ERROR] Export failed: {e}{C.reset}")
    finally:
        sys.stdout.write("\x1b[?25h")
        sys.stdout.flush()

    input(f"\n  {C.gray}Press Enter to return to the DeadMoon menu...{C.reset}")


def import_favorites():
    """Option 2: Import all artists, albums, and playlists from CSV into a target account."""
    print(f"\n  {C.purple}--- IMPORT FAVORITES FROM CSV ---{C.reset}")
    arl = input(f"  {C.cyan}Enter DESTINATION Deezer ARL token:{C.reset} ").strip()
    if not arl:
        print(f"  {C.red}[!] ARL token cannot be empty.{C.reset}")
        return

    csv_path = input(f"  {C.cyan}Input CSV filename [{DEFAULT_CSV}]:{C.reset} ").strip() or DEFAULT_CSV
    if not os.path.isfile(csv_path):
        print(f"  {C.red}[!] File not found: '{csv_path}'{C.reset}")
        return

    try:
        print(f"  {C.yellow}[*] Authenticating with destination Deezer account...{C.reset}")
        session, user_id, username, api_token = create_authenticated_session(arl)
    except Exception as e:
        print(f"  {C.red}[ERROR] Authentication failed: {e}{C.reset}")
        return

    items = []
    with open(csv_path, mode="r", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row.get("type") and row.get("id"):
                items.append(row)

    if not items:
        print(f"  {C.red}[!] No valid items found in '{csv_path}'.{C.reset}")
        return

    # Reverse so most recently favorited items on Account A end up at the top on Account B
    items.reverse()
    total = len(items)
    success_count = 0
    fail_count = 0
    log_buffer = deque(maxlen=6)
    log_buffer.append(f"{C.green}[AUTH]{C.reset} Target: {C.bold}{username}{C.reset} (ID: {user_id}) — {total} items queued")

    sys.stdout.write("\x1b[2J\x1b[H\x1b[?25l")
    try:
        for idx, item in enumerate(items, 1):
            item_type = item["type"].strip().lower()
            item_id = item["id"].strip()
            name = item.get("name", item_id) or item_id

            draw_kinetic_hud(
                idx,
                f"IMPORTING TO {username.upper()}",
                idx,
                total,
                f"Syncing {item_type}: {name}",
                log_buffer,
            )

            try:
                if item_type == "artist":
                    res = gw_call(
                        session,
                        "artist.addFavorite",
                        api_token=api_token,
                        payload={"ART_ID": str(item_id)},
                    )
                elif item_type == "album":
                    res = gw_call(
                        session,
                        "album.addFavorite",
                        api_token=api_token,
                        payload={"ALB_ID": str(item_id)},
                    )
                elif item_type == "playlist":
                    res = gw_call(
                        session,
                        "playlist.addFavorite",
                        api_token=api_token,
                        payload={"PARENT_PLAYLIST_ID": int(item_id)},
                    )
                    if res.get("error"):
                        ok, msg = clone_playlist_fallback(session, api_token, item_id, name)
                        if ok:
                            log_buffer.append(f"{C.purple}[CLONED]{C.reset} {name[:35]} -> {msg}")
                            success_count += 1
                            time.sleep(0.15)
                            continue
                else:
                    log_buffer.append(f"{C.yellow}[SKIP]{C.reset} Unknown type '{item_type}' ({name[:30]})")
                    continue

                if res.get("error"):
                    log_buffer.append(f"{C.red}[ERR]{C.reset} {item_type.upper()} {name[:30]}: {res['error']}")
                    fail_count += 1
                else:
                    log_buffer.append(f"{C.green}[OK]{C.reset} Added {item_type}: {C.white}{name[:40]}{C.reset}")
                    success_count += 1

            except Exception as e:
                log_buffer.append(f"{C.red}[EXC]{C.reset} {item_type.upper()} {name[:28]}: {e}")
                fail_count += 1

            time.sleep(0.15)

        log_buffer.append(
            f"{C.bold}{C.green}[DONE]{C.reset} Succeeded: {C.green}{success_count}{C.reset} | Failed: {C.red}{fail_count}{C.reset}"
        )
        draw_kinetic_hud(total + 1, "IMPORT COMPLETE", total, total, "All queued items processed.", log_buffer)
    finally:
        sys.stdout.write("\x1b[?25h")
        sys.stdout.flush()

    input(f"\n  {C.gray}Press Enter to return to the DeadMoon menu...{C.reset}")


# ============================================================================
# INTERACTIVE MAIN MENU
# ============================================================================
def main():
    enable_windows_ansi()
    run_boot_animation()
    menu_frame = 0

    while True:
        sys.stdout.write("\x1b[2J\x1b[H")
        sys.stdout.write(render_header(menu_frame))
        menu_frame += 1
        print(f"    {C.cyan}1.{C.reset} {C.white}Export Favorites (Artists, Albums, Playlists) to .CSV{C.reset}")
        print(f"    {C.purple}2.{C.reset} {C.white}Import Favorites from .CSV to Deezer Account{C.reset}")
        print(f"    {C.yellow}3.{C.reset} {C.white}Replay DeadMoon Kinetic Splash Animation{C.reset}")
        print(f"    {C.red}4.{C.reset} {C.white}Exit{C.reset}")
        print(f"\n  {C.purple}============================================================================{C.reset}")

        try:
            choice = input(f"\n  {C.bold}{C.cyan}Select an option (1-4):{C.reset} ").strip()
        except (EOFError, KeyboardInterrupt):
            print(f"\n  {C.yellow}Signing off from the DeadMoon relay. Goodbye!{C.reset}")
            sys.exit(0)

        if choice == "1":
            export_favorites()
        elif choice == "2":
            import_favorites()
        elif choice == "3":
            run_boot_animation()
        elif choice == "4":
            print(f"\n  {C.green}Signing off from the DeadMoon relay. Goodbye!{C.reset}")
            sys.exit(0)
        else:
            print(f"\n  {C.red}[!] Invalid selection. Choose 1, 2, 3, or 4.{C.reset}")
            time.sleep(1)


if __name__ == "__main__":
    main()
