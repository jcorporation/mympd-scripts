-- {"name": "Tagart", "file": "Tagart/Tagart.lua", "version": 4, "desc": "Fetches tagart on demand.", "order":0, "arguments":["tag", "value"]}
local providers = require "scripts/TagartProviders"

local rc, msg = mympd.check_arguments({tag = "notempty", value = "notempty"})
if rc == false then
    return msg
end

local tag = mympd_arguments.tag
local value = mympd_arguments.value
mympd.log(7, "Fetching tagart for " .. tag .. "=" .. value)

local out = mympd.tmp_file()
if out == nil then
    mympd.log(3, "Failure creating tmp file.")
    return mympd.http_redirect("/assets/coverimage-notavailable")
end

rc = 1
for _, provider in pairs(providers) do
    if provider.tags[tag] then
        rc = provider.get(tag, value, out)
        if rc == 0 then
            mympd.log(6, "Tagart found on " .. provider.name)
            break
        end
    end
end

if rc == 1 then
    mympd.remove_file(out)
    return mympd.http_redirect("/assets/coverimage-notavailable")
end

-- Cache the fetched tagart and send it to the client
local filename
rc, filename = mympd.cache_thumbs_write(out, value, nil)
if rc == 0 then
    return mympd.http_serve_file(filename)
end

return mympd.http_redirect("/assets/coverimage-notavailable")
