# Jukebox

This scripts can be used to extend the jukebox function of myMPD. You must add a trigger for the `mympd_jukebox` event and change the jukebox mode to `Script`.

## JukeboxBlissify

Blissify is a program used to make playlists of songs that sound alike from your MPD track library, à la Spotify radio.

1. Install [Blissify](https://github.com/Polochon-street/blissify-rs)
2. Index your MPD library: `blissify init` - this can take a long time.
3. Add the variable `blissify_path` to define the path to your blissify binary.
4. Optional: Add the variable `blissify_config` to specify the blissify configuration file.
5. Clear the queue and play a song from which Blissify should start.

| ARGUMENT | DESCRIPTION |
| -------- | ----------- |
| addToQueue | Set it to `1` to add songs directly to the MPD queue and not into the jukebox queue. |

## JukeboxRandomPlaylist

Adds random songs from a random playlist.
