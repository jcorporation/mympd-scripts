# Maloja

This is a scrobbler for the native [Maloja](https://github.com/krateng/maloja) API.

## Usage

- Set your Maloja settings: Scripts -> Variables
  - New variable with key `maloja_token` and your API token as value
  - New variable with key `maloja_host` and your Maloja Host as value, e.g. `https://maloja.lan`.
- Create a new script
  - Import the `MalojaScrobbler.lua` script
- Create a new trigger
  - Event: `mympd_scrobble`
  - Action: above script
- Optional: Add the variable `scrobble_genre_blacklist` with a comma separated list of genres that should not be scrobbled.
