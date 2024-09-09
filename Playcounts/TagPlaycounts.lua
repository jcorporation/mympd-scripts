-- {"name": "TagPlaycounts", "file": "Playcounts/TagPlaycounts.lua", "version": 2, "desc": "Sets playcounts for tags.", "order":0, "arguments":["tags"]}
mympd.init()

if mympd_state.current_song == nil then
    return
end

if string.sub(mympd_state.current_song.uri, 1, 8) == "https://" or
   string.sub(mympd_state.current_song.uri, 1, 7) == "http://"
then
  return
end

for tag in string.gmatch(mympd_arguments.tags, "[^,]+") do
    if mympd_state.current_song[tag]
    then
        for _, v in pairs(mympd_state.current_song[tag]) do
            mympd.api("MYMPD_API_STICKER_INC", {
                uri = v,
                type = tag,
                name = "playCount"
            })
        end
    end
end
