-- {"order":1,"arguments":[]}

local addSongs = 1
local min_jukebox_length = 50

local function send_error(message)
    mympd.api("INTERNAL_API_JUKEBOX_ERROR", {
        error = message
    })
end

-- Get the first 2000 playlists
local rc, result = mympd.api("MYMPD_API_PLAYLIST_LIST", {
    offset = 0,
    limit = 2000,
    searchstr = "",
    type = 0
})
if rc == 1 then
    send_error(result.message)
    return
end

-- Get playlist by random number
math.randomseed(os.time())
local number = math.random(1, #result.data)
local playlist = result.data[number].uri

-- Get length of the jukebox queue
rc, result = mympd.api("MYMPD_API_JUKEBOX_LENGTH", {})
if rc == 1 then
    send_error("Failure getting jukebox queue length " .. playlist)
    return
end
local jukebox_length = result.length

-- Get the songs from the playlist
local songs
rc, songs = mympd.api("MYMPD_API_PLAYLIST_CONTENT_LIST", {
    plist = playlist,
    expression = "",
    offset = 0,
    limit = addSongs + min_jukebox_length - jukebox_length,
    fields = {}
})
if rc == 1 then
    send_error("Failure getting playlist " .. playlist)
    return
end

-- Add addSongs entries from playlist to the MPD queue
local addUris = {}
for i = 1, addSongs do
    table.insert(addUris, songs.data[i].uri)
end
rc, result = mympd.api("MYMPD_API_QUEUE_APPEND_URIS", {
    uris = addUris,
    play = true
})
if rc == 1 then
    send_error(result.message)
    return
end

-- Add additional songs to the jukebox queue
addUris = {}
addSongs = addSongs + 1
for i = addSongs, songs.returnedEntities do
    table.insert(addUris, songs.data[i].uri)
end
rc, result = mympd.api("MYMPD_API_JUKEBOX_APPEND_URIS", {
    uris = addUris
})
if rc == 1 then
    send_error(result.message)
    return
end

-- Send signal that filling jukebox queue has finished successfully
mympd.api("INTERNAL_API_JUKEBOX_CREATED", {})
