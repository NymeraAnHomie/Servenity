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
local Camera = workspace.CurrentCamera
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

local Location = {
	Islands = {
		["Frozen Cathedral"] = CFrame.new(5224.056152, -360.426178, 3413.142578, 0.021708, -0.000000, -0.999764, 0.000000, 1.000000, -0.000000, 0.999764, -0.000000, 0.021708),
		["Dojo's Approach"] = CFrame.new(1717.514771, 183.499954, 218.672638, -0.069664, 0.000000, 0.997571, -0.000000, 1.000000, -0.000000, -0.997571, -0.000000, -0.069664),
		["False Believer"] = CFrame.new(3729.072998, -440.174469, 6843.669434, -0.612672, -0.000000, -0.790337, 0.000000, 1.000000, -0.000000, 0.790337, -0.000000, -0.612672)
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
    Inventory = Window:AddTab({ Title = "Inventory", Icon = "rbxassetid://10709769841" }),
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
        Tabs.Main:AddInput("main_auto_parry_delay", {Title = "Auto Parry Delay", Default = "0.0131515102323", Placeholder = "0", Callback = function(v)
			getgenv().AutoParryDelay = tonumber(v)
        end})
    end
end

--// Teleport
do
    --// Catacomb
    local Teleport_Catacombs = Tabs.Teleport:AddSection("Catacombs") do
        Tabs.Teleport:AddToggle("auto_broken_lever_piece", {Title = "Auto Broken Lever Piece", Description = "no work idk why", Default = false })
        Tabs.Teleport:AddDropdown("teleport_catacomb_lever_dropdown", {Title = "Choose Lever", Default = 1, Values = LeverListsDropdown })
        Tabs.Teleport:AddButton({Title = "Teleport to Lever", Callback = function()
            Character.HumanoidRootPart.CFrame = Location.CatacombLevers[tostring(Options["teleport_catacomb_lever_dropdown"].Value)]
        end})
    end
    
    --// Islands
    local Teleport_NPCs = Tabs.Teleport:AddSection("NPCs") do
        Tabs.Teleport:AddDropdown("teleport_islands_dropdown", {Title = "Choose Islands", Default = 1, Values = IslandListsDropdown })
		Tabs.Teleport:AddButton({Title = "Teleport to Islands", Callback = function()
		    Character.HumanoidRootPart.CFrame = Location.Islands[tostring(Options["teleport_islands_dropdown"].Value)]
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
	local Modifications = Tabs.Miscellaneous:AddSection("Modifications") do
	    Tabs.Miscellaneous:AddToggle("modifications_walkspeed_enabled", {Title = "Walkspeed", Default = false })
    	Tabs.Miscellaneous:AddInput("modifications_walkspeed_speed_amount", {Title = "Walkspeed Amount", Default = "", Placeholder = "5", Callback = function(v)
			getgenv().WalkspeedCFrameAmount = v
        end})
	end
	
    --// World
	local World = Tabs.Miscellaneous:AddSection("World") do
	    Tabs.Miscellaneous:AddToggle("miscellaneous_anti_afk", {Title = "Anti Afk", Default = false })
    	Tabs.Miscellaneous:AddToggle("miscellaneous_remove_fog", {Title = "Anti Fog", Default = false })
        Tabs.Miscellaneous:AddToggle("miscellaneous_remove_blur", {Title = "Full Brightness", Default = false })
	end
	
	--// Character
	local Character = Tabs.Miscellaneous:AddSection("Character") do
        Tabs.Miscellaneous:AddToggle("miscellaneous_inf_jump", {Title = "Infinite Jump", Default = false })
        Tabs.Miscellaneous:AddToggle("miscellaneous_infinite_oxygen", {Title = "Infinite Oxygen", Default = true })
        Tabs.Miscellaneous:AddToggle("miscellaneous_walk_on_water", {Title = "Walk on water", Default = true })
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
	SaveManager:SetFolder("Servenity/Fisch")
	InterfaceManager:BuildInterfaceSection(Tabs.Settings)
	SaveManager:BuildConfigSection(Tabs.Settings)
	Window:SelectTab(1)
	SaveManager:LoadAutoloadConfig()
end

RunService.RenderStepped:Connect(function()
    if Options["miscellaneous_remove_fog"].Value then
        Lighting.FogEnd = 9e9
        Lighting.FogColor = Color3.fromRGB(255, 255, 255)
    else
        Lighting.FogEnd = Original.FogEnd
        Lighting.FogColor = Original.FogColor
    end
    if Options["miscellaneous_remove_blur"].Value then
        Lighting.Brightness = 0.35
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = Original.Brightness
        Lighting.OutdoorAmbient = Original.OutdoorAmbient
        Lighting.GlobalShadows = true
    end
end)

local LastParryTime = 0
RunService.RenderStepped:Connect(function()
    if Options["main_auto_parry_toggle"].Value then
        local CurrentTime = tick()
        if CurrentTime - LastParryTime >= (tonumber(AutoParryDelay) or 0.0131515102323) then
            if Options["main_auto_parry_method"].Value == "Retry" then
                if not LocalPlayer.Character:FindFirstChild("PerfectBlock") then
                    ReplicatedStorage.Remotes.Block:FireServer(false)
                    ReplicatedStorage.Remotes.Block:FireServer(true)
                    ReplicatedStorage.Remotes.Block:FireServer(false)
                end
                
            elseif Options["main_auto_parry_method"].Value == "Add" then
                ReplicatedStorage.Remotes.Block:FireServer(false)
                ReplicatedStorage.Remotes.Block:FireServer(true)
                if not LocalPlayer.Character:FindFirstChild("PerfectBlock") then
                    local PerfectBlock = Instance.new("BoolValue", LocalPlayer.Character)
                    PerfectBlock.Name = "PerfectBlock"
                    PerfectBlock.Value = true
                end
                if not LocalPlayer.Character:FindFirstChild("Parrying") then
                    local Parrying = Instance.new("BoolValue", LocalPlayer.Character)
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

UserInputService.JumpRequest:Connect(function()
    if Options["miscellaneous_inf_jump"].Value and Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
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

-- workspace

-- cframe
seed 1: CFrame.new(4979.690430, -343.090027, 611.070740, 0.999845, -0.000000, -0.017632, 0.000000, 1.000000, 0.000000, 0.017632, -0.000000, 0.999845)
seed 2: CFrame.new(5121.161621, -343.500092, 537.244568, -0.764907, 0.000000, -0.644141, -0.000000, 1.000000, 0.000000, 0.644141, 0.000000, -0.764907)

]]