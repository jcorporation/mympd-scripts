-- {"name": "WidgetAlbumDetail", "file": "AlbumDetailWidgets/WidgetAlbumDetail.lua", "version": 1, "desc": "Album details from various providers.", "order":0,"arguments":["AlbumId","Album","AlbumArtist","MUSICBRAINZ_RELEASEGROUPID","MUSICBRAINZ_ALBUMID"]}
local response_headers = "Content-type: text/html\r\n"

local provider_TheAudioDB = {
    name = "The Audio DB",
    fetch = function()
        if mympd.isnilorempty(mympd_arguments.MUSICBRAINZ_RELEASEGROUPID) then
            return nil
        end
        local uri = string.format("https://www.theaudiodb.com/api/v1/json/123/album-mb.php?i=%s",
            mympd.urlencode(mympd_arguments.MUSICBRAINZ_RELEASEGROUPID)
        )
        local rc, code, headers, body = mympd.http_client("GET", uri, "", "", true)
        if rc > 0 then
            return nil
        end
        local data = json.decode(body)
        if data.album ~= nil and data.album[1] ~= nil then
            return data.album[1].strDescription
        end
        return nil
    end
}

local provider_LastFM = {
    name = "Last.FM",
    fetch = function()
        if mympd.isnilorempty(mympd_env.var.lastfm_api_key) then
            return nil
        end
        local uri = nil
        if not mympd.isnilorempty(mympd_arguments.MUSICBRAINZ_ALBUMID) then
            uri = string.format("http://ws.audioscrobbler.com/2.0/?method=album.getinfo&api_key=%s&format=json&mbid=%s",
                mympd_env.var.lastfm_api_key,
                mympd.urlencode(mympd_arguments.MUSICBRAINZ_ALBUMID)
            )
        else
            uri = string.format("http://ws.audioscrobbler.com/2.0/?method=album.getinfo&api_key=%s&format=json&artist=%s&album=%s",
                mympd_env.var.lastfm_api_key,
                mympd.urlencode(mympd_arguments.AlbumArtist),
                mympd.urlencode(mympd_arguments.Album)
            )
        end
        local rc, code, headers, body = mympd.http_client("GET", uri, "", "", true)
        if rc > 0 then
            return nil
        end
        local data = json.decode(body)
        if data.album ~= nil and data.album.wiki ~= nil then
            if data.album.wiki.content ~= nil
            then
                return data.album.wiki.content
            end
            return data.album.wiki.summary
        end
        return nil
    end
}

local providers = {
    provider_LastFM,
    provider_TheAudioDB
}

-- Fetch the album details
for _, provider in pairs(providers) do
    mympd.log(6, "Try to fetch album details from " .. provider.name)
    local album_desc = provider.fetch()
    if album_desc ~= nil then
        return mympd.http_reply("200", response_headers, string.format("<div class=\"scriptResponse\">%s</div>", album_desc))
    end
end

-- No album details found
mympd.log(7, "No album description found for " .. mympd_arguments.MUSICBRAINZ_RELEASEGROUPID)
return mympd.http_reply("200", response_headers, "")
