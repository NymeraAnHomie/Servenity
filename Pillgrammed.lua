local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Backpack = LocalPlayer.Backpack
local Camera = workspace.CurrentCamera
local ScreenCenter = Camera.ViewportSize / 2
local Character = LocalPlayer.Character
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

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
        
        if ServerMode == "Best Ping" then
            for _, Server in ipairs(ServersList) do
                local Ping = ServerhopGetPing(Server.id)
                if Ping < BestPing then
                    BestPing, BestServer = Ping, Server
                end
            end
        elseif ServerMode == "Worst Ping" then
            for _, Server in ipairs(ServersList) do
                local Ping = ServerhopGetPing(Server.id)
                if Ping > BestPing then
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
local function ForceEquipTool(toolName)
    if Humanoid and Backpack then
        local Tool = Backpack:FindFirstChild(toolName)
        if Tool then
            Humanoid:EquipTool(Tool)
        end
    end
end
local function UnEquipTool(toolName)
    if Character and Backpack then
        local Tool = Character:FindFirstChild(toolName)
        if Tool then
            Tool.Parent = Backpack
        end
    end
end

local AutoFarmObj = Instance.new("Part", Workspace)
AutoFarmObj.Size = Vector3.new(2, 2, 2)
AutoFarmObj.Anchored = true

local Location = {
	Islands = {
		["Frozen Cathedral"] = CFrame.new(5224.056152, -360.426178, 3413.142578, 0.021708, -0.000000, -0.999764, 0.000000, 1.000000, -0.000000, 0.999764, -0.000000, 0.021708),
		["Dojo's Approach"] = CFrame.new(1717.514771, 183.499954, 218.672638, -0.069664, 0.000000, 0.997571, -0.000000, 1.000000, -0.000000, -0.997571, -0.000000, -0.069664),
		["False Believer"] = CFrame.new(3729.072998, -440.174469, 6843.669434, -0.612672, -0.000000, -0.790337, 0.000000, 1.000000, -0.000000, 0.790337, -0.000000, -0.612672),
		["Hidden Bellkeeper"] = CFrame.new(4272.542480, -467.906494, 3901.058350, 0.995006, -0.000000, 0.099818, 0.000000, 1.000000, -0.000000, -0.099818, 0.000000, 0.995006),
		["Prism Troll Arena"] = CFrame.new(724.753174, -15.909891, 52.852535, -0.113037, 0.000000, 0.993591, 0.000000, 1.000000, -0.000000, -0.993591, 0.000000, -0.113037),
		["Purple Shark Arena"] = CFrame.new(-2008.019653, -695.037781, -536.772400, -0.721517, 0.000000, 0.692396, 0.000000, 1.000000, 0.000000, -0.692396, 0.000000, -0.721517),
		["Big Iron"] = CFrame.new(2328.838623, -17.500006, -3243.009277, 0.999465, -0.000000, -0.032718, 0.000000, 1.000000, -0.000000, 0.032718, 0.000000, 0.999465),
		["Unfair Fight"] = CFrame.new(4470.296875, -329.125580, -2199.090576, 0.006444, -0.000000, 0.999979, 0.000000, 1.000000, 0.000000, -0.999979, 0.000000, 0.006444),
		["Patris Island"] = CFrame.new(-3117.919678, -21.224762, -4241.643066, 0.973629, -0.000000, -0.228137, 0.000000, 1.000000, 0.000000, 0.228137, -0.000000, 0.973629),
		["Ceremonial Greatblade"] = CFrame.new(20727.357422, -1406.500366, -349.841766, -0.364550, -0.000000, -0.931184, 0.000000, 1.000000, -0.000000, 0.931184, -0.000000, -0.364550)
    },
	CatacombLevers = {
		["Lever 1"] = CFrame.new(5205.883789, -279.500092, 481.946106, -0.761892, 0.000000, 0.647704, 0.000000, 1.000000, -0.000000, -0.647704, 0.000000, -0.761892),
		["Lever 2"] = CFrame.new(4779.029785, -279.500092, -483.483521, 0.999262, -0.000000, -0.038401, 0.000000, 1.000000, 0.000000, 0.038401, -0.000000, 0.999262),
		["Lever 3"] = CFrame.new(4991.687012, -279.500092, 389.135803, 0.053997, 0.000000, 0.998541, 0.000000, 1.000000, -0.000000, -0.998541, 0.000000, 0.053997),
		["Catacomb Arena"] = CFrame.new(5356.958496, -403.500092, 317.145111, 0.999997, -0.000000, 0.002545, 0.000000, 1.000000, -0.000000, -0.002545, 0.000000, 0.999997)
	},
	Cataseeds = {
		["Seed 1"] = CFrame.new(4979.690430, -343.090027, 611.070740, 0.999845, -0.000000, -0.017632, 0.000000, 1.000000, 0.000000, 0.017632, -0.000000, 0.999845),
		["Seed 2"] = CFrame.new(5121.161621, -343.500092, 537.244568, -0.764907, 0.000000, -0.644141, -0.000000, 1.000000, 0.000000, 0.644141, 0.000000, -0.764907)	
	}
}
local Ores = {
    "Diamond",
    "Emerald",
    "Ruby",
    "Sapphire",
    "Mithril",
    "Silver",
    "Gold",
    "Iron",
    "Zinc",
    "Copper",
    "Tin",
    "Sulfur",
    "Demetal"
}
local Original = {
	FogEnd = Lighting.FogEnd,
	FogColor = Lighting.FogColor,
	Brightness = Lighting.Brightness,
	OutdoorAmbient = Lighting.OutdoorAmbient
}

