-- {"name": "WidgetMostPlayedSongs", "file": "HomeWidgets/WidgetMostPlayedSongs.lua", "version": 3, "desc": "Home widget for most played songs.", "order":0,"arguments":["entries"]}
local headers = "Content-type: text/html\r\n"

local rc, msg = mympd.check_arguments({entries = "number"})
if rc == false then
    local body = "<div class=\"text-center p-3\">" .. msg .. "</div>"
    return mympd.http_reply("500", headers, body)
end

local entries = tonumber(mympd_arguments.entries)

local options = {
    uri = "",
    type = "song",
    name = "playCount",
    op = "gt",
    value = "0",
    sort = "value_int",
    sortdesc = true,
    offset = 0,
    limit = entries
}
local rows = {}
local result
rc, result = mympd.api("MYMPD_API_STICKER_FIND", options)
if rc == 0 then
    for _,data in ipairs(result.data)
    do
        local song
        rc, song = mympd.api("MYMPD_API_SONG_DETAILS", {uri = data.uri})
        if rc == 0 then
            table.insert(rows, "<div class=\"list-group-item list-group-item-action clickable\" data-href='{\"cmd\":\"songDetails\",\"options\":[" ..
                json.encode(mympd.htmlencode(data.uri)) .. "]}'>" .. mympd.htmlencode(song.Title) .. "<br/><small>" ..
                mympd.htmlencode(table.concat(song.Artist, ', ')) .. "</small></div>")
        end
    end
end

local body = "<div class=\"list-group list-group-flush\">" ..
    table.concat(rows) ..
    "</div>"

return mympd.http_reply("200", headers, body)
