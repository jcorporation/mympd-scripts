-- {"name": "PlayRandomPlaylist", "file": "Misc/PlayRandomPlaylist.lua", "version": 1, "desc": "Plays a random playlist.", "order":1,"arguments":[]}
-- get the first 2000 playlists
local rc, result = mympd.api("MYMPD_API_PLAYLIST_LIST", {
    offset = 0,
    limit = 2000,
    searchstr = "",
    type = 0
})
if rc == 1 then
    return "Failure getting playlists"
end
-- random number
math.randomseed(os.time())
local number = math.random(1, #result.data)
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
    return "Failure playing " .. playlist
end
