-- Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Variables
local EmergencyTP = false
local EmergencyHealthVal = 2000
local lp = Players.LocalPlayer
local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/dirt", true))()
local Table = {}
local teleportMobDist = -140
local teleportPlayerDist = -140
local Regions = {}

for i, v in pairs(game:GetService("ReplicatedStorage").Storage.Regions:GetChildren()) do
    table.insert(Regions, v.Name)
end

local blockedRemotes = {
    "OxygenRemote",
    "DrownRemote",
    "RequestMeteors",
    "MeteorSelfDamage",
    "LavaSelfDamage",
    "TornadoSelfDamage",
    "MobProjectileDamageRemote"
}

local staminaAttributes = {"sr", "st", "tak"}

local DeliveryPoints = {"DeliveryPointGreen", "DeliveryPointRed", "DeliveryPointWhite"}

local function getPresentAmount()
    local greenPresent = lp.PlayerGui.Data.MiscItems.PresentGreen.Value
    local redPresent = lp.PlayerGui.Data.MiscItems.PresentRed.Value
    local whitePresent = lp.PlayerGui.Data.MiscItems.PresentWhite.Value

    if (greenPresent >= 1) or (redPresent >= 1) or (whitePresent >= 1) then
        return true
    end
end

local function getDoughAmount()
    local cookieDough = lp.PlayerGui.Data.MiscItems.CookieDough.Value
    local peppermintDough = lp.PlayerGui.Data.MiscItems.PeppermintDough.Value
    local sprinkleDough = lp.PlayerGui.Data.MiscItems.SprinkleDough.Value
    
    if (cookieDough >= 5) or (peppermintDough >= 5) or (sprinkleDough >= 5) then
        return true
    end
end

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

window:Toggle("Snowman Autofarm",{location = Table, flag = "Snowman Autofarm"},function()
    while Table["Snowman Autofarm"] and task.wait() do
        for i = 1, 40 do
            ReplicatedStorage.Remotes.CompleteForageableRemote:InvokeServer(i)
            task.wait()
        end
    end
end)

window:Toggle("Present Autofarm",{location = Table, flag = "Present Autofarm"},function()
    while Table["Present Autofarm"] and task.wait() do
        for _, v in pairs(workspace.Interactions.SpawnedDeliveryObjects:GetChildren()) do
            if v then
                ReplicatedStorage.Remotes.GetSpawnedDeliveryObjectRemote:InvokeServer(v.Name)
                v:Destroy()
                task.wait()
            else
                break
            end
        end
        for _, v in DeliveryPoints do
            if getPresentAmount() then
                ReplicatedStorage.Remotes.DeliveryDropoffEvent:FireServer(workspace.Event[v])
            end
        end
    end
end)

window:Toggle("Cookie Autofarm",{location = Table, flag = "Cookie Autofarm"},function()
    while Table["Cookie Autofarm"] and task.wait() do
        if getDoughAmount() then
            ReplicatedStorage.Remotes.JerryLoadUp:FireServer()
            ReplicatedStorage.Remotes.JerryUnbox:InvokeServer()
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
        if workspace.Event.Spawner.Spawner.MobRoots:FindFirstChild("WinterYetiBoss") and not EmergencyTP then
            lp.Character.HumanoidRootPart.CFrame = workspace.Event.Spawner.Spawner.MobRoots.WinterYetiBoss.CFrame:ToWorldSpace(CFrame.new(0, teleportMobDist, 0))
        else
            lp.Character.HumanoidRootPart.CFrame = CFrame.new(1820, 5303, 3156)
        end
    end
end)

window:Slider("Distance",{location = Table, min = 1, max = -300, default = -140, precise = true, flag = "Mob Distance"}, function()
   teleportMobDist = Table["Mob Distance"]
end)

window:Section("Teleports")

window:Button("Boss Room Teleport", function()
    ReplicatedStorage.Remotes.Portal:FireServer("BossPortalStart")
end)

window:Button("Meat Teleport",function()
    if getNearestResource("Meat") then
        lp.Character.HumanoidRootPart.CFrame = getNearestResource("Meat").Food.CFrame:ToWorldSpace(CFrame.new(0, 10, 0))
    end
end)

window:Button("Water Teleport",function()
    lp.Character.HumanoidRootPart.CFrame = CFrame.new(1080, 466, 676)
end)

window:Button("Mud Teleport",function()
    if getNearestResource("Mud") then
        lp.Character.HumanoidRootPart.CFrame = getNearestResource("Mud").CFrame:ToWorldSpace(CFrame.new(0, 10, 0))
    end
end)

