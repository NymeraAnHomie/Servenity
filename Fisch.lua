local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Character = LocalPlayer.Character
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = Workspace.CurrentCamera

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local AutoFarmObj = Instance.new("Part", Workspace)
AutoFarmObj.Size = Vector3.new(5, 1, 5)
AutoFarmObj.Anchored = true

function SetDraggable(Instance, DragBuff)
    local Dragging, DragStart, StartPos
    local DragBuffer = DragBuff
    local function UpdateInput(Input)
        local Delta = Input.Position - DragStart
        Instance.Position = UDim2.new(
            StartPos.X.Scale,
            StartPos.X.Offset + Delta.X,
            StartPos.Y.Scale,
            StartPos.Y.Offset + Delta.Y
        )
    end
    Instance.InputBegan:Connect(function(Input)
        if (Input.UserInputType == Enum.UserInputType.Touch or Input.UserInputType == Enum.UserInputType.MouseButton1) then
            local ButtonBounds = Instance.AbsolutePosition
            local ButtonSize = Instance.AbsoluteSize
            local MousePos = Input.Position
            if MousePos.X >= ButtonBounds.X - DragBuffer and MousePos.X <= ButtonBounds.X + ButtonSize.X + DragBuffer and
                MousePos.Y >= ButtonBounds.Y - DragBuffer and MousePos.Y <= ButtonBounds.Y + ButtonSize.Y + DragBuffer then
                Dragging = true
                DragStart = Input.Position
                StartPos = Instance.Position
            end
        end
    end)
    Instance.InputChanged:Connect(function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.Touch or Input.UserInputType == Enum.UserInputType.MouseMovement) then
            UpdateInput(Input)
        end
    end)
    Instance.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.Touch or Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
end
local function ServerhopGetPing(serverId)
    local startTime = tick()
    local success = pcall(function()
        game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?cursor=" .. serverId, false)
    end)
    if not success then
        warn("[Error]: Failed to get ping for server ID " .. serverId)
    end
    return success and (tick() - startTime) or math.huge
end
local function ServerHop()
    local GameId = game.PlaceId
    local ServersList = {}
    local BestServer, BestPing = nil, math.huge
    local ServerMode = getgenv().ServerHopMode or getgenv().ServerHopMode

    local Success, Response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. GameId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    
    if Success and Response.data then
        for _, Server in pairs(Response.data) do
            if Server.playing < Server.maxPlayers and Server.id ~= game.JobId then
                table.insert(ServersList, Server)
            end
        end
        
        if ServerMode == "Ping" then
            for _, Server in ipairs(ServersList) do
                local Ping = ServerhopGetPing(Server.id)
                if Ping < BestPing then
                    BestPing, BestServer = Ping, Server
                end
            end
        elseif ServerMode == "Lowest" then
            table.sort(ServersList, function(a, b) return a.playing < b.playing end)
            BestServer = ServersList[1]
        elseif ServerMode == "Highest" then
            table.sort(ServersList, function(a, b) return a.playing > b.playing end)
            BestServer = ServersList[1]
        end
        
        if BestServer then
            TeleportService:TeleportToPlaceInstance(GameId, BestServer.id, Players.LocalPlayer)
        else
            warn("[Error]: No gudable servers found")
        end
    else
        warn("[Error]: Failed to fetch server list")
    end
end
local function Equip(NameToEquip)
    local BackpackEvent = LocalPlayer.PlayerGui.hud.safezone.backpack.events:FindFirstChild("equip")
    local ItemToEquip = LocalPlayer.Backpack:FindFirstChild(NameToEquip)
    if not BackpackEvent then return end
    if not ItemToEquip then return end
    BackpackEvent:FireServer(ItemToEquip)
end
local function AutoAppraise(Fish, Mutation)
    local AppraiseEvent = workspace.world.npcs.Appraiser.appraiser.appraise
    if not Fish or not Mutation then return end
    local success, result = pcall(function()
        return AppraiseEvent:InvokeServer(Fish)
    end)
    if not success then return end
    if not Character then return end
    local Tool = Character:FindFirstChildOfClass("Tool")
    if Tool and Tool.Name == Mutation .. " " .. Fish then
        Fluent:Notify({
	        Title = "Auto Appraise",
	        Content = "You have appraised the fish to your selected option.",
	        Duration = 3
	    })
        return
    end
end
local function FavoriteItem(ToolName)
    for _, Tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if string.find(Tool.Name, ToolName) then
            PlayerGui.hud.safezone.backpack.events.favourite:FireServer(LocalPlayer.Backpack[Tool])
            return
        end
    end
end

