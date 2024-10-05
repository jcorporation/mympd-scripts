-- {"name": "audioscrobbler", "file": "audioscrobbler/audioscrobbler.lua", "version": 1, "desc": "Generic audioscrobbler implementation.", "order":0, "arguments":["trigger"]}

local handshake_uri = mympd_env.var.scrobbler_handshake_uri
local username = mympd_env.var.scrobbler_username
local password = mympd_env.var.scrobbler_password

local function urlencode_data(data)
  local s = ""
  local a = {}
  for k, v in pairs(data) do
    table.insert(a, k .. "=" .. mympd.urlencode(v))
  end
  s = s .. table.concat(a, "&")
 return s
end

local function sendHandshake()
  local timestamp = tostring(os.time())
  local token = mympd.hash_md5(mympd.hash_md5(password) .. timestamp)
  local data = {
    hs = "true",
    p = "1.2.1",
    c = "myMPD",
    v = "1.0",
    u = username,
    t = timestamp,
    a = token
  }
  local rc, code, headers, body = mympd.http_client("GET", handshake_uri .. "?" .. urlencode_data(data), "", "")
  local lines = mympd.splitlines(body)

  if code == 200 and lines[1] == "OK" then
    return lines[2], lines[3], lines[4]
  end
  mympd.log(3, body)
  return nil
end

local function sendData(uri, data)
  local extra_headers = 'Content-type: application/x-www-form-urlencoded\r\n'
  data = urlencode_data(data)
  local rc, code, headers, body = mympd.http_client("POST", uri, extra_headers, data)
  return rc, code, body
end

-- main
mympd.init()

local librefm_session_id, playing_uri, submit_uri = sendHandshake()
if mympd_env.var.scrobble_enforce_https == "1" then
  playing_uri = string.gsub(playing_uri, "http://", "https://")
  submit_uri = string.gsub(submit_uri, "http://", "https://")
end

if librefm_session_id == nil then
  return "libre.fm handshake failed."
end

mympd.log(7, "librefm_session_id: " .. librefm_session_id)

if mympd_arguments.trigger == "scrobble" then
  if mympd_state.current_song == nil then
    return "Scrobble: Not playing"
  end

  local data = {}
  data["s"] = librefm_session_id
  data["a[0]"] = mympd_state.current_song.Artist[1]
  data["t[0]"] = mympd_state.current_song.Title
  data["i[0]"] = tostring(mympd_state.start_time)
  data["o[0]"] = "P"
  data["r[0]"] = ""
  data["l[0]"] = tostring(mympd_state.current_song.Duration)
  data["b[0]"] = mympd_state.current_song.Album
  data["n[0]"] = mympd_state.current_song.Track
  data["m[0]"] = mympd_state.current_song.MUSICBRAINZ_TRACKID or ""

  local rc, code, body = sendData(submit_uri, data)
  body = mympd.trim(body)
  if code == 200 and body == "OK" then
    return "Scrobble: " .. mympd_state.current_song.Artist[1] .. " - " .. mympd_state.current_song.Title .. " OK"
  end

  mympd.log(3, "'" .. body .. "'")
  return "Scrobble Error: " .. body
end

if mympd_arguments.trigger == "player" then
  if mympd_state.play_state ~= 2 or
     mympd_state.elapsed_time > 5 or
     mympd_state.current_song == nil
  then
    return "Now Playing: Not Playing"
  end

  if string.sub(mympd_state.current_song.uri, 1, 8) == "https://" or
     string.sub(mympd_state.current_song.uri, 1, 7) == "http://"
  then
    return "webradio"
  end

  local data = {
    s = librefm_session_id,
    a = mympd_state.current_song.Artist[1],
    t = mympd_state.current_song.Title,
    b = mympd_state.current_song.Album,
    l = tostring(mympd_state.current_song.Duration),
    n = mympd_state.current_song.Track,
    m = mympd_state.current_song.MUSICBRAINZ_TRACKID or ""
  }

  local rc, code, body = sendData(playing_uri, data)
  body = mympd.trim(body)
  if code == 200 and body == "OK" then
    return "Now Playing: " .. mympd_state.current_song.Artist[1] .. " - " .. mympd_state.current_song.Title .. " - OK"
  end

  mympd.log(3, "'" .. body .. "'")
  return "Now Playing Error: " .. body
end

return "librefm: unknown function"
