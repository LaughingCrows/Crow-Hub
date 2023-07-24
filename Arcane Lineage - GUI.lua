--- UI Library
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

--- Overall Settings
local Window = Rayfield:CreateWindow({
   Name = "Arcane Lineage GUI",
   LoadingTitle = "Crow Hub",
   LoadingSubtitle = "by LaughingCrows",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "Crow Hub"
   },
   Discord = {
      Enabled = false,
      Invite = "tgkfNtS5qy",
      RememberJoins = true
   },
   KeySystem = false,
   KeySettings = {
      Title = "Crow Hub",
      Subtitle = "Key System",
      Note = "Join the discord (discord.gg/tgkfNtS5qy)",
      FileName = "CrowKey",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = ""
   }
})



--- Anticheat Bypass
for i,v in next, getgc() do
    if typeof(v) == "function" and islclosure(v) and not isexecutorclosure(v) then
        local Constants = debug.getconstants(v)
        if table.find(Constants, "Detected") and table.find(Constants, "crash") then
            setthreadidentity(2)
            hookfunction(v, function()
                return task.wait(9e9)
            end)
            setthreadidentity(7)
        end
    end
end



--- Combat Tab
local Tab = Window:CreateTab("Combat")

--- All Button Options
local Section = Tab:CreateSection("Buttons:")

--- Always Auto Dudge Button
local Button = Tab:CreateButton({
    Name = "Always Auto Dodge",
    Callback = function()
        --- Auto Dodge
        local old; old = hookmetamethod(game, "__namecall", function(dodge, ...)
            local args = {...} 
            if dodge.Name == "RemoteFunction" and getnamecallmethod() == "FireServer" then
                if typeof(args[1]) == "table" and args[2] == "DodgeMinigame" then
                    args[1] = {true, true}
                    return old(dodge, unpack(args))
                end
            end
            return old(dodge, ...)
        end)
    end,
})

-- Always Max Energy
local Button = Tab:CreateButton({
    Name = "Begin w/ Max Energy",
    Callback = function()
        local LocalPlayer = game:GetService("Players").LocalPlayer

        local listen = function(character)
            character.ChildAdded:Connect(function(obj)
                if obj.Name == "FightInProgress" then
                    for i = 1, 30 do
                        task.wait(.1)
                        LocalPlayer.PlayerGui.Combat.CombatHandle.Meditate:FireServer("bitch")
                    end
                end
            end)
        end

        LocalPlayer.CharacterAdded:Connect(function(character)
            listen(character)
        end)

        listen(LocalPlayer.Character)
    end,
})

--- Respawn Button
local Button = Tab:CreateButton({
    Name = "Emergency Respawn (Semi-Godmode)",
    Callback = function()
        --- Sets health to 0
        game:GetService("Players").LocalPlayer.Character.Humanoid.Health = 0
    end,
})



--- All Toggle Options
local Section = Tab:CreateSection("Toggles:")

--- Faster Dodge Toggle
local Toggle = Tab:CreateToggle({
    Name = "Faster Auto Dodge",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        --- Sets true or false for Thread
        _G.toggle1 = Value

        --- Faster Auto Dodge
        task.spawn(function()
            while _G.toggle1 and task.wait() do
                if game:GetService("Players").LocalPlayer.PlayerGui.Combat.Block.Visible == true then
                    for i = 1, 3 do
                        game:GetService("ReplicatedStorage").Remotes.Information.RemoteFunction:FireServer({true, true}, "DodgeMinigame")
                    end
                    game:GetService("Players").LocalPlayer.PlayerGui.Combat.Block.Visible = false
                end
            end
        end)
    end,
})



--- All Dropdown Options
local Section = Tab:CreateSection("Dropdowns:")

