-- {"order":1,"arguments":[]}
-- get the first 2000 playlists
local rc, result = mympd.api("MYMPD_API_PLAYLIST_LIST", {
    offset = 0,
    limit = 2000,
    searchstr = "",
    type = 0
})
-- random number
math.randomseed(os.time())
local number = math.random(1, #result.result.data)
-- get playlist by random number
local playlist = result.data[number].uri
-- play the playlist
local raw_result
rc, raw_result = mympd.api("MYMPD_API_QUEUE_REPLACE_PLAYLISTS", {
    plist = { playlist },
    play = true
})
-- return the playlist name
return "Playing " .. playlist
