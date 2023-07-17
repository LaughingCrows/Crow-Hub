local AttackSet = {}
table.insert(AttackSet, "Disabled")
for i, v in ipairs(game:GetService("Players").LocalPlayer.PlayerGui.Combat.ActionBG.AttacksPage.ScrollingFrame:GetChildren()) do
    if v.ClassName == "TextButton" then
        table.insert(AttackSet, v.Name)
    end
end

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

local Window = Rayfield:CreateWindow({
   Name = "Arcane Lineage GUI",
   LoadingTitle = "Crow Hub",
   LoadingSubtitle = "by LaughingCrows",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Crow Hub"
   },
   Discord = {
      Enabled = false,
      Invite = "tgkfNtS5qy", -- The Discord invite code, do not include discord.gg/
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },
   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Crow Hub",
      Subtitle = "Key System",
      Note = "Join the discord (discord.gg/tgkfNtS5qy)",
      FileName = "CrowKey",
      SaveKey = true,
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = "Hello"
   }
})

local Tab = Window:CreateTab("Combat")

    local Section = Tab:CreateSection("Buttons:")

        local Button = Tab:CreateButton({
            Name = "Always Auto Dodge",
            Callback = function()
                -- Adonis Anticheat Bypass
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

                -- Auto Dodge
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

        local Button = Tab:CreateButton({
            Name = "Emergency Respawn (Semi-Godmode)",
            Callback = function()
                game:GetService("Players").LocalPlayer.Character.Humanoid.Health = 0
            end,
        })

    local Section = Tab:CreateSection("Toggles:")

        local Toggle = Tab:CreateToggle({
            Name = "Faster Auto Dodge",
            CurrentValue = false,
            Flag = "Toggle1",
            Callback = function(Value)
                getgenv().on_off = Value
                --// Faster Auto Dodge
                task.spawn(function()
                    while on_off and task.wait() do
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

        local Toggle = Tab:CreateToggle({
            Name = "Auto Heal",
            CurrentValue = false,
            Flag = "Toggle2",
            Callback = function(Value1)
                getgenv().onoff = Value1
                task.spawn(function()
                    while onoff and task.wait() do
                        --// Variables
                        local player = game:GetService("Players").LocalPlayer.Character
                        local health = player.Humanoid.Health
                        local maxhealth = player.Humanoid.MaxHealth
                        local autoheal = -maxhealth
                        --// AutoHeal
                        if health < maxhealth and not player:FindFirstChild("FightInProgress") then
                            game:GetService("ReplicatedStorage").Remotes.Information.EnviroEffects:FireServer("Fall", autoheal)
                        end
                    end
                end)
            end,
        })

    local Section = Tab:CreateSection("Dropdowns:")
        local Dropdown = Tab:CreateDropdown({
            Name = "Faster Auto Skill",
            Options = {"Disabled", "Dagger", "Fist", "Magic", "Spear", "Sword"},
            CurrentOption = {"Disabled"},
            MultipleOptions = false,
            Flag = "Dropdown1",
            Callback = function(Option)
                task.spawn(function()
                    --// Variables
                    local Weapon = Option[1]
                    local Player = game:GetService("Players").LocalPlayer.Character
                    local CombatUI = game:GetService("Players").LocalPlayer.PlayerGui.Combat.MagicQTE
                    local CombatRemote = game:GetService("ReplicatedStorage").Remotes.Information.RemoteFunction
                    -- Auto Skill
                    local old_
                    old_ = hookmetamethod(game, "__namecall", function(self, ...)
                    if self.Name == "RemoteFunction" and getnamecallmethod() == "FireServer" then
                        local args = {...}
                        if args[2] == Weapon.."QTE" then
                        args[1] = true
                        return old_(self, unpack(args))
                        end
                    end
                    return old_(self, ...)
                    end)
                    --// Faster Auto Skill
                    while task.wait() and Option[1] ~= "Disabled" do
                        if Player:FindFirstChild("FightInProgress") and CombatUI.Visible == true or game:GetService("Players").LocalPlayer.PlayerGui.Combat.SpearQTE:FindFirstChild("Dot") then
                            CombatRemote:FireServer(true, Weapon.."QTE")
                            CombatUI.Visible = false
                        end
                    end
                end)
            end,
        })

        local Dropdown = Tab:CreateDropdown({
            Name = "Priority 1 Skill",
            Options = AttackSet,
            CurrentOption = {"Disabled"},
            MultipleOptions = false,
            Flag = "Dropdown1",
            Callback = function(Option)
                task.spawn(function()
                    while Option[1] ~= "Disabled" and task.wait(1) do
                        local Skill = Option[1]
                        local Player = game:GetService("Players").LocalPlayer.Character
                        local CombatUI = game:GetService("Players").LocalPlayer.PlayerGui.Combat.ActionBG
                        local CombatRemote = game:GetService("Players").LocalPlayer.PlayerGui.Combat.CombatHandle
                        local Stm = game:GetService("Players").LocalPlayer.PlayerGui.HUD.Holder.EnergyOutline.Count.Text
                        local StmTxt = string.gsub(Stm, "/6", "")
                        local StmInt = tonumber(StmTxt)
                        local SkillCost = CombatUI.AttacksPage.ScrollingFrame:WaitForChild(Skill).Cost.Text
                        local SkillCostInt = tonumber(SkillCost)
                        if Player:FindFirstChild("FightInProgress") and StmInt >= SkillCostInt and CombatUI.AttacksPage.ScrollingFrame[Skill].CD.Visible ~= true then
                            for i, v in ipairs(workspace.Living:GetDescendants()) do
                                if v.Name == "FightInProgress" and v.Parent ~= Player and v.Value == Player.FightInProgress.Value then
                                    CombatRemote.RemoteFunction:InvokeServer("Attack", Skill, {["Attacking"] = v.Parent})
                                    CombatUI.Visible = false
                                end
                            end
                        end
                    end
                end)
            end,
        })

        local Dropdown = Tab:CreateDropdown({
            Name = "Priority 2 Skill",
            Options = AttackSet,
            CurrentOption = {"Disabled"},
            MultipleOptions = false,
            Flag = "Dropdown1",
            Callback = function(Option)
                task.spawn(function()
                    while Option[1] ~= "Disabled" and task.wait(1) do
                        local Skill = Option[1]
                        local Player = game:GetService("Players").LocalPlayer.Character
                        local CombatUI = game:GetService("Players").LocalPlayer.PlayerGui.Combat.ActionBG
                        local CombatRemote = game:GetService("Players").LocalPlayer.PlayerGui.Combat.CombatHandle
                        local Stm = game:GetService("Players").LocalPlayer.PlayerGui.HUD.Holder.EnergyOutline.Count.Text
                        local StmTxt = string.gsub(Stm, "/6", "")
                        local StmInt = tonumber(StmTxt)
                        local SkillCost = CombatUI.AttacksPage.ScrollingFrame:WaitForChild(Skill).Cost.Text
                        local SkillCostInt = tonumber(SkillCost)
                        if Player:FindFirstChild("FightInProgress") and StmInt >= SkillCostInt and CombatUI.AttacksPage.ScrollingFrame[Skill].CD.Visible ~= true then
                            for i, v in ipairs(workspace.Living:GetDescendants()) do
                                if v.Name == "FightInProgress" and v.Parent ~= Player and v.Value == Player.FightInProgress.Value then
                                    CombatRemote.RemoteFunction:InvokeServer("Attack", Skill, {["Attacking"] = v.Parent})
                                    CombatUI.Visible = false
                                end
                            end
                        end
                    end
                end)
            end,
        })

        local Dropdown = Tab:CreateDropdown({
            Name = "Priority 3 Skill",
            Options = AttackSet,
            CurrentOption = {"Disabled"},
            MultipleOptions = false,
            Flag = "Dropdown1",
            Callback = function(Option)
                task.spawn(function()
                    while Option[1] ~= "Disabled" and task.wait(1) do
                        local Skill = Option[1]
                        local Player = game:GetService("Players").LocalPlayer.Character
                        local CombatUI = game:GetService("Players").LocalPlayer.PlayerGui.Combat.ActionBG
                        local CombatRemote = game:GetService("Players").LocalPlayer.PlayerGui.Combat.CombatHandle
                        local Stm = game:GetService("Players").LocalPlayer.PlayerGui.HUD.Holder.EnergyOutline.Count.Text
                        local StmTxt = string.gsub(Stm, "/6", "")
                        local StmInt = tonumber(StmTxt)
                        local SkillCost = CombatUI.AttacksPage.ScrollingFrame:WaitForChild(Skill).Cost.Text
                        local SkillCostInt = tonumber(SkillCost)
                        if Player:FindFirstChild("FightInProgress") and StmInt >= SkillCostInt and CombatUI.AttacksPage.ScrollingFrame[Skill].CD.Visible ~= true then
                            for i, v in ipairs(workspace.Living:GetDescendants()) do
                                if v.Name == "FightInProgress" and v.Parent ~= Player and v.Value == Player.FightInProgress.Value then
                                    CombatRemote.RemoteFunction:InvokeServer("Attack", Skill, {["Attacking"] = v.Parent})
                                    CombatUI.Visible = false
                                end
                            end
                        end
                    end
                end)
            end,
        })

        local Dropdown = Tab:CreateDropdown({
            Name = "Priority 4 Skill",
            Options = AttackSet,
            CurrentOption = {"Disabled"},
            MultipleOptions = false,
            Flag = "Dropdown1",
            Callback = function(Option)
                task.spawn(function()
                    while Option[1] ~= "Disabled" and task.wait(1) do
                        local Skill = Option[1]
                        local Player = game:GetService("Players").LocalPlayer.Character
                        local CombatUI = game:GetService("Players").LocalPlayer.PlayerGui.Combat.ActionBG
                        local CombatRemote = game:GetService("Players").LocalPlayer.PlayerGui.Combat.CombatHandle
                        local Stm = game:GetService("Players").LocalPlayer.PlayerGui.HUD.Holder.EnergyOutline.Count.Text
                        local StmTxt = string.gsub(Stm, "/6", "")
                        local StmInt = tonumber(StmTxt)
                        local SkillCost = CombatUI.AttacksPage.ScrollingFrame:WaitForChild(Skill).Cost.Text
                        local SkillCostInt = tonumber(SkillCost)
                        if Player:FindFirstChild("FightInProgress") and StmInt >= SkillCostInt and CombatUI.AttacksPage.ScrollingFrame[Skill].CD.Visible ~= true then
                            for i, v in ipairs(workspace.Living:GetDescendants()) do
                                if v.Name == "FightInProgress" and v.Parent ~= Player and v.Value == Player.FightInProgress.Value then
                                    CombatRemote.RemoteFunction:InvokeServer("Attack", Skill, {["Attacking"] = v.Parent})
                                    CombatUI.Visible = false
                                end
                            end
                        end
                    end
                end)
            end,
        })

local Tab = Window:CreateTab("Teleports")

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

    local Dropdown = Tab:CreateDropdown({
        Name = "Trainers",
        Options = {"Arandor", "Ysa", "Boots", "Martial Artist", "Tivek", "Dernon", "Luther", "Saint", "Aberon", "Landrum", "Orin", "Inette", "Kayrein", "Ulys", "Dark Wraith", "Cantia", "Thorin", "Selia"},
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
