# Album Detail Widgets

This scripts can be used as the backend for widgets in the album detail view. They return a http response with html content that is displayed in the widget.

This scripts are called with following arguments that are referencing the currently displayed album.

- AlbumId
- Album
- AlbumArtist
- MUSICBRAINZ_RELEASEGROUPID
- MUSICBRAINZ_ALBUMID

## WidgetAlbumDetail

Get's the album details from various providers. Currently implemented providers are:

- [TheAudioDB](https://www.theaudiodb.com) - Free API
- [Last.fm](https://www.last.fm/) - API key required. You can get your API key and shared secret from: [https://www.last.fm/api](https://www.last.fm/api)

### Used variables

| VARIABLE | VALUE |
| -------- | ----- |
| lastfm_api_key | your api key |
