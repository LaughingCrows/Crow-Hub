-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Variables
local lp = Players.LocalPlayer
local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/dirt",true))()
local Table = {}

-- Needs to be updated with more quests
local QuestList = {
    ["Hunter"] = {
        ["Name"] = "Hunter",
        ["Tasks"] = {1, 2, 3},
        ["Coordinates"] = CFrame.new(5655, 93, -2210)
    },
    ["Sheriff"] = {
        ["Name"] = "Sheriff",
        ["Tasks"] = {1, 2},
        ["Coordinates"] = CFrame.new(5440, 79, -2392)
    },
    ["Grumbles"] = {
        ["Name"] = "Grumbles",
        ["Tasks"] = {1, 2},
        ["Coordinates"] = CFrame.new(5591, 90, -2136)
    },
    ["Earl"] = {
        ["Name"] = "Earl",
        ["Tasks"] = {1},
        ["Coordinates"] = CFrame.new(5733, 109, -2072)
    },
    ["Nubzy"] = {
        ["Name"] = "Nubzy",
        ["Tasks"] = {1},
        ["Coordinates"] = CFrame.new(5405, 79, -2318)
    },
    ["Karim"] = {
        ["Name"] = "Karim",
        ["Tasks"] = {1, 2},
        ["Coordinates"] = CFrame.new(6042, 77, -186)
    },
    ["Nasir"] = {
        ["Name"] = "Nasir",
        ["Tasks"] = {1, 2},
        ["Coordinates"] = CFrame.new(6032, 77, -243)
    },
}

local QuestList2 = {}

for i, v in pairs(QuestList) do
    table.insert(QuestList2, i)
    table.sort(QuestList2)
end

local CubitList = {
    ["Spawn"] = CFrame.new(5411, 169, -2081),
    ["Slime Island"] = CFrame.new(3399, 82, -8731),
    ["Vampire Town"] = CFrame.new(4312, 466, -3582),
    ["Above the Savannah"] = CFrame.new(-2815, 231, -4649),
    ["Forest Inn"] = CFrame.new(3826, 275, -800),
    ["Elf Shrine"] = CFrame.new(3690, 268, 174),
    ["Tomb"] = CFrame.new(6109, 210, -506),
    ["Brimstone"] = CFrame.new(15050, 535, 97),
    ["Tundra"] = CFrame.new()
}

local CubitList2 = {}

for i, v in pairs(CubitList) do
    table.insert(CubitList2, i)
    table.sort(CubitList2)
end

local function float(bool)
    if bool and not lp.Character:FindFirstChild("Float") then
        local Float = Instance.new("Part")
        Float.Name = "Float"
        Float.Parent = lp.Character
        Float.Transparency = 1
        Float.Size = Vector3.new(2, 0.2, 1.5)
        Float.Anchored = true
        local FloatValue = -3.1
        Float.CFrame = lp.Character.HumanoidRootPart.CFrame * CFrame.new(0, FloatValue, 0)
        
        floatDied = lp.Character:FindFirstChildOfClass("Humanoid").Died:Connect(function()
            floatingFunc:Disconnect()
            lp.Character.Float:Destroy()
            floatDied:Disconnect()
        end)
        
        local function FloatPadLoop()
            if lp.Character:FindFirstChild("Float") and lp.Character.HumanoidRootPart then
                Float.CFrame = lp.Character.HumanoidRootPart.CFrame * CFrame.new(0, FloatValue, 0)
            else
                floatingFunc:Disconnect()
                lp.Character:FindFirstChild("Float"):Destroy()
                floatDied:Disconnect()
            end
        end

        floatingFunc = RunService.Heartbeat:Connect(FloatPadLoop)
    else
        floatingFunc:Disconnect()
        lp.Character:FindFirstChild("Float"):Destroy()
        floatDied:Disconnect()
    end
end

