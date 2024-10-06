# libre.fm

Scrobble tracks, send now playing and feedback from myMPD to libre.fm, using the Scrobbling API from last.fm.

## Create variables

| VARIABLE | VALUE |
| -------- | ----- |
| librefm_session_key | your session key |

You can use the script `librefm` with the trigger argument set to `key` to fetch and set the session key. It will asks for your last.fm username and password.

## Set triggers for events

| EVENT | SCRIPT | ARGUMENT |
| ----- | ------ | -------- |
| mpd_player | librefm | trigger = player |
| mympd_scrobble | librefm | trigger = scrobble |
| mympd_feedback | librefm | trigger = feedback |
