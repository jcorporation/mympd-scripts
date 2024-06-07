-- {"order":1,"arguments":[]}

mympd.init()

local extensions = {
    "webp",
    "jpg",
    "jpeg",
    "png",
    "avif"
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
            return true
        end
    end
    return false
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
        if not check_image(path) then
            local out = mympd.tmp_file()
            local uri = mympd_state.mympd_uri .. 'albumart-thumb?offset=0&uri=' .. mympd.urlencode(album.uri)
            rc, code, headers = mympd_http_download(uri, out)
            if rc == 0 then
                local name = mympd.covercache_write(out, album.uri)
                mympd.log(6, "Covercache: " .. name)
                downloaded = downloaded + 1
            else
                errors = errors + 1
            end
        else
            existing = existing + 1
        end
    end
end

return "Existing: " .. existing .. ", Downloaded: " .. downloaded .. ", Errors: " .. errors
