-- {"name": "lastfmLib", "file": "last.fm/lastfmLib.lua", "version": 1, "desc": "Library requried by the other last.fm modules.", "order":0, "arguments":[]}

lastfmLib = {}

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

lastfmLib.sendData = function(data)
  local extra_headers = 'Content-type: application/x-www-form-urlencoded\r\n'
  local hash = hashRequest(data, mympd_env.var_lastfm_secret)
  data["api_sig"] = hash
  data = urlencode_data(data)
  local rc, code, headers, body = mympd.http_client("POST", "https://ws.audioscrobbler.com/2.0/?format=json", extra_headers, data)
  return rc, body
end

return lastfmLib
