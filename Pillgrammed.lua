local function LPH_NO_VIRTUALIZE(code)
    return code
end
local LPH_JIT_MAX = LPH_NO_VIRTUALIZE

local DeveloperMode = true
local CallbackList = {}
local ConnectionList = {}
local Flags = {} --// Ignore

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Options = Fluent.Options

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

LPH_NO_VIRTUALIZE(function() --// UI Creation
	local HttpService = game:GetService("HttpService")
	
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
			["Ceremonial Greatblade"] = CFrame.new(20727.357422, -1406.500366, -349.841766, -0.364550, -0.000000, -0.931184, 0.000000, 1.000000, -0.000000, 0.931184, -0.000000, -0.364550),
			["Psychocrab"] = CFrame.new(-1862.924438, -374.765137, -1576.290527, -0.077071, 0.000000, -0.997026, 0.000000, 1.000000, 0.000000, 0.997026, 0.000000, -0.077071)
	    },
		CatacombLevers = {
			["Lever 1"] = CFrame.new(5205.883789, -279.500092, 481.946106, -0.761892, 0.000000, 0.647704, 0.000000, 1.000000, -0.000000, -0.647704, 0.000000, -0.761892),
			["Lever 2"] = CFrame.new(4779.029785, -279.500092, -483.483521, 0.999262, -0.000000, -0.038401, 0.000000, 1.000000, 0.000000, 0.038401, -0.000000, 0.999262),
			["Lever 3"] = CFrame.new(4991.687012, -279.500092, 389.135803, 0.053997, 0.000000, 0.998541, 0.000000, 1.000000, -0.000000, -0.998541, 0.000000, 0.053997),
			["Catacomb Arena"] = CFrame.new(5356.958496, -403.500092, 317.145111, 0.999997, -0.000000, 0.002545, 0.000000, 1.000000, -0.000000, -0.002545, 0.000000, 0.999997)
		},
		Cataseeds = {
			["Seed 1"] = CFrame.new(4979.690430, -343.090027, 611.070740, 0.999845, -0.000000, -0.017632, 0.000000, 1.000000, 0.000000, 0.017632, -0.000000, 0.999845),
			["Seed 2"] = CFrame.new(5121.161621, -343.500092, 537.244568, -0.764907, 0.000000, -0.644141, -0.000000, 1.000000, 0.000000, 0.644141, 0.000000, -0.764907),
			["Seed 3"] = CFrame.new(5122.408203, -261.500092, 764.158875, -0.974852, -0.000000, 0.222852, 0.000000, 1.000000, 0.000000, -0.222852, 0.000000, -0.974852),
			["Seed 4"] = CFrame.new(5063.382812, -279.500092, 298.873962, 0.350624, 0.000000, -0.936516, 0.000000, 1.000000, 0.000000, 0.936516, -0.000000, 0.350624),
			["Seed 5"] = CFrame.new(4796.077148, -330.500092, -193.093597, -0.761918, 0.000000, -0.647673, 0.000000, 1.000000, 0.000000, 0.647673, 0.000000, -0.761918)
		}
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
	    if NPC:FindFirstChild("HumanoidRootPart") and not (string.find(NPC.Name, "Sign") or string.find(NPC.Name, "Dock") or string.find(NPC.Name, "Hobo") or string.find(NPC.Name, "Mela")) then
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
	    Visuals = Window:AddTab({ Title = "Visuals", Icon = "rbxassetid://10723346959" }),
	    Teleport = Window:AddTab({ Title = "Teleport", Icon = "rbxassetid://10734922971" }),
	    Misc = Window:AddTab({ Title = "Misc", Icon = "rbxassetid://10747373176" }),
	    Settings = Window:AddTab({ Title = "Settings", Icon = "rbxassetid://10734950309" })
	}
	
	--// Main
	local AutoParry = Tabs.Main:AddSection("Auto Parry") do
		Tabs.Main:AddToggle("main_auto_parry_toggle", {Title = "Master Switch", Default = false })
	    Tabs.Main:AddToggle("main_auto_parry_ping_based", {Title = "Ping Based", Default = false })
	    Tabs.Main:AddInput("main_auto_parry_rate", {Title = "Rate", Callback = function(v)
			Flags.AutoParryDelay = tonumber(v)
	    end})
    end
    local AutoDodge = Tabs.Main:AddSection("Auto Dodge") do
        Tabs.Main:AddToggle("main_auto_dodge_toggle", {Title = "Master Switch", Default = false })
        Tabs.Main:AddDropdown("main_auto_dodge_mode", {Title = "Mode", Default = 1, Values = {"Blatant", "Legit"} })
    end
    
    --// Visuals
    local PlayersESP = Tabs.Visuals:AddSection("Players") do
        Tabs.Visuals:AddToggle("render_esp_players", {Title = "Master Switch", Default = false })
        Tabs.Visuals:AddToggle("render_esp_players_distance", {Title = "Visualize Distance", Default = false })
    end
    local RiftsESP = Tabs.Visuals:AddSection("Rifts") do
        Tabs.Visuals:AddToggle("render_esp_rifts", {Title = "Master Switch", Default = false })
        Tabs.Visuals:AddToggle("render_esp_rifts_faux_wax", {Title = "Visualize Faux Wax", Default = false })
        Tabs.Visuals:AddToggle("render_esp_rifts_distance", {Title = "Visualize Distance", Default = false })
    end
    
    --// Teleport
    local Teleport_Islands = Tabs.Teleport:AddSection("Islands") do
        Tabs.Teleport:AddDropdown("teleport_islands_dropdown", {Title = "Choose Islands", Default = 1, Values = IslandListsDropdown })
		Tabs.Teleport:AddButton({Title = "Teleport to Islands", Callback = function()
		    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = Location.Islands[tostring(Options["teleport_islands_dropdown"].Value)]
		end})
		Tabs.Teleport:AddButton({Title = "Claim all Mirrors", Description = "This may not successfully claim all mirrors on the first attempt; you may need to try again.", Callback = function()
			Window:Dialog({Title = "Claim All Mirrors", Content = "This process may take around 10 seconds to complete, depending on your internet connection. Do you want to continue?", Buttons = {{Title = "Confirm", Callback = function()
	            for _, v in pairs(game:GetService("Workspace").Mirrors:GetDescendants()) do
				    if v:IsA("ProximityPrompt") and v.Parent:IsA("BasePart") then
				        game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = v.Parent.CFrame
				        task.wait(0.35)
				        fireproximityprompt(v, 1)
				        task.wait(0.35)
				    end
				end
	        end},{Title = "Cancel", Callback = function()
	            print("[User]: Has Cancelled the dialog")
	        end}}})
        end})
    end
    
    local TeleportNPCs = Tabs.Teleport:AddSection("NPCs") do
        Tabs.Teleport:AddDropdown("teleport_workspace_npc_dropdown", {Title = "Choose NPCs", Default = 1, Values = NPCsListsDropdown })
		Tabs.Teleport:AddButton({Title = "Teleport to NPC", Callback = function()
		    local NPCs = game:GetService("Workspace").NPCs:FindFirstChild(Options["teleport_workspace_npc_dropdown"].Value)
		    if NPCs then game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = NPCs.HumanoidRootPart.CFrame end
		end})
		Tabs.Teleport:AddButton({Title = "Teleport to Hobo", Callback = function()
		    local HoboDude = game:GetService("Workspace"):FindFirstChild("Hobo")
			if HoboDude then game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = HoboDude.HumanoidRootPart.CFrame end
		end})
		Tabs.Teleport:AddButton({Title = "Teleport to Mela", Callback = function()
		    local MelaDude = game:GetService("Workspace").NPCs:FindFirstChild("Mela")
			if MelaDude then game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = MelaDude.HumanoidRootPart.CFrame end
		end})
    end
    
    --// Misc
    local Modifications = Tabs.Misc:AddSection("Modifications") do
	    Tabs.Misc:AddToggle("modifications_walkspeed", {Title = "Walkspeed", Default = false })
    	Tabs.Misc:AddInput("modifications_walkspeed_speed_amount", {Title = "Walkspeed Amount", Default = "", Placeholder = "5", Callback = function(v)
			Flags.WalkspeedCFrameAmount = tonumber(v)
        end})
        Tabs.Misc:AddToggle("modifications_inf_jump", {Title = "Infinite Jump", Default = false })
	end
	
	--// Settings
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
end)()

