-- {"name": "WidgetAlbums", "file": "PlaybackWidgets/WidgetLastFMsimilarArtists.lua", "version": 1, "desc": "Playback widget for Last.fm similar artists.", "order":0,"arguments":[]}
local response_headers = "Content-type: text/html\r\n"

if mympd.isnilorempty(mympd_env.var.lastfm_api_key) then
    local response_body = "<div class=\"text-center p-3\">No Last.fm API Key set</div>"
    return mympd.http_reply("200", response_headers, response_body)
end

local entries = 5

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
local rc, code, headers, body = mympd.http_client("GET", uri, "", "")
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
    table.insert(rows, "<li><span class=\"clickable\" data-href='{\"cmd\":\"gotoAlbumList\",\"options\":[" ..
            "\"Artist\"" .. "," .. json.encode(mympd.htmlencode(data.name)) .. "]}'>" .. mympd.htmlencode(data.name) .. "</span>&nbsp;&ndash;&nbsp;<small>" ..
            "<a target=\"_blank\" href=\"" .. mympd.htmlencode(data.url) .. "\">Last.FM</a></small></li>")
end
local response_body = "<div><h4>Similar Artists</h4>" .. "<ul>" .. table.concat(rows) .. "</ul></div>"
return mympd.http_reply("200", response_headers, response_body)
