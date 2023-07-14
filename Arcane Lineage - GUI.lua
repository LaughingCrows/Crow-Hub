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

    local Section = Tab:CreateSection("Toggles:")

        local Toggle = Tab:CreateToggle({
            Name = "Faster Auto Dodge",
            CurrentValue = false,
            Flag = "Toggle1",
            Callback = function(Value)
                getgenv().onnoff = Value
                --// Faster Auto Dodge
                while onnoff and task.wait() do
                    if game:GetService("Players").LocalPlayer.PlayerGui.Combat.Block.Visible == true then
                        game:GetService("ReplicatedStorage").Remotes.Information.RemoteFunction:FireServer({true, true}, "DodgeMinigame")
                        game:GetService("Players").LocalPlayer.PlayerGui.Combat.Block.Visible = false
                    end
                end
            end,
        })

        local Toggle = Tab:CreateToggle({
            Name = "Auto Heal",
            CurrentValue = false,
            Flag = "Toggle1",
            Callback = function(Value1)
                getgenv().on_off = Value1
                while on_off and task.wait() do
                    --// Variables
                    local player = game:GetService("Players").LocalPlayer.Character
                    local health = player.Humanoid.Health
                    local maxhealth = player.Humanoid.MaxHealth
                    local autoheal = -maxhealth
                    --// Auto Heal
                    if health < maxhealth and not player:FindFirstChild("FightInProgress") then
                        game:GetService("ReplicatedStorage").Remotes.Information.EnviroEffects:FireServer("Fall", autoheal)
                    end
                end
            end,
        })

        local Section = Tab:CreateSection("Options: Dagger, Fist, Magic, Spear, Sword")
        
        local Input = Tab:CreateInput({
            Name = "Faster Auto Skill",
            PlaceholderText = "Type Weapon",
            RemoveTextAfterFocusLost = false,
            Callback = function(Text)
                getgenv().onoff = true
                --// Variables
                local Weapon = Text
                local Player = game:GetService("Players").LocalPlayer.Character
                local CombatUI = game:GetService("Players").LocalPlayer.PlayerGui.Combat.MagicQTE
                local CombatRemote = game:GetService("ReplicatedStorage").Remotes.Information.RemoteFunction
                --// Faster Auto Skill
                while onoff and task.wait() do
                    if Player:FindFirstChild("FightInProgress") and CombatUI.Visible == true then
                        CombatRemote:FireServer(true, Weapon.."QTE")
                        CombatUI.Visible = false
                    end
                end
            end,
        })

        local Section = Tab:CreateSection("Exact Ability Name:")
        local Input = Tab:CreateInput({
            Name = "Auto Attack",
            PlaceholderText = "Type Ability Name",
            RemoveTextAfterFocusLost = false,
            Callback = function(Text)
                getgenv().on_off = true
                local Ability = Text
                --// Variables
                local Player = game:GetService("Players").LocalPlayer.Character
                local CombatUI = game:GetService("Players").LocalPlayer.PlayerGui.Combat.ActionBG
                local CombatRemote = game:GetService("Players").LocalPlayer.PlayerGui.Combat.CombatHandle.RemoteFunction
                --/ Combat Handler
                game:GetService("RunService").Stepped:connect(function()
                    if on_off and Player:FindFirstChild("FightInProgress") then
                        for i, v in ipairs(workspace.Living:GetDescendants()) do
                            if v.Name == "FightInProgress" and v.Parent ~= Player and v.Value == Player.FightInProgress.Value then
                                CombatRemote:InvokeServer("Attack", Ability, {["Attacking"] = v.Parent})
                                CombatUI.Visible = false
                            end
                        end
                    end
                end)
            end,
        })

local Tab = Window:CreateTab("Teleports")

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