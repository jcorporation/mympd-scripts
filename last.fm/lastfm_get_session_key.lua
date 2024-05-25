-- {"order":1,"arguments":["username", "password"]}
mympd.init()

local lastfm_lib = require "scripts/lastfm_lib"

local data = {
  method   = "auth.getMobileSession",
  username = mympd_arguments.username,
  password = mympd_arguments.password,
  api_key  = mympd_state.var_lastfm_api_key,
}

local rc, body = lastfm_lib.sendData(data)
local ret = json.decode(body)

mympd.api("MYMPD_API_SCRIPT_VAR_SET", { key = "lastfm_session_key", value = ret.session.key })

return "Set session key for last.fm to " .. ret.session.key
