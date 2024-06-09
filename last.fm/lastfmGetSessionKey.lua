-- {"order":1,"arguments":["username", "password"]}
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