--- Fast Auto Skill Dropdown
local Dropdown = Tab:CreateDropdown({
    Name = "Faster Auto Skill",
    Options = {"Disabled", "Dagger", "Fist", "Magic", "Spear", "Sword"},
    CurrentOption = {"Disabled"},
    MultipleOptions = false,
    Flag = "Dropdown1",
    Callback = function(Option)
        task.spawn(function()
            --- Variables
            local Weapon = Option[1]
            local Player = game:GetService("Players").LocalPlayer.Character
            local CombatUI = game:GetService("Players").LocalPlayer.PlayerGui.Combat.MagicQTE
            local CombatRemote = game:GetService("ReplicatedStorage").Remotes.Information.RemoteFunction
            --- Auto Skill Hook
            local old_; old_ = hookmetamethod(game, "__namecall", function(self, ...)
                local args = {...}
                if self.Name == "RemoteFunction" and getnamecallmethod() == "FireServer" then
                    if args[2] == Weapon.."QTE" then
                        args[1] = true
                        return old_(self, unpack(args))
                    end
                end
                return old_(self, ...)
            end)
            --- Faster Auto Skill
            while task.wait() and Option[1] ~= "Disabled" do
                if Player:FindFirstChild("FightInProgress") and CombatUI.Visible == true or game:GetService("Players").LocalPlayer.PlayerGui.Combat.SpearQTE:FindFirstChild("Dot") then
                    CombatRemote:FireServer(true, Weapon.."QTE")
                    CombatUI.Visible = false
                end
            end
        end)
    end,
})

--- Grab Attack Set
local attackSet = {}
table.insert(attackSet, "Disabled")
for i, v in ipairs(game:GetService("Players").LocalPlayer.PlayerGui.Combat.ActionBG.AttacksPage.ScrollingFrame:GetChildren()) do
    if v.ClassName == "TextButton" then
        table.insert(attackSet, v.Name)
    end
end

--- Priority 1 Auto Skill
local Dropdown = Tab:CreateDropdown({
    Name = "Priority 1 Skill",
    Options = attackSet,
    CurrentOption = {"Disabled"},
    MultipleOptions = false,
    Flag = "Dropdown1",
    Callback = function(Option)
        --- Priority 1 Skill
        task.spawn(function()
            while Option[1] ~= "Disabled" and task.wait(1) do
                --- Variables
                local Skill = Option[1]
                local Player = game:GetService("Players").LocalPlayer.Character
                local CombatUI = game:GetService("Players").LocalPlayer.PlayerGui.Combat.ActionBG
                local CombatRemote = game:GetService("Players").LocalPlayer.PlayerGui.Combat.CombatHandle
                --- Gets Current Stamina
                local Stm = game:GetService("Players").LocalPlayer.PlayerGui.HUD.Holder.EnergyOutline.Count.Text
                local StmTxt = string.gsub(Stm, "/6", "")
                local StmInt = tonumber(StmTxt)
                --- Get Stamina required for Skill
                local SkillCost = CombatUI.AttacksPage.ScrollingFrame:WaitForChild(Skill).Cost.Text
                local SkillCostInt = tonumber(SkillCost)
                ---Combat Handler
                if Player:FindFirstChild("FightInProgress") and StmInt >= SkillCostInt and CombatUI.AttacksPage.ScrollingFrame[Skill].CD.Visible ~= true then
                    for i, v in ipairs(workspace.Living:GetDescendants()) do
                        if v.Name == "FightInProgress" and v.Parent ~= Player and v.Value == Player.FightInProgress.Value then
                            CombatRemote.RemoteFunction:InvokeServer("Attack", Skill, {["Attacking"] = v.Parent})
                            task.wait(1)
                            CombatUI.Visible = false
                        end
                    end
                end
            end
        end)
    end,
})

--- Priority 2 Auto Skill
local Dropdown = Tab:CreateDropdown({
    Name = "Priority 2 Skill",
    Options = attackSet,
    CurrentOption = {"Disabled"},
    MultipleOptions = false,
    Flag = "Dropdown1",
    Callback = function(Option)
        ---Priority 2 Skill
        task.spawn(function()
            while Option[1] ~= "Disabled" and task.wait(1) do
                --- Variables
                local Skill = Option[1]
                local Player = game:GetService("Players").LocalPlayer.Character
                local CombatUI = game:GetService("Players").LocalPlayer.PlayerGui.Combat.ActionBG
                local CombatRemote = game:GetService("Players").LocalPlayer.PlayerGui.Combat.CombatHandle
                --- Gets Current Stamina
                local Stm = game:GetService("Players").LocalPlayer.PlayerGui.HUD.Holder.EnergyOutline.Count.Text
                local StmTxt = string.gsub(Stm, "/6", "")
                local StmInt = tonumber(StmTxt)
                --- Get Stamina required for Skill
                local SkillCost = CombatUI.AttacksPage.ScrollingFrame:WaitForChild(Skill).Cost.Text
                local SkillCostInt = tonumber(SkillCost)
                ---Combat Handler
                if Player:FindFirstChild("FightInProgress") and StmInt >= SkillCostInt and CombatUI.AttacksPage.ScrollingFrame[Skill].CD.Visible ~= true then
                    for i, v in ipairs(workspace.Living:GetDescendants()) do
                        if v.Name == "FightInProgress" and v.Parent ~= Player and v.Value == Player.FightInProgress.Value then
                            CombatRemote.RemoteFunction:InvokeServer("Attack", Skill, {["Attacking"] = v.Parent})
                            task.wait(1)
                            CombatUI.Visible = false
                        end
                    end
                end
            end
        end)
    end,
})