local IslandListsDropdown = {}
local LeverListsDropdown = {}
local NPCsListsDropdown = {}
local CataseedsListsDropdown = {}

for island in pairs(Location.Islands) do
    table.insert(IslandListsDropdown, island)
end
for Lever in pairs(Location.CatacombLevers) do
    table.insert(LeverListsDropdown, Lever)
end
for _, NPC in pairs(workspace.NPCs:GetChildren()) do
    if NPC:FindFirstChild("HumanoidRootPart") and not (string.find(NPC.Name, "Sign") or string.find(NPC.Name, "Dock") or string.find(NPC.Name, "Hobo")) then
        table.insert(NPCsListsDropdown, NPC.Name)
    end
end
for Cataseeds in pairs(Location.Cataseeds) do
    table.insert(CataseedsListsDropdown, Cataseeds)
end

local Window = Fluent:CreateWindow({
    Title = "Servenity",
    SubTitle = "V1 Private",
    TabWidth = 160,
    Size = UDim2.fromOffset(610, 385),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.Insert
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "rbxassetid://10734886202" }),
    Auto = Window:AddTab({ Title = "Auto", Icon = "rbxassetid://10734923549" }),
    Render = Window:AddTab({ Title = "Render", Icon = "rbxassetid://10723346959" }),
    PVP = Window:AddTab({ Title = "PVP", Icon = "rbxassetid://10734975692" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "rbxassetid://10734922971" }),
    Miscellaneous = Window:AddTab({ Title = "Miscellaneous", Icon = "rbxassetid://10747373176" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "rbxassetid://10734950309" })
}

getgenv().Options = Fluent.Options

--// Main
do
    --// Auto Parry
    local Main_Auto_Parry = Tabs.Main:AddSection("Auto Parry") do
        Tabs.Main:AddToggle("main_auto_parry_toggle", {Title = "Auto Parry", Default = false })
        Tabs.Main:AddToggle("main_auto_parry_ping_based", {Title = "Ping Based Delay", Description = "Automatically Set you're parry delay depending on you're ping.", Default = false })
        Tabs.Main:AddDropdown("main_auto_parry_method", {Title = "Perfect Block", Default = 1, Values = {"Retry", "Add"} })
        Tabs.Main:AddInput("main_auto_parry_radius", {Title = "Auto Parry Radius", Default = "5", Callback = function(v)
			getgenv().AutoParryRadius = tonumber(v)
        end})
        Tabs.Main:AddInput("main_auto_parry_delay", {Title = "Auto Parry Delay", Default = "0.013518910", Callback = function(v)
			getgenv().AutoParryDelay = tonumber(v)
        end})
    end
    
    --// Auto Slash
    local Main_Auto_Attack = Tabs.Main:AddSection("Auto Attack") do
        Tabs.Main:AddToggle("main_auto_slash_toggle", {Title = "Auto Slash", Default = false })
        Tabs.Main:AddToggle("main_auto_heavy_slash_toggle", {Title = "Auto Heavy Slash", Default = false })
    end
