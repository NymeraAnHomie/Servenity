local function LPH_NO_VIRTUALIZE(code)
    return code
end
local LPH_JIT_MAX = LPH_NO_VIRTUALIZE

local MainColor = Color3.fromRGB(255, 255, 255)
local DeveloperMode = true
local CallbackList = {}
local ConnectionList = {}
local MovementCache = {Time = {}, Position = {}}

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/NymeraAnHomie/Library/refs/heads/main/OrionLib/Source.lua')))()
local Hydroxide = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Upbolt/Hydroxide/revision/ohaux.lua"))()
local Flags = OrionLib.Flags

LPH_JIT_MAX(function() -- Main Cheat
    local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")
	local UserInputService = game:GetService("UserInputService")
	local Workspace = game:GetService("Workspace")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Lighting = game:GetService("Lighting")
    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera
    
    local BacktrackObjects = Instance.new("Folder", workspace)
    local HitboxObjects = Instance.new("Folder", workspace)
	
	function Raycast(Origin, Direction, Filter, Whitelist)
	    local RaycastParams = RaycastParams.new()
	    RaycastParams.FilterDescendantsInstances = Filter or {}
	    RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	    RaycastParams.IgnoreWater = false
	    if Whitelist then
	        RaycastParams.FilterType = Enum.RaycastFilterType.Whitelist
	        RaycastParams.FilterDescendantsInstances = Whitelist
	    end
	    local RaycastResult = workspace:Raycast(Origin, Direction, RaycastParams)
	    return RaycastResult
	end

    local network = {}
	function network:send(name, ...)
	    local action = {...}
	    if name == "spot" then
	        if action[1] then
	            ReplicatedStorage.PlayerEvents.SpotPlayer:FireServer(action[1])
	        end
	    elseif name == "stab" then
	        local Target = Players[action[1].Target]
	        local args = {
	            [1] = {
	                ["shellSpeed"] = action[1].StabSpeed,
	                ["shellName"] = "DefaultMelee",
	                ["origin"] = Vector3.new(0, 0, 0),
	                ["weaponName"] = "Knife",
	                ["shellType"] = "Melee",
	                ["shellMaxDist"] = action[1].MaxDistance,
	                ["filterDescendants"] = {
	                    [1] = LocalPlayer.Character,
	                    [2] = workspace.Camera.Viewmodel
	                }
	            },
	            [2] = Target.Character.Humanoid,
	            [3] = 2,
	            [4] = 1,
	            [5] = Target.Character.Head
	        }
	
	        ReplicatedStorage.ACS_Engine.Events.Damage:InvokeServer(unpack(args))
	    elseif name == "collectcash" and not action[1] then
	        ReplicatedStorage.CollectCashEvent:FireServer()
	    elseif name == "prestige" and not action[1] then
	        ReplicatedStorage.RequestPrestigeEvent:FireServer()
	    elseif name == "purchase" and action[1] then
	        ReplicatedStorage.RequestPurchaseEvent:FireServer(action[1])
	    elseif name == "purchase_vehicle" then
	        ReplicatedStorage.RequestVehiclePurchaseEvent:FireServer(action[1])
	    elseif name == "purchase_helicopter" then
	        ReplicatedStorage.RequestHeliPurchaseEvent:FireServer(action[1])
	    elseif name == "stance" then
	        ReplicatedStorage.ACS_Engine.Events.Stance:FireServer(action[1], 0)
	        MovementCache.Stance = action[1]
	    elseif name == "sendchat" then
	        if game:GetService("TextChatService").ChatVersion == Enum.ChatVersion.LegacyChatService then
	            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(tostring(action[1]), "All")
	        else
	            game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(tostring(action[1]))
	        end
	    end
	end

	table.insert(ConnectionList, RunService.RenderStepped:Connect(function()
	    local Teamcheck = Flags["team_checks"].Value
	
	    if Flags["hitboxes_main_toggle"].Value then
	        for _, Player in next, Players:GetPlayers() do
	            if Player.Name ~= Players.LocalPlayer.Name then
	                if not Teamcheck or Player.Team ~= Players.LocalPlayer.Team then
	                    pcall(function()
	                        if Player.Character and Player.Character:FindFirstChild("Head") then
	                            Player.Character.Head.Size = Vector3.new(
	                                Flags["hitboxes_size"].Value,
	                                Flags["hitboxes_size"].Value,
	                                Flags["hitboxes_size"].Value
	                            )
	                            Player.Character.Head.Transparency = Flags["hitboxes_transparency"].Value
	                            Player.Character.Head.Color = Flags["hitboxes_color"].Value
	                            Player.Character.Head.Material = "Neon"
	                            Player.Character.Head.CanCollide = false
	                            Player.Character.Head.Massless = true
	                        end
	                    end)
	                end
	            end
	        end
	    end
	
	    if Flags["knife_bot_main_toggle"].Value then
		    for _, Player in next, Players:GetPlayers() do
		        if Player.Name ~= Players.LocalPlayer.Name then
		            if not Teamcheck or Player.Team ~= Players.LocalPlayer.Team then
		                if Player.Character and Player.Character:FindFirstChild("Head") then
		                    if (Players.LocalPlayer.Character.Head.Position - Player.Character.Head.Position).Magnitude <= Flags["knife_bot_radius"].Value then
		                        network:send("stab", {
		                            Target = Player.Name,
		                            StabSpeed = 20000,
		                            MaxDistance = Flags["knife_bot_radius"].Value,
		                        })
		                    end
		                end
		            end
		        end
		    end
		
		    if Flags["knife_bot_kill_all"].Value then
		        for _, Player in next, Players:GetPlayers() do
		            if Player.Name ~= Players.LocalPlayer.Name then
		                if not Teamcheck or Player.Team ~= Players.LocalPlayer.Team then
		                    if Player.Character and Player.Character:FindFirstChild("Head") then
		                        network:send("stab", {
		                            Target = Player.Name,
		                            StabSpeed = 20000,
		                            MaxDistance = math.huge,
		                        })
		                    end
		                end
		            end
		        end
		    end
		end
	end))
	
	table.insert(ConnectionList, RunService.RenderStepped:Connect(function()
	    if Flags["tycoon_auto_collect_cash"].Value then
	        network:send("collectcash")
	    end
	    
	    if Flags["tycoon_auto_buy"].Value then
	        for _, child in pairs(workspace[LocalPlayer.AssociatedTycoon.Value].BuyButtons:GetChildren()) do
	            if child:FindFirstChild("ButtonPart") then
	                network:send("purchase", child.ButtonPart)
	            end
	        end
	        local Vehicle = {}
	        local Helicopter = {}
	        network:send("purchase_vehicle", Vechicle)
	        network:send("purchase_helicopter ", Helicopter)
	    end
	    
	    if Flags["tycoon_auto_prestige"].Value then
	        network:send("prestige")
	    end
	end))

	table.insert(ConnectionList, RunService.RenderStepped:Connect(function(DeltaTime)  
	    if Flags["anti_aim_main_toggle"].Value and LocalPlayer.Character then  
	        local Yaw = Flags["anti_aim_yaw"].Value and Flags["anti_aim_yaw_amount"].Value or 0  
	        local Pitch = Flags["anti_aim_pitch"].Value and Flags["anti_aim_pitch_amount"].Value or 0  
	        local SpinSpeed = Flags["anti_aim_spin_bot"].Value and Flags["anti_aim_spin_bot_speed"].Value or 0  
	        local Jitter = Flags["anti_aim_jitter"].Value and Flags["anti_aim_jitter_speed"].Value or 0  
	  
	        local SpinDirection = Flags["anti_aim_spin_bot_direction"].Value == "Left" and -1 or 1  
	  
	        local YawRotation = CFrame.Angles(0, math.rad(Yaw * SpinDirection), 0)  
	        local PitchRotation = CFrame.Angles(math.rad(Pitch), 0, 0)  
	        local SpinRotation = CFrame.Angles(0, math.rad(SpinSpeed * SpinDirection * DeltaTime * 60), 0)  
	        local JitterRotation = Flags["anti_aim_jitter"].Value and CFrame.Angles(0, math.rad(math.random(-Jitter, Jitter)), 0) or CFrame.new()  
	  
	        if Flags["anti_aim_force_stance"].Value then  
	            if Flags["anti_aim_set_stance"].Value == "Stand" then  
	                network:send("stance", 0)  
	            elseif Flags["anti_aim_set_stance"].Value == "Crouch" then  
	                network:send("stance", 1)  
	            elseif Flags["anti_aim_set_stance"].Value == "Prone" then  
	                network:send("stance", 2)  
	            end  
	            MovementCache.Stance = Flags["anti_aim_set_stance"].Value  
	        end  
	  
	        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * YawRotation * PitchRotation * SpinRotation * JitterRotation  
	    end  
	  
	    if Flags["third_person_main_toggle"].Value then  
	        if LocalPlayer.Character:FindFirstChildWhichIsA("Tool") then
	            LocalPlayer.CameraMaxZoomDistance = Flags["third_person_zoom_distance"].Value
			    LocalPlayer.CameraMinZoomDistance = Flags["third_person_zoom_distance"].Value
			    LocalPlayer.CameraMode = Enum.CameraMode.Classic
	        else
				LocalPlayer.CameraMaxZoomDistance = 20
			    LocalPlayer.CameraMinZoomDistance = 0.5
			    LocalPlayer.CameraMode = Enum.CameraMode.Classic
			end
	    end  
	end))
	
	local ChatSpamLists = {"i bet stealth developer are peterfiles", "stop playing the game", "couldnt be me", "servenity on top", "best anticheat - stealth devs"}
	local stillGoing = true
    local PlayerWeapon = nil
	task.spawn(function()
	    while stillGoing do
	        task.wait(.35) -- you would not believe the lag
	
			local function RefreshPlayerWeapon()
		        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("ACS_Client") then
		            PlayerWeapon = LocalPlayer.Character.ACS_Client.ACS_Framework
		        else
		            PlayerWeapon = nil
		        end
		    end
	
			if Flags["chat_spam_main_toggle"].Value then
		        task.wait(Flags["chat_spam_delay"].Value)
		        network:send("sendchat", ChatSpamLists[math.random(1, #ChatSpamLists)])
			end
	
	        RefreshPlayerWeapon()
	        if PlayerWeapon then
	            local ReloadFunction = Hydroxide.searchClosure(PlayerWeapon, "Reload", 1, {
	                [1] = "Type", [2] = "Gun", [3] = "Stinger", [4] = "Launcher", [5] = "Grapple Hook", [6] = "Ammo"
	            })
	            local AdsFunction = Hydroxide.searchClosure(PlayerWeapon, "ADS", 3, {
	                [1] = "IsAimingDownSights", [2] = "IsTurret", [3] = "setInProgress", [4] = "ADS", [5] = "canAim", [6] = 0.2
	            })
	            local BulletSpreadFunction = Hydroxide.searchClosure(PlayerWeapon, "Unnamed function", 2, {
	                [1] = "Value", [2] = "ACS_Settings", [3] = "FindFirstChild", [4] = "require", [6] = "MaxStoredAmmo", [7] = "StoredAmmo"
	            })
	            local RecoilFunction = Hydroxide.searchClosure(PlayerWeapon, "setup", 13, {
	                [1] = "Humanoid", [2] = "WaitForChild", [3] = "Health", [4] = "MouseIconEnabled", [5] = "Enum", [6] = "CameraMode"
	            })
           	local MovementData = debug.getupvalue(Hydroxide.searchClosure(PlayerWeapon, "GunFx", 4, {
			        [1] = "IsTurret", [2] = "SeatPart", [3] = "Parent", [4] = "gun", [5] = "base", [6] = "Handle"
			    }), 4)
	
	            if RecoilFunction then
	                local RecoilData = debug.getupvalue(RecoilFunction, 13)
	                if RecoilData then
	                    if Flags["gun_mods_no_bullet_recoil"].Value then
	                        RecoilData["HorizontalRecoil"] = 0
	                        RecoilData["VerticalRecoil"] = 0
	                    else
	                        RecoilData["HorizontalRecoil"] = 0.5
	                        RecoilData["VerticalRecoil"] = 0.7
	                    end
	                end
	            end
	
	            if ReloadFunction then
	                local AmmoData = debug.getupvalue(ReloadFunction, 1)
	                if AmmoData then
	                    AmmoData["Ammo"] = Flags["gun_mods_inf_ammo"].Value and 99998 or 20
	                end
	            end
	
	            if AdsFunction then
	                local AdsData = debug.getupvalue(AdsFunction, 3)
	                if AdsData then
	                    AdsData["BulletDrop"] = Flags["gun_mods_no_bullet_drop"].Value and 0 or 0.25
	                end
	            end
	
	            if BulletSpreadFunction then
	                local BulletSpreadData = debug.getupvalue(BulletSpreadFunction, 2)
	                if BulletSpreadData and BulletSpreadData["MaxSpread"] then
	                    BulletSpreadData["MaxSpread"] = Flags["gun_mods_no_bullet_spread"].Value and 0 or 0.75
	                    BulletSpreadData["MinSpread"] = Flags["gun_mods_no_bullet_spread"].Value and 0 or 0.75
	                end
	            end
	
            	if Flags["movement_walk_speed"].Value then
				    if MovementData then
				        local WalkspeedTypes = {"SlowPace", "Crouch", "Normal", "Aim", "Run"}
				        for _, speedType in pairs(WalkspeedTypes) do
				            MovementData[speedType .. "WalkSpeed"] = Flags["movement_walk_speed_amount"].Value
				        end
				    end
				end
	        end
	    end
	end)

	LocalPlayer.CharacterAdded:Connect(function(character)
	    stillGoing = true
	    RefreshPlayerWeapon()
	end)
	
	LocalPlayer.CharacterRemoving:Connect(function()
	    stillGoing = false
	    PlayerWeapon = nil
	end)
	
	UnloadCheat = function()
		OrionLib:Destroy()
		HitboxObjects:Destroy()
		BacktrackObjects:Destroy()
	end
	-- wasn't that so bad right?
end)()

LPH_NO_VIRTUALIZE(function() -- UI Creation
    local HttpService = game:GetService("HttpService")
    
    local window = OrionLib:MakeWindow({Name = "Servenity", IntroEnabled = false, SaveConfig = true, ConfigFolder = "Servenity"})
    OrionLib.SelectedTheme = "Default"

	local legit = window:MakeTab({Name = "Legit", Icon = "rbxassetid://4483345998"})
	local rage = window:MakeTab({Name = "Rage", Icon = "rbxassetid://8547236654"})
	local visuals = window:MakeTab({Name = "Visual", Icon = "rbxassetid://107233469599"})
	local misc = window:MakeTab({Name = "Misc", Icon = "rbxassetid://10747373176"})
	local settings = window:MakeTab({Name = "Settings", Icon = "rbxassetid://10734950309"})
	
	legit:AddSection({Name = "Checks"})
	legit:AddToggle({Name = "Team", Flag = "team_checks", Save = true})
	
	legit:AddSection({Name = "Hitboxes"})
	legit:AddToggle({Name = "Enabled", Flag = "hitboxes_main_toggle", Save = true})
	legit:AddSlider({Name = "Size", Flag = "hitboxes_size",  Max = 200, Default = 14, ValueName = "px", Save = true})
	legit:AddSlider({Name = "Transparency", Flag = "hitboxes_transparency", Max = 1, Increment = 0.01, Default = 0.4, ValueName = "%", Save = true})
	legit:AddColorpicker({Name = "Color", Default = MainColor, Flag = "hitboxes_color", Save = true})
	
	legit:AddSection({Name = "Gun Mods"})
	legit:AddToggle({Name = "Infinite Ammo", Flag = "gun_mods_inf_ammo", Save = true})
	legit:AddToggle({Name = "Force Automatic", Flag = "gun_mods_force_automatic", Save = true})
	legit:AddToggle({Name = "No Drops", Flag = "gun_mods_no_bullet_drop", Save = true})
	legit:AddToggle({Name = "No Spread", Flag = "gun_mods_no_bullet_spread", Save = true})
	legit:AddToggle({Name = "No Recoil", Flag = "gun_mods_no_bullet_recoil", Save = true})
    
    rage:AddSection({Name = "Knife Bot"})
	rage:AddToggle({Name = "Enabled", Flag = "knife_bot_main_toggle", Save = true})
	rage:AddToggle({Name = "Kill All", Flag = "knife_bot_kill_all", Save = true})
	rage:AddSlider({Name = "Radius", Flag = "knife_bot_radius", Max = 20000, Default = 200, ValueName = "px", Save = true})
    
    rage:AddSection({Name = "Anti Aim"})
    rage:AddToggle({Name = "Enabled", Flag = "anti_aim_main_toggle", Save = true})
    rage:AddToggle({Name = "Yaw", Flag = "anti_aim_yaw", Save = true})
    rage:AddSlider({Name = "Yaw Amount", Flag = "anti_aim_yaw_amount", Max = 360, Min = 1, Default = 180, ValueName = "Degrees", Save = true})
    rage:AddToggle({Name = "Pitch", Flag = "anti_aim_pitch", Save = true})
    rage:AddSlider({Name = "Pitch Amount", Flag = "anti_aim_pitch_amount", Max = 180, Min = 1, Default = 0, ValueName = "Degrees", Save = true})
    rage:AddToggle({Name = "Spin Bot", Flag = "anti_aim_spin_bot", Save = true})
    rage:AddSlider({Name = "Spin Bot Speed", Flag = "anti_aim_spin_bot_speed", Max = 160, Min = 1, Default = 15, ValueName = "Degrees & Seconds", Save = true})
    rage:AddDropdown({Name = "Spin Bot Direction", Flag = "anti_aim_spin_bot_direction", Default = "Left", Options = {"Left", "Right"} })
    rage:AddToggle({Name = "Jitter", Flag = "anti_aim_jitter", Save = true})
    rage:AddSlider({Name = "Jitter Speed", Flag = "anti_aim_jitter_speed", Max = 160, Min = 1, Default = 15, ValueName = "Degrees & Seconds", Save = true})
    rage:AddToggle({Name = "Force Stance", Flag = "anti_aim_force_stance", Save = true})
    rage:AddDropdown({Name = "Set Stance", Flag = "anti_aim_set_stance", Default = "Stand", Options = {"Stand", "Crouch", "Prone"} })
    
    misc:AddSection({Name = "Movement"})
	misc:AddToggle({Name = "Walk Speed", Flag = "movement_walk_speed", Save = true})
	misc:AddSlider({Name = "Set Speed", Flag = "movement_walk_speed_amount", Max = 235, Min = 1, Default = 50, ValueName = "Studs & Seconds", Save = true})
	
	misc:AddSection({Name = "Tycoon"})
	misc:AddToggle({Name = "Auto Collect Cash", Flag = "tycoon_auto_collect_cash", Save = true})
	misc:AddToggle({Name = "Auto Buy", Flag = "tycoon_auto_buy", Save = true})
	misc:AddToggle({Name = "Auto Prestige", Flag = "tycoon_auto_prestige", Save = true})
	
	misc:AddSection({Name = "Sounds"})
    misc:AddDropdown({Name = "Hit Sound", Flag = "sounds_hit", Default = "none", Options = {"none", "amongus", "fatality", "bubble", "cod", "anime", "anime2", "anime3", "anime4"} })
    misc:AddDropdown({Name = "Kill Sound", Flag = "sounds_kill", Default = "none", Options = {"none", "amongus", "fatality", "bubble", "cod", "anime", "anime2", "anime3", "anime4"} })
    
    misc:AddSection({Name = "Chat Spam"})
    misc:AddToggle({Name = "Enabled", Flag = "chat_spam_main_toggle", Save = true})
    misc:AddToggle({Name = "Team Only", Flag = "chat_spam_team_only", Save = true})
    misc:AddSlider({Name = "Chat Spam Delay", Flag = "chat_spam_delay", Max = 2, Min = 0.1, Default = 0.8, Increment = 0.01, ValueName = "Seconds", Save = true})
    
    visuals:AddSection({Name = "Third Person"})
    visuals:AddToggle({Name = "Enabled", Flag = "third_person_main_toggle", Save = true})
    visuals:AddSlider({Name = "Zoom Distance", Flag = "third_person_zoom_distance", Max = 20, Min = 0, Default = 0, ValueName = "Studs", Save = true})
    
    OrionLib:WindowMobileToggle({})
end)()
