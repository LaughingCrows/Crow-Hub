-- Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Variables
local lp = Players.LocalPlayer
local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/dirt", true))()
local Table = {}
local teleportMobDist = -100
local teleportPlayerDist = -300

local blockedRemotes = {
    "OxygenRemote",
    "DrownRemote",
    "RequestMeteors",
    "MeteorSelfDamage",
    "LavaSelfDamage",
    "TornadoSelfDamage",
    "MobProjectileDamageRemote"
}

local mobsList = {
    "WinterYetiBoss"
}

local function getNearestResource(type)
    local resource = nil 
    local distance = math.huge
    
    if type == "Meat" then   
        for _, v in pairs(workspace.Interactions.Food:GetChildren()) do
            if string.find(v.Name, "Carcass") or string.find(v.Name, "Ribs") then
                if v:FindFirstChild("Food") and not v.Food:FindFirstChild("Flies") then
                    local foodDist = lp:DistanceFromCharacter(v.Food.Position)
                    if foodDist < distance then
                        resource = v
                        distance = foodDist
                    end
                end
            end
        end
    
        return resource 
    elseif type == "Water" then
        for _, v in pairs(workspace.Interactions.Lakes:GetChildren()) do
            if string.find(v.Name, "Lake") and v:FindFirstChild("WaterZone") then
                local waterDist = lp:DistanceFromCharacter(v.WaterZone.Position)
                if waterDist < distance then
                    resource = v
                    distance = waterDist
                end
            end
        end
        
        return resource
    elseif type == "Mud" then
        for _, v in pairs(workspace.Interactions:GetChildren()) do
            if string.find(v.Name, "Mud") then
                local mudDist = lp:DistanceFromCharacter(v.Position)
                if mudDist < distance then
                    resource = v
                    distance = mudDist
                end
            end
        end
        
        return resource
    end
 end

local window = Lib:CreateWindow("Crow Hub")

window:Section("Event")

window:Toggle("Claim Candy Canes",{location = Table, flag = "Claim Candy Canes"},function()
    while Table["Claim Candy Canes"] and task.wait() do
        for i = 1, 40 do
            ReplicatedStorage.Remotes.CompleteForageableRemote:InvokeServer(i)
        end
    end
end)

window:Toggle("Auto Claim Tokens",{location = Table, flag = "Auto Claim Tokens"},function()
    while Table["Auto Claim Tokens"] and task.wait() do
        for _, v in pairs(Workspace.Interactions.SpawnedTokens:GetChildren()) do
            if v then
                ReplicatedStorage.Remotes.GetSpawnedTokenRemote:InvokeServer()
                v:Destroy()
            end
        end
    end
end)

window:Toggle("Mob Kill Aura", {location = Table, flag = "Mob Kill Aura"}, function()
    while Table["Mob Kill Aura"] and task.wait() do
        for _, v in pairs(workspace.Event.Spawner.Spawner.MobRoots:GetChildren()) do
            if v then
                ReplicatedStorage.Remotes.MobDamageRemote:FireServer({v})
                ReplicatedStorage.Remotes.MobDamageRemoteBreath:FireServer({v})
                ReplicatedStorage.Remotes.MobDamageRemoteWhip:FireServer({v})
            end
        end
    end
end)

window:Toggle("Boss Autofarm", {location = Table, flag = "Boss Autofarm"}, function()
    while Table["Boss Autofarm"] and task.wait() do
        if workspace.Event.Spawner.Spawner.MobRoots:FindFirstChild("WinterYetiBoss") then
            lp.Character.HumanoidRootPart.CFrame = workspace.Event.Spawner.Spawner.MobRoots.WinterYetiBoss.CFrame:ToWorldSpace(CFrame.new(0, teleportMobDist, 0))
        else
            lp.Character.HumanoidRootPart.CFrame = CFrame.new(1820, 5303, 3156)
        end
    end
end)

window:Slider("Distance",{location = Table, min = 1, max = -200, default = -100, precise = true, flag = "Mob Distance"}, function()
   teleportMobDist = Table["Mob Distance"]
end)

window:Section("Teleports")