local Location = {
    ChosenIsland = "The Depths",
    ChosenTotem = "Aurora Totem",
    ChosenNPC = "Test",
    Islands = {
        ["Snowcap"] = CFrame.new(2671.10425, 151.982208, 2388.95044, -0.459605783, 1.04652365e-09, -0.888123035, 2.21191843e-09, 1, 3.36813424e-11, 0.888123035, -1.94897543e-09, -0.459605783),
        ["Forsaken"] = CFrame.new(-2498.24683, 136.949753, 1624.8551, 0.999999821, -2.66347158e-08, -0.000577610394, 2.66658251e-08, 1, 5.38535616e-08, 0.000577610394, -5.38689555e-08, 0.999999821),
        ["Desolate"] = CFrame.new(-1654.96729, -213.679413, -2845.95215, -1, 7.76459572e-08, -6.47454382e-17, 7.76459572e-08, 1, -1.66771785e-09, -6.47461132e-17, -1.66771785e-09, -1),
        ["Desolate Shop"] = CFrame.new(-979.196411, -247.910156, -2699.87207, 0.587748766, 0, 0.809043527, 0, 1, 0, -0.809043527, 0, 0.587748766),
        ["Arch"] = CFrame.new(978.960266, 131.320236, -1233.784668, 0.322281, 0.000000, 0.946644, 0.000000, 1.000000, -0.000000, -0.946644, 0.000000, 0.322281),
        ["Volcano"] = CFrame.new(-1909.778564, 164.711090, 313.717010, -0.038677, -0.000000, 0.999252, -0.000000, 1.000000, 0.000000, -0.999252, -0.000000, -0.038677),
        ["Havessters Spike"] = CFrame.new(-1264.720459, 171.711365, 1554.462158, 0.156100, -0.000000, -0.987741, -0.000000, 1.000000, -0.000000, 0.987741, 0.000000, 0.156100),
        ["Roslit"] = CFrame.new(-1466.507812, 132.525497, 705.705383, 0.011282, 0.000000, -0.999936, -0.000000, 1.000000, 0.000000, 0.999936, 0.000000, 0.011282),
        ["Moosewood"] = CFrame.new(383.884644, 134.500519, 244.472412, -0.000720544602, -2.32285691e-10, -0.999999762, 4.29488639e-10, 1, -2.32595221e-10, 0.999999762, -4.29656144e-10, -0.000720544602),
        ["Sunstone"] = CFrame.new(-932.780151, 131.881989, -1119.189087, -0.891026, -0.000000, 0.453953, -0.000000, 1.000000, 0.000000, -0.453953, 0.000000, -0.891026),
        ["The Depths"] = CFrame.new(949.425171, -711.662109, 1245.91809, -0.925751507, -2.93172011e-08, -0.378132463, -3.72767879e-08, 1, 1.3730217e-08, 0.378132463, 2.68063314e-08, -0.925751507),
        ["Vertigo"] = CFrame.new(-112.007278, -515.299377, 1040.32788, -1, 1.36623202e-09, -8.52235508e-15, 1.36623202e-09, 1, -3.63848951e-10, 8.52185787e-15, -3.63848951e-10, -1),
        ["Brine Pool"] = CFrame.new(-1794.09546, -142.878433, -3302.68604, -0.0177831985, -7.63470283e-08, 0.999841869, 1.89731448e-08, 1, 7.66965584e-08, -0.999841869, 2.03340544e-08, -0.0177831985),
        ["Mushroom"] = CFrame.new(2501.48584, 131.000015, -720.699463, 3.68081814e-08, 8.53819131e-08, -1, 1.957986e-10, 1, 8.53819131e-08, 1, -1.95801736e-10, 3.68081814e-08),
        ["Keeper Altar"] = CFrame.new(1311.00732, -802.427002, -81.4699707, -0.0228943285, 4.18314947e-08, -0.999737918, -4.11508445e-08, 1, 4.27848299e-08, 0.999737918, 4.21195878e-08, -0.0228943285),
        ["Terrapin"] = CFrame.new(-143.862732, 145.100067, 1909.52588, -0.879716396, 6.53489494e-08, -0.475498736, 4.80829385e-08, 1, 4.84745755e-08, 0.475498736, 1.97805026e-08, -0.879716396),
        ["Ancient Archive"] = CFrame.new(-3159.99512, -745.614014, 1684.16797, 1, -7.40275823e-08, 2.84239377e-06, 7.40277315e-08, 1, -5.38872342e-08, -2.84239377e-06, 5.38874474e-08, 1),
        ["Ancient Isle"] = CFrame.new(6056.0498, 195.280151, 278.566376, -0.850848079, -8.56003481e-08, -0.525411725, -5.92180562e-08, 1, -6.70232012e-08, 0.525411725, -2.59127031e-08, -0.850848079),
        ["Ancient Archive Entrance"] = CFrame.new(5921.37988, 164.931091, 457.289581, 0.632040918, 4.07546175e-08, 0.774935007, 6.71610767e-10, 1, -5.3138784e-08, -0.774935007, 3.41063391e-08, 0.632040918),
        ["Northen Expedition"] = CFrame.new(19563.322266, 141.034576, 5286.112793, -0.899414, -0.000000, 0.437097, 0.000000, 1.000000, 0.000000, -0.437097, 0.000000, -0.899414)
    },
    Totem = {
        ["Aurora Totem"] = CFrame.new(-1813.348022, -136.927963, -3281.077637, -0.422536, -0.000000, 0.906346, -0.000000, 1.000000, 0.000000, -0.906346, 0.000000, -0.422536),
        ["Smokescreen Totem"] = CFrame.new(2791.951172, 139.729446, -629.169678, 0.580793, 0.000000, 0.814051, -0.000000, 1.000000, -0.000000, -0.814051, -0.000000, 0.580793),
        ["Windset Totem"] = CFrame.new(2851.845459, 179.838745, 2703.349121, -0.390777, -0.000000, -0.920485, -0.000000, 1.000000, -0.000000, 0.920485, -0.000000, -0.390777),
        ["Tempest Totem"] = CFrame.new(37.580360, 132.499969, 1940.727173, -0.016323, -0.000000, -0.999867, 0.000000, 1.000000, -0.000000, 0.999867, -0.000000, -0.016323),
        ["Sundial Totem"] = CFrame.new(-1149.792725, 134.499954, -1073.856445, 0.996527, 0.000000, 0.083266, -0.000000, 1.000000, -0.000000, -0.083266, 0.000000, 0.996527),
        ["Eclipse Totem"] = CFrame.new(5966.475586, 274.108398, 842.755554, 0.968658, -0.000000, 0.248398, 0.000000, 1.000000, 0.000000, -0.248398, -0.000000, 0.968658),
        ["Meteor Totem"] = CFrame.new(-1947.877197, 275.356659, 230.777985, -0.199754, 0.000000, -0.979846, 0.000000, 1.000000, 0.000000, 0.979846, 0.000000, -0.199754),
        ["Bilzzard Totem"] = CFrame.new(20148.884766, 742.952759, 5804.236328, 0.998622, 0.000000, -0.052486, 0.000000, 1.000000, 0.000000, 0.052486, 0.000000, 0.998622),
        ["Avalanche Totem"] = CFrame.new(19710.455078, 467.630585, 6061.452637, 0.314567, -0.000000, 0.949235, 0.000000, 1.000000, 0.000000, -0.949235, -0.000000, 0.314567)
    },
    NPC = {
	    ["Test"] = CFrame.new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
	}
}
local AutoBuy = {
	ChosenAutoBuy = "Crab Cage",
	Items = {
		["Crab Cage"] = CFrame.new(-921.549194, 131.078812, -1106.665894, -0.967867, 0.000000, 0.251462, 0.000000, 1.000000, 0.000000, -0.251462, 0.000000, -0.967867),
		["Bait Crate"] = CFrame.new(385.700500, 136.994141, 335.602051, -0.848685, -0.000000, -0.528898, -0.000000, 1.000000, -0.000000, 0.528898, -0.000000, -0.848685),
		["Quality Bait Crate"] = CFrame.new(-175.573959, 143.273819, 1933.769897, -0.862027, -0.000000, 0.506862, -0.000000, 1.000000, -0.000000, -0.506862, -0.000000, -0.862027),
		["Coral Geode"] = CFrame.new(-1643.960327, -213.679443, -2848.067627, -0.996809, 0.000000, 0.079825, 0.000000, 1.000000, 0.000000, -0.079825, 0.000000, -0.996809)
	},
}
local EventFish = {
    "Megalodon Default",
    "Megalodon Ancient",
    "Great White Shark",
    "Whale Shark",
    "The Depths - Serpent",
    "Isonade"
}

local islandNames = {}
local NPCNames = {}
local TotemNames = {}
local AutoBuyItems = {}
for islandName in pairs(Location.Islands) do
    table.insert(islandNames, islandName)
end
for NPCName in pairs(Location.NPC) do
	table.insert(NPCNames, NPCName)
end
for TotemName in pairs(Location.Totem) do
	table.insert(TotemNames, TotemName)
end
for AutoBuyItem in pairs(AutoBuy.Items) do
	table.insert(AutoBuyItems, AutoBuyItem)
end

--// Window
local Window = Fluent:CreateWindow({
    Title = "Servenity",
    SubTitle = "V2 Private",
    TabWidth = 160,
    Size = UDim2.fromOffset(610, 385),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.Insert
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "rbxassetid://10734886202" }),
    Dupe = Window:AddTab({ Title = "Dupe", Icon = "rbxassetid://10709798574" }),
    Auto = Window:AddTab({ Title = "Auto", Icon = "rbxassetid://10734923549" }),
    Webhook = Window:AddTab({ Title = "Webhook", Icon = "rbxassetid://10734950813" }),
    Inventory = Window:AddTab({ Title = "Inventory", Icon = "rbxassetid://10709769841" }),
    Shop = Window:AddTab({ Title = "Shop", Icon = "rbxassetid://10734952479" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "rbxassetid://10734922971" }),
    Miscellaneous = Window:AddTab({ Title = "Miscellaneous", Icon = "rbxassetid://10747373176" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "rbxassetid://10734950309" })
}

getgenv().Options = Fluent.Options
getgenv().SavedPosition_CFrame = CFrame.new(0, 0, 0)
if not isfile("Servenity/SavedPos.cf") then
    writefile("Servenity/SavedPos.cf", tostring(SavedPosition_CFrame))
else
    local savedData = readfile("Servenity/SavedPos.cf")
    SavedPosition_CFrame = CFrame.new(unpack(savedData:split(", ")))
end

