-- {"name": "WidgetStats", "file": "HomeWidgets/WidgetStats.lua", "version": 1, "desc": "Home widget for MPD DB stats.", "order":0,"arguments":[]}
local headers = "Content-type: text/html\r\n"

local rc, result = mympd.api("MYMPD_API_STATS", {})
local rows = {}
if rc == 0 then
    table.insert(rows, "<tr><th>Artists</th><td>" .. mympd.htmlencode(result.artists) .. "</td></tr>")
    table.insert(rows, "<tr><th>Albums</th><td>" .. mympd.htmlencode(result.albums) .. "</td></tr>")
    table.insert(rows, "<tr><th>Songs</th><td>" .. mympd.htmlencode(result.songs) .. "</td></tr>")
end

local body = "<table class=\"table\">" ..
    table.concat(rows) ..
    "</table>"

return mympd.http_reply("200", headers, body)