window:Button("Boss Room Teleport", function()
    ReplicatedStorage.Remotes.Portal:FireServer("BossPortalStart")
end)

window:Button("Meat Teleport",function()
    lp.Character.HumanoidRootPart.CFrame = getNearestResource("Meat").Food.CFrame:ToWorldSpace(CFrame.new(0, 10, 0))
end)

window:Button("Water Teleport",function()
    lp.Character.HumanoidRootPart.CFrame = CFrame.new(1080, 466, 676)
end)

window:Button("Mud Teleport",function()
    lp.Character.HumanoidRootPart.CFrame = getNearestResource("Mud").CFrame:ToWorldSpace(CFrame.new(0, 10, 0))
end)

window:Section("PVP")

window:Toggle("Player Kill Aura", {location = Table, flag = "Player Kill Aura"}, function()
    while Table["Player Kill Aura"] and task.wait() do
        for i, v in pairs(Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                ReplicatedStorage.Remotes.CharactersDamageRemote:FireServer({v.Character})
                ReplicatedStorage.Remotes.CharactersDamageRemoteBreath:FireServer({v.Character})
                ReplicatedStorage.Remotes.CharactersDamageRemoteWhip:FireServer({v.Character})
            end
        end
    end
end)

window:Toggle("TP under Player", {location = Table, flag = "TP under Player"}, function()
    while Table["TP under Player"] and task.wait() do
        if workspace.Characters:FindFirstChild(Table["Player List"]):FindFirstChild("HumanoidRootPart") then
            lp.Character.HumanoidRootPart.CFrame = workspace.Characters[Table["Player List"]].HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0, teleportPlayerDist, 0))
        end
    end
end)

window:Dropdown("Player List",{location = Table, flag = "Player List",search = true, list = nil, PlayerList = true}, function()
end)

window:Slider("Distance",{location = Table, min = 1, max = -150, default = -100, precise = true, flag = "Player Distance"}, function()
    teleportPlayerDist = Table["Player Distance"]
 end)

window:Section("Survival")
window:Toggle("Infinite Stamina", {location = Table, flag = "Infinite Stamina"}, function()
    lp.Character.Data:SetAttribute("sr", math.huge)
    lp.Character.Data:SetAttribute("st", math.huge)

    lp.Character.Data:GetAttributeChangedSignal("sr"):Connect(function()
        task.wait()
        lp.Character.Data:SetAttribute("sr", math.huge)
    end)

    lp.Character.Data:GetAttributeChangedSignal("sr"):Connect(function()
        task.wait()
        lp.Character.Data:SetAttribute("st", math.huge)
    end)
end)

window:Toggle("Auto Eat", {location = Table, flag = "Auto Eat"}, function()
    while Table["Auto Eat"] and task.wait() do
        local args = {
            [1] = getNearestResource("Meat")
        }

        ReplicatedStorage.Remotes.Food:FireServer(unpack(args))
    end
end)

window:Toggle("Auto Drink", {location = Table, flag = "Auto Drink"}, function()
    while Table["Auto Drink"] and task.wait() do
        local args = {
            [1] = getNearestResource("Water")
        }

        ReplicatedStorage.Remotes.DrinkRemote:FireServer(unpack(args))
    end
end)

window:Toggle("Auto Mud Roll", {location = Table, flag = "Auto Mud Roll"}, function()
    while Table["Auto Mud Roll"] and task.wait() do
        local args = {
            [1] = getNearestResource("Mud")
        }

        ReplicatedStorage.Remotes.Mud:FireServer(unpack(args))
    end
end)

window:Toggle("Auto Hide Scent", {location = Table, flag = "Auto Hide Scent"}, function()
    while Table["Auto Hide Scent"] and not lp.Character.Ailments:GetAttribute("HideScent") and task.wait() do
       ReplicatedStorage.Remotes.HideScent:FireServer()
    end
end)

window:Toggle("Block All Damage", {location = Table, flag = "Block All Damage"}, function()
    local old; old = hookmetamethod(game, "__namecall", newcclosure(function(remote, ...)
        local args = {...}
        if table.find(blockedRemotes, remote.Name) and Table["Block All Damage"] then
            return
        end
        return old(remote, ...)
    end))
end)