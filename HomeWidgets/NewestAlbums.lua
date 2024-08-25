-- {"name": "NewestAlbums", "file": "HomeWidgets/NewestAlbums.lua", "version": 1, "desc": "Home widget for newest albums.", "order":0,"arguments":[]}
local headers ="Content-type: text/html\r\n"
local options = {
    expression = "",
    sort = "Added",
    sortdesc = false,
    fields = {
        "AlbumArtist",
        "Album"
    },
    offset = 0,
    limit = 10
}
local rows = {}
local rc, result = mympd.api("MYMPD_API_DATABASE_ALBUM_LIST", options)
if rc == 0 then
    for _,data in ipairs(result.data)
    do
        table.insert(rows, "<div class=\"list-group-item list-group-item-action clickable\" data-href='{\"cmd\":\"gotoAlbum\",\"options\":[\"" .. data.AlbumId .. "\"]}'>" .. data.Album .. "</div>")
    end
end

local body = "<div class=\"list-group list-group-flush\">" ..
    table.concat(rows) ..
    "</div>"

return mympd.http_reply("200", headers, body)
