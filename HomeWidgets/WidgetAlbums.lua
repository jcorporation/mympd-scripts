-- {"name": "WidgetAlbums", "file": "HomeWidgets/WidgetAlbums.lua", "version": 2, "desc": "Home widget for albums.", "order":0,"arguments":["view|select;newest;random","entries"]}
local headers = "Content-type: text/html\r\n"
local entries
local method
local options
if not mympd.isnilorempty(mympd_arguments.entries) then
    entries = tonumber(mympd_arguments.entries)
else
    entries = 10
end

if mympd_arguments.view == "newest" then
    method = "MYMPD_API_DATABASE_ALBUM_LIST"
    options = {
        expression = "",
        sort = "Last-Modified",
        sortdesc = false,
        fields = {
            "AlbumArtist",
            "Album"
        },
        offset = 0,
        limit = entries
    }
elseif mympd_arguments.view == "random" then
    method = "MYMPD_API_DATABASE_LIST_RANDOM"
    options = {
        plist = "Database",
        quantity = entries,
        mode = 2
    }
else
    return mympd.http_reply("200", headers, "<p>Invalid view</p>")
end
local rows = {}
local rc, result = mympd.api(method, options)
if rc == 0 then
    for _,data in ipairs(result.data)
    do
        table.insert(rows, "<div class=\"list-group-item list-group-item-action clickable\" data-href='{\"cmd\":\"gotoAlbum\",\"options\":[\"" .. data.AlbumId .. "\"]}'>" ..
            mympd.htmlencode(data.Album) .. "<br/><small>" ..
            mympd.htmlencode(table.concat(data.AlbumArtist, ", ")) .. "</small></div>")
    end
end

local body = "<div class=\"list-group list-group-flush\">" ..
    table.concat(rows) ..
    "</div>"

return mympd.http_reply("200", headers, body)