end

--// Automatically
do
     --// Auto Farm
    local Auto_Farm = Tabs.Auto:AddSection("Bosses") do
        Tabs.Auto:AddButton({Title = "Select Tool", Description = "Sets the selected tool to the one currently held by the player.", Callback = function()
		    local HeldTool = Character:FindFirstChildOfClass("Tool")
		    if HeldTool then
		        getgenv().AutoFarmToolName = HeldTool.Name
		        Fluent:Notify({Title = "Tool Selected", Content = "Selected tool: " .. HeldTool.Name, Duration = 3})
		    else
		        Fluent:Notify({Title = "No Tool Found", Content = "No tool equipped. Please equip a tool first.", Duration = 3})
		    end
		end})
		Tabs.Auto:AddParagraph({Title = "Auto Farm Notification", Content = "If the auto-farm feature fails to teleport to the mob, it indicates that the mob has not yet spawned. Please proceed to the mob’s spawn location to continue."})
		Tabs.Auto:AddToggle("auto_farm_deposit_cash", {Title = "Auto Deposit Cash", Default = false })
        Tabs.Auto:AddToggle("auto_farm_cove_skeleton", {Title = "Auto Farm Cove Skeleton", Default = false })
        Tabs.Auto:AddToggle("auto_farm_prism_troll", {Title = "Auto Farm Prism Troll", Default = false })
        Tabs.Auto:AddToggle("auto_farm_granny", {Title = "Auto Farm Granny", Default = false })
    end
    
    --// Auto Farm Ore
    local Auto_Farm = Tabs.Auto:AddSection("Mining (in developing)") do
        Tabs.Auto:AddToggle("auto_farm_ore", {Title = "Start Auto Mining", Default = false })
        Tabs.Auto:AddDropdown("auto_farm_ore_dropdown", {Title = "Choose Ores", Default = 1, Values = Ores })
    end
end

--// Render
do
     --// Players
    local Render_ESP = Tabs.Render:AddSection("Visuals") do
        Tabs.Render:AddToggle("render_esp_players", {Title = "ESP Players", Default = false })
        Tabs.Render:AddToggle("render_esp_players_distance", {Title = "Players Distance", Default = false })
        Tabs.Render:AddToggle("render_esp_rifts", {Title = "ESP Rifts", Default = false })
        Tabs.Render:AddToggle("render_esp_rifts_distance", {Title = "Rifts Distance", Default = false })
    end
end

