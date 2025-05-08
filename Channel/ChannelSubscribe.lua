-- {"name": "ChannelSubscribe", "file": "Channel/ChannelSubscribe.lua", "version": 3, "desc": "Subscribes to a MPD channel.", "order":0, "arguments":["channel"]}

local rc, msg = mympd.check_arguments({channel = "notempty"})
if rc == false then
    return mympd.jsonrpc_error(msg)
end

local result
rc, result = mympd.api("MYMPD_API_CHANNEL_SUBSCRIBE", {
    channel = mympd_arguments.channel
})

if rc == 1 then
    return "Failure subscribing to the channel: " .. result.data.msg
end
