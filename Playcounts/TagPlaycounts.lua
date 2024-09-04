-- {"name": "TagPlaycounts", "file": "Playcounts/TagPlaycounts.lua", "version": 1, "desc": "Sets playcounts for tags.", "order":0, "arguments":["tags"]}
local rc, result = mympd.api("MYMPD_API_PLAYER_CURRENT_SONG")
if rc ~= 0 then
    return
end

if result.webradio or
   string.sub(result.uri, 1, 8) == "https://" or
   string.sub(result.uri, 1, 7) == "http://"
then
  return
end

for tag in string.gmatch(mympd_arguments.tags, "[^,]+") do
    if result[tag] and result[tag][1]
    then
        mympd.api("MYMPD_API_STICKER_INC", {
            uri = result[tag][1],
            type = tag,
            name = "playCount"
        })
    end
end
