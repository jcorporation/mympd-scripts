-- {"name": "ListenBrainzPlayer", "file": "ListenBrainz/ListenBrainzPlayer.lua", "version": 2, "desc": "Sends the now playing info to ListenBrainz.", "order":0, "arguments":[]}
if mympd_env.var_listenbrainz_token == nil then
  return "No ListenBrainz token set"
end

local uri = "https://api.listenbrainz.org/1/feedback/recording-feedback"
local extra_headers = "Content-type: application/json\r\n"..
  "Authorization: Token " .. mympd_env.var_listenbrainz_token .. "\r\n"

mympd.init()

if mympd_state.play_state ~= 2 or
   mympd_state.elapsed_time > 5
then
  return
end

if mympd_state.current_song == nil then
  return
end

if string.sub(mympd_state.current_song.uri, 1, 8) == "https://" or
   string.sub(mympd_state.current_song.uri, 1, 7) == "http://"
then
  return
end

local artist_mbids = {}
if mympd_state.current_song.MUSICBRAINZ_ARTISTID ~= nil then
  for _, v in pairs(mympd_state.current_song["MUSICBRAINZ_ARTISTID"]) do
    if v ~= "" then
      artist_mbids[#artist_mbids + 1] = v
    end
  end
end
if mympd_state.current_song.MUSICBRAINZ_ALBUMARTISTID ~= nil then
  for _, v in pairs(mympd_state.current_song.MUSICBRAINZ_ALBUMARTISTID) do
    if v ~= "" then
      artist_mbids[#artist_mbids + 1] = v
    end
  end
end
local payload = json.encode({
  listen_type = "playing_now",
  payload = {{
    track_metadata = {
      additional_info = {
        release_mbid = mympd_state.current_song.MUSICBRAINZ_RELEASETRACKID,
        recording_mbid = mympd_state.current_song.MUSICBRAINZ_TRACKID,
        artist_mbids = artist_mbids
      },
      artist_name = mympd_state.current_song.Artist[1],
      track_name = mympd_state.current_song.Title,
      release_name = mympd_state.current_song.Album
    }
  }}
});
local rc, code, header, body = mympd.http_client("POST", uri, extra_headers, payload)
if rc > 0 then
  return body
end
