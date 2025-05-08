-- {"name": "ListenBrainzPlaylistImport", "file": "ListenBrainz/ListenBrainzPlaylistImport.lua", "version": 4, "desc": "Imports generated playlists from ListenBrainz.", "order":1, "arguments":[]}
if mympd.isnilorempty(mympd_env.var.listenbrainz_token) then
    return mympd.jsonrpc_error("No ListenBrainz token set")
end

local extra_headers = "Authorization: Token " .. mympd_env.var.listenbrainz_token .. "\r\n"

local function fetch_playlists()
    local uri = "https://api.listenbrainz.org/1/user/" ..
        mympd_env.var.listenbrainz_username .. "/playlists/createdfor"
    local rc, code, headers, body = mympd.http_client("GET", uri, extra_headers, "")
    if rc == 1 then
        return "Failure fetching playlists"
    end
    local playlists = json.decode(body)
    if playlists == nil then
        return mympd.jsonrpc_error("Failure decoding response from ListenBrainz")
    end
    local values = {}
    local displayValues = {}
    for _, playlist in pairs(playlists.playlists) do
        table.insert(values, playlist.playlist.identifier)
        table.insert(displayValues, { title = playlist.playlist.title })
    end
    local data = {
        { name = "Action", type = "hidden", value = "Import" },
        { name = "Playlists", type = "list", displayValue = displayValues, value = values, defaultValue = "" }
    }
    return mympd.dialog("ListenBrainz Playlists", data, "ListenBrainzPlaylistImport")
end

local function import_playlist(playlist_uri)
    local mbid = string.gsub(playlist_uri, "(.*/)(.*)", "%2")
    local uri = "https://api.listenbrainz.org/1/playlist/" .. mbid
    local rc, code, header, body = mympd.http_client("GET", uri, extra_headers, "")
    if rc == 1 then
        return mympd.jsonrpc_error("Failure fetching playlist " .. mbid)
    end
    local playlist = json.decode(body)
    if playlist == nil then
        return "Failure decoding response from ListenBrainz"
    end
    for _, track in pairs(playlist.playlist.track) do
        mympd.api("MYMPD_API_PLAYLIST_CONTENT_APPEND_SEARCH", {
            plist = playlist.playlist.title,
            expression = "((Title == '" .. track.title .. "') AND (Artist == '" .. track.creator .. "'))",
            sort = "Title",
            sortdesc = false
        })
    end
end

if mympd_arguments.Action == "Import" then
    for playlist in string.gmatch(mympd_arguments.Playlists, "[^;;]+") do
        import_playlist(playlist)
    end
    return "Playlist(s) imported"
end

return fetch_playlists()
