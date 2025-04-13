# Background

This script fetches background images.

## Arguments

| ARGUMENT | DESCRIPTION |
| -------- | ----------- |
| uri | URI of current playing song. |
| hash | Hash of the myMPD client application. |

## Usage

1. Import the `Background.lua` and `BackgroundProviders.lua` scripts.
2. Create a new trigger
    - Event: `mympd_bgimage`
    - Script: above script

## Available providers

| PROVIDER | REQUIRED TAGS |
| -------- | ------------- |
| [Fanart.tv](https://fanart.tv/) | MUSICBRAINZ_ARTISTID |

### Fanart.tv

This provider fetches the artist background image type from [fanart.tv](https://fanart.tv/). You must create a new variable `fanart_tv_api_key` with your API key for Fanart.tv.
