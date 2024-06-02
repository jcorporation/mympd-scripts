-- {"order":1,"arguments":[]}

local p_coverartarchive = {
    name = "Coverartarchive",
    get = function(song, out)
        if not song.MUSICBRAINZ_ALBUMID then
            return 1
        end
        return mympd.http_download("https://coverartarchive.org/release/" .. song.MUSICBRAINZ_ALBUMID .. "/front", out)
    end
}

local p_fanart_tv = {
    name = "Fanart.tv",
    get = function(song, out)
        if not mympd_env.var_fanart_tv_api_key or
           not song.MUSICBRAINZ_ARTISTID or
           not song.MUSICBRAINZ_RELEASEGROUPID
        then
            return 1
        end
        local uri = "http://webservice.fanart.tv/v3/music/" .. song.MUSICBRAINZ_ARTISTID[1] .. "?api_key=" .. mympd_env.var_fanart_tv_api_key
        local rc, code, header, body = mympd.http_client("GET", uri, "", "")
        if rc == 1 then
            return 1
        end
        local data = json.decode(body)
        if not data then
            mympd.log(7, "Invalid json data received")
            return 1
        end
        if not data.albums[song.MUSICBRAINZ_RELEASEGROUPID] or
           not data.albums[song.MUSICBRAINZ_RELEASEGROUPID].albumcover or
           not data.albums[song.MUSICBRAINZ_RELEASEGROUPID].albumcover[1] or
           not data.albums[song.MUSICBRAINZ_RELEASEGROUPID].albumcover[1].url
        then
            mympd.log(7, "Album not found")
            return 1
        end
        return mympd.http_download(data.albums[song.MUSICBRAINZ_RELEASEGROUPID].albumcover[1].url, out)
    end
}

-- Return the providers as lua table
-- You can use this table to sort or disable providers
return {
    p_coverartarchive,
    p_fanart_tv
}
