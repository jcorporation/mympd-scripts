# Home Widgets

This scripts can be used as the backend for widgets on the home screen. They return a http response with html content that is displayed in the widget.

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

## WidgetStats

Show MPD database statistics.

## WidgetSongs

Lists newest or random songs.

| ARGUMENT | DESCRIPTION |
| -------- | ----------- |
| entries | Number of songs to list. |
| view | `random` or `newest` |
