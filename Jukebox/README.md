# Jukebox

This scripts can be used to fill the jukebox queue. You must add a trigger for the `mympd_jukebox` event and change the jukebox mode to `Script`.

## Random Playlists

Adds random songs from a random playlist.

## Blissify

Blissify is a program used to make playlists of songs that sound alike from your MPD track library, à la Spotify radio.

This script creates a "seeded" playlist.

1. Install Blissify: https://github.com/Polochon-street/blissify-rs
2. Add a variable `blissify_path` to define the path to your blissify binary.
3. Index your MPD library: `blissify init` - this can take a long time.
4. Clear the queue and play a song from which Blissify should start.
