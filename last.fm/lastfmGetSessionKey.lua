-- {"name": "lastfmGetSessionKey", "file": "last.fm/lastfmGetSessionKey.lua", "version": 1, "desc": "Fetches the session key from last.fm and sets the myMPD variable.", "order":0, "arguments":["username", "password|password"]}
local lastfmLib = require "scripts/lastfmLib"

local data = {
  method   = "auth.getMobileSession",
  username = mympd_arguments.username,
  password = mympd_arguments.password,
  api_key  = mympd_env.var_lastfm_api_key,
}

local rc, body = lastfmLib.sendData(data)
local ret = json.decode(body)

mympd.api("MYMPD_API_SCRIPT_VAR_SET", { key = "lastfm_session_key", value = ret.session.key })

return "Set session key for last.fm to " .. ret.session.key
