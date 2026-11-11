-- {"name": "WidgetPlaylistDetailExample", "file": "PlaylistDetailWidgets/WidgetPlaylistDetailExample.lua", "version": 2, "desc": "Example widget for playlist detail view.", "order":0,"arguments":["plist","smartpls"]}
local response_headers = "Content-type: text/html\r\n"

local response_body = "<div><ul>" ..
    "<li>" .. mympd_arguments.plist .. "</li>" ..
    "<li>" .. mympd_arguments.smartpls .. "</li>" ..
    "</ul></div>"
return mympd.http_reply("200", response_headers, response_body)
