jhud.wmod("chat")
jhud.rmod("player")
function this:api(api, data, callback)
    local url = "api.pd2stats.com/%s/?%s"
    local datam = {}
    for i,v in pairs(data) do
        table.insert(datam, i.."="..v)
    end
    Steam:http_request(url:format(api, datam:concat("&")), callback or function() end)
end

function this:__init()
    if not jhud.player then return end
    if jhud.chat then
        self.lang = L:new("pd2stats")
        jhud.chat:addCommand("commend", function(chat, plys, reason)
            local ply = jhud.play:getPlayers(plys)
            reason = reason:lower()
            local reasons = {
                t = "teacher",
                l = "leader",
                f = "kind",
                k = "kind",
                friendly = "kind",
                teacher = true,
                leader = true,
                kind = true,
            }
            local doreason = reasons[reason]
            if doreason == true then
                doreason = reason
            end
            if not doreason then return jhud.chat.MISSING_ARGUMENTS end --TODO make this a chatfail
            local sendids = {}
            for i,v in pairs(plys) do
                self:api("commend/v2", {
                    id = v:cID(),
                    reason = doreason,
                    type = "lua",
                }, self:parseWrapper(v.id))
                table.insert(sendids, v.id)
            end
            if self.config.showCommends then
                jhud.net:sendPure(
                    jhud.net:asNetMethod(
                        jhud.net.TO_PEERS_SPECIFIC,
                        unpack(sendids)
                    ),
                    "jhud.pd2stats.commend",
                    doreason,
                    jhud.net:getPeerID()
                )
            end
            jhud.chat("COMMEND", jhud.chat:nice{
                self.lang("docommend1"),
                plys,
                self.lang("docommend2"):format(doreason),
            }, self.config.commend)
        end)
        jhud.net:hook("jhud.pd2stats.commend", function(reason, from)
            local from = jhud.player:playerByPeerID(tonumber(from))
            local name = from and from:name() or self.lang("someone")
            jhud.chat(
                "COMMEND",
                self.lang("commend"):format(self.lang(reason), name),
                self.config.commend,
                "icon_buy" -- + symbol
            )
        end)
    end
end
function this:__postaddpeer(id)
    if not jhud.player then return end
    local ply = jhud.player:playerByPeerID(id)
    if not ply then return end
    self:api("player_data/v1", {
        type = "lua",
        id = ply:cID()
    }, self:parseWrapper(id))
end
function this:parseWrapper(id)
    return function(success, data)
        local ply = jhud.player:playerByPeerID(id)
        if not ply then return end
        self:parse(player, success, data)
    end
end

function this:parse(ply, success, data)
    if not success then jhud.log("Failed to access pd2stats.com") return end
    local datafunc = loadstring("return "..data)
    if not datafunc then return end
    local succ, pdata = pcall(datafunc)
    if not succ then return end
    if pdata.error_code == 0 then
        ply.pd2skillsdata = {
            commend = pdata.commend_leader,
            teacher = pdata.commend_teacher,
            kind = pdata.commend_kind,
        }
    else
        jhud.log("PD2 api failure: ", pdata.error_code, pdata.error_string)
    end
end
