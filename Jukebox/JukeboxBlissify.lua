-- {"name": "JukeboxBlissify", "file": "Jukebox/JukeboxBlissify.lua", "version": 9, "desc": "Uses blissify-rs to populate the jukebox queue.", "order":0,"arguments":["addToQueue"]}

if mympd.isnilorempty(mympd_env.var.blissify_path) then
    return "Variable blissify_path not set"
end

local blissify_path = mympd_env.var.blissify_path
local blissify_config = ""
if not mympd.isnilorempty(mympd_env.var.blissify_config) then
    blissify_config = "-c " .. mympd_env.var.blissify_config
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
-- request one more song (https://github.com/Polochon-street/blissify-rs/issues/66)
local to_add = addSongs + min_jukebox_length - jukebox_length + 1
local last_song = nil
if jukebox_length > 0 then
    last_song = result.data[jukebox_length].uri
end

if last_song == nil then
    -- fallback to playing song
    if mympd_state.current_song ~= nil
    then
        last_song = mympd_state.current_song.uri
    end
end

if last_song == nil then
    -- fallback to add random song
    rc, result = mympd.api("MYMPD_API_QUEUE_ADD_RANDOM", {
        plist = "Database",
        quantity = 1,
        mode = 1,
        play = true
    })
    if rc == 0 then
        mympd.api("INTERNAL_API_JUKEBOX_CREATED", {})
        return
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
local cmd = string.format("%s %s playlist --seed-song --dry-run --from-song \"%s\" %d 2>/dev/null", blissify_path, blissify_config, full_song_path, to_add)
local output = mympd.os_capture(cmd)
-- Skip reference song
local i = 0
for line in string.gmatch(output, "[^\n]+") do
    if i > 1 then
        table.insert(songs, string.sub(line, prefix_len))
    end
    i = i + 1
end

if mympd_arguments.addToQueue == "1" then
    -- Add addSongs entries from playlist to the MPD queue
    local addUris = {}
    for j = 1, addSongs do
        table.insert(addUris, songs[j])
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
    if mympd_state.play_state ~= 2 then
        mympd.api("MYMPD_API_PLAYER_PLAY", {})
    end
end

-- Add songs to the jukebox queue
local addUris = {}
for j = addSongs, #songs do
    table.insert(addUris, songs[j])
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
