-- {"name": "CovercachePrepopulate", "file": "Covercache/CovercachePrepopulate.lua", "version": 4, "desc": "Prepopulates the myMPD covercache.", "order":1,"arguments":[]}

mympd.init()

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

local function create_placeholder(filename)
    local f = io.open(filename, "w")
    if f == nil then
        return false
    end
    io.write(f, '<?xml version="1.0" encoding="UTF-8"?><svg width="63.5mm" height="63.5mm" version="1.1" viewBox="0 0 63.5 63.5" xmlns="http://www.w3.org/2000/svg"><g transform="translate(21.167 -117.08)"><rect x="-21.167" y="117.08" width="63.5" height="63.5" fill="#b3b3b3"/><path d="m29.674 133.99v13.978l-6.3634-6.3846-8.4845 8.5057-8.4845-8.4845-8.4845 8.4845-6.3634-6.3846v-9.7148c0-2.3332 1.909-4.2423 4.2423-4.2423h29.696c2.3332 0 4.2423 1.909 4.2423 4.2423zm-6.3634 13.618 6.3634 6.3846v9.6936c0 2.3332-1.909 4.2423-4.2423 4.2423h-29.696c-2.3332 0-4.2423-1.909-4.2423-4.2423v-13.957l6.3634 6.3422 8.4845-8.4845 8.4845 8.4845z" fill="#fff" stroke-width=".26458"/></g></svg>')
    io.close(f)
    return true
end

local rc, result, code, headers

rc, result = mympd.api("MYMPD_API_DATABASE_ALBUM_LIST", {
    offset = 0,
    limit = 10000,
    expression = "",
    sort = "Title",
    sortdesc = false,
    fields = {}
})

local existing = 0
local errors = 0
local downloaded = 0
for _, album in pairs(result.data) do
    if album.uri and album.uri ~= "" then
        local path = mympd_env.cachedir_cover .. "/" .. mympd.hash_sha1(album.uri) .. "-0"
        local existing_file = check_image(path)
        if existing_file ~= nil then
            mympd.update_mtime(existing_file)
            existing = existing + 1
        else
            local out = mympd.tmp_file()
            local uri = mympd_state.mympd_uri .. 'albumart?offset=0&uri=' .. mympd.urlencode(album.uri)
            rc, code, headers = mympd_http_download(uri, "", out)
            if rc == 0 then
                local name
                rc, name = mympd.cache_cover_write(out, album.uri)
                if rc == 0 then
                    mympd.log(6, "Covercache: " .. name)
                    downloaded = downloaded + 1
                else
                    mympd.log(3, "Covercache: " .. name)
                    create_placeholder(path .. ".svg")
                    errors = errors + 1
                end
            else
                errors = errors + 1
                create_placeholder(path .. ".svg")
            end
        end
    end
end

return "Existing: " .. existing .. ", Downloaded: " .. downloaded .. ", Errors: " .. errors
