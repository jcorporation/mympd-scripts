-- {"name": "WidgetMostPlayedTag", "file": "HomeWidgets/WidgetMostPlayedTag.lua", "version": 3, "desc": "Home widget for most played tag.", "order":0,"arguments":["tag","entries"]}
local headers = "Content-type: text/html\r\n"

local rc, msg = mympd.check_arguments({tag = "notempty", entries = "number"})
if rc == false then
    local body = "<div class=\"text-center p-3\">" .. msg .. "</div>"
    return mympd.http_reply("500", headers, body)
end

local entries = tonumber(mympd_arguments.entries)
local options = {
    uri = "",
    type = mympd_arguments.tag,
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
        table.insert(rows, "<div class=\"list-group-item list-group-item-action clickable\" data-href='{\"cmd\":\"gotoAlbumList\",\"options\":[" ..
            json.encode(mympd_arguments.tag) .. ", " .. json.encode(mympd.htmlencode(data.uri)) .. "]}'>" .. mympd.htmlencode(data.uri) .. "</div>")
    end
end

local body = "<div class=\"list-group list-group-flush\">" ..
    table.concat(rows) ..
    "</div>"

return mympd.http_reply("200", headers, body)
