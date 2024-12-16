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
local PlayerGUI = LocalPlayer.PlayerGui
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
		["Big Iron"] = CFrame.new(2328.838623, -17.500006, -3243.009277, 0.999465, -0.000000, -0.032718, 0.000000, 1.000000, -0.000000, 0.032718, 0.000000, 0.999465)
    },
	CatacombLevers = {
		["Lever 1"] = CFrame.new(5205.883789, -279.500092, 481.946106, -0.761892, 0.000000, 0.647704, 0.000000, 1.000000, -0.000000, -0.647704, 0.000000, -0.761892),
		["Lever 2"] = CFrame.new(4779.029785, -279.500092, -483.483521, 0.999262, -0.000000, -0.038401, 0.000000, 1.000000, 0.000000, 0.038401, -0.000000, 0.999262),
		["Lever 3"] = CFrame.new(4991.687012, -279.500092, 389.135803, 0.053997, 0.000000, 0.998541, 0.000000, 1.000000, -0.000000, -0.998541, 0.000000, 0.053997),
		["Catacomb Arena"] = CFrame.new(5356.958496, -403.500092, 317.145111, 0.999997, -0.000000, 0.002545, 0.000000, 1.000000, -0.000000, -0.002545, 0.000000, 0.999997)
	},
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

for island in pairs(Location.Islands) do
    table.insert(IslandListsDropdown, island)
end
for Lever in pairs(Location.CatacombLevers) do
    table.insert(LeverListsDropdown, Lever)
end
for _, NPC in pairs(workspace.NPCs:GetChildren()) do
    if NPC:FindFirstChild("HumanoidRootPart") and not (string.find(NPC.Name, "Sign") or string.find(NPC.Name, "Dock")) then
        table.insert(NPCsListsDropdown, NPC.Name)
    end
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
        Tabs.Main:AddDropdown("main_auto_parry_method", {Title = "Perfect Block", Default = 1, Values = {"Retry", "Add"} })
        Tabs.Main:AddToggle("main_auto_parry_ping_based", {Title = "Ping Based", Default = false })
        Tabs.Main:AddInput("main_auto_parry_delay", {Title = "Auto Parry Delay", Default = "0.0131515102323", Placeholder = "0", Callback = function(v)
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
    local Auto_Farm = Tabs.Auto:AddSection("Auto Farm") do
        Tabs.Auto:AddButton({Title = "Select Tool", Description = "Sets the selected tool to the one currently held by the player.", Callback = function()
		    local HeldTool = Character:FindFirstChildOfClass("Tool")
		    if HeldTool then
		        getgenv().AutoFarmToolName = HeldTool.Name
		        Fluent:Notify({Title = "Tool Selected", Content = "Selected tool: " .. HeldTool.Name, Duration = 3})
		    else
		        Fluent:Notify({Title = "No Tool Found", Content = "No tool equipped. Please equip a tool first.", Duration = 3})
		    end
		end})
		Tabs.Auto:AddParagraph({Title = "Info", Content = "All cash earned will be sent to the bank NPC."})
        Tabs.Auto:AddToggle("auto_farm_cove_skeleton", {Title = "Auto Farm Cove Skeleton", Default = false })
    end
end

--// Render
do
     --// Players
    local Render_ESP = Tabs.Render:AddSection("Visuals") do
        Tabs.Render:AddToggle("render_esp_players", {Title = "ESP Players", Default = false })
        Tabs.Render:AddToggle("render_esp_players_distance", {Title = "Distance", Default = false })
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
		        Character.HumanoidRootPart.CFrame = NPCs.HumanoidRootPart.CFrame
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
			getgenv().WalkspeedCFrameAmount = v
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
		    Window:Dialog({Title = "Delete Exploits File", Content = "Are you sure you want to reset your data? This action cannot be unthenne.", Buttons = {
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
	SaveManager:SetFolder("Servenity/Pillgrammed")
	InterfaceManager:BuildInterfaceSection(Tabs.Settings)
	SaveManager:BuildConfigSection(Tabs.Settings)
	Window:SelectTab(1)
	SaveManager:LoadAutoloadConfig()
end

--// Main
local LastParryTime = 0
RunService.RenderStepped:Connect(function()
    if Options["main_auto_parry_toggle"].Value then
        local CurrentTime = tick()
        if CurrentTime - LastParryTime >= (tonumber(AutoParryDelay) or 0.013) then
            if Options["main_auto_parry_method"].Value == "Retry" then
                if not Character:FindFirstChild("PerfectBlock") then
                    ReplicatedStorage.Remotes.Block:FireServer(false)
                    ReplicatedStorage.Remotes.Block:FireServer(true)
                    ReplicatedStorage.Remotes.Block:FireServer(false)
                end
                if not Character:FindFirstChild("Parrying") then
                    local Parrying = Instance.new("BoolValue", Character)
                    Parrying.Name = "Parrying"
                    Parrying.Value = true
                end
            elseif Options["main_auto_parry_method"].Value == "Add" then
                ReplicatedStorage.Remotes.Block:FireServer(false)
                ReplicatedStorage.Remotes.Block:FireServer(true)
                if not Character:FindFirstChild("PerfectBlock") then
                    local PerfectBlock = Instance.new("BoolValue", Character)
                    PerfectBlock.Name = "PerfectBlock"
                    PerfectBlock.Value = true
                end
                if not Character:FindFirstChild("Parrying") then
                    local Parrying = Instance.new("BoolValue", Character)
                    Parrying.Name = "Parrying"
                    Parrying.Value = true
                end
            end
            LastParryTime = CurrentTime
        end
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
    if Options["auto_farm_cove_skeleton"].Value then
        local Skeleton = Workspace.Mobs:FindFirstChild("The Skeleton")
        local Tool = Character:FindFirstChildOfClass("Tool")
        ReplicatedStorage.Remotes.Bank:InvokeServer(true, 1)        
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
end)

--// ESP
local EspCache = {}
RunService.RenderStepped:Connect(function()
    if Options["render_esp_players"].Value then
        for _, Player in ipairs(Players:GetPlayers()) do
            if Player ~= Players.LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("Head") then
                if not EspCache[Player] then
                    EspCache[Player] = {
                        NameText = Drawing.new("Text"),
                        HpText = Drawing.new("Text")
                    }

                    EspCache[Player].NameText.Size = 18
                    EspCache[Player].NameText.Color = Color3.fromRGB(255, 255, 255)
                    EspCache[Player].NameText.Center = true
                    EspCache[Player].NameText.Outline = true
                    EspCache[Player].NameText.OutlineColor = Color3.fromRGB(0, 0, 0)
                    EspCache[Player].HpText.Size = 18
                    EspCache[Player].HpText.Color = Color3.fromRGB(0, 255, 0)
                    EspCache[Player].HpText.Center = true
                    EspCache[Player].HpText.Outline = true
                    EspCache[Player].HpText.OutlineColor = Color3.fromRGB(0, 0, 0)
                end
                local Esp = EspCache[Player]
                local HeadPosition = Player.Character.Head.Position + Vector3.new(0, 2.5, 0)
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(HeadPosition)
                if OnScreen then
                    Esp.NameText.Position = Vector2.new(ScreenPos.X, ScreenPos.Y)
                    Esp.NameText.Visible = true
                    Esp.NameText.Text = Player.Name
                    local Health = Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health or 0
                    Esp.HpText.Position = Vector2.new(ScreenPos.X, ScreenPos.Y + 20)
                    Esp.HpText.Visible = true
                    Esp.HpText.Text = "HP: " .. math.floor(Health)
                    if Options["render_esp_players_distance"].Value then
                        local Distance = (Player.Character.HumanoidRootPart.Position - Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        Esp.NameText.Text = Player.Name .. " (" .. math.floor(Distance) .. " studs)"
                    end
                else
                    Esp.NameText.Visible = false
                    Esp.HpText.Visible = false
                end
            elseif EspCache[Player] then
                EspCache[Player].NameText.Visible = false
                EspCache[Player].HpText.Visible = false
            end
        end
    else
        for _, Esp in pairs(EspCache) do
            Esp.NameText.Visible = false
            Esp.HpText.Visible = false
        end
    end
end)

Players.PlayerRemoving:Connect(function(Player)
    if EspCache[Player] then
        for _, Esp in pairs(EspCache[Player]) do
            Esp:Remove()
        end
        EspCache[Player] = nil
    end
end)

LocalPlayer.CharacterAdded:Connect(function(Char)
    Character = Char
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
	if Options["auto_farm_cove_skeleton"].Value then
	    local Skeleton = Workspace.Mobs:FindFirstChild("The Skeleton")
	    local Tool = Character:FindFirstChildOfClass("Tool")
	    if not Skeleton then
	        ForceEquipTool("Tainted Flower")
	    end
	    if Skeleton then
		    ForceEquipTool(AutoFarmToolName)
	    end
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

-- remote

-- workspace

-- cframe
seed 1: CFrame.new(4979.690430, -343.090027, 611.070740, 0.999845, -0.000000, -0.017632, 0.000000, 1.000000, 0.000000, 0.017632, -0.000000, 0.999845)
seed 2: CFrame.new(5121.161621, -343.500092, 537.244568, -0.764907, 0.000000, -0.644141, -0.000000, 1.000000, 0.000000, 0.644141, 0.000000, -0.764907)

]]
