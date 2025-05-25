-- {"name": "MalojaScrobbler", "file": "Maloja/MalojaScrobbler.lua", "version": 6, "desc": "Scrobbles songs to your Maloja server.", "order":0, "arguments":[]}
if mympd.isnilorempty(mympd_env.var.maloja_token) then
    return mympd.jsonrpc_error("No Maloja token set")
end

if mympd.isnilorempty(mympd_env.var.maloja_host) then
    return mympd.jsonrpc_error("No Maloja host set")
end

mympd.init()

if mympd_state.current_song == nil then
    return
end

if string.sub(mympd_state.current_song.uri, 1, 8) == "https://" or
   string.sub(mympd_state.current_song.uri, 1, 7) == "http://"
then
    return
end

if mympd.tblvalue_in_list(mympd_env.var.scrobble_genre_blacklist, mympd_state.current_song.Genre) == true then
  return
end

local uri = mympd_env.var.maloja_host .. "/apis/mlj_1/newscrobble?key=" .. mympd_env.var.maloja_token
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
    return mympd.jsonrpc_error(body)
end
