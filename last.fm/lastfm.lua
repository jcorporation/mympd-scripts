-- {"name": "lastfm", "file": "last.fm/lastfm.lua", "version": 7, "desc": "Interface for last.fm.", "order":0, "arguments":["trigger"]}

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

local function firstTagValue(field)
  return (field and field[1]) or ""
end

local function hashRequest(data, secret)
  local keys = {}
  for key in pairs(data) do
    table.insert(keys, key)
  end

  table.sort(keys)

  local s = ""
  for _, key in ipairs(keys) do
    s = s .. key .. data[key]
  end

  s = s .. secret
  return mympd.hash_md5(s)
end

local function urlencode_data(data)
  local a = {}
  for k, v in pairs(data) do
    table.insert(a, mympd.urlencode(k) .. "=" .. mympd.urlencode(v))
  end
  return table.concat(a, "&")
end

local function sendData(data)
  local extra_headers = 'Content-type: application/x-www-form-urlencoded\r\n'
  data["api_sig"] = hashRequest(data, mympd_env.var.lastfm_secret)
  local encoded = urlencode_data(data)

  local code, headers, body
  rc, code, headers, body = mympd.http_client(
    "POST",
    "https://ws.audioscrobbler.com/2.0/?format=json",
    extra_headers,
    encoded
  )

  return rc, body
end

-- MAIN
mympd.init()

-- NOW PLAYING
if mympd_arguments.trigger == "player" then
  if mympd_state.play_state ~= 2 or mympd_state.elapsed_time > 5 then
    return "Now Playing: Not Playing"
  end

  if not mympd_state.current_song then
    return "Now Playing: Not Playing"
  end

  if string.sub(mympd_state.current_song.uri, 1, 8) == "https://" or
     string.sub(mympd_state.current_song.uri, 1, 7) == "http://" then
    return "webradio"
  end

  if mympd.tblvalue_in_list(mympd_env.var.scrobble_genre_blacklist, mympd_state.current_song.Genre) then
    return
  end

  local data = {
    method      = "track.updateNowPlaying",
    api_key     = mympd_env.var.lastfm_api_key,
    track       = mympd_state.current_song.Title,
    artist      = mympd.firstTableValue(mympd_state.current_song.Artist),
    album       = mympd_state.current_song.Album or "",
    albumArtist = mympd.firstTableValue(mympd_state.current_song.AlbumArtist),
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
    return "Now Playing: " .. data.artist .. " - " .. data.track .. " - ignored code " .. code
  end

  return "Now Playing: " .. data.artist .. " - " .. data.track .. " - OK"
end

-- SCROBBLE
if mympd_arguments.trigger == "scrobble" then
  if not mympd_state.current_song then
    return "Scrobble: Not playing"
  end

  if mympd.tblvalue_in_list(mympd_env.var.scrobble_genre_blacklist, mympd_state.current_song.Genre) then
    return
  end

  local data = {
    method      = "track.scrobble",
    api_key     = mympd_env.var.lastfm_api_key,
    timestamp   = tostring(mympd_state.start_time),
    track       = mympd_state.current_song.Title,
    artist      = mympd.firstTableValue(mympd_state.current_song.Artist),
    album       = mympd_state.current_song.Album or "",
    albumArtist = mympd.firstTableValue(mympd_state.current_song.AlbumArtist),
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
    return "Scrobble: " .. data.artist .. " - " .. data.track .. " ignored, code " .. code
  end

  return "Scrobble: " .. data.artist .. " - " .. data.track .. " OK"
end

-- FEEDBACK
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

  if not mympd_state.current_song then
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

  return "Feedback: " .. data.artist .. " - " .. data.track .. " OK"
end

-- GET SESSION KEY DIALOG
if mympd_arguments.trigger == "key" then
  local data = {
    { name = "Username", type = "text", value = "" },
    { name = "Password", type = "password", value = "" },
    { name = "trigger",  type = "hidden", value = "fetchkey" }
  }
  return mympd.dialog("Get Last.fm key", data, "lastfm")
end

-- FETCH SESSION KEY
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

  mympd.api("MYMPD_API_SCRIPT_VAR_SET", {
    key = "lastfm_session_key",
    value = ret.session.key
  })

  return "Set session key for Last.fm to " .. ret.session.key
end

return "lastfm: unknown function"
