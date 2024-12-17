# Playcounts

- Create a new trigger
  - Event: `mympd_scrobble`

## TagPlaycounts

Increments Playcounts for tags. This is only supported since MPD 0.24 and only for [some tags](https://mpd.readthedocs.io/en/latest/protocol.html#stickers).

- Use this script as action for the mympd_scrobble event.
- Specify the tags as comma separated list. e.g. `Artist,Album,Composer`
- The Album tag increments the playcount for the AlbumId