--// Main
do
    --// Farming
    local Main_AutoFish_Config = Tabs.Main:AddSection("Config") do
	    Tabs.Main:AddDropdown("auto_fish_config_reel_mode", {Title = "Reel Mode", Default = 1, Values = {"Instant", "Filled", "Legit", "Fail"} })
        Tabs.Main:AddDropdown("auto_fish_config_shake_method", {Title = "Shake Method", Default = 1, Values = {"UINavigation", "VIM"} })
        Tabs.Main:AddToggle("auto_fish_anti_perfect_catch", {Title = "Anti Perfect-Catch", Default = false })
        Tabs.Main:AddButton({Title = "Save Position", Callback = function()
            if Character and Character:FindFirstChild("HumanoidRootPart") then
                SavedPosition_CFrame = Character.HumanoidRootPart.CFrame
                writefile("Servenity/SavedPos.cf", tostring(SavedPosition_CFrame))
            end
        end})
        Tabs.Main:AddButton({Title = "TP To Saved Position", Callback = function()
            if Character and Character:FindFirstChild("HumanoidRootPart") then
                Character.HumanoidRootPart.CFrame = SavedPosition_CFrame
            end
        end})
    end
	local Main_AutoFish_Main = Tabs.Main:AddSection("Auto Fish") do
		Tabs.Main:AddToggle("auto_fish_cast", {Title = "Auto Cast", Default = false })
		Tabs.Main:AddToggle("auto_fish_shake", {Title = "Auto Shake", Default = false })
		Tabs.Main:AddToggle("auto_fish_reel", {Title = "Auto Reel", Default = false })
		Tabs.Main:AddToggle("auto_fish_leave_aurora_borealis", {Title = "Serverhop on Aurora Borealis", Description = "Serverhop when a Aurora Borealis happens.", Default = false })
		Tabs.Main:AddToggle("auto_fish_nuke_minigame", {Title = "Auto Play Nuke Minigame", Default = false })
	end
	
    --// Auto Event Fish
    local Main_Auto_Megalodon_Config = Tabs.Main:AddSection("Event Fish") do
	    Tabs.Main:AddToggle("auto_fish_megalodon", {Title = "Auto Megalodon", Default = false })
	    Tabs.Main:AddToggle("auto_fish_isonade", {Title = "Auto Isonade", Default = false })
	    Tabs.Main:AddToggle("auto_fish_whale_shark", {Title = "Auto Whale Shark", Default = false })
	    Tabs.Main:AddToggle("auto_fish_great_white_shark", {Title = "Auto Great Whale Shark", Default = false })
    	Tabs.Main:AddToggle("auto_fish_ancient_depth_serpent", {Title = "Auto Ancient Depth Serpent", Default = false })
    	Tabs.Main:AddToggle("auto_fish_event_fish_sundial", {Title = "Auto Sundial", Default = false })
    end
end

--// Automatically
do
    --// Auto Appraise
    local Auto_Appraise_Config = Tabs.Auto:AddSection("Auto Appraise") do
	    Tabs.Auto:AddToggle("inventory_auto_favorite", {Title = "Auto Appraise", Default = false })
    	Tabs.Auto:AddToggle("inventory_allow_weight", {Title = "Allow Weight", Default = false })
    	Tabs.Auto:AddToggle("inventory_allow_mutation", {Title = "Allow Mutation", Default = false })
    end
end

--// Inventory
do
    --// Auto Favorite
    local Inventory_Auto_Favorite = Tabs.Inventory:AddSection("Favorite") do
        Tabs.Inventory:AddInput("inventory_favorite_item", {Title = "Item", Default = "", Placeholder = "Fish", Callback = function(v)
	        getgenv().FishForceFavoriteName = tostring(v)
        end})
        Tabs.Inventory:AddToggle("inventory_auto_favorite", {Title = "Auto Favorite", Default = false })
	    Tabs.Inventory:AddButton({Title = "Favorite", Callback = function()
		    FavoriteItem(tostring(FishForceFavoriteName))
		end})
    end
end

--// Shop
do
   --// Auto Buy Main Settings
   local Shop_Auto_Buy_Settings = Tabs.Shop:AddSection("Auto Buy Settings") do
        Tabs.Shop:AddToggle("auto_buy", {Title = "Auto Buy", Default = false })
        Tabs.Shop:AddDropdown("auto_buy_item_dropdown", {Title = "Choose items", Default = 1, Values = AutoBuyItems, Callback = function(v)
		    AutoBuy.ChosenAutoBuy = v
		end})
		Tabs.Shop:AddInput("auto_buy_item_delay", {Title = "Auto Buy Delay", Default = "1", Placeholder = "1", Callback = function(v)
	        getgenv().AutoBuyDelay = tonumber(v or 0.5)
        end})
		Tabs.Shop:AddInput("auto_buy_item_amount", {Title = "Amount to Buy", Default = "10", Placeholder = "10", Callback = function(v)
	        getgenv().AutoBuyAmount = tonumber(v or 10)
        end})
    end
    local Shop_Merlin = Tabs.Shop:AddSection("Merlin") do
	    Tabs.Shop:AddToggle("merlin_auto_buy_relic", {Title = "Auto Buy Relic", Description = "Relic Price: 11,000C$", Default = false })
	    Tabs.Shop:AddToggle("merlin_auto_buy_luck", {Title = "Auto Buy Luck", Description = "Luck Price: 5,000C$", Default = false })
	    Tabs.Shop:AddInput("merlin_auto_buy_amount", {Title = "Amount to Buy", Default = "10", Placeholder = "10", Callback = function(v)
	        getgenv().MerlinAutoBuyAmount = tonumber(v or 10)
        end})
    end
end

