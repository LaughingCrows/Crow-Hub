-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Variables
local lp = Players.LocalPlayer
local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/dirt",true))()
local Table = {}

local function getNearestResource(type)
    local resource = nil 
    local distance = math.huge
    
    if type == "Meat" then   
        for _, v in pairs(workspace.Interactions.Food:GetChildren()) do
            if string.find(v.Name, "Carcass") or string.find(v.Name, "Ribs") then
                if v:FindFirstChild("Food") then
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
                local waterDist = lp:DistanceFromCharacter(v.Position)
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

local function getWater()
    lp.Character.HumanoidRootPart.CFrame = CFrame.new(1080, 466, 676)
end

local window = Lib:CreateWindow("Creatures of Sonaria")

window:Section("Event")

window:Toggle("Claim Candy Canes",{location = Table, flag = "Toggle"},function()
    while Table["Toggle"] and task.wait() do
        for i = 1, 40 do
            ReplicatedStorage.Remotes.CompleteForageableRemote:InvokeServer(i)
        end
    end
end)

window:Section("Teleports")

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
    
window:Button("Fast Eat",function()
    for i = 1, 30 do 
        local args = {
            [1] = getNearestResource("Meat")
        }

        ReplicatedStorage.Remotes.Food:FireServer(unpack(args))
    end
end)

window:Button("Fast Drink",function()
    for i = 1, 30 do 
        local args = {
            [1] = getNearestResource("Water")
        }

        ReplicatedStorage.Remotes.DrinkRemote:FireServer(unpack(args))
    end
end)

window:Button("Fast Hide Scent",function()
    for i = 1, 30 do 
        local args = {
            [1] = getNearestResource("Mud")
        }

        ReplicatedStorage.Remotes.Mud:FireServer(unpack(args))
    end
end)