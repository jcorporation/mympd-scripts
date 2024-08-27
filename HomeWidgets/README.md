# Home Widgets

This scripts can be used as the backend for widgets on the home screen. They return a http response with html content that is displayed in the widget.

## AlbumsWidget

Lists newest or random albums.

| ARGUMENT | DESCRIPTION |
| -------- | ----------- |
| entries | Number of albums to list. |
| view | `random` or `newest` |

## BatteryIndicatorWidget

Reads the battery capacity from the sys filesystem.

| ARGUMENT | DESCRIPTION |
| -------- | ----------- |
| battery | The battery sys folder, e.g. `BAT0` |

## SongsWidget

Lists newest or random songs.

| ARGUMENT | DESCRIPTION |
| -------- | ----------- |
| entries | Number of songs to list. |
| view | `random` or `newest` |
