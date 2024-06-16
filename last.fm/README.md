# last.fm

Scrobble tracks, send now playing and feedback from myMPD to last.fm.

## Create variables

| VARIABLE | VALUE |
| -------- | ----- |
| lastfm_api_key | your api key |
| lastfm_secret | your shared secret |
| lastfm_session_key | your session key |

You can use the script `lastfmGetSessionKey.lua` to set the session key. This script asks for your last.fm username and password. Set the variables `lastfm_api_key` and `lastfm_secret` before.

The last.fm APi is available for everyone. You can get your API key and shared secret from: https://www.last.fm/api

## Set triggers for events

| EVENT | SCRIPT |
| ----- | ------ |
| mpd_player | lastfmPlayer |
| mympd_scrobble | lastfmScrobbler |
| mympd_feedback | lastfmFeedback |

***

- Initial version: https://github.com/loop333/mympd_lastfm_scrobbler
- [License](LICENSE)
