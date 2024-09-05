-- {"name": "MalojaScrobbler", "file": "Maloja/MalojaScrobbler.lua", "version": 2, "desc": "Scrobbles songs to your Maloja server.", "order":0, "arguments":[]}
if mympd_env.var_maloja_token == nil then
    return "No Maloja token set"
end

if mympd_env.var_maloja_uri == nil then
    return "No Maloja URI set"
end

if mympd_state.current_song == nil then
    return
end

if string.sub(mympd_state.current_song.uri, 1, 8) == "https://" or
   string.sub(mympd_state.current_song.uri, 1, 7) == "http://"
then
    return
end

local uri = mympd_env.var_maloja_host .. "/apis/mlj_1/newscrobble?key=" .. mympd_env.var_maloja_token
local extra_headers = "Content-type: application/json\r\n"

local payload = json.encode({
    artists = mympd_state.current_song.Artist,
    title = mympd_state.current_song.Title,
    album = mympd_state.current_song.Album,
    time = mympd_state.start_time
});

if mympd_state.current_song.AlbumArtist ~= nil and
   #mympd_state.current_song.AlbumArtist > 0
then
    payload.albumartists = mympd_state.current_song.AlbumArtist
end

local rc, code, headers, body = mympd.http_client("POST", uri, extra_headers, payload)
if rc > 0 then
    return body
end
