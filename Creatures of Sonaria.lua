-- Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Variables
local lp = Players.LocalPlayer
local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/dirt",true))()
local Table = {}
local selectedMob = nil

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

window:Toggle("Claim Candy Canes",{location = Table, flag = "Toggle9"},function()
    while Table["Toggle9"] and task.wait() do
        for i = 1, 40 do
            ReplicatedStorage.Remotes.CompleteForageableRemote:InvokeServer(i)
        end
    end
end)

window:Toggle("Auto Claim Tokens",{location = Table, flag = "Toggle4"},function()
    while Table["Toggle4"] and task.wait() do
        for _, v in pairs(Workspace.Interactions.SpawnedTokens:GetChildren()) do
            if v then
                ReplicatedStorage.Remotes.GetSpawnedTokenRemote:InvokeServer()
                v:Destroy()
            end
        end
    end
end)

window:Dropdown("Dropdown", {location = Table, flag = "Dropdown",search = true, list = mobsList, PlayerList = false}, function()
    selectedMob = Table["Dropdown"]
end)

window:Toggle("Toggle", {location = Table, flag = "Toggle5"}, function()
    while Table["Toggle5"] and task.wait() do
        lp.Character.HumanoidRootPart.CFrame = workspace.Event.Spawner.Spawner.MobRoots[Table["Dropdown"]].CFrame:ToWorldSpace(CFrame.new(0, -70, 0))
    end
end)

window:Section("Teleports")

window:Button("Boss Teleport", function()
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

window:Section("Survival")

window:Button("Infinite Stamina",function()
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

window:Button("Fast Eat",function()
    for i = 1, 10 do 
        local args = {
            [1] = getNearestResource("Meat")
        }

        ReplicatedStorage.Remotes.Food:FireServer(unpack(args))
    end
end)

window:Button("Fast Drink",function()
    for i = 1, 10 do 
        local args = {
            [1] = getNearestResource("Water")
        }

        ReplicatedStorage.Remotes.DrinkRemote:FireServer(unpack(args))
    end
end)

window:Button("Fast Hide Scent",function()
    for i = 1, 10 do 
        local args = {
            [1] = getNearestResource("Mud")
        }

        ReplicatedStorage.Remotes.Mud:FireServer(unpack(args))
    end
end)

window:Toggle("Mob Kill Aura", {location = Table, flag = "Toggle2"}, function()
    while Table["Toggle2"] and task.wait() do
        for _, v in pairs(workspace.Event.Spawner.Spawner.MobRoots:GetChildren()) do
            if v then
                ReplicatedStorage.Remotes.MobDamageRemote:FireServer({v})
                ReplicatedStorage.Remotes.MobDamageRemoteBreath:FireServer({v})
                ReplicatedStorage.Remotes.MobDamageRemoteWhip:FireServer({v})
            end
        end
    end
end)

window:Toggle("Player Kill Aura", {location = Table, flag = "Toggle3"}, function()
    while Table["Toggle3"] and task.wait() do
        for i, v in pairs(Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                ReplicatedStorage.Remotes.CharactersDamageRemote:FireServer({v.Character})
                ReplicatedStorage.Remotes.CharactersDamageRemoteBreath:FireServer({v.Character})
                ReplicatedStorage.Remotes.CharactersDamageRemoteWhip:FireServer({v.Character})
            end
        end
    end
end)

for _, table in pairs(blockedRemotes) do
    local old; old = hookmetamethod(game, "__namecall", function(remote, ...)
        local args = {...}
        if remote.Name == table then
            return
        end
        return old(remote, ...)
    end)
end

window:Button("Block All Damage",function()
    for _, table in pairs(blockedRemotes) do
        local old; old = hookmetamethod(game, "__namecall", function(remote, ...)
            local args = {...}
            if remote.Name == table then
                return
            end
            return old(remote, ...)
        end)
    end
end)