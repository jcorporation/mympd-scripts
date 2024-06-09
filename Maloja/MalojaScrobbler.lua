-- {"order":1,"arguments":[]}
if mympd_env.var_maloja_token == nil then
    return "No Maloja token set"
end

if mympd_env.var_maloja_uri == nil then
    return "No Maloja URI set"
end

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

local uri = mympd_env.var_maloja_host .. "/apis/mlj_1/newscrobble?key=" .. mympd_env.var_maloja_token
local extra_headers = "Content-type: application/json\r\n"

local payload = json.encode({
    artists = result.Artist,
    title = result.Title,
    album = result.Album,
    time = result.startTime
});

if result.AlbumArtist ~= nil and
   #result.AlbumArtist > 0
then
    payload.albumartists = result.AlbumArtist
end

local code, headers, body
rc, code, headers, body = mympd.http_client("POST", uri, extra_headers, payload)
if rc > 0 then
    return body
end