--// Teleport
do
    --// Islands
    local Teleport_Islands = Tabs.Teleport:AddSection("Island") do
	    Tabs.Teleport:AddDropdown("teleport_island_dropdown", {Title = "Choose Island", Default = 1, Values = islandNames, Callback = function(v)
		    Location.ChosenIsland = v
		end})
		Tabs.Teleport:AddButton({Title = "Teleport to Island", Callback = function()
		    if Location.ChosenIsland and Location.Islands[Location.ChosenIsland] then
		        if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		            Character.HumanoidRootPart.CFrame = Location.Islands[Location.ChosenIsland]
		        end
		    end
		end})
    end
    
    --// Totem
    local Teleport_Totem = Tabs.Teleport:AddSection("Totem") do
	    Tabs.Teleport:AddDropdown("teleport_totem_dropdown", {Title = "Choose Totem", Default = 1, Values = TotemNames, Callback = function(v)
		    Location.ChosenTotem = v
		end})
		Tabs.Teleport:AddButton({Title = "Teleport to Totem", Callback = function()
		    if Location.ChosenTotem and Location.Totem[Location.ChosenTotem] then
		        if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		            Character.HumanoidRootPart.CFrame = Location.Totem[Location.ChosenTotem]
		        end
		    end
		end})
    end
    
    --// NPC
    local Teleport_Islands = Tabs.Teleport:AddSection("NPC") do
	    Tabs.Teleport:AddDropdown("teleport_npc_dropdown", {Title = "Choose NPCs", Default = 1, Values = NPCNames, Callback = function(v)
		    Location.ChosenNPC = v
		end})
		Tabs.Teleport:AddButton({Title = "Teleport to NPC", Callback = function()
		    if Location.ChosenNPC and Location.NPC[Location.ChosenNPC] then
		        if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		            Character.HumanoidRootPart.CFrame = Location.NPC[Location.ChosenNPC]
		        end
		    end
		end})
    end
    
    --// Player
    local Teleport_Player = Tabs.Teleport:AddSection("Player") do
	    Tabs.Teleport:AddInput("teleport_player_target_username", {Title = "Choose Username", Default = "", Placeholder = "User", Callback = function(v)
			getgenv().TPToPlayerUsername = v
        end})
		Tabs.Teleport:AddButton({Title = "Teleport to Player", Description = "Has to be the exact username.", Callback = function()
		    local TargetPlayer = Players:FindFirstChild(TPToPlayerUsername)
		    if TargetPlayer and TargetPlayer.Character then
		        local TargetHumanoid = TargetPlayer.Character:FindFirstChild("Humanoid")
		        if TargetHumanoid then
		            Character.HumanoidRootPart.CFrame = TargetPlayer.Character.HumanoidRootPart.CFrame
		        end
		    end
		end})
    end
    
    --// Fishing Rod
    local Teleport_Fishing_Rod = Tabs.Teleport:AddSection("Fishing Rod") do
        Tabs.Teleport:AddButton({Title = "Heaven Rod", Callback = function()
			Character.HumanoidRootPart.CFrame = CFrame.new(20027.599609, -467.665955, 7111.936523, -0.999731, 0.000000, -0.023211, 0.000000, 1.000000, 0.000000, 0.023211, 0.000000, -0.999731)
	    end})
	    Tabs.Teleport:AddButton({Title = "Rod of the Depths", Callback = function()
			Character.HumanoidRootPart.CFrame = CFrame.new(1704.745239, -902.527039, 1445.513062, 0.997756, 0.000000, 0.066960, -0.000000, 1.000000, 0.000000, -0.066960, -0.000000, 0.997756)
	    end})
	    Tabs.Teleport:AddButton({Title = "Trident", Callback = function()
			Character.HumanoidRootPart.CFrame = CFrame.new(-1479.373657, -221.735641, -2333.345215, -0.997665, -0.000000, 0.068291, -0.000000, 1.000000, 0.000000, -0.068291, 0.000000, -0.997665)
	    end})
    end
end

--// Miscellaneous
do
    --// Modifications
	local Modifications = Tabs.Miscellaneous:AddSection("Modifications") do
	    Tabs.Miscellaneous:AddToggle("modifications_walkspeed_enabled", {Title = "Walkspeed", Default = false })
    	Tabs.Miscellaneous:AddInput("modifications_walkspeed_speed_amount", {Title = "Walkspeed Amount", Default = "5", Placeholder = "5", Callback = function(v)
			getgenv().WalkspeedCFrameAmount = tonumber(v or 5)
        end})
        Tabs.Miscellaneous:AddToggle("modifications_inf_jump", {Title = "Infinite Jump", Default = false })
	end
	
    --// World
	local World = Tabs.Miscellaneous:AddSection("World") do
	    Tabs.Miscellaneous:AddToggle("miscellaneous_anti_afk", {Title = "Anti Afk", Default = false })
    	Tabs.Miscellaneous:AddToggle("miscellaneous_remove_fog", {Title = "Anti Fog", Default = false })
        Tabs.Miscellaneous:AddToggle("miscellaneous_remove_blur", {Title = "Anti Blur", Default = false })
	end
	
	--// Character
	local Character = Tabs.Miscellaneous:AddSection("Character") do
        Tabs.Miscellaneous:AddToggle("miscellaneous_infinite_oxygen", {Title = "Infinite Oxygen", Default = true})
        Tabs.Miscellaneous:AddToggle("miscellaneous_infinite_temperature", {Title = "Infinite Temperature", Default = true})
        Tabs.Miscellaneous:AddToggle("miscellaneous_walk_on_water", {Title = "Walk on water", Default = true, Callback = function(v)
            for _, child in pairs(Workspace.zones.fishing:GetChildren()) do
			    if child:IsA("BasePart") then
			        child.CanCollide = v
			    end
			end
        end})
	    Tabs.Miscellaneous:AddToggle("miscellaneous_anchor_body", {Title = "Anchor Body", Default = false })
	end
	
	--// Notifications
	local Notifications = Tabs.Miscellaneous:AddSection("Notifications") do
	    Tabs.Miscellaneous:AddToggle("miscellaneous_notify_zone_event", {Title = "Notify Zone Event", Default = true })
    	Tabs.Miscellaneous:AddToggle("miscellaneous_player_joinorleft_log", {Title = "Player Left/Join", Default = false })
	end
	local HideIdentity = Tabs.Miscellaneous:AddSection("Hide Identity") do
    	Tabs.Miscellaneous:AddToggle("hide_identity", {Title = "Hide Idenitity", Default = false })
	end
end