--// Teleport
do
    --// Catacomb
    local Teleport_Catacombs = Tabs.Teleport:AddSection("Catacombs") do
        Tabs.Teleport:AddToggle("auto_broken_lever_piece", {Title = "Auto Broken Lever Piece", Default = false })
        Tabs.Teleport:AddDropdown("teleport_catacomb_lever_dropdown", {Title = "Choose Lever", Default = 1, Values = LeverListsDropdown })
        Tabs.Teleport:AddButton({Title = "Teleport to Lever", Callback = function()
            Character.HumanoidRootPart.CFrame = Location.CatacombLevers[tostring(Options["teleport_catacomb_lever_dropdown"].Value)]
        end})
    end
    
    --// Islands
    local Teleport_Islands = Tabs.Teleport:AddSection("Islands") do
        Tabs.Teleport:AddDropdown("teleport_islands_dropdown", {Title = "Choose Islands", Default = 1, Values = IslandListsDropdown })
		Tabs.Teleport:AddButton({Title = "Teleport to Islands", Callback = function()
		    Character.HumanoidRootPart.CFrame = Location.Islands[tostring(Options["teleport_islands_dropdown"].Value)]
		end})
		Tabs.Teleport:AddButton({Title = "Claim all Mirrors", Description = "This may not successfully claim all mirrors on the first attempt; you may need to try again.", Callback = function()
			Window:Dialog({Title = "Claim All Mirrors", Content = "This process may take around 10 seconds to complete, depending on your internet connection. Do you want to continue?", Buttons = {
				{Title = "Confirm", Callback = function()
		            for _, v in pairs(Workspace.Mirrors:GetDescendants()) do
					    if v:IsA("ProximityPrompt") and v.Parent:IsA("BasePart") then
					        Character.HumanoidRootPart.CFrame = v.Parent.CFrame
					        task.wait(0.5)
					        fireproximityprompt(v, 1)
					        task.wait(0.5)
					    end
					end
		        end},
		        {Title = "Cancel", Callback = function()
		            print("[User]: Has Cancelled the dialog")
		        end}}
			})
        end})
    end
    
    --// NPCs
    local Teleport_NPCs = Tabs.Teleport:AddSection("NPCs") do
        Tabs.Teleport:AddDropdown("teleport_workspace_npc_dropdown", {Title = "Choose NPCs", Default = 1, Values = NPCsListsDropdown })
		Tabs.Teleport:AddButton({Title = "Teleport to NPC", Callback = function()
		    local NPCs = Workspace.NPCs:FindFirstChild(Options["teleport_workspace_npc_dropdown"].Value)
		    if NPCs then
        		if Options["teleport_workspace_npc_dropdown"].Value == "Hibbalons" then
					Window:Dialog({Title = "Risky NPC Detected", Content = "Interacting with this NPC may break the NPC teleporter. This cannot be undone.", Buttons = {
						{Title = "Confirm", Callback = function()
				            Character.HumanoidRootPart.CFrame = NPCs.HumanoidRootPart.CFrame
				        end},
				        {Title = "Cancel", Callback = function()
				            print("[User]: Has Cancelled The data Dialog")
				        end}}
					})
				else
					Character.HumanoidRootPart.CFrame = NPCs.HumanoidRootPart.CFrame
		    	end
		    end
		end})
		Tabs.Teleport:AddButton({Title = "Teleport to Hobo", Callback = function()
		    local HoboDude = Workspace:FindFirstChild("Hobo")
			if HoboDude then
			    Character.HumanoidRootPart.CFrame = HoboDude.HumanoidRootPart.CFrame
			else
			    Fluent:Notify({Title = "Notification", Content = "Hobo has not yet spawned.", Duration = 5})
			end
		end})
    end
end

