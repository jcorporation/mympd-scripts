# last.fm

Scrobble tracks from myMPD to last.fm.

Tested on Debian 13, you need to install MD5 library:

```sh
sudo apt-get install lua-md5
```

Import `lastfm_lib.lua` as `lastfm_lib`.

## Create variables

| VARIABLE | VALUE |
| -------- | ----- |
| lastfm_api_key | your api key |
| lastfm_secret | your secret |
| lastfm_session_key | your session key |

You can use the script `lastfm_get_session_key.lua` to get the session key. This script asks for your last.fm username and password. Set the variables `lastfm_api_key` and `lastfm_secret` before.

## Set triggers for events

| EVENT | SCRIPT |
| ----- | ------ |
| Player | lastfm_player |
| Scrobble | lastfm_scrobble |
| Feedback | lastfm_feedback |

***

- Initial version: https://github.com/loop333/mympd_lastfm_scrobbler
- [License](LICENSE)