LPH_JIT_MAX(function() --// Main Cheat
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Workspace = game:GetService("Workspace")
	local Lighting = game:GetService("Lighting")
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local Players = game:GetService("Players")
	
	local LocalPlayer = Players.LocalPlayer
	local Camera = Workspace.CurrentCamera
	local EspCache = {Players = {}, Rifts = {}, Mobs = {}}
	local MovementCache = {time = {}, position = {}}
	local RiftsLocation = {
	    [1] = "Deep Desert",
	    [2] = "Mountain Basin",
	    [3] = "Patchland Grove",
	    [4] = "The Backdoors",
	    [5] = "Strange Chasm",
	    [6] = "Cloud Wilds",
	    [7] = "Light House"
	}
	
	local Network = {}
	function Network:send(action, settings)
		if action == "parry" then
			ReplicatedStorage.Remotes.Block:FireServer(false)
			ReplicatedStorage.Remotes.Block:FireServer(true)
		elseif action == "roll" then
			ReplicatedStorage.Remotes.Roll:FireServer()
		elseif action == "dive" then
		    ReplicatedStorage.Remotes.Roll:FireServer({[1] = {["Dive"] = true}})
		elseif action == "slash" then
	 	   LocalPlayer.Character:FindFirstChildOfClass("Tool"):Activate()
		elseif action == "heavy" then
			LocalPlayer.Character:FindFirstChildOfClass("Tool").Slash:FireServer(2)
		elseif action == "skill" and settings.number then
		    ReplicatedStorage.Remotes.SkillKey:FireServer(Vector3.new(0, 0, 0), settings.number)
		end
	end
	
	local ParryRate = 0
	
	table.insert(ConnectionList, RunService.RenderStepped:Connect(function()
	    local Tick = tick()
		if Options["main_auto_parry_toggle"].Value then
			if Tick - ParryRate >= (tonumber(Flags.AutoParryDelay)) then
				Network:send("parry")
				ParryRate = Tick
			end
		end
		if Options["main_auto_dodge_toggle"].Value then
			if Options["main_auto_dodge_mode"].Value == "Blatant" then
				Network:send("roll")
			elseif Options["main_auto_dodge_mode"].Value == "Legit" then
			
			end
		end
		if Options["modifications_walkspeed"].Value then
	        LocalPlayer.Character.HumanoidRootPart.CFrame = 
			LocalPlayer.Character.HumanoidRootPart.CFrame + 
			LocalPlayer.Character.Humanoid.MoveDirection * Flags.WalkspeedCFrameAmount
		end
	end))
	table.insert(ConnectionList, RunService.RenderStepped:Connect(function()
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
	end))
	
	Players.PlayerRemoving:Connect(function(Player)
	    if EspCache.Players[Player] then
	        for _, Text in pairs(EspCache.Players[Player]) do
	            Text:Remove()
	        end
	        EspCache.Players[Player] = nil
	    end
	end)
	
	UserInputService.JumpRequest:Connect(function()
	    if Options["modifications_inf_jump"].Value and LocalPlayer.Character:FindFirstChild("Humanoid") then
	        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	    end
	end)
	-- wasn't that bad right?
end)()

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
        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.LeftControl, false, nil)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.LeftControl, false, nil)
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

-- cframe
]]