do
    --// Settings
	local Settings_Exploits_Upper = Tabs.Settings:AddSection("Exploit Settings") do
		Tabs.Settings:AddButton({Title = "Delete Exploits File", Callback = function()
		    Window:Dialog({Title = "Delete Exploits File", Content = "Are you sure you want to reset your data? This action cannot be undone.", Buttons = {
				{Title = "Confirm", Callback = function()
		            for _, v in next, {"Servenity"} do 
						if isfolder(v) then 
							delfolder(v) 
						end
					end
		        end},
		        {Title = "Cancel", Callback = function()
		            print("[User]: Has Cancelled The data removals")
		        end}}
			})
		end})
	end
	
	local Settings_Serverhop = Tabs.Settings:AddSection("Serverhop") do
	    Tabs.Settings:AddDropdown("settings_serverhop_mode", {Title = "Server Mode", Default = 1, Values = {"Lowest", "Highest", "Ping"}, Callback = function(v)
            getgenv().ServerHopMode = v
        end})
	    Tabs.Settings:AddButton({Title = "Join Server", Callback = function()
            ServerHop()
        end})
	end
	
	SaveManager:SetLibrary(Fluent)
	InterfaceManager:SetLibrary(Fluent)
	SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})
	InterfaceManager:SetFolder("Servenity")
	SaveManager:SetFolder("Servenity/Fisch")
	InterfaceManager:BuildInterfaceSection(Tabs.Settings)
	SaveManager:BuildConfigSection(Tabs.Settings)
	Window:SelectTab(1)
	SaveManager:LoadAutoloadConfig()
end

--// Auto Buy
local LastAutoBuyTime = 0
local PurchaseCount = 0
RunService.RenderStepped:Connect(function()
    if Options["auto_buy"].Value then
        if tick() - LastAutoBuyTime < AutoBuyDelay then return end
        if AutoBuyAmount and PurchaseCount >= AutoBuyAmount then
            Options["auto_buy"]:SetValue(false)
            return
        end
        local DialogUI = PlayerGui:FindFirstChild("over")
        local PromptUI = DialogUI and DialogUI.Enabled and DialogUI:FindFirstChild("prompt")
        local ConfirmPromptButton = PromptUI and PromptUI:FindFirstChild("confirm")
        local PromptAmountButton = PromptUI and PromptUI:FindFirstChild("amount")
        Character.HumanoidRootPart.CFrame = AutoBuy.Items[AutoBuy.ChosenAutoBuy]
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        if ConfirmPromptButton and ConfirmPromptButton.Visible then
            if AutoBuy.Items and Character and HumanoidRootPart then
                GuiService.SelectedObject = ConfirmPromptButton
                if GuiService.GuiNavigationEnabled and GuiService.SelectedObject == ConfirmPromptButton then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                    PurchaseCount = PurchaseCount + 1
                end
                LastAutoBuyTime = tick()
            end
        end
    end
end)

--// Auto Buy Merlin
local LastBuyTime = 0
local MerlinPurchaseCount = 0

