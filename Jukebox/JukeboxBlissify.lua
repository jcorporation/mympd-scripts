-- {"name": "JukeboxBlissify", "file": "Jukebox/JukeboxBlissify.lua", "version": 2, "desc": "Uses blissify-rs to populate the jukebox queue.", "order":1,"arguments":["addToQueue"]}
local blissify_path = mympd_env.var_blissify_path
local blissify_config = ""
if mympd_env.var_blissify_config ~= nil and
   mympd_env.var_blissify_config ~= ""
then
    blissify_config = "-c " .. mympd_env.var_blissify_config
end
local addSongs = 1
local min_jukebox_length = 50

local function send_error(message)
    -- Send signal that jukebox queue can not be filled
    mympd.api("INTERNAL_API_JUKEBOX_ERROR", {
        error = message
    })
end

mympd.init()

-- Get length and last song of the jukebox queue
local rc, result = mympd.api("MYMPD_API_JUKEBOX_LIST", {
    expression = "",
    offset = 0,
    limit = 1000,
    fields = {}
})
if rc == 1 then
    send_error("Failure getting jukebox queue.")
    return
end
local jukebox_length = result.totalEntities
local to_add = addSongs + min_jukebox_length - jukebox_length
local last_song = nil
if jukebox_length > 0 then
    last_song = result.data[jukebox_length].uri
else
    -- fallback to playing song
    rc, result = mympd.api("MYMPD_API_PLAYER_CURRENT_SONG")
    if rc == 0 and result.uri then
        last_song = result.uri
    end
end

if last_song == nil then
    send_error("Failure getting reference song.")
    mympd.notify_partition(1, "You must add the first song to start the jukebox.")
    return
end

-- Get songs from blissify
local full_song_path = mympd_state.music_directory .. "/" .. last_song
local prefix_len = #mympd_state.music_directory + 2
local songs = {}
local cmd = string.format("%s %s playlist --dry-run --from-song \"%s\" %d 2>/dev/null", blissify_path, blissify_config, full_song_path, to_add)
local output = mympd.os_capture(cmd)
for line in string.gmatch(output, "[^\n]+") do
    table.insert(songs, string.sub(line, prefix_len))
end

if mympd_arguments.addToQueue == "1" then
    -- Add addSongs entries from playlist to the MPD queue
    local addUris = {}
    for i = 1, addSongs do
        table.insert(addUris, songs[i])
    end
    rc, result = mympd.api("MYMPD_API_QUEUE_APPEND_URIS", {
        uris = addUris,
        play = false
    })
    if rc == 1 then
        send_error(result.message)
        return
    end
    addSongs = addSongs + 1
end

-- Add songs to the jukebox queue
local addUris = {}
for i = addSongs, #songs do
    table.insert(addUris, songs[i])
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
