-- {"name": "librefm", "file": "libre.fm/librefm.lua", "version": 1, "desc": "Interface for libre.fm.", "order":0, "arguments":["trigger"]}

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
  data["api_sig"] = hashRequest(data, "168b59e805fba6fea78d857ecbda4b7f")
  data = urlencode_data(data)
  local rc, code, headers, body = mympd.http_client("POST", "https://libre.fm/2.0/?format=json", extra_headers, data)
  return rc, body
end

-- main
mympd.init()

local play_state = mympd_state.play_state
local elapsed_time = mympd_state.elapsed_time

if mympd_arguments.trigger == "player" then
  if play_state ~= 2 or elapsed_time > 5 then
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
    api_key     = "168b59e805fba6fea78d857ecbda4b7f",
    track       = mympd_state.current_song.Title,
    artist      = mympd_state.current_song.Artist[1],
    album       = mympd_state.current_song.Album,
    albumArtist = mympd_state.current_song.AlbumArtist[1],
    sk          = mympd_env.var.librefm_session_key,
  }

  local rc, body = sendData(data)
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
    api_key     = "168b59e805fba6fea78d857ecbda4b7f",
    timestamp   = tostring(mympd_state.start_time),
    track       = mympd_state.current_song.Title,
    artist      = mympd_state.current_song.Artist[1],
    album       = mympd_state.current_song.Album,
    albumArtist = mympd_state.current_song.AlbumArtist[1],
    sk          = mympd_env.var.librefm_session_key,
  }

  local rc, body = sendData(data)
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
    api_key     = "notusedbylibre.fm",
    track       = mympd_state.current_song.Title,
    artist      = mympd_state.current_song.Artist[1],
    sk          = mympd_env.var.librefm_session_key,
  }

  local rc, body = sendData(data)
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
  return mympd.dialog("Get last.fm key", data, "librefm")
end

if mympd_arguments.trigger == "fetchkey" then
  local data = {
    method   = "auth.getMobileSession",
    username = mympd_arguments.Username,
    password = mympd_arguments.Password,
    api_key  = "168b59e805fba6fea78d857ecbda4b7f",
  }

  local rc, body = sendData(data)
  local ret = json.decode(body)
  if ret.session == nil then
    return("Failure get the session key: " .. ret.message)
  end
  mympd.api("MYMPD_API_SCRIPT_VAR_SET", { key = "librefm_session_key", value = ret.session.key })

  return "Set session key for last.fm to " .. ret.session.key
end

return "librefm: unknown function"