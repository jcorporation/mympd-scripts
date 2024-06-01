# Albumart

This script fetches albumart.

## Usage

1. Create a new variable `fanart_tv_api_key` with your API key for Fanart.tv.
2. Import the Albumart.lua script
3. Create a new trigger
    - Event: `mympd_albumart`
    - Script: above script

## Available providers

| PROVIDER | REQUIRED TAGS |
| -------- | ------------- |
| [Cover Art Archive](https://coverartarchive.org/) | MUSICBRAINZ_ALBUMID |
| [Fanart.tv](https://fanart.tv/) | MUSICBRAINZ_ARTISTID, MUSICBRAINZ_RELEASEGROUPID |
