function this:__init()
    self.file = io.open("lines.txt", "a")
    jhud.hook("SoundSource", "post_event", function(ss, line)
        self:write(line)
    end)
end
function this:__cleanup()
    self.file:close()
end
function this:write(line)
    if not self.file then return end
    self.file:write(Application:time().."\t"..line.."\n")
end
