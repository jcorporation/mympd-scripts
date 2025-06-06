-- {"name": "ListenBrainzFeedback", "file": "ListenBrainz/ListenBrainzFeedback.lua", "version": 6, "desc": "Sends feedback to ListenBrainz.", "order":0, "arguments":["uri","vote","type"]}
if mympd.isnilorempty(mympd_env.var.listenbrainz_token) then
  return mympd.jsonrpc_error("No ListenBrainz token set")
end

local uri = "https://api.listenbrainz.org/1/feedback/recording-feedback"
local extra_headers = "Content-type: application/json\r\n"..
  "Authorization: Token " .. mympd_env.var.listenbrainz_token .. "\r\n"

local rc, msg = mympd.check_arguments({uri = "notempty", vote = "number", ["type"] = "required"})
if rc == false then
    return msg
end

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
local song
rc, song = mympd.api("MYMPD_API_SONG_DETAILS", { uri = mympd_arguments.uri })
if rc == 0 then
  local mbid = song.MUSICBRAINZ_TRACKID
  if not mympd.isnilorempty(mbid) then
    local payload = json.encode({
      recording_mbid = mbid,
      score = vote
    });
    local code, header, body
    rc, code, header, body = mympd.http_client("POST", uri, extra_headers, payload)
    if rc > 0 then
      return mympd.jsonrpc_error(body)
    end
  end
end