window:Dropdown("Region Teleport", {location = Table, flag = "Region Teleport", search = true, list = Regions, PlayerList = false}, function()
    lp.Character.HumanoidRootPart.CFrame = game:GetService("ReplicatedStorage").Storage.Regions[Table["Region Teleport"]].CFrame:ToWorldSpace(CFrame.new(-1000, 0, 0))
end)

window:Section("PVP")

local billboardGUI = Instance.new("BillboardGui")
billboardGUI.Active = true
billboardGUI.AlwaysOnTop = true
billboardGUI.ClipsDescendants = true
billboardGUI.LightInfluence = 1
billboardGUI.Size = UDim2.new(0, 120, 0, 50)
billboardGUI.StudsOffset = Vector3.new(0, 1, 0)
billboardGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local textLabel = Instance.new("TextLabel")
textLabel.Font = Enum.Font.Unknown
textLabel.Text = "nameHolder"
textLabel.TextColor3 = Color3.new(1, 1, 1)
textLabel.TextScaled = true
textLabel.TextSize = 14
textLabel.TextStrokeTransparency = 0.5
textLabel.TextWrapped = true
textLabel.BackgroundColor3 = Color3.new(1, 1, 1)
textLabel.BackgroundTransparency = 1
textLabel.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
textLabel.Size = UDim2.new(1, 0, 1, 0)
textLabel.Parent = billboardGUI

window:Toggle("Player ESP", {location = Table, flag = "Player ESP"}, function()
    while task.wait() do
        for i, v in pairs(Players:GetChildren()) do
            if Table["Player ESP"] and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and not v.Character.HumanoidRootPart:FindFirstChild("nameESP") then
                if v ~= Players.LocalPlayer then
                    local billboardGUIClone = billboardGUI:Clone()
                    billboardGUIClone.Name = "nameESP"
                    billboardGUIClone.TextLabel.Text = v.Name
                    billboardGUIClone.Parent = v.Character:FindFirstChild("HumanoidRootPart")
                end
            elseif Table["Player ESP"] == false and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.HumanoidRootPart:FindFirstChild("nameESP") then
                v.Character.HumanoidRootPart:FindFirstChild("nameESP"):Destroy()
            end
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        if Table["Player ESP"] then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and not player.Character.HumanoidRootPart:FindFirstChild("nameESP") then
                if player ~= Players.LocalPlayer then
                    local billboardGUIClone = billboardGUI:Clone()
                    billboardGUIClone.Name = "nameESP"
                    billboardGUIClone.TextLabel.Text = player.Name
                    billboardGUIClone.Parent = v.Character:FindFirstChild("HumanoidRootPart")            
                end
            end
        elseif Table["Player ESP"] == false and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.HumanoidRootPart:FindFirstChild("nameESP") then
            v.Character.HumanoidRootPart:FindFirstChild("nameESP"):Destroy()
        end
    end)
end)

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
        if workspace.Characters[Table["Select Player"]]:FindFirstChild("HumanoidRootPart") then
            lp.Character.HumanoidRootPart.CFrame = workspace.Characters[Table["Select Player"]].HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(0, teleportPlayerDist, 0))
        end
    end
end)

window:Dropdown("Select Player", {location = Table, flag = "Select Player", search = true, list = nil, PlayerList = true}, function()
end)

window:Slider("Distance",{location = Table, min = 1, max = -300, default = -140, precise = true, flag = "Player Distance"}, function()
    teleportPlayerDist = Table["Player Distance"]
 end)

window:Section("Survival")

window:Toggle("Emergency TP", {location = Table, flag = "Emergency TP"}, function()
    RunService.Heartbeat:Connect(function()
        if Table["Emergency TP"] and lp.Character then
            if lp.Character.Data:GetAttribute("h") <= EmergencyHealthVal then
                EmergencyTP = true
                lp.Character.HumanoidRootPart.CFrame = CFrame.new(1820, 5303, 3156)
            end
        elseif EmergencyTP then -- acts as a debounce I think?
            EmergencyTP = false
        end
    end)
end)

window:Box("HP Value:", {location = Table, flag = "Emergenct Health Value", type = "number", hold = "2000 Default"}, function()
   EmergencyHealthVal = tonumber(Table["Emergenct Health Value"])
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
    while Table["Auto Hide Scent"] and task.wait() do
        if not lp.Character.Ailments:GetAttribute("HideScent") then
            ReplicatedStorage.Remotes.HideScent:FireServer()
        end
    end
end)