--- Priority 3 Auto Skill
local Dropdown = Tab:CreateDropdown({
    Name = "Priority 3 Skill",
    Options = attackSet,
    CurrentOption = {"Disabled"},
    MultipleOptions = false,
    Flag = "Dropdown1",
    Callback = function(Option)
        ---Priority 3 Skill
        task.spawn(function()
            while Option[1] ~= "Disabled" and task.wait(1) do
                --- Variables
                local Skill = Option[1]
                local Player = game:GetService("Players").LocalPlayer.Character
                local CombatUI = game:GetService("Players").LocalPlayer.PlayerGui.Combat.ActionBG
                local CombatRemote = game:GetService("Players").LocalPlayer.PlayerGui.Combat.CombatHandle
                --- Gets Current Stamina
                local Stm = game:GetService("Players").LocalPlayer.PlayerGui.HUD.Holder.EnergyOutline.Count.Text
                local StmTxt = string.gsub(Stm, "/6", "")
                local StmInt = tonumber(StmTxt)
                --- Get Stamina required for Skill
                local SkillCost = CombatUI.AttacksPage.ScrollingFrame:WaitForChild(Skill).Cost.Text
                local SkillCostInt = tonumber(SkillCost)
                ---Combat Handler
                if Player:FindFirstChild("FightInProgress") and StmInt >= SkillCostInt and CombatUI.AttacksPage.ScrollingFrame[Skill].CD.Visible ~= true then
                    for i, v in ipairs(workspace.Living:GetDescendants()) do
                        if v.Name == "FightInProgress" and v.Parent ~= Player and v.Value == Player.FightInProgress.Value then
                            CombatRemote.RemoteFunction:InvokeServer("Attack", Skill, {["Attacking"] = v.Parent})
                            task.wait(1)
                            CombatUI.Visible = false
                        end
                    end
                end
            end
        end)
    end,
})

--- Priority 4 Auto Skill
local Dropdown = Tab:CreateDropdown({
    Name = "Priority 4 Skill",
    Options = attackSet,
    CurrentOption = {"Disabled"},
    MultipleOptions = false,
    Flag = "Dropdown1",
    Callback = function(Option)
        ---Priority 4 Skill
        task.spawn(function()
            while Option[1] ~= "Disabled" and task.wait(1) do
                --- Variables
                local Skill = Option[1]
                local Player = game:GetService("Players").LocalPlayer.Character
                local CombatUI = game:GetService("Players").LocalPlayer.PlayerGui.Combat.ActionBG
                local CombatRemote = game:GetService("Players").LocalPlayer.PlayerGui.Combat.CombatHandle
                --- Gets Current Stamina
                local Stm = game:GetService("Players").LocalPlayer.PlayerGui.HUD.Holder.EnergyOutline.Count.Text
                local StmTxt = string.gsub(Stm, "/6", "")
                local StmInt = tonumber(StmTxt)
                --- Get Stamina required for Skill
                local SkillCost = CombatUI.AttacksPage.ScrollingFrame:WaitForChild(Skill).Cost.Text
                local SkillCostInt = tonumber(SkillCost)
                ---Combat Handler
                if Player:FindFirstChild("FightInProgress") and StmInt >= SkillCostInt and CombatUI.AttacksPage.ScrollingFrame[Skill].CD.Visible ~= true then
                    for i, v in ipairs(workspace.Living:GetDescendants()) do
                        if v.Name == "FightInProgress" and v.Parent ~= Player and v.Value == Player.FightInProgress.Value then
                            CombatRemote.RemoteFunction:InvokeServer("Attack", Skill, {["Attacking"] = v.Parent})
                            task.wait(1)
                            CombatUI.Visible = false
                        end
                    end
                end
            end
        end)
    end,
})

