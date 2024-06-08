-- {"order":1,"arguments":[]}
if mympd_env.var_listenbrainz_token == nil then
  return "No ListenBrainz token set"
end

local uri = "https://api.listenbrainz.org/1/submit-listens"
local extra_headers = "Content-type: application/json\r\n"..
  "Authorization: Token " .. mympd_env.var_listenbrainz_token .. "\r\n"

local rc, result = mympd.api("MYMPD_API_PLAYER_CURRENT_SONG")
if rc ~= 0 then
  return
end

if result.webradio or
   string.sub(result.uri, 1, 8) == "https://" or
   string.sub(result.uri, 1, 7) == "http://"
then
  return
end

local artist_mbids = {}
if result.MUSICBRAINZ_ARTISTID ~= nil then
  for _, v in pairs(result["MUSICBRAINZ_ARTISTID"]) do
    if v ~= "" then
      artist_mbids[#artist_mbids + 1] = v
    end
  end
end
if result.MUSICBRAINZ_ALBUMARTISTID ~= nil then
  for _, v in pairs(result.MUSICBRAINZ_ALBUMARTISTID) do
    if v ~= "" then
      artist_mbids[#artist_mbids + 1] = v
    end
  end
end
local payload = json.encode({
  listen_type = "single",
  payload = {{
    listened_at = result.startTime,
    track_metadata = {
      additional_info = {
        release_mbid = result.MUSICBRAINZ_RELEASETRACKID,
        recording_mbid = result.MUSICBRAINZ_TRACKID,
        artist_mbids = artist_mbids
      },
      artist_name = result.Artist[1],
      track_name = result.Title,
      release_name = result.Album
    }
  }}
});
local code, header, body
rc, code, header, body = mympd.http_client("POST", uri, extra_headers, payload)
if rc > 0 then
  return body
end
