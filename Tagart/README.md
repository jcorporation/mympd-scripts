# Tagart

This script fetches tagart. You must create a directory in the `/var/lib/mympd/pics/` directory with the tag name to enable image retrieval for a tag.

```sh
# Enable display of tags Artist and AlbumArtist
mkdir /var/lib/mympd/pics/Artist
mkdir /var/lib/mympd/pics/AlbumArtist
```

## Usage

1. Create a new variable `fanart_tv_api_key` with your API key for Fanart.tv.
2. Import the `Tagart.lua` and the `TagartProviders.lua` scripts.
3. Create a new trigger
    - Event: `mympd_albumart`
    - Script: above script

## Available providers

| PROVIDER | SUPPORTED TAGS | REQUIRED TAGS |
| -------- | -------------- | ------------- |
| [Fanart.tv](https://fanart.tv/) | Artist, AlbumArtist | Artist, AlbumArtist, MUSICBRAINZ_ARTISTID |
