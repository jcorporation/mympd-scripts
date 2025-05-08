-- {"name": "ListenBrainzSetPin", "file": "ListenBrainz/ListenBrainzSetPin.lua", "version": 4, "desc": "Sets or unsets the pin on ListenBrainz.", "order":1, "arguments":["uri","blurb_content","pinned_until"]}
if mympd.isnilorempty(mympd_env.var.listenbrainz_token) then
  return mympd.jsonrpc_error("No ListenBrainz token set")
end

local rc, msg = mympd.check_arguments({uri = "notempty", blurb_content = "required", pinned_until = "required"})
if rc == false then
    return msg
end

local pin_uri = "https://api.listenbrainz.org/1/pin"
local unpin_uri = "https://api.listenbrainz.org/1/pin/unpin"
local extra_headers = "Content-type: application/json\r\n"..
  "Authorization: Token " .. mympd_env.var.listenbrainz_token .. "\r\n"
local payload = ""
local uri = ""

if not mympd.isnilorempty(mympd_arguments.uri) then
  local song
  rc, song = mympd.api("MYMPD_API_SONG_DETAILS", {uri = mympd_arguments.uri})
  if rc == 0 then
    local mbid = song.MUSICBRAINZ_TRACKID
    if mbid ~= nil then
      payload = json.encode({
        recording_mbid = mbid,
        blurb_content = mympd_arguments.blurb_content,
        pinned_until = mympd_arguments.pinned_until
      });
      uri = pin_uri
    end
  end
else
  uri = unpin_uri
end

if uri ~= "" then
  local code, header, body
  rc, code, header, body = mympd.http_client("POST", uri, extra_headers, payload)
  if rc > 0 then
    return mympd.jsonrpc_error(body)
  end
end