window:Toggle("Auto Ungrab", {location = Table, flag = "Auto Ungrab"}, function()
    while Table["Auto Ungrab"] and task.wait() do
        ReplicatedStorage.Remotes.Ungrab:FireServer()
    end
end)

window:Toggle("Infinite Stamina", {location = Table, flag = "Infinite Stamina"}, function()
    for _, v in staminaAttributes do
        if v ~= "tak" then
            lp.Character.Data:SetAttribute(v, math.huge)
            lp.Character.Data:GetAttributeChangedSignal(v):Connect(function()
                task.wait()
                lp.Character.Data:SetAttribute(v, math.huge)
            end)
        else
            lp.Character.Data:SetAttribute(v, -math.huge)
            lp.Character.Data:GetAttributeChangedSignal(v):Connect(function()
                task.wait()
                lp.Character.Data:SetAttribute(v, -math.huge)
            end)
        end
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

window:Section("Stat Modifiers")

window:Toggle("Noclip", {location = Table, flag = "Noclip"}, function()
    if Table["Noclip"] == false then
        lp.Character:FindFirstChild("Hitbox").CanCollide = true
    end
    
    while Table["Noclip"] and task.wait() do
        lp.Character:FindFirstChild("Hitbox").CanCollide = false
    end
end)

window:Slider("Bite Cooldown",{location = Table, min = -3, max = 3, default = nil, precise = true, flag = "Bite Cooldown"}, function()
    local getAttribute = lp.Character.Data:GetAttributeChangedSignal("BiteCooldown")

    local function setAttribute()
        task.wait()
        lp.Character.Data:SetAttribute("BiteCooldown", Table["Bite Cooldown"])
    end

    if getAttribute:Connect(setAttribute).Connected ~= nil then
        getAttribute:Connect(setAttribute):Disconnect()
    end

    lp.Character.Data:SetAttribute("BiteCooldown", Table["Bite Cooldown"])
    getAttribute:Connect(setAttribute)
end)

window:Slider("Walk Speed",{location = Table, min = 1, max = 300, default = nil, precise = true, flag = "Walk Speed"}, function()
    local getAttribute = lp.Character.Data:GetAttributeChangedSignal("s")

    local function setAttribute()
        task.wait()
        lp.Character.Data:SetAttribute("s", Table["Walk Speed"])
    end

    if getAttribute:Connect(setAttribute).Connected ~= nil then
        getAttribute:Connect(setAttribute):Disconnect()
    end

    lp.Character.Data:SetAttribute("s", Table["Walk Speed"])
    getAttribute:Connect(setAttribute)
end)

window:Slider("Sprint Speed",{location = Table, min = 1, max = 300, default = nil, precise = true, flag = "Sprint Speed"}, function()
    local getAttribute = lp.Character.Data:GetAttributeChangedSignal("ss")

    local function setAttribute()
        task.wait()
        lp.Character.Data:SetAttribute("ss", Table["Sprint Speed"])
    end

    if getAttribute:Connect(setAttribute).Connected ~= nil then
        getAttribute:Connect(setAttribute):Disconnect()
    end

    lp.Character.Data:SetAttribute("ss", Table["Sprint Speed"])
    getAttribute:Connect(setAttribute)
end)

window:Slider("Fly Speed",{location = Table, min = 1, max = 300, default = nil, precise = true, flag = "Fly Speed"}, function()
    local getAttribute = lp.Character.Data:GetAttributeChangedSignal("fs")

    local function setAttribute()
        task.wait()
        lp.Character.Data:SetAttribute("fs", Table["Fly Speed"])
    end

    if getAttribute:Connect(setAttribute).Connected ~= nil then
        getAttribute:Connect(setAttribute):Disconnect()
    end

    lp.Character.Data:SetAttribute("fs", Table["Fly Speed"])
    getAttribute:Connect(setAttribute)
end)

window:Slider("Turn Radius",{location = Table, min = 0, max = -300, default = nil, precise = true, flag = "Turn Radius"}, function()
    local getAttribute = lp.Character.Data:GetAttributeChangedSignal("tr")

    local function setAttribute()
        task.wait()
        lp.Character.Data:SetAttribute("tr", Table["Turn Radius"])
    end

    if getAttribute:Connect(setAttribute).Connected ~= nil then
        getAttribute:Connect(setAttribute):Disconnect()
    end

    lp.Character.Data:SetAttribute("tr", Table["Turn Radius"])
    getAttribute:Connect(setAttribute)
end)