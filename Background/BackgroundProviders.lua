-- {"name": "BackgroundProviders", "file": "Background/BackgroundProviders.lua", "version": 1, "desc": "Background providers for the Background script.", "order":0,"arguments":[]}

local p_fanart_tv = {
    name = "Fanart.tv",
    get = function(song, out)
        if mympd.isnilorempty(mympd_env.var.fanart_tv_api_key) or
           not song.MUSICBRAINZ_ARTISTID or
           mympd.isnilorempty(song.MUSICBRAINZ_ARTISTID[1])
        then
            return 1
        end
        local uri = "http://webservice.fanart.tv/v3/music/" .. song.MUSICBRAINZ_ARTISTID[1] .. "?api_key=" .. mympd_env.var.fanart_tv_api_key
        local rc, code, header, body = mympd.http_client("GET", uri, "", "", true)
        if rc == 1 then
            return 1
        end
        local data = json.decode(body)
        if not data then
            mympd.log(7, "Invalid json data received")
            return 1
        end
        if not data.artistbackground or
           not data.artistbackground[1] or
           mympd.isnilorempty(data.artistbackground[1].url)
        then
            mympd.log(7, "Background not found")
            return 1
        end
        return mympd.http_download(data.artistbackground[1].url, "", "", true)
    end
}

-- Return the providers as lua table
-- You can use this table to sort or disable providers
return {
    p_fanart_tv
}
