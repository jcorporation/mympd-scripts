-- {"name": "WidgetAlbums", "file": "HomeWidgets/WidgetLastFMsimilarArtists.lua", "version": 2, "desc": "Home widget for Last.fm similar artists.", "order":0,"arguments":["entries"]}
local response_headers = "Content-type: text/html\r\n"

if mympd.isnilorempty(mympd_env.var.lastfm_api_key) then
    local response_body = "<div class=\"text-center p-3\">No Last.fm API Key set</div>"
    return mympd.http_reply("200", response_headers, response_body)
end

local entries
local rc, msg = mympd.check_arguments({entries = "number"})
if rc == false then
    entries = 10
else
    entries = tonumber(mympd_arguments.entries)
end

mympd.init()
if not mympd_state.current_song then
    local response_body = "<div class=\"text-center p-3\">Not playing</div>"
    return mympd.http_reply("200", response_headers, response_body)
end

local artist = mympd.firstTableValue(mympd_state.current_song.Artist)
if artist == "" then
    local response_body = "<div class=\"text-center p-3\">No artist set.</div>"
    return mympd.http_reply("200", response_headers, response_body)
end

local uri = string.format("https://ws.audioscrobbler.com/2.0/?method=artist.getsimilar&limit=%d&artist=%s&format=json&api_key=%s",
    entries,
    mympd.urlencode(artist),
    mympd_env.var.lastfm_api_key
)
local code, headers, body
rc, code, headers, body = mympd.http_client("GET", uri, "", "")
if rc ~= 0 then
    local response_body = "<div class=\"text-center p-3\">Invalid response from Last.fm.</div>"
    return mympd.http_reply("200", response_headers, response_body)
end

local result = json.decode(body)
if not result.similarartists.artist then
    local response_body = "<div class=\"text-center p-3\">No similar artists found.</div>"
    return mympd.http_reply("200", response_headers, response_body)
end

local rows = {}
for _,data in ipairs(result.similarartists.artist)
do
    table.insert(rows, "<div class=\"list-group-item list-group-item-action clickable\" data-href='{\"cmd\":\"gotoAlbumList\",\"options\":[" ..
            "\"Artist\"" .. "," .. json.encode(mympd.htmlencode(data.name)) .. "]}'>" .. mympd.htmlencode(data.name) .. "<small class=\"float-end\">(" ..
            "<a target=\"_blank\" href=\"" .. mympd.htmlencode(data.url) .. "\">Last.FM</a>)</small></div>")
end
local response_body = "<div class=\"list-group list-group-flush\">" ..
    table.concat(rows) ..
    "</div>"
return mympd.http_reply("200", response_headers, response_body)