RunService.RenderStepped:Connect(function()
    local SafeZoneUI = PlayerGui:FindFirstChild("options") and PlayerGui.options:FindFirstChild("safezone")
    local RespondMessageOption1 = SafeZoneUI and SafeZoneUI:FindFirstChild("1option") and SafeZoneUI["1option"]:FindFirstChild("button")
    local RespondMessageOption2 = SafeZoneUI and SafeZoneUI:FindFirstChild("3option") and SafeZoneUI["3option"]:FindFirstChild("button")
    if Options["merlin_auto_buy_luck"].Value or Options["merlin_auto_buy_relic"].Value then
        if tick() - LastBuyTime < 0.3 or MerlinPurchaseCount >= (MerlinAutoBuyAmount or 10) then
            Options["merlin_auto_buy_luck"].Value = false
            Options["merlin_auto_buy_relic"].Value = false
            return
        end
        Character.HumanoidRootPart.CFrame = CFrame.new(-928.971863, 225.730988, -995.030945, -0.610376, 0, -0.792112, 0, 1, 0, 0.792112, 0, -0.610376)
        GuiService.SelectedObject = RespondMessageOption1
        if GuiService.GuiNavigationEnabled and GuiService.SelectedObject == RespondMessageOption1 then
            GuiService.SelectedObject = Options["merlin_auto_buy_luck"].Value and RespondMessageOption2 or RespondMessageOption1
            if GuiService.SelectedObject then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                MerlinPurchaseCount += 1
                LastBuyTime = tick()
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    --// Auto Fish Code
	if Options["auto_fish_cast"].Value and Character then
	    local Tool = Character:FindFirstChildOfClass("Tool")
	    if Tool then
	        local EventsFolder = Tool:FindFirstChild("events")
	        local CastEvent = EventsFolder and EventsFolder:FindFirstChild("cast")
	        if CastEvent and CastEvent:IsA("RemoteEvent") then
	            CastEvent:FireServer(math.random(97, 100), 1)
	        end
	    end
	end

	if Options["auto_fish_shake"].Value then
	    local ScreenGui = PlayerGUI:FindFirstChild("shakeui")
	    if ScreenGui and ScreenGui.Enabled then
	        local SafeZone = ScreenGui:FindFirstChild("safezone")
	        local ShakeButton = SafeZone and SafeZone:FindFirstChild("button")
	        if ShakeButton and ShakeButton.Visible and ShakeButton:IsA("ImageButton") then
	            if Options["auto_fish_config_shake_method"].Value == "VIM" then
	                local CenterXShakeButton = ShakeButton.AbsolutePosition.X + (ShakeButton.AbsoluteSize.X / 2)
	                local CenterYShakeButton = ShakeButton.AbsolutePosition.Y + (ShakeButton.AbsoluteSize.Y / 2)
	                VirtualInputManager:SendMouseButtonEvent(CenterXShakeButton, CenterYShakeButton, 0, true, LocalPlayer, 0)
	                VirtualInputManager:SendMouseButtonEvent(CenterXShakeButton, CenterYShakeButton, 0, false, LocalPlayer, 0)
	            elseif Options["auto_fish_config_shake_method"].Value == "UINavigation" then
	                GuiService.SelectedObject = ShakeButton
	                if GuiService.GuiNavigationEnabled and GuiService.SelectedObject == ShakeButton then
	                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
	                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
	                end
	            end
	        end
	    end
	end
	
	--// Auto Nuke Minigame
	if Options["auto_fish_nuke_minigame"].Value then
	    local NukeMinigameUI = PlayerGui:FindFirstChild("NukeMinigame")
	    if NukeMinigameUI and NukeMinigameUI:FindFirstChild("Center") then
	        local NukeMinigameArrow = NukeMinigameUI.Center.Marker:FindFirstChild("Pointer")
	        if NukeMinigameUI.Enabled and NukeMinigameArrow and NukeMinigameArrow.Visible then
	            if NukeMinigameArrow.Rotation > 60 then
	                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
	            elseif NukeMinigameArrow.Rotation < -60 then
	                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, nil)
	            end
	        end
	    end
	end
	
	--// Miscellaneous Code
    if Character then
	    local Client = Character:FindFirstChild("client")
	    if Client then
	        local ClientOxygen = Client:FindFirstChild("oxygen")
	        local ClientMountainPeakOxygen = Client:FindFirstChild("oxygen(peaks)")
	        local ClientTemperature = Client:FindFirstChild("temperature")
	        if ClientOxygen then
	            local DisableOxygen = Options["miscellaneous_infinite_oxygen"].Value
	            ClientOxygen.Disabled = DisableOxygen
	            if ClientMountainPeakOxygen then
	                ClientMountainPeakOxygen.Disabled = DisableOxygen
	            end
	        end
	        if ClientTemperature then
	            ClientTemperature.Disabled = Options["miscellaneous_infinite_temperature"].Value
	        end
	    end
	end
    
    if Options["miscellaneous_anchor_body"].Value and Humanoid and HumanoidRootPart then
        HumanoidRootPart.Anchored = true
    else
        HumanoidRootPart.Anchored = false
    end
    
    --// Short Code
	if Options["modifications_walkspeed_enabled"].Value then
        local v1ws, v2ws = LocalPlayer.Character.HumanoidRootPart, LocalPlayer.Character.Humanoid
        v1ws.CFrame = v1ws.CFrame + v2ws.MoveDirection * WalkspeedCFrameAmount
    end
	if Options["inventory_auto_favorite"].Value then
		FavoriteItem(FishForceFavoriteName)
	end
	if Options["miscellaneous_anti_afk"].Value then
		ReplicatedStorage:WaitForChild("events"):WaitForChild("afk"):FireServer(false)
	end
end)

