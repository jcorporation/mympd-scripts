-- {"name": "WidgetMostPlayedAlbums", "file": "HomeWidgets/WidgetMostPlayedAlbums.lua", "version": 2, "desc": "Home widget for most played albums.", "order":0,"arguments":["entries"]}
local headers = "Content-type: text/html\r\n"
local entries
if mympd.isnilorempty(mympd_arguments.entries) then
    entries = 10
else
    entries = tonumber(mympd_arguments.entries)
end
local options = {
    uri = "",
    type = "filter",
    name = "playCount",
    op = "gt",
    value = "0",
    sort = "value_int",
    sortdesc = true,
    offset = 0,
    limit = entries
}
local rows = {}
local rc, result = mympd.api("MYMPD_API_STICKER_FIND", options)
if rc == 0 then
    for _,data in ipairs(result.data)
    do
        local albums
        rc, albums = mympd.api("MYMPD_API_DATABASE_ALBUM_LIST", {
            expression = data.uri,
            sort = "Album",
            sortdesc = false,
            offset = 0,
            limit = 1,
            fields = {"AlbumArtist", "Album"}
        })
        if rc == 0 then
            table.insert(rows, "<div class=\"list-group-item list-group-item-action clickable\" data-href='{\"cmd\":\"gotoAlbum\",\"options\":[" ..
                json.encode(mympd.htmlencode(albums.data[1].AlbumId)) .. "]}'>" .. mympd.htmlencode(albums.data[1].Album) .. "<br/><small>" ..
                mympd.htmlencode(table.concat(albums.data[1].AlbumArtist, ', ')) .. "</small></div>")
        end
    end
end

local body = "<div class=\"list-group list-group-flush\">" ..
    table.concat(rows) ..
    "</div>"

return mympd.http_reply("200", headers, body)
