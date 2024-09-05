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
    if mympd_state.current_song[tag] and mympd_state.current_song[tag][1]
    then
        mympd.api("MYMPD_API_STICKER_INC", {
            uri = mympd_state.current_song[tag][1],
            type = tag,
            name = "playCount"
        })
    end
end