--- Autofarm Tab
local Tab = Window:CreateTab("Autofarm")

--- Faster Dodge Toggle
local Toggle = Tab:CreateToggle({
    Name = "Auto Level/Stat",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        getgenv().togglers = true
        while togglers and task.wait(1) and (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - workspace.NPCs.Aretim.Position).magnitude > 100 do
        local Lvl = game:GetService("Players").LocalPlayer.PlayerGui.HUD.Holder.Level.Text
        local LvlText = string.gsub(Lvl, "Level: ", "")
        local LvlInt = tonumber(LvlText)
        local LvlReq = LvlInt ^ 2 + 20
        
        local SP = game:GetService("Players").LocalPlayer.PlayerGui.HUD.Holder.Essence.Text
        local SPNum = tonumber(SP)
        
        if SPNum >= LvlReq and LvlInt ~= 40 then
            local OldPos = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame
            
            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.NPCs.Aretim.CFrame
            
            task.wait(1)
        
            fireproximityprompt(workspace.NPCs.Aretim.ProximityPrompt)
            
            task.wait(1)
        
            for i, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.NPCDialogue.BG:GetDescendants()) do
                if v.ClassName == "TextButton" and v.Text ~= "Not yet." then
                    getconnections(v.MouseButton1Click)[1]:Fire()
                end
            end
            
            repeat
                task.wait()
            until game:GetService("Players").LocalPlayer.PlayerGui.HUD.StatAllocate.Visible == true
        
            local Strength, Arcane, Endurance, Speed, Luck = 3, 0, 0, 0, 0
        
            game:GetService("ReplicatedStorage").Remotes.Information.StatAllocation:FireServer(Strength, Arcane, Endurance, Speed, Luck)
            
            game:GetService("Players").LocalPlayer.PlayerGui.HUD.StatAllocate.Visible = false
            
            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = OldPos
        end
        end
    end,
})


--- Teleport Tab
local Tab = Window:CreateTab("Teleports")

--- NPC Dropdown
local Dropdown = Tab:CreateDropdown({
    Name = "NPCS",
    Options = {"Aretim", "Eye3", "Blacksmith", "Dealer", "Guild Clerk", "Doctor", "Merchant", "Mysterious Merchant", "Itinerant", "Krit"},
    CurrentOption = {"None"},
    MultipleOptions = false,
    Flag = "Dropdown1",
    Callback = function(Option)
        local NPC = Option[1]
        for i, v in pairs(game:GetService("Workspace"):GetDescendants()) do
            if v.Name == NPC then
                if v:FindFirstChild("HumanoidRootPart") then
                    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame
                else
                    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
                end
            end        
        end
    end,
})

local Trainers = {}
for i, v in ipairs(workspace.NPCs:GetDescendants()) do
    if v.Name == "Trainer" then 
        table.insert(Trainers, v.Parent.Name)
    end
end

local Dropdown = Tab:CreateDropdown({
    Name = "Trainers",
    Options = Trainers,
    CurrentOption = {"None"},
    MultipleOptions = false,
    Flag = "Dropdown1",
    Callback = function(Option)
        local NPC = Option[1]
        game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.NPCs[NPC].HumanoidRootPart.CFrame
    end,
})

local Tab = Window:CreateTab("Player")

local Tab = Window:CreateTab("Miscellanious")
    local Button = Tab:CreateButton({
    Name = "Bypass Anti-Cheat",
    Callback = function()
        for i,v in next, getgc() do
            if typeof(v) == "function" and islclosure(v) and not isexecutorclosure(v) then
                local Constants = debug.getconstants(v)
                if table.find(Constants, "Detected") and table.find(Constants, "crash") then
                    setthreadidentity(2)
                    hookfunction(v, function()
                        return task.wait(9e9)
                    end)
                    setthreadidentity(7)
                end
            end
        end
    end,
    })
