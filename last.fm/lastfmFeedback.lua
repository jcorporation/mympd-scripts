-- {"order":1,"arguments":["uri","vote","type"]}
local lastfmLib = require "scripts/lastfmLib"

-- main
if mympd_arguments.type == "like" then
  if mympd_arguments.vote == "1" then
    return "Feedback: dislike"
  end
else
  if mympd_arguments.vote <= 5 then
    return "Star rating <= 5"
  end
end

local rc, result = mympd.api("MYMPD_API_PLAYER_CURRENT_SONG")
if rc ~= 0 then
  return "Feedback: Not playing"
end

local artist = result.Artist[1]
local title = result.Title

local data = {
  method      = "track.love",
  api_key     = mympd_env.var_lastfm_api_key,
  track       = title,
  artist      = artist,
  sk          = mympd_env.var_lastfm_session_key,
}

local body
rc, body = lastfmLib.sendData(data)
if rc ~= 0 then
  return "Feedback: Error"
end
--ret = json.decode(body) -- always {}

return "Feedback: " .. artist .. " - " .. title .. " OK"
