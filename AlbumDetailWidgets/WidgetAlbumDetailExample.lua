-- {"name": "WidgetAlbumDetailExample", "file": "AlbumDetailWidgets/WidgetAlbumDetailExample.lua", "version": 2, "desc": "Example widget for album detail view.", "order":0,"arguments":["AlbumId","Album","AlbumArtist"]}
local response_headers = "Content-type: text/html\r\n"

local response_body = "<div><ul>" ..
    "<li>" .. mympd_arguments.AlbumId .. "</li>" ..
    "<li>" .. mympd_arguments.Album .. "</li>" ..
    "<li>" .. mympd_arguments.AlbumArtist .. "</li>" ..
    "</ul></div>"
return mympd.http_reply("200", response_headers, response_body)
