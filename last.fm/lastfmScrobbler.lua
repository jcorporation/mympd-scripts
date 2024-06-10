-- {"name": "lastfmScrobbler", "file": "last.fm/lastfmScrobbler.lua", "version": 1, "desc": "Scrobbles songs to last.fm.", "order":1,"arguments":[]}
local lastfmLib = require "scripts/lastfmLib"

-- main
local rc, result = mympd.api("MYMPD_API_PLAYER_CURRENT_SONG")
if rc ~= 0 then
  return "Scrobble: Not playing"
end

local artist = result.Artist[1]
local title = result.Title
local album = result.Album
local albumArtist = result.AlbumArtist[1]

local data = {
  method      = "track.scrobble",
  api_key     = mympd_env.var_lastfm_api_key,
  timestamp   = tostring(os.time()-30),
  track       = title,
  artist      = artist,
  album       = album,
  albumArtist = albumArtist,
  sk          = mympd_env.var_lastfm_session_key,
}

local body
rc, body = lastfmLib.sendData(data)
if rc ~= 0 then
  return "Scrobble: Error"
end

local ret = json.decode(body)
local code = ret.scrobbles.scrobble.ignoredMessage.code
if code ~= "0" then
  return "Scrobble: " .. artist .. " - " .. title .. " ignored, code " .. code
end

return "Scrobble: " .. artist .. " - " .. title .. " OK"
