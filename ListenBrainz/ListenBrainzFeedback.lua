-- {"name": "ListenBrainzFeedback", "file": "ListenBrainz/ListenBrainzFeedback.lua", "version": 1, "desc": "Sends feedback to ListenBrainz.", "order":0, "arguments":["uri","vote","type"]}
if mympd_env.var_listenbrainz_token == nil then
  return "No ListenBrainz token set"
end

local uri = "https://api.listenbrainz.org/1/feedback/recording-feedback"
local headers = "Content-type: application/json\r\n"..
  "Authorization: Token " .. mympd_env.var_listenbrainz_token .. "\r\n"

local vote
if mympd_arguments.type == "like" then
  -- thumbs up/down
  vote = mympd_arguments.vote - 1
else
  -- stars rating
  if mympd_arguments.vote > 5 then
    -- treat more than 5 stars as like
    vote = 1
  else
    -- do not send feedback to ListenBrainz
    return
  end
end

-- get song details
local rc, song = mympd.api("MYMPD_API_SONG_DETAILS", { uri = mympd_arguments.uri })
if rc == 0 then
  local mbid = song.MUSICBRAINZ_TRACKID
  if mbid ~= nil and mbid ~= "" then
    local payload = json.encode({
      recording_mbid = mbid,
      score = vote
    });
    local code, header, body
    rc, code, header, body = mympd.http_client("POST", uri, headers, payload)
    if rc > 0 then
      return body
    end
  end
end
