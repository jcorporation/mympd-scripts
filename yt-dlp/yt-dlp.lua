-- {"name": "yt-dlp", "file": "yt-dlp/yt-dlp.lua", "version": 2, "desc": "Stream music from YouTube and other services with the help of yt-dlp.", "order":0, "arguments":["uri"]}

-- yt-dlp helper functions
local yt_dlp_path = "yt-dlp"
local yt_dlp_cache = string.gsub((os.getenv("TMPDIR") or "/tmp"), "/+$", "").. "/yt-dlp"

local function yt_dlp_call(uri, parse_json, ...)
    local args = {...}
    local cmd = string.format(
      "'%s' --cache-dir '%s' --paths 'temp:%s' %s '%s' 2>/dev/null",
      yt_dlp_path, yt_dlp_cache, yt_dlp_cache, table.concat(args, " "), uri
    )
    mympd.log(6, "running command: " .. cmd)
    local output = mympd.os_capture(cmd)

    -- check result from yt-dlp for malformed format or bad data
    if string.sub(output, 1, 2) == "NA" then
        mympd.log(3, "bad format or no metadata: " ..output)
        error("yt-dlp failed to parse --format string, or returned no usable metadata!")
    end

    if not parse_json then
        -- return string if we don't have to parse json
        return output
    elseif not output or output == "" then
        -- return an empty table if there isn't output
        return {}
    else
        -- remove any trailing commas, pack into json array, and parse
        return json.decode("[" ..string.gsub(output, ",+$", "").. "]")
    end
end

local extensions = {
    "webp",
    "jpg",
    "jpeg",
    "png",
    "avif",
    "svg"
}

local function file_exists(name)
    local f = io.open(name,"r")
    if f ~= nil then
        io.close(f)
        return true
    end
    return false
end

local function check_image(base)
    for _, ext in ipairs(extensions) do
        local p = base .. "." .. ext
        if file_exists(p) then
            return p
        end
    end
    return nil
end

-- uri argument is required
if mympd_arguments.uri == "" then
    return "No URI provided"
end

if mympd_env.scriptevent == "http" then
    -- calling from a stream play event: redirect to the real stream URI
    local uri = yt_dlp_call(mympd_arguments.uri, false,
        "--format bestaudio",
        "--print '%(urls)s'")
    if not uri or uri == "" then
        error("yt-dlp did not return a URI for this track: " ..mympd_arguments.uri)
    end
    return mympd.http_redirect(uri)
else
    -- calling from user invocation/API
    mympd.notify_client(0, "Starting yt-dlp...")
    mympd.init()

    local misc_cache = mympd_env.cachedir_misc .. "/"

    -- look up the uri
    local results = yt_dlp_call(mympd_arguments.uri, true,
        "--print '%(.{" ..
            "id,webpage_url,availability,thumbnails_table," ..
            "fulltitle,title,episode," ..
            "artist,album_artist,composer,creator,channel,uploader," ..
            "album,playlist_title,series,season," ..
            "disc_number,season_number," ..
            "track_number,playlist_index,episode_number,playlist_count," ..
            "genre,release_date,description,extractor,extractor_key})j,'",
        "--no-simulate",
        "--skip-download",
        "--write-thumbnail",
        "--output 'thumbnail:" .. misc_cache .. "%(id)s.%(ext)s'",
        "--flat-playlist")
    if #results < 1 then
        return "No streams found"
    end

    -- generate script URIs and process metadata to create the streams
    local uri_format = string.format(
        "%sscript/%s/%s?uri=%%s",
        mympd_state.mympd_uri_plain,
        mympd_env.partition,
        mympd.urlencode(mympd_env.scriptname)
    )
    for i, x in ipairs(results) do
        local uri = string.format(uri_format, mympd.urlencode(x.webpage_url))

        -- special processing for some values
        local title = x.fulltitle or x.title or x.episode or uri
        if x.availability and x.availability ~= "public" then
            -- notify if stream is not public, to signal it will probably not play
            title = "[" ..x.availability.. "] " .. title
        end

        local album = x.album or x.playlist_title
        if not album then
            if x.series and x.season then
                album = x.series.. " / " ..x.season
            else
                album = x.series or x.season or x.extractor_key
            end
        end

        local track = x.track_number or x.playlist_index or x.episode_number
        if track then
            track = tostring(track)
        end
        if x.playlist_count then
            track = track.. "/" ..tostring(x.playlist_count)
        end

        local disc = x.disc_number or x.season_number
        if disc then
            disc = tostring(disc)
        end

        local comment = "[" ..mympd_env.scriptname.. "] " .. x.extractor.. ": " .. x.webpage_url
        if x.webpage_url ~= mympd_arguments.uri then
            comment = comment.. " | from: " ..mympd_arguments.uri
        end
        if x.description then
            -- replace illegal characters from the tag value with a space
            comment = comment.. " | " .. string.gsub(x.description, "[\r\n\t]+", " ")
        end
        if #comment > 3000 then
            comment = string.sub(comment, 1, 3000 - 3) .. "..."
        end

        -- build metadata table
        local meta = {
          title   = title,
          artist  = x.artist or x.album_artist or x.composer or
                    x.creator or x.channel or x.uploader,
          album   = album,
          disc    = disc,
          track   = track,
          genre   = x.genre,
          date    = x.release_date,
          comment = comment
        }

        local thumb = check_image(misc_cache .. x.id)
        if thumb == nil then
            -- yt-dlp didn't download the thumbnail or it doesn't have one, download it
            -- Workaround for: https://github.com/yt-dlp/yt-dlp/issues/9983
            local thumbs = {}
            for id, w, h, th in string.gmatch(x.thumbnails_table.."\n", "(%w+)%s+(%w+)%s+(%w+)%s+(%g+)[\r\n]+") do
                if id ~= "ID" then
                    w = tonumber(w) or 0
                    h = tonumber(h) or 0
                    table.insert(thumbs, {size = w + h, thumb = th})
                end
            end
            if #thumbs > 0 then
                table.sort(thumbs, function(a, b) return a.size > b.size end)
                thumb = thumbs[1].thumb
                if thumb and thumb ~= "" then
                    local tmp_file = mympd.tmp_file()
                    mympd.log(6, "Downloading " .. thumb .. " to " ..tmp_file)
                    local rc, code, headers = mympd.http_download(thumb, "", tmp_file)
                    if rc == 0 then
                        rc = mympd.cache_cover_write(tmp_file, uri)
                        if rc == 1 then
                            mympd.notify_client(2, "Failed to rename thumbnail!")
                        end
                    else
                        mympd.notify_client(2, "Failed to download thumbnail!")
                    end
                end
            end
        else
            -- if yt-dlp downloaded the thumbnail, rename it from id to hash
            local rc = mympd.cache_cover_write(thumb, uri)
            if rc == 1 then
                mympd.notify_client(2, "Failed to rename thumbnail!")
            end
        end

        -- append result to the queue and set tags
        -- NOTE: change to MYMPD_API_QUEUE_INSERT_URI_TAGS
        --       or MYMPD_API_QUEUE_REPLACE_URI_TAGS if you prefer
        mympd.api("MYMPD_API_QUEUE_APPEND_URI_TAGS", {uri = uri, tags = meta, play = false})
    end
end