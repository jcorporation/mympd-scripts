# yt-dlp

This script extracts the audio links and the associated metadata from an YouTube links and other services with the help of yt-dlp. It appends the result to the MPD queue. On playback MPD calls the script again to get the real streaming uri.

The script was written by [sevmonster](https://github.com/sevmonster) - [Discussion](https://github.com/jcorporation/mympd-scripts/discussions/7).

## Usage

1. Install [yt-dlp](https://github.com/yt-dlp/yt-dlp)
2. Import the script `yt-dlp`
3. Start it from the main menu and copy the YouTube link in URI field.
