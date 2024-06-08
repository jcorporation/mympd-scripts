# ListenBrainz

## General

- Set your ListenBrainz API token: Scripts -> Variables
  - New variable with key `listenbrainz_token` and your API token as value
- Enable tags in MPD and myMPD:
  - MUSICBRAINZ_ALBUMARTISTID
  - MUSICBRAINZ_ARTISTID
  - MUSICBRAINZ_RELEASETRACKID
  - MUSICBRAINZ_TRACKID

## Scrobbling

You can send your listening habits to ListenBrainz.

- Create a new script
  - Import the `ListenBrainzScrobbler.lua` script
- Create a new trigger
  - Event: `mympd_scrobble`
  - Action: above script

## Feedback

You can send hate/love feedback to ListenBrainz with the thumbs up and down buttons in the playback view.

- Create a new script
  - Import the `ListenBrainzFeedback.lua` script
- Create a new trigger
  - Event: `mympd_feedback`
  - Action: above script
  - Leave the arguments empty

## Set Pin

Sets the pin to the current song or removes the pin if no uri is provided.
