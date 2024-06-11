-- {"name": "TagartProviders", "file": "Tagart/TagartProviders.lua", "version": 1, "desc": "Tagart providers for the Tagart script.", "order": 0, "arguments":[]}

local p_fanart_tv = {
    name = "Fanart.tv",
    tags = {
        Artist = true,
        AlbumArtist = true
    },
    get = function(tag, value, out)
        if not mympd_env.var_fanart_tv_api_key
        then
            return 1
        end
        local rc, code, header, body, song
        rc, song = mympd.api("MYMPD_API_DATABASE_SEARCH", {
            expression = "((" .. tag .. " == '" .. value .. "') AND (MUSICBRAINZ_ARTISTID != ''))",
            sort = "Title",
            sortdesc = false,
            offset = 0,
            limit = 1,
            fields = {
                "MUSICBRAINZ_ARTISTID"
            }
        })
        if rc ~= 0 or
           not song.data or
           not song.data[1] or
           not song.data[1].MUSICBRAINZ_ARTISTID or
           not song.data[1].MUSICBRAINZ_ARTISTID[1] or
           song.data[1].MUSICBRAINZ_ARTISTID[1] == ""
        then
            mympd.log(7, "MUSICBRAINZ_ARTISTID not found")
            return 1
        end

        local uri = "http://webservice.fanart.tv/v3/music/" .. song.data[1].MUSICBRAINZ_ARTISTID[1] .. "?api_key=" .. mympd_env.var_fanart_tv_api_key
        rc, code, header, body = mympd.http_client("GET", uri, "", "")
        if rc == 1 then
            return 1
        end
        local data = json.decode(body)
        if not data then
            mympd.log(7, "Invalid json data received")
            return 1
        end
        if not data.artistthumb or
           not data.artistthumb[1] or
           not data.artistthumb[1].url
        then
            mympd.log(7, "Tagart not found")
            return 1
        end
        return mympd.http_download(data.artistthumb[1].url, "", out)
    end
}

-- Return the providers as lua table
-- You can use this table to sort or disable providers
return {
    p_fanart_tv
}
