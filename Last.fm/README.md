# last.fm

Scrobble tracks, send now playing and feedback from myMPD to last.fm.

## Create variables

| VARIABLE | VALUE |
| -------- | ----- |
| lastfm_api_key | your api key |
| lastfm_secret | your shared secret |
| lastfm_session_key | your session key |
| scrobble_genre_blacklist | Comma separated list of genres that should not be scrobbled. |

You can use the script `lastfm.lua` with the trigger argument set to `key` to fetch and set the session key. It will asks for your last.fm username and password. Set the variables `lastfm_api_key` and `lastfm_secret` before.

The last.fm APi is available for everyone. You can get your API key and shared secret from: https://www.last.fm/api

## Set triggers for events

| EVENT | SCRIPT | ARGUMENT |
| ----- | ------ | -------- |
| mpd_player | lastfm | trigger = player |
| mympd_scrobble | lastfm | trigger = scrobble |
| mympd_feedback | lastfm | trigger = feedback |

***

- Initial version: https://github.com/loop333/mympd_lastfm_scrobbler
- [License](LICENSE)