RunService.RenderStepped:Connect(function()
    local CurrentTime = tick()
    local AutoEventZoneYValue = 12.5
    local AutoFarmObjYValue = 0
    
    --// Auto Megalodon
    if Options["auto_fish_megalodon"].Value and Character then
        local MegalodonDefault = Workspace.zones.fishing:WaitForChild("Megalodon Default")
        local MegalodonAncient = Workspace.zones.fishing:WaitForChild("Megalodon Ancient")
        if MegalodonDefault then
            Character.HumanoidRootPart.CFrame = MegalodonDefault.CFrame + Vector3.new(0, AutoEventZoneYValue, 0)
            AutoFarmObj.CFrame = MegalodonDefault.CFrame + Vector3.new(0, -AutoFarmObjYValue, 0)
            return
        elseif MegalodonAncient then
            Character.HumanoidRootPart.CFrame = MegalodonAncient.CFrame + Vector3.new(0, AutoEventZoneYValue, 0)
            AutoFarmObj.CFrame = MegalodonAncient.CFrame + Vector3.new(0, -AutoFarmObjYValue, 0)
            return
        end
    end
    
    --// Auto Whale Shark
    if Options["auto_fish_whale_shark"].Value and Character then
        local WhaleShark = Workspace.zones.fishing:WaitForChild("Whale Shark")
        if WhaleShark then
            Character.HumanoidRootPart.CFrame = WhaleShark.CFrame + Vector3.new(0, AutoEventZoneYValue, 0)
            AutoFarmObj.CFrame = WhaleShark.CFrame + Vector3.new(0, -AutoFarmObjYValue, 0)
            return
        end
    end
    
    --// Auto Isonade
    if Options["auto_fish_isonade"].Value and Character then
        local Isonade = Workspace.zones.fishing:WaitForChild("Isonade")
        if Isonade then
            Character.HumanoidRootPart.CFrame = Isonade.CFrame + Vector3.new(0, AutoEventZoneYValue , 0)
            AutoFarmObj.CFrame = Isonade.CFrame + Vector3.new(0, -AutoFarmObjYValue, 0)
            return
        end
    end
    
    --// Great White Shark
    if Options["auto_fish_great_white_shark"].Value and Character then
        local GreatWhiteShark = Workspace.active:WaitForChild("Great White Shark")
        if GreatWhiteShark then
            Character.HumanoidRootPart.CFrame = GreatWhiteShark.RootPart.CFrame + Vector3.new(0, AutoEventZoneYValue, 0)
            AutoFarmObj.CFrame = GreatWhiteShark.CFrame + Vector3.new(0, -AutoFarmObjYValue, 0)
            return
        end
    end

    --// Ancient Depth Serpent
    if Options["auto_fish_ancient_depth_serpent"].Value and Character then
        local AncientDepthSerpent = Workspace.active.fishing:WaitForChild("The Depths - Serpent")
        if AncientDepthSerpent then
            Character.HumanoidRootPart.CFrame = AncientDepthSerpent.RootPart.CFrame + Vector3.new(0, AutoEventZoneYValue, 0)
            AutoFarmObj.CFrame = AncientDepthSerpent.CFrame + Vector3.new(0, -AutoFarmObjYValue, 0)
            return
        end
    end
    
    --// Auto Pop Sundial
    if Options["auto_fish_event_fish_sundial"].Value and Character then
        local SundialTotemCooldown = 5.5
        LastSundialPopTime = LastSundialPopTime or 0
        if CurrentTime - LastSundialPopTime >= SundialTotemCooldown then
            Equip("Sundial Totem")
            local Tool = Character:FindFirstChildOfClass("Tool")
            if Tool and Tool.Name == "Sundial Totem" then
                Tool:Activate()
                LastSundialPopTime = CurrentTime
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Options["modifications_inf_jump"].Value and Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local FishingZone = Workspace.active or Workspace.zones.fishing
FishingZone.ChildAdded:Connect(function(Child)
    if Options["miscellaneous_notify_zone_event"].Value and FishingZone then
        if table.find(EventFish, Child.Name) then
            Fluent:Notify({
                Title = "Event Fish Spotted!",
                Content = "A rare event fish, " .. Child.Name .. ", has been detected!",
                Duration = 3
            })
        end
    end
end)

PlayerGui.ChildAdded:Connect(function(Child)
    if not (Child:IsA("ScreenGui") and Child.Name == "reel") then return end
    local ReelEvent = ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished")
    if Options["auto_fish_reel"].Value then
        task.spawn(function()
            while Child and Child.Parent and ReelEvent do
                task.wait()
                if Options["auto_fish_config_reel_mode"].Value == "Instant" then
                    ReelEvent:FireServer(100, 1)
                elseif Options["auto_fish_config_reel_mode"].Value == "Filled" then
                    local ReelBar = Child:FindFirstChild("bar")
                    local ReelPlayerBar = ReelBar and ReelBar:FindFirstChild("playerbar")
                    if ReelPlayerBar then
                        ReelPlayerBar.Size = UDim2.new(1, 0, 1, 0)
                    end
                elseif Options["auto_fish_config_reel_mode"].Value == "Legit" then
                    local PlayerBar = Child:FindFirstChild("bar") and Child.bar:FindFirstChild("playerbar")
                    local FishBar = Child:FindFirstChild("bar") and Child.bar:FindFirstChild("fish")
                    if PlayerBar and FishBar then
                        PlayerBar.Position = FishBar.Position
                    end
                elseif Options["auto_fish_config_reel_mode"].Value == "Fail" then
                    ReelEvent:FireServer(5, 1)
                end
            end
        end)
    end
end)

if game:GetService("UserInputService").TouchEnabled then
    local ScreenGui = Instance.new("ScreenGui", cloneref(game.CoreGui))
    local ImageButton = Instance.new("ImageButton", ScreenGui)
    SetDraggable(ImageButton, 41)
    local UICorner = Instance.new("UICorner", ImageButton)
    ScreenGui.DisplayOrder = 9999
    ImageButton.BorderSizePixel = 0
    ImageButton.BackgroundTransparency = 0
    ImageButton.BackgroundColor3 = Color3.new(1, 1, 1)
    ImageButton.Image = "rbxassetid://132320421349635"
    ImageButton.Size = UDim2.new(0, 50, 0, 50)
    ImageButton.Position = UDim2.new(0, 430, 0, 148)
    ImageButton.BorderColor3 = Color3.new(0, 0, 0)
    ImageButton.AutoButtonColor = false
    ImageButton.Position = UDim2.new(0, 0, 0, 0)
    ImageButton.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
    ImageButton.MouseButton1Click:Connect(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, nil)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, nil)
    end)
end

--[[ debug code or saved code

-- basically copy ur cframe to add new tp
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    local HumanoidRootPart = LocalPlayer.Character.HumanoidRootPart
    local cframe = HumanoidRootPart.CFrame
    local cframeString = string.format("CFrame.new(%f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f)", cframe:GetComponents())
    setclipboard(cframeString)
end

-- copy ur SelectedObject GuiObject useful for finding ui to make auto stuff
local GuiService = game:GetService("GuiService")
local function getFullPath(guiObject)
    if not guiObject then
        return "No object selected"
    end
    local path = guiObject.Name
    local parent = guiObject.Parent
    while parent do
        path = parent.Name .. "." .. path
        parent = parent.Parent
    end
    return path
end
GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
    local selected = GuiService.SelectedObject
    print("Currently selected object:", getFullPath(selected))
end)

-- remote
ReplicatedStorage.events.finishedloading:FireServer()

-- workspace
Workspace.active["Safe Whirlpool"]
Workspace.active["Whale Shark"]
Workspace.active["Great White Shark"].RootPart
Workspace.zones.fishing["The Depths - Serpent"]
Workspace.zones.fishing.Isonade
]]
