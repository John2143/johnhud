setmetatable(jhud.chat, {
	__call = function(_,name,message,color)
		if not message then
			message = name
			name = jhud.chat.icons.Skull
		end
		if managers and managers.chat and managers.chat._receivers and managers.chat._receivers[1] then
			for __,rcv in pairs( managers.chat._receivers[1] ) do
				rcv:receive_message(name, tostring(message), color or Color(1,1,1))
			end
		end
	end
})

function this:chatAll(text, toself)
	managers.network:session():send_to_peers_ip_verified( 'send_chat_message', 1, text)
	if not toself then self("JohnHUD", text) end
end

local Icon = {
	A=57344, B=57345,	X=57346, Y=57347, Back=57348, Start=57349,
	Skull = 57364, Ghost = 57363, Dot = 1031, Chapter = 1015, Div = 1014, BigDot = 1012,
	Times = 215, Divided = 247, LC=139, RC=155, DRC = 1035, Deg = 1024, PM= 1030, No = 1033
}
jhud.chat.icons = {}
for k,v in pairs(Icon) do
	jhud.chat.icons[k] = utf8.char(v)
end

function this:sterileEmotes(text)
	-- print("text is "..text)
	for i,v in pairs(jhud.chat.icons) do
		text = string.gsub(text, string.format("%%%%%s%%%%", i:lower()), v) --lua for best regex of 2015
	end
	return text
end
function this:__init()
	jhud.hook("HUDChat", "receive_message", function(self, name, message)
		return {
			[2] = jhud.chat:sterileEmotes(name),
			[3] = jhud.chat:sterileEmotes(message)
		}
	end)
end
