-- {"name": "WidgetSongs", "file": "HomeWidgets/WidgetSongs.lua", "version": 3, "desc": "Home widget for songs.", "order":0,"arguments":["view|select;newest;random","entries"]}
local headers = "Content-type: text/html\r\n"
local entries
local method
local options
if  mympd.isnilorempty(mympd_arguments.entries) then
    entries = 10
else
    entries = tonumber(mympd_arguments.entries)
end

if mympd_arguments.view == "newest" then
    method = "MYMPD_API_DATABASE_SEARCH"
    options = {
        expression = "(base '')",
        sort = "Last-Modified",
        sortdesc = false,
        fields = {
            "Artist",
            "Title"
        },
        offset = 0,
        limit = entries
    }
elseif mympd_arguments.view == "random" then
    method = "MYMPD_API_DATABASE_LIST_RANDOM"
    options = {
        plist = "Database",
        quantity = entries,
        mode = 1
    }
else
    return mympd.http_reply("200", headers, "<p>Invalid view</p>")
end
local rows = {}
local rc, result = mympd.api(method, options)
if rc == 0 then
    for _,data in ipairs(result.data)
    do
        table.insert(rows, "<div class=\"list-group-item list-group-item-action clickable\" data-href='{\"cmd\":\"songDetails\",\"options\":[" ..
            json.encode(mympd.htmlencode(data.uri)) .. "]}'>" .. mympd.htmlencode(data.Title) .. "<br/><small>" ..
            mympd.htmlencode(table.concat(data.Artist, ", ")) .. "</small></div>")
    end
end

local body = "<div class=\"list-group list-group-flush\">" ..
    table.concat(rows) ..
    "</div>"

return mympd.http_reply("200", headers, body)
