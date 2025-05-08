-- {"name": "TagPlaycounts", "file": "Playcounts/TagPlaycounts.lua", "version": 3, "desc": "Sets playCount and lastPlayed for tags.", "order":0, "arguments":["tags"]}

local rc, msg = mympd.check_arguments({tags = "notempty"})
if rc == false then
    return mympd.jsonrpc_error(msg)
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

local function inc_playcount(uri, stickerType)
    mympd.api("MYMPD_API_STICKER_PLAYCOUNT", {
        uri = uri,
        type = stickerType
    })
end

for tag in string.gmatch(mympd_arguments.tags, "[^,]+") do
    if tag == "Album" then
        inc_playcount(mympd_state.current_album, "mympd_album")
    elseif mympd_state.current_song[tag] then
        for _, v in pairs(mympd_state.current_song[tag]) do
            inc_playcount(v, tag)
        end
    end
end
