# Audioscrobbler

Generic audioscrobbler that implements the Last.fm Submissions Protocol v1.2.1.

- [API Documentation](https://www.last.fm/de/api/submissions)

## Create variables

| VARIABLE | VALUE |
| -------- | ----- |
| scrobbler_username | Username |
| scrobbler_password | Password |
| scrobbler_handshake_uri | Handshake URI |
| scrobble_enforce_https | 1 = Enforce https |

### Handshake URI

- last.fm: `https://post.audioscrobbler.com/`
- libre.fm: `https://turtle.libre.fm/`

### Set triggers for events

| EVENT | SCRIPT | ARGUMENT |
| ----- | ------ | -------- |
| mpd_player | audioscrobbler | trigger = player |
| mympd_scrobble | audioscrobbler | trigger = scrobble |
