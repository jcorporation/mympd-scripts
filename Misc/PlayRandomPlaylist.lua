-- {"name": "PlayRandomPlaylist", "file": "Misc/PlayRandomPlaylist.lua", "version": 2, "desc": "Plays a random playlist.", "order":1, "arguments":[]}
-- get the first 2000 playlists
local rc, result = mympd.api("MYMPD_API_PLAYLIST_LIST", {
    offset = 0,
    limit = 2000,
    searchstr = "",
    type = 0
})
if rc == 1 then
    return mympd.jsonrpc_error("Failure getting playlists")
end

if result.returnedEntities == 0 then
    return mympd.jsonrpc_error("No playlists found.")
end

-- random number
math.randomseed(os.time())
local number = math.random(1, result.returnedEntities)
-- get playlist by random number
local playlist = result.data[number].uri
-- play the playlist
rc, result = mympd.api("MYMPD_API_QUEUE_REPLACE_PLAYLISTS", {
    plist = { playlist },
    play = true
})
if rc == 0 then
    -- return the playlist name
    return "Playing " .. playlist
else
    return mympd.jsonrpc_error("Failure playing " .. playlist)
end
