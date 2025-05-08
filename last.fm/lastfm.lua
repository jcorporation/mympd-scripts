-- {"name": "lastfm", "file": "last.fm/lastfm.lua", "version": 3, "desc": "Interface for last.fm.", "order":0, "arguments":["trigger"]}

if mympd.isnilorempty(mympd_env.var.lastfm_api_key) then
  return mympd.jsonrpc_error("No Last.fm API Key set")
end
if mympd.isnilorempty(mympd_env.var.lastfm_session_key) then
  return mympd.jsonrpc_error("No Last.fm Session Key set")
end

local rc, msg = mympd.check_arguments({trigger = "notempty"})
if rc == false then
    return msg
end

local function hashRequest(data, secret)
  local keys = {}
  for key in pairs(data) do
    table.insert(keys, key)
  end
  table.sort(keys)
  local s = ""
  for k, v in pairs(keys) do
    s = s .. v .. data[v]
  end
  s = s .. secret
  local hash = mympd.hash_md5(s)
  return hash
end

local function urlencode_data(data)
  local s = ""
  local a = {}
  for k, v in pairs(data) do
    table.insert(a, mympd.urlencode(k) .. "=" .. mympd.urlencode(v))
  end
  s = table.concat(a, "&")
 return s
end

local function sendData(data)
  local extra_headers = 'Content-type: application/x-www-form-urlencoded\r\n'
  local hash = hashRequest(data, mympd_env.var.lastfm_secret)
  data["api_sig"] = hash
  data = urlencode_data(data)
  local code, headers, body
  rc, code, headers, body = mympd.http_client("POST", "https://ws.audioscrobbler.com/2.0/?format=json", extra_headers, data)
  return rc, body
end

-- main
mympd.init()

if mympd_arguments.trigger == "player" then
  if mympd_state.play_state ~= 2 or mympd_state.elapsed_time > 5 then
    return "Now Playing: Not Playing"
  end

  if mympd_state.current_song == nil then
    return "Now Playing: Not Playing"
  end

  if string.sub(mympd_state.current_song.uri, 1, 8) == "https://" or
     string.sub(mympd_state.current_song.uri, 1, 7) == "http://" then
    return "webradio"
  end

  local data = {
    method      = "track.updateNowPlaying",
    api_key     = mympd_env.var.lastfm_api_key,
    track       = mympd_state.current_song.Title,
    artist      = mympd_state.current_song.Artist[1],
    album       = mympd_state.current_song.Album,
    albumArtist = mympd_state.current_song.AlbumArtist[1],
    sk          = mympd_env.var.lastfm_session_key,
  }

  local body
  rc, body = sendData(data)
  if rc ~= 0 then
    return "Now Playing: Error"
  end

  local ret = json.decode(body)
  local code = ret.nowplaying.ignoredMessage.code
  if code ~= "0" then
    return "Now Playing: " .. mympd_state.current_song.Artist[1] .. " - " .. mympd_state.current_song.Title .. " - ignored code " .. code
  end

  return "Now Playing: " .. mympd_state.current_song.Artist[1] .. " - " .. mympd_state.current_song.Title .. " - OK"
end

if mympd_arguments.trigger == "scrobble" then
  if mympd_state.current_song == nil then
    return "Scrobble: Not playing"
  end

  local data = {
    method      = "track.scrobble",
    api_key     = mympd_env.var.lastfm_api_key,
    timestamp   = tostring(mympd_state.start_time),
    track       = mympd_state.current_song.Title,
    artist      = mympd_state.current_song.Artist[1],
    album       = mympd_state.current_song.Album,
    albumArtist = mympd_state.current_song.AlbumArtist[1],
    sk          = mympd_env.var.lastfm_session_key,
  }

  local body
  rc, body = sendData(data)
  if rc ~= 0 then
    return "Scrobble: Error"
  end

  local ret = json.decode(body)
  local code = ret.scrobbles.scrobble.ignoredMessage.code
  if code ~= "0" then
    return "Scrobble: " .. mympd_state.current_song.Artist[1] .. " - " .. mympd_state.current_song.Title .. " ignored, code " .. code
  end

  return "Scrobble: " .. mympd_state.current_song.Artist[1] .. " - " .. mympd_state.current_song.Title .. " OK"
end

if mympd_arguments.trigger == "feedback" then
  if mympd_arguments.type == "like" then
    if mympd_arguments.vote == "1" then
      return "Feedback: dislike"
    end
  else
    if mympd_arguments.vote <= 5 then
      return "Star rating <= 5"
    end
  end

  if mympd_state.current_song == nil then
    return "Feedback: Not playing"
  end

  local data = {
    method      = "track.love",
    api_key     = mympd_env.var.lastfm_api_key,
    track       = mympd_state.current_song.Title,
    artist      = mympd_state.current_song.Artist[1],
    sk          = mympd_env.var.lastfm_session_key,
  }

  local body
  rc, body = sendData(data)
  if rc ~= 0 then
    return "Feedback: Error"
  end

  return "Feedback: " .. mympd_state.current_song.Artist[1] .. " - " .. mympd_state.current_song.Title .. " OK"
end

if mympd_arguments.trigger == "key" then
  local data = {
    { name = "Username", type = "text", value = "" },
    { name = "Password", type = "password", value = ""},
    { name = "trigger", type = "hidden", value = "fetchkey"}
  }
  return mympd.dialog("Get last.fm key", data, "lastfm")
end

if mympd_arguments.trigger == "fetchkey" then
  local data = {
    method   = "auth.getMobileSession",
    username = mympd_arguments.Username,
    password = mympd_arguments.Password,
    api_key  = mympd_env.var.lastfm_api_key,
  }

  local body
  rc, body = sendData(data)
  local ret = json.decode(body)
  mympd.api("MYMPD_API_SCRIPT_VAR_SET", { key = "lastfm_session_key", value = ret.session.key })

  return "Set session key for last.fm to " .. ret.session.key
end

return "lastfm: unknown function"
