-- {"name": "ChannelSubscribe", "file": "Channel/ChannelSubscribe.lua", "version": 1, "desc": "Subscribes to a MPD channel.", "order":0, "arguments":["channel"]}

local channel = mympd_arguments.channel
if not channel or channel == "" then
    channel = "myMPD"
end

local rc, result = mympd.api("MYMPD_API_CHANNEL_SUBSCRIBE", {
    channel = channel
})

if rc == 1 then
    return "Failure subscribing to the channel: " .. result.data.msg
end
