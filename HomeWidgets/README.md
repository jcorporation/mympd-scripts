# Home Widgets

This scripts can be used as the backend for widgets on the home screen.

This scripts return a http reply with html content that is displayed in the widget. JavaScript functions can be called with the `data-href` attribute. Styling is done with [Bootstrap](https://getbootstrap.com/docs/5.3/getting-started/introduction/).

| WIDGET | DESCRIPTION |
| ------ | ----------- |
| BatteryIndicator | Shows the battery level. |
| NewestAlbums | Shows newest albums, by Added timestamp. |

## BatteryIndicator

Reads the battery capacity from the sys filesystem.

| ARGUMENT | DESCRIPTION |
| -------- | ----------- |
| battery | The battery sys folder, e.g. `BAT0` |