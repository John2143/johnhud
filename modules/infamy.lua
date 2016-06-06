jhud.rlib("file")
function this:setInfamy(rank)
    if managers and managers.experience then
--its up to you whether or not you use this: you wont receive a CHEATER tag, you won't
-- get banned by ovk, but I'm not going to implment it anywhere as a base feature in johnhud.
--PS you wont receive the actual infamy points or achievements.
--This does permanantly save to your playerfile, so its up to you to keep track.
--Current max infamy: 5
--Current hard coded max: 7
--Hype train hype: 25
        managers.experience._global.rank = jhud.digest(rank)
    end
end
function this:getInfamy()
    return jhud.undigest(managers.experience._global.rank)
end
function this:oldInfamy(rank)
    rank = rank or 0
    local values = {
        {1, "I"},
        {4, "IV"},
        {5, "V"},
        {9, "IX"},
        {10, "X"},
        {40, "XL"},
        {50, "L"},
        {90, "LC"},
        {100, "C"},
    }
    local retstr = ''
    for i = #values, 1, -1 do
        if rank == 0 then break end --not necessary but may be faster
        local num = values[i][1]
        while(rank >= num) do
            retstr = retstr..values[i][2]
            rank = rank - num
        end
    end
    return retstr
end
function this:restoreInfamy()
    jhud.hook("ExperienceManager", "rank_string", function(em, rank)
        return self:oldInfamy(rank)
    end, jhud.hook.OVERRIDE)
end

function this:emptyTree()
    local st = {}
    for i,v in pairs(self.st.skills) do
        st[i] = {
            total = v.total,
            unlocked = 0,
        }
    end
    return st
end

function this:emptySSTree()
    local ss = {}
    local zero = jhud.digest(0)
    for i = 1, 5 do
        ss[i] = {points_spent = zero, unlocked = false}
    end
    return ss
end
function this:emptySwitch()
    return {
        points = jhud.digest(120),
        skills = self:emptyTree(),
        unlocked = true,
        specialization = jhud.digest(4), --perk deck default is 4 -> rogue
        trees = self:emptySSTree(),
    }
end
function this:newSkillTree(name)
    local skilldata = self:emptySwitch()
    name = name or "Unnamed"
    skilldata.name = name
    self:saveTree(name, skilldata, true)
    self:initSkillTree(name, skilldata)

    table.insert(self.skilltrees, name)
    self:saveTrees()
end
function this:removeSkillTree(name)
    table.delete(self.skilltrees, name)
    self:saveTrees()

    self:doInitSkilltrees()
end
function this:saveSkillTree()
    local ss = self.st.selected_skill_switch
    local jhudtree = ss - self.lastRealTree
    if jhudtree < 1 then return end --overkill implemented tree
    local treename = self.skilltrees[jhudtree]

    self:saveTree(treename, ss)
end
function this:initSkillTree(name, data)
    local skilldata = data or self:loadTree(name)

    self.st.skill_switches[self.nextskilltree] = skilldata
    --managers.skilltree:set_skill_switch_name(self.nextskilltree, name:upper())
    self.nextskilltree = self.nextskilltree + 1
end
function this:doInitSkilltrees()
    local sw = self.st.skill_switches
    for i,v in pairs(sw) do
        if i > self.lastRealTree then
            sw[i] = nil
        end
    end
    self.nextskilltree = self.lastRealTree + 1 --the next skilltree
    for i,v in ipairs(self.skilltrees) do
        self:initSkillTree(v)
    end
    if self.st.selected_skill_switch >= self.nextskilltree then
        self.st.selected_skill_switch = 0
    end
end
function this:renameSkillTree(id, new)
    local ss = id - self.lastRealTree
    local old = self.skilltrees[ss]
    self.skilltrees[ss] = new

    self:saveTrees()
    self:saveTree(new, id)
end
local path = "skilltree/"
function this:loadTree(name)
    return jhud.load(path..name)
end
function this:saveTree(name, id, notID)
    if notID then
        jhud.save(path..name, id)
    else
        jhud.save(path..name, self.st.skill_switches[id])
    end
end
function this:saveTrees() --recycling helps :)
    jhud.save("skilltrees", self.skilltrees)
end
function this:numJHUDTrees()
    return #self.skilltrees
end
function this:treeIndex(id)
    return id - self.lastRealTree
end
function this:isJHUDTree(id)
    return self:treeIndex(id) > 0
end
function this:createSkilltreeButton()
    local stg = managers.menu_component._skilltree_gui
    local lastpanel = stg._skill_tree_panel:child("switch_skills_button")
    local pan = stg._panel:text{
        name = "jhud_newskilltree",
        text = self.lang("newtree"),
        font_size = lastpanel:font_size(),
    }
    pan:set_top(lastpanel:top())
    pan:set_left(lastpanel:left())
end
function this:__init(carry)
    if not managers.skilltree then return end
    self.st = managers.skilltree._global
    self.lastRealTree = 5
    self.skilltrees = jhud.load('skilltrees')
    self:doInitSkilltrees()
    jhud.hook("SkillTreeGui", "_stop_rename_skill_switch", function(stg)
        local id = self.st.selected_skill_switch
        if self:isJHUDTree(id) then
            self:renameSkillTree(id, stg._renaming_skill_switch)
        end
    end)
    jhud.hook("SkillTreeManager", "save", function(stm, data)
        for i,v in pairs(self.st.skill_switches) do
            if self:isJHUDTree(i) then
                self:saveTree(self.skilltrees[self:treeIndex(i)], i)
            end
        end
    end)
    --[[ Will implement later
    if managers.menu_component then
        self:createSkilltreeButton()
    else
        jhud.hook("SkillTreeGui", "_setup", function()
            self:createSkilltreeButton()
        end, jhud.hook.POSTHOOK)
    end
    ]]
    if self.config.useRoman then
        self:restoreInfamy()
    end
    self.lang = L:new("skilltree")
    if jhud.chat then
        jhud.chat:addCommand("skillset", function(chat, ...)
            local isnew, name, delete, force
            for i,v in pairs{...} do
                if v == "-n" or v == "--new" then
                    isnew = true
                elseif v == "-d" or v == "--delete" then
                    delete =  true
                elseif v == "-f" or v == "--force" then
                    force = true
                else
                    name = v
                end
            end

            if isnew then
                self:newSkillTree(name)
                chat("SKSET", self.lang("new"), chat.config.spare1)
            else
                local setid = tonumber(name)
                if not setid then
                    if not name then return chat.MISSING_ARGUMENTS end
                    local multi = {}
                    for i,v in pairs(self.st.skill_switches) do
                        if managers.skilltree:get_skill_switch_name(i):lower():find(name:lower()) then
                            setid = i
                            table.insert(multi, v.name)
                        end
                    end
                    if multi[2] then
                        chat("SKSET", self.lang("multi"):format(table.concat(multi, ", ")), chat.config.failed)
                        return
                    end
                end
                if not setid then chat("SKSET", self.lang("none"), chat.config.failed) end
                if delete then
                    if self:isJHUDTree(setid) then
                        if jhud.undigest(self.st.skill_switches[setid].points) < 120 and not force then
                            chat("SKSET", self.lang("notempty"), chat.config.failed)
                        else
                            local treename = self.skilltrees[self:treeIndex(setid)]
                            self:removeSkillTree(treename)
                            chat("SKSET", self.lang("removed"):format(treename), chat.config.spare1)
                        end
                    else
                        chat("SKSET", self.lang("notjhud"), chat.config.failed)
                    end
                else
                    if managers.job and
                        managers.job._global.current_job and
                        managers.job._global.current_job.last_completed_stage ~= 0 and
                        not force
                    then

                        chat("SKSET", self.lang("betweendays"), chat.config.failed)
                    else
                        chat("SKSET", self.lang("changed"):format(managers.skilltree:get_skill_switch_name(setid)), chat.config.spare1)
                        managers.skilltree:switch_skills(setid)
                    end
                end
            end
        end)
    end
end