-- Teleports to NPC and begins their quest at whatever stage you are at
local function startQuest(NPC)
    local oldPos = lp.Character.HumanoidRootPart.CFrame
    local questTask = nil
    local questCords = nil

    for i, v in pairs(QuestList) do
        if i == NPC then
            questCords = v.Coordinates
        end
    end

    float(true); task.wait()

    lp.Character.HumanoidRootPart.CFrame = questCords; task.wait(1)

    for i, v in pairs(QuestList) do
        if i == NPC then
            for i1, v1 in pairs(v.Tasks) do
                questTask = v1
                
                local args = {
                    [1] = "UnlockQuest",
                    [2] = NPC,
                    [3] = questTask
                }

                ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
            end
        end
    end

    task.wait(1)

    lp.Character.HumanoidRootPart.CFrame = oldPos; task.wait(1)

    float(false)
end

-- Completes the quest if requirements are met
local function completeQuest()
    local questName = nil
    
    for i, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.MainGui.TopRight.QuestList:GetChildren()) do
        if v.Name == "Frame" then
            questName  = v.Title.Text
        end
    end
    
    local args = {
    [1] = "RedeemQuest",
    [2] = questName,
    [3] = ""
    }

    ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
end

local function claimCubit(Cubit)
    float(true)

    lp.Character.HumanoidRootPart.CFrame = CubitList[Cubit]
    
    task.wait(1)
    
    repeat task.wait()
    until lp.PlayerGui.MainGui.InteractTip.Visible == true
    
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    
    float(false)
end

local function killMob(NPC)
    local args = {
        [1] = "Input",
        [2] = "",
        [3] = 0,
        [4] = "SlashEvent",
        [5] = NPC.HumanoidRootPart,
        [6] = math.huge
    }

    lp.Character.Combat.RemoteEvent:FireServer(unpack(args))
end

local function killAuraLoop()
    for i, v in pairs(workspace.NPCs:GetChildren()) do
        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then 
            if v:FindFirstChild("Enemy") and v:FindFirstChild("HumanoidRootPart") then
                if (lp.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude <= Table["Slider"] then
                    killMob(v)
                end
            end
        end
    end
end

local window = Lib:CreateWindow("Crow Hub")

local KillAura = window:Section("Kill Aura")

window:Toggle("Toggle", {location = Table, flag = "Toggle"}, function()
    while task.wait() and Table["Toggle"] do
        killAuraLoop()
    end
end)

window:Slider("Distance", {location = Table, min = 1, max = 60, default = 30, precise = true, flag = "Slider"}, function()
   print(Table["Slider"])
end)

local AutoFarm = window:Section("Auto Farm")

local AutoQuest = window:Section("Auto Quest")

window:Dropdown("Dropdown",{location = Table,flag = "Dropdown", search = true, list = QuestList2, PlayerList = false},function()
    startQuest(Table["Dropdown"])
end)

window:Button("Complete Quest",function()
    completeQuest()
end)

local Cubits = window:Section("Cubits")

window:Dropdown("Dropdown",{location = Table,flag = "Dropdown", search = true, list = CubitList2, PlayerList = false},function()
    claimCubit(Table["Dropdown"])
end)
   
local Development = window:Section("Development")

window:Box("Type:",{location = Table,flag = "Box", type = "", hold = "Cubit or NPC" --[[ PlaceHolderText ]]},function()
    print(Table["Box"])
end)

window:Box("Name:",{location = Table,flag = "Box", type = "", hold = "Name" --[[ PlaceHolderText ]]},function()
    print(Table["Box"])
end)

window:Box("Tasks:",{location = Table,flag = "Box", type = "number", hold = "Total of 1-3" --[[ PlaceHolderText ]]},function()
    print(Table["Box"])
end)

window:Button("Grab Coordinates",function()
    local pos = Players.LocalPlayer.Character.HumanoidRootPart.Position
    local roundedPos = math.round(pos.X) .. ", " .. math.round(pos.Y) .. ", " .. math.round(pos.Z)
    print(roundedPos)
end)

window:Button("Send Information",function()
    print("webhook sent")
end)