--// Miscellaneous
do
    --// Modifications
	local Miscellaneous_Modifications = Tabs.Miscellaneous:AddSection("Modifications") do
	    Tabs.Miscellaneous:AddToggle("modifications_walkspeed_enabled", {Title = "Walkspeed", Default = false })
    	Tabs.Miscellaneous:AddInput("modifications_walkspeed_speed_amount", {Title = "Walkspeed Amount", Default = "", Placeholder = "5", Callback = function(v)
			getgenv().WalkspeedCFrameAmount = tonumber(v)
        end})
        Tabs.Miscellaneous:AddToggle("modifications_inf_jump", {Title = "Infinite Jump", Default = false })
	end
	
	--// Races
	local Miscellaneous_Races = Tabs.Miscellaneous:AddSection("Race") do
	    Tabs.Miscellaneous:AddDropdown("miscellaneous_race_dropdown", {Title = "Choose Race", Default = 1, Values = {"Human", "Ice Troll", "Vampire"} })
		Tabs.Miscellaneous:AddButton({Title = "Get Race", Callback = function()
			if Options["miscellaneous_race_dropdown"].Value == "Human" then
				ReplicatedStorage.Remotes.Skill:FireServer("Reaper")
			elseif Options["miscellaneous_race_dropdown"].Value == "Ice Troll" then
				ReplicatedStorage.Remotes.Skill:FireServer("Ice")
			elseif Options["miscellaneous_race_dropdown"].Value == "Vampire" then
				ReplicatedStorage.Remotes.Skill:FireServer("Vampire")
			end
        end})
	end
	
	--// Game Info
	local Miscellaneous_World = Tabs.Miscellaneous:AddSection("Notify") do
        Tabs.Miscellaneous:AddToggle("game_info_meteor_notify", {Title = "Meteor Notification", Description = "Displays a notification when a meteor spawns.", Default = true })
	end
	
	--// World
	local Miscellaneous_World = Tabs.Miscellaneous:AddSection("World") do
	    Tabs.Miscellaneous:AddToggle("miscellaneous_anti_afk", {Title = "Anti Afk", Default = false })
    	Tabs.Miscellaneous:AddToggle("miscellaneous_anti_fog", {Title = "Anti Fog", Default = false })
        Tabs.Miscellaneous:AddToggle("miscellaneous_anti_rain", {Title = "Anti Rain", Default = false })
        Tabs.Miscellaneous:AddToggle("miscellaneous_anti_wind", {Title = "Anti Wind", Default = false })
        Tabs.Miscellaneous:AddToggle("miscellaneous_always_day", {Title = "Always Day", Default = false })
        Tabs.Miscellaneous:AddToggle("miscellaneous_anti_blur", {Title = "Full Brightness", Default = false })
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
	    Tabs.Settings:AddDropdown("settings_serverhop_mode", {Title = "Server Mode", Default = 1, Values = {"Lowest", "Highest", "Worst Ping", "Best Ping"}, Callback = function(v)
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
	SaveManager:SetFolder("Servenity/Pillgrammed")
	InterfaceManager:BuildInterfaceSection(Tabs.Settings)
	SaveManager:BuildConfigSection(Tabs.Settings)
	Window:SelectTab(1)
	SaveManager:LoadAutoloadConfig()
end

--// Main
local AutoParrySet = {
    [50] = 0.01891210,
    [100] = 0.0161310,
    [150] = 0.0218910,
    [250] = 0.0125,
    [200] = 0.012,
    [300] = 0.013,
}
local LastParryTime = 0

RunService.RenderStepped:Connect(function()
    if Options["main_auto_parry_toggle"].Value then
        local CurrentTime = tick()
        if CurrentTime - LastParryTime >= (tonumber(AutoParryDelay) or 0.013518910) then
            local AutoParryMethod = Options["main_auto_parry_method"].Value
            local PerfectBlock = Character:FindFirstChild("PerfectBlock")
            local Parrying = Character:FindFirstChild("Parrying")

            if AutoParryMethod == "Retry" then
                if not PerfectBlock then
                    ReplicatedStorage.Remotes.Block:FireServer(true)
                end
                if not Parrying then
                    Parrying = Instance.new("BoolValue", Character)
                    Parrying.Name = "Parrying"
                    Parrying.Value = true
                end
            elseif AutoParryMethod == "Add" then
                ReplicatedStorage.Remotes.Block:FireServer(true)
                if not PerfectBlock then
                    PerfectBlock = Instance.new("BoolValue", Character)
                    PerfectBlock.Name = "PerfectBlock"
                    PerfectBlock.Value = true
                end
                if not Parrying then
                    Parrying = Instance.new("BoolValue", Character)
                    Parrying.Name = "Parrying"
                    Parrying.Value = true
                end
            end

            if Options["main_auto_parry_ping_based"].Value then
                local PingValue = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
                local Ping = tonumber(string.match(PingValue, "%d+"))
                if Ping then
                    for Threshold, Value in pairs(AutoParrySet) do
                        if Ping <= Threshold then
                            AutoParryDelay = Value
                            break
                        end
                    end
                end
            end
            LastParryTime = CurrentTime
        end
        ReplicatedStorage.Remotes.Block:FireServer(false)
    end

    if Options["modifications_walkspeed_enabled"].Value then
        local v1ws, v2ws = LocalPlayer.Character.HumanoidRootPart, LocalPlayer.Character.Humanoid
        v1ws.CFrame = v1ws.CFrame + v2ws.MoveDirection * WalkspeedCFrameAmount
    end
end)

--// World Visuals
local MeteorNotified = false
RunService.RenderStepped:Connect(function()
    if Options["miscellaneous_anti_fog"].Value then
        Lighting.FogEnd = 9e9
        Lighting.FogColor = Color3.fromRGB(255, 255, 255)
    else
        Lighting.FogEnd = Original.FogEnd
        Lighting.FogColor = Original.FogColor
    end
    if Options["miscellaneous_anti_blur"].Value then
        Lighting.Brightness = 0.35
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = Original.Brightness
        Lighting.OutdoorAmbient = Original.OutdoorAmbient
        Lighting.GlobalShadows = true
    end
    if ReplicatedStorage and ReplicatedStorage.GameInfo then
	    if Options["miscellaneous_anti_rain"].Value then
	        ReplicatedStorage.GameInfo.Raining = false
	        ReplicatedStorage.GameInfo.HeavyRain = false
	    end
	    if Options["miscellaneous_anti_wind"].Value then
	        ReplicatedStorage.GameInfo.Windy = false
	        ReplicatedStorage.GameInfo.Windness = 0
	    end
	    if Options["miscellaneous_always_day"].Value then
	        ReplicatedStorage.GameInfo.Time = 10
	    end
	    if Options["game_info_meteor_notify"].Value and ReplicatedStorage.GameInfo.Meteor.Value < 1 and not MeteorNotified then
	        Fluent:Notify({
	            Title = "Game Info",
	            Content = "Meteor has spawned.",
	            Duration = 3
	        })
	        MeteorNotified = true
	    elseif ReplicatedStorage.GameInfo.Meteor.Value >= 1 then
	        MeteorNotified = false
	    end
	end
end)

UserInputService.JumpRequest:Connect(function()
    if Options["modifications_inf_jump"].Value and Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

--// Auto Farm
RunService.RenderStepped:Connect(function()
    local Tool = Character:FindFirstChildOfClass("Tool")
    local Mobs = Workspace:FindFirstChild("Mobs")
    if Options["auto_farm_deposit_cash"].Value then
	    ReplicatedStorage.Remotes.Bank:InvokeServer(true, 1)
    end
    if Options["auto_farm_cove_skeleton"].Value then
        local Skeleton = Mobs:FindFirstChild("The Skeleton")
        if Skeleton and Skeleton:FindFirstChild("Head") then
            local CoveSkeletonCFrame = Skeleton.Head.CFrame
            UnEquipTool("Tainted Flower")
            ForceEquipTool(AutoFarmToolName)
            AutoFarmObj.CFrame = CoveSkeletonCFrame + Vector3.new(0, -5.5, 0)
            Character.HumanoidRootPart.CFrame = AutoFarmObj.CFrame + Vector3.new(0, 3.5, 0)
            if Tool then
                Tool:Activate()
            end
        else
            ForceEquipTool("Tainted Flower")
            Character.HumanoidRootPart.CFrame = Workspace.Map.BlackenedIsland.Altar.Water.CFrame + Vector3.new(0, 5.5, 0)
            if Tool then
                Tool:Activate()
            end
        end
    end
    if Options["auto_farm_prism_troll"].Value then
	    local PrismTroll = Mobs.PrismTroll:FindFirstChild("Prism Troll")
	    if PrismTroll then
        	ForceEquipTool(AutoFarmToolName)
            AutoFarmObj.CFrame = PrismTroll.Head.CFrame + Vector3.new(0, 3.5, 0)
            Character.HumanoidRootPart.CFrame = AutoFarmObj.CFrame + Vector3.new(0, 0.5, 0)
            if Tool then
                Tool:Activate()
            end
	    end
    end
    if Options["auto_farm_granny"].Value then
        local GrannyRockHitbox = Mobs:FindFirstChild("Granny")
        if GrannyRockHitbox and GrannyRockHitbox.Granny then
            local GrannyHitboxCFrame = GrannyRockHitbox.Granny.CFrame
            ForceEquipTool(AutoFarmToolName)
            AutoFarmObj.CFrame = GrannyHitboxCFrame + Vector3.new(0, -4.5, 0)
            Character.HumanoidRootPart.CFrame = AutoFarmObj.CFrame + Vector3.new(0, 3, 0)
            if Tool then
                Tool:Activate()
            end
        end
    end
end)

--// ESP
local EspCache = {
    Players = {},
    Rifts = {}
}
local RiftsLocation = {
    [1] = "Deep Desert",
    [2] = "Mountain Basin",
    [3] = "Patchland Grove",
    [4] = "The Backdoors",
    [5] = "Strange Chasm",
    [6] = "Cloud Wilds",
    [7] = "Light House"
}

RunService.RenderStepped:Connect(function()
    -- Player ESP
    if Options["render_esp_players"].Value then
        for _, Player in ipairs(Players:GetPlayers()) do
            if Player ~= Players.LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("Head") then
                if not EspCache.Players[Player] then
                    EspCache.Players[Player] = {
                        NameText = Drawing.new("Text"),
                        HpText = Drawing.new("Text")
                    }
                    local Esp = EspCache.Players[Player]
                    Esp.NameText.Size, Esp.NameText.Color, Esp.NameText.Center = 18, Color3.fromRGB(255, 255, 255), true
                    Esp.NameText.Outline, Esp.NameText.OutlineColor, Esp.NameText.Font = true, Color3.fromRGB(0, 0, 0), 2
                    Esp.HpText.Size, Esp.HpText.Color, Esp.HpText.Center = 18, Color3.fromRGB(0, 255, 0), true
                    Esp.HpText.Outline, Esp.HpText.OutlineColor, Esp.HpText.Font = true, Color3.fromRGB(0, 0, 0), 2
                end
                local Esp = EspCache.Players[Player]
                local HeadPosition = Player.Character.Head.Position + Vector3.new(0, 2.5, 0)
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(HeadPosition)
                if OnScreen then
                    local Health = Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health or 0
                    Esp.NameText.Position, Esp.NameText.Visible = Vector2.new(ScreenPos.X, ScreenPos.Y), true
                    Esp.NameText.Text = Player.Name
                    Esp.HpText.Position, Esp.HpText.Visible = Vector2.new(ScreenPos.X, ScreenPos.Y + 20), true
                    Esp.HpText.Text = "HP: " .. math.floor(Health)
                    if Options["render_esp_players_distance"].Value then
                        local Distance = (Player.Character.HumanoidRootPart.Position - Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        Esp.NameText.Text = Player.Name .. " (" .. math.floor(Distance) .. " studs)"
                    end
                else
                    Esp.NameText.Visible, Esp.HpText.Visible = false, false
                end
            elseif EspCache.Players[Player] then
                EspCache.Players[Player].NameText.Visible, EspCache.Players[Player].HpText.Visible = false, false
            end
        end
    else
        for _, Esp in pairs(EspCache.Players) do
            Esp.NameText.Visible, Esp.HpText.Visible = false, false
        end
    end

    -- Rift ESP
    if Options["render_esp_rifts"].Value then
        for i, name in pairs(RiftsLocation) do
            local rift = Workspace:FindFirstChild("RiftSpawn" .. i)
            if rift and rift:IsA("BasePart") then
                if not EspCache.Rifts[i] then
                    EspCache.Rifts[i] = Drawing.new("Text")
                    EspCache.Rifts[i].Size, EspCache.Rifts[i].Color, EspCache.Rifts[i].Center = 18, Color3.fromRGB(255, 0, 255), true
                    EspCache.Rifts[i].Outline, EspCache.Rifts[i].OutlineColor, EspCache.Rifts[i].Font = true, Color3.fromRGB(0, 0, 0), 2
                end
                local RiftEsp = EspCache.Rifts[i]
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(rift.Position)
                if OnScreen then
                    RiftEsp.Position, RiftEsp.Visible = Vector2.new(ScreenPos.X, ScreenPos.Y), true
                    RiftEsp.Text = name
                    if Options["render_esp_rifts_distance"].Value then
                        local Distance = (rift.Position - Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        RiftEsp.Text = name .. " (" .. math.floor(Distance) .. " studs)"
                    end
                else
                    RiftEsp.Visible = false
                end
            elseif EspCache.Rifts[i] then
                EspCache.Rifts[i].Visible = false
            end
        end
    else
        for _, RiftEsp in pairs(EspCache.Rifts) do
            RiftEsp.Visible = false
        end
    end
end)

Players.PlayerRemoving:Connect(function(Player)
    if EspCache.Players[Player] then
        for _, Text in pairs(EspCache.Players[Player]) do
            Text:Remove()
        end
        EspCache.Players[Player] = nil
    end
end)

LocalPlayer.CharacterAdded:Connect(function(Char)
    Character = Char
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
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

-- remote
workspace.NPCs:FindFirstChild("Magic Chalkman").Script.RemoteEvent:FireServer()
workspace.NPCs:FindFirstChild("Thief King").RemoteEvent:FireServer()
workspace.Hobo.RemoteEvent:FireServer()
workspace.NPCs.Stray.Script.Manager:FireServer(1)
Workspace.Mobs.Old

-- cframe

]]
