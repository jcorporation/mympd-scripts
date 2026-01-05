# Home Widgets

This scripts can be used as the backend for widgets on the home screen. They return a http response with html content that is displayed in the widget.

## WidgetMostPlayedAlbums

Lists most played albums. You must use the Playcounts script to set album playcounts in the sticker database.

| ARGUMENT | DESCRIPTION |
| -------- | ----------- |
| entries | Number of albums to list. |

## WidgetMostPlayedTag

Lists most played tag. You must use the Playcounts script to set tag playcounts in the sticker database.

| ARGUMENT | DESCRIPTION |
| -------- | ----------- |
| tag | Tagtype, e.g. Artist |
| entries | Number of artists to list. |

## WidgetMostPlayedSongs

Lists most played albums. Song playcounts are always maintained if the sticker database is enabled.

| ARGUMENT | DESCRIPTION |
| -------- | ----------- |
| entries | Number of songs to list. |

## WidgetAlbums

Lists newest or random albums.

| ARGUMENT | DESCRIPTION |
| -------- | ----------- |
| entries | Number of albums to list. |
| view | `random` or `newest` |

## WidgetBatteryIndicator

Reads the battery capacity from the sys filesystem.

| ARGUMENT | DESCRIPTION |
| -------- | ----------- |
| battery | The battery sys folder, e.g. `BAT0` |

## WidgetPlaylists

Lists newest playlists.

| ARGUMENT | DESCRIPTION |
| -------- | ----------- |
| entries | Number of playlists to list. |

## WidgetRaspberryStatus

Uses vcgencmd to get Raspberry Pi status information. The mympd user needs read access to `/dev/vcio`.

## WidgetRaspberryStatusGPIOd

Connects to the REST-API of myGPIOd to read Raspberry Pi status information. Set the argument `mygpiod_uri` to the uri of myGPIOd, default: `http://localhost:8081/api/`.

## WidgetStats

Show MPD database statistics.

## WidgetSongs

Lists newest or random songs.

| ARGUMENT | DESCRIPTION |
| -------- | ----------- |
| entries | Number of songs to list. |
| view | `random` or `newest` |
