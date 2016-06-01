function this:voiceline(line)
    if line and managers.player:player_unit() then
        managers.player:player_unit():sound():say(line,true,true)
        return true
    end
    return false
end
function this:bainline(line, net)
    if not managers.dialog then return end
    if line then
        managers.dialog:queue_dialog(line, {})
    end
    if net and jhud.net and jhud.net:isServer() then
        managers.network:session():send_to_peers_synched("bain_comment", line)
    end
end

this.internalnames = {
    hoxton = 5,
    clover = 7,
    houston = 2,
    wick = 6,
}

function this:__init()
    if not jhud.binds then return end
    for i,v in pairs(jhud.binds.voice) do
        if i ~= "" then
            jhud.bind(i, function()
                self:voiceline(v)
            end)
        end
    end
    for i,v in pairs(jhud.binds.bainlines) do
        if i ~= "" then
            jhud.bind(i, function()
                self:bainline(v, true)
            end)
        end
    end
end
