-- {"name": "WidgetPlaylists", "file": "HomeWidgets/WidgetPlaylists.lua", "version": 4, "desc": "Home widget for playlists.", "order":0,"arguments":["entries"]}
local headers = "Content-type: text/html\r\n"

local rc, msg = mympd.check_arguments({entries = "number"})
if rc == false then
    local body = "<div class=\"text-center p-3\">" .. msg .. "</div>"
    return mympd.http_reply("500", headers, body)
end

local entries = tonumber(mympd_arguments.entries)

local method = "MYMPD_API_PLAYLIST_LIST"
local options = {
    searchstr = "",
    sort = "Last-Modified",
    sortdesc = false,
    fields = {
        "Name",
        "Last-Modified"
    },
    type = 0,
    offset = 0,
    limit = entries
}

local rows = {}
local result
rc, result = mympd.api(method, options)
if rc == 0 then
    for _,data in ipairs(result.data)
    do
        table.insert(rows, "<div class=\"list-group-item list-group-item-action clickable\" data-href='{\"cmd\":\"gotoPlaylist\",\"options\":[" ..
            json.encode(mympd.htmlencode(data.Name)) .. "]}'>" .. mympd.htmlencode(data.Name) .. "</div>")
    end
end

local body = "<div class=\"list-group list-group-flush\">" ..
    table.concat(rows) ..
    "</div>"

return mympd.http_reply("200", headers, body)
