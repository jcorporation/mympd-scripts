# Lyrics

Here can you find scripts to get lyrics from an external lyrics provider.

## Generic lyrics fetcher

This script is inspired by the [MusicBee Lyrics Reloaded Plugin](https://www.getmusicbee.com/addons/plugins/467/lyrics-reloaded-latest/).

It uses a generic script that is configured by a provider configuration file.

The workflow is:

1. Normalizes the artist and title with the provided `artist_filter` and `title_filter` function.
2. Identifies lyrics link by a search, defined by `identity_uri` and `identity_pattern`.
3. Opens the lyrics link and extract lyrics, defined by `lyrics_uri` and `lyrics_pattern`.
4. Normalizes the result defined by the `result_filter` function and optionally strips html tags.

You can use the variables `{artist}` and `{title}` for uris and patterns.

The script supports any number of providers.

### Usage

1. Import the `Lyrics.lua` and `LyricsProviders.lua` scripts.
2. Attach the script `Lyrics.lua` to the Lyrics trigger to fetch lyrics on demand. Only the first trigger will be executed.
3. Edit the `LyricsProviders.lua` to add / remove /change the lyrics providers.
