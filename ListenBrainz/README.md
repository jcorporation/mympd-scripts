# ListenBrainz

## General

- Set your ListenBrainz API token: Scripts -> Variables
  - New variable with key `listenbrainz_token` and your API token as value
- Enable tags in MPD and myMPD:
  - MUSICBRAINZ_ALBUMARTISTID
  - MUSICBRAINZ_ARTISTID
  - MUSICBRAINZ_RELEASETRACKID
  - MUSICBRAINZ_TRACKID

## Feedback

You can send hate/love feedback to ListenBrainz with the thumbs up and down buttons in the playback view.

- Create a new script
  - Import the `ListenBrainzFeedback.lua` script
- Create a new trigger
  - Event: `mympd_feedback`

## Playlist Import

Fetches a list of created playlists for your username.

- Set your ListenBrainz username: Scripts -> Variables
  - New variable with key `listenbrainz_username` and your username as value.
- Import the script.
- Run it manually, it should fetch a list of created playlists and you can select which should be imported.

## Scrobbling

You can send your listening habits to ListenBrainz.

- Create a new script
  - Import the `ListenBrainzScrobbler.lua` script
- Create a new trigger
  - Event: `mympd_scrobble`

## Now Playing

You can send now playing info to ListenBrainz.

- Create a new script
  - Import the `ListenBrainzPlayer.lua` script
- Create a new trigger
  - Event: `mpd_player`

## Set Pin

Sets the pin to the current song or removes the pin if no uri is provided.
