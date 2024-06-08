-- {"order":1,"arguments":["uri","blurb_content","pinned_until"]}
if mympd_env.var_listenbrainz_token == nil then
  return "No ListenBrainz token set"
end

local pin_uri = "https://api.listenbrainz.org/1/pin"
local unpin_uri = "https://api.listenbrainz.org/1/pin/unpin"
local headers = "Content-type: application/json\r\n"..
  "Authorization: Token " .. mympd_env.var_listenbrainz_token .. "\r\n"
local payload = ""
local uri = ""

if mympd_arguments.uri ~= "" then
  local rc, song = mympd.api("MYMPD_API_SONG_DETAILS", {uri = mympd_arguments.uri})
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
  local rc, code, header, body = mympd.http_client("POST", uri, headers, payload)
  if rc > 0 then
    return body
  end
end
