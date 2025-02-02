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

LPH_NO_VIRTUALIZE(function() -- UI Creation
    local HttpService = game:GetService("HttpService")
    
    local Window = OrionLib:MakeWindow({Name = "Servenity", IntroEnabled = false, SaveConfig = true, ConfigFolder = "Servenity"})
    OrionLib.SelectedTheme = "Default"

	local Combat = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998"})
	local Misc = Window:MakeTab({Name = "Misc", Icon = "rbxassetid://10734920149"})
	local AntiAim = Window:MakeTab({Name = "Anti Aim", Icon = "rbxassetid://137296469153995"})
	local Visual = Window:MakeTab({Name = "Visual", Icon = "rbxassetid://10723346959"})
	
	Combat:AddSection({Name = "Checks"})
	Combat:AddToggle({Name = "Team", Flag = "combat_checks_team", Save = true})
	
	Combat:AddSection({Name = "Hitbox Extender"})
	Combat:AddToggle({Name = "Enabled", Flag = "combat_hitboxextend_main_toggle", Save = true})
	Combat:AddSlider({Name = "Size", Max = 100, Default = 14, Flag = "combat_hitboxextend_size", Save = true})
	Combat:AddSlider({Name = "Transparency", Max = 1, Increment = 0.01, Default = 0.4, Flag = "combat_hitboxextend_transparency", Save = true})
	Combat:AddColorpicker({Name = "Color", Default = MainColor, Flag = "combat_hitboxextend_color", Save = true})
	
	Combat:AddSection({Name = "Knife Aura"})
	Combat:AddToggle({Name = "Enabled", Flag = "combat_knife_aura_main_toggle", Save = true})
	Combat:AddSlider({Name = "Radius", Max = 5000, Default = 100, Flag = "combat_knife_aura_radius", Save = true})
	
	Combat:AddSection({Name = "Auto Burst"})
	Combat:AddToggle({Name = "Enabled", Flag = "combat_auto_burst_main_toggle", Save = true})
	Combat:AddToggle({Name = "Percent", Flag = "combat_auto_burst_percent", Save = true})
	Combat:AddSlider({Name = "Burst", Max = 10, Increment = 1, Default = 10, Flag = "combat_auto_burst_burst_amount", Save = true})
	
	Combat:AddSection({Name = "Hooks"})
	Combat:AddToggle({Name = "Infinite Ammo", Flag = "combat_hook_inf_ammo", Save = true})
	Combat:AddToggle({Name = "Bullet Multiplier", Flag = "combat_hook_bullet_multiplier", Save = true})
	Combat:AddToggle({Name = "Magic Bullet", Flag = "combat_hook_magic_bullet", Save = true})
	Combat:AddToggle({Name = "No Drops", Flag = "combat_hook_no_bullet_drop", Save = true})
	Combat:AddToggle({Name = "No Spread", Flag = "combat_hook_no_bullet_spread", Save = true})
	Combat:AddToggle({Name = "No Recoil", Flag = "combat_hook_no_bullet_recoil", Save = true})
	Combat:AddToggle({Name = "Always Air Kill", Flag = "combat_hooks_airkill", Save = true})
	Combat:AddToggle({Name = "Always No Scope", Flag = "combat_hooks_no_scope", Save = true})
	
	Misc:AddSection({Name = "Miscellaneous"})
	Misc:AddToggle({Name = "Auto Sprint", Flag = "miscellaneous_auto_sprint", Save = true})
	
	Misc:AddSection({Name = "Base"})
	Misc:AddToggle({Name = "Auto Collect Cash", Flag = "base_auto_collect_cash", Save = true})
	Misc:AddToggle({Name = "Auto Buy", Flag = "base_auto_buy", Save = true})
	Misc:AddToggle({Name = "Auto Prestige", Flag = "base_auto_prestige", Save = true})
	
	AntiAim:AddSection({Name = "Anti-Aimbot Angle"})
    AntiAim:AddToggle({Name = "Enabled", Flag = "anti_aim_main_toggle", Save = true})
    AntiAim:AddDropdown({Name = "Pitch", Flag = "anti_aim_pitch", Default = "Down", Options = {"Off", "Down", "Up", "Jitter", "Zero"} })
    AntiAim:AddDropdown({Name = "Degree", Flag = "anti_aim_degree", Default = "Off", Options = {"Off", "180", "Spin"} })
    AntiAim:AddSlider({Name = "Yaw Pitch", Max = 100, Default = 14, Flag = "anti_aim_yaw_pitch", Save = true})
    AntiAim:AddDropdown({Name = "Disabler", Flag = "anti_aim_disabler", Default = "Off", Options = {"Off", "InAir", "Freefall"} })
    
    OrionLib:WindowMobileToggle({})
end)()

LPH_JIT_MAX(function() -- Main Cheat
    local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")
	local UserInputService = game:GetService("UserInputService")
	local Workspace = game:GetService("Workspace")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Lighting = game:GetService("Lighting")
    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera
    
    local AutoBurstFOV = Drawing.new("Circle")

    local network = {}
	function network.send(name, action)
	    if name == "spot" then
	        if action then
	            ReplicatedStorage.PlayerEvents.SpotPlayer:FireServer(action)
	        end
	    elseif name == "stab" then
	        local Target = Players[action.Target]
			local args = {
			    [1] = {
			        ["shellSpeed"] = action.StabSpeed,
			        ["shellName"] = "DefaultMelee",
			        ["origin"] = Vector3.new(0, 0, 0),
			        ["weaponName"] = "Knife",
			        ["shellType"] = "Melee",
			        ["shellMaxDist"] = action.MaxDistance,
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
	    elseif name == "collectcash" then
	        ReplicatedStorage.CollectCashEvent:FireServer()
	    elseif name == "prestige" then
	        ReplicatedStorage.RequestPrestigeEvent:FireServer()
	    elseif name == "purchase" then
	        if action.name and action.ButtonPart then
	            ReplicatedStorage.RequestPurchaseEvent:FireServer(action.name)
	        end
	    elseif name == "purchase_vehicle" then
	        if action.name and type(action) == "table" then
	            ReplicatedStorage.RequestVehiclePurchaseEvent:FireServer(action.name)
	        end
	    end
	end

	table.insert(ConnectionList, RunService.RenderStepped:Connect(function()
	    local Teamcheck = Flags["combat_checks_team"].Value
	
	    if Flags["combat_hitboxextend_main_toggle"].Value then
	        for _, Player in next, Players:GetPlayers() do
	            if Player.Name ~= Players.LocalPlayer.Name then
	                if not Teamcheck or Player.Team ~= Players.LocalPlayer.Team then
	                    pcall(function()
	                        if Player.Character and Player.Character:FindFirstChild("Head") then
	                            Player.Character.Head.Size = Vector3.new(
	                                Flags["combat_hitboxextend_size"].Value,
	                                Flags["combat_hitboxextend_size"].Value,
	                                Flags["combat_hitboxextend_size"].Value
	                            )
	                            Player.Character.Head.Transparency = Flags["combat_hitboxextend_transparency"].Value
	                            Player.Character.Head.Color = Flags["combat_hitboxextend_color"].Value
	                            Player.Character.Head.Material = "Neon"
	                            Player.Character.Head.CanCollide = false
	                            Player.Character.Head.Massless = true
	                        end
	                    end)
	                end
	            end
	        end
	    end
	
	    if Flags["combat_knife_aura_main_toggle"].Value then
	        local KnifeAuraRadius = Flags["combat_knife_aura_radius"].Value
	
	        for _, Player in next, Players:GetPlayers() do
	            if Player.Name ~= Players.LocalPlayer.Name then
	                if not Teamcheck or Player.Team ~= Players.LocalPlayer.Team then
	                    if Player.Character and Player.Character:FindFirstChild("Head") then
	                        local playerHeadPosition = Player.Character.Head.Position
	                        local localPlayerPosition = Players.LocalPlayer.Character.Head.Position
	                        local distance = (localPlayerPosition - playerHeadPosition).Magnitude
	
	                        if distance <= KnifeAuraRadius then
	                            network.send("stab", {
	                                Target = Player.Name,
	                                StabSpeed = 99999,
	                                MaxDistance = KnifeAuraRadius,
	                            })
	                        end
	                    end
	                end
	            end
	        end
	    end
	end))
	
	table.insert(ConnectionList, RunService.RenderStepped:Connect(function()
	    if Flags["base_auto_collect_cash"].Value then
	        network.send("collectcash", nil)
	    end
	    
	    if Flags["base_auto_buy"].Value then
	        for _, child in pairs(Workspace[LocalPlayer.AssociatedTycoon.Value].BuyButtons:GetChildren()) do
	            if child:FindFirstChild("ButtonPart") then
	                local action = {name = child.Name, ButtonPart = child}
	                network.send("purchase", action)
	            end
	        end
	        local vehicleNames = {}
	        network.send("purchase_vehicle", vehicleNames)
	    end
	    
	    if Flags["base_auto_prestige"].Value then
	        network.send("prestige", nil)
	    end
	end))

	table.insert(ConnectionList, RunService.RenderStepped:Connect(function()
	    if Flags["anti_aim_main_toggle"].Value then
	        MovementCache.ReceivedPosition = LocalPlayer.Character.HumanoidRootPart.Position
	        MovementCache.UpdateReceived = true
	
	        if Flags["anti_aim_pitch"].Value == "Down" then
	            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(-30), 0, 0)
	        elseif Flags["anti_aim_pitch"].Value == "Up" then
	            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(30), 0, 0)
	        elseif Flags["anti_aim_pitch"].Value == "Jitter" then
	            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(math.random(-10, 10)), 0, 0)
	        elseif Flags["anti_aim_pitch"].Value == "Zero" then
	            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, 0, 0)
	        end
	
	        if Flags["anti_aim_degree"].Value == "180" then
	            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(180), 0)
	        elseif Flags["anti_aim_degree"].Value == "Spin" then
	            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(math.random(0, 360)), 0)
	        end
	
	        if Flags["anti_aim_yaw_pitch"].Value then
	            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(Flags["anti_aim_yaw_pitch"].Value), 0)
	        end
	
	        if Flags["anti_aim_disabler"].Value == "InAir" and LocalPlayer.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Physics then
	            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(90), 0)
	        elseif Flags["anti_aim_disabler"].Value == "Freefall" and LocalPlayer.Character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
	            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(90), 0)
	        end
	    end
	end))
	
	task.spawn(function()
	    local stillGoing = true
	    local PlayerWeapon = nil
	
	    local function RefreshPlayerWeapon()
	        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("ACS_Client") then
	            PlayerWeapon = LocalPlayer.Character.ACS_Client.ACS_Framework
	        else
	            PlayerWeapon = nil
	        end
	    end
	
	    while stillGoing do
	        task.wait(1)
	
	        RefreshPlayerWeapon()
	
	        if PlayerWeapon then
	            if Flags["combat_hooks_airkill"].Value then
	                ReplicatedStorage.ACS_Engine.Events.EditKillConditions:FireServer("InAir", true)
	            end
	            if Flags["combat_hooks_no_scope"].Value then
	                ReplicatedStorage.ACS_Engine.Events.EditKillConditions:FireServer("Aiming", false)
	            end
	
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
	
	            if RecoilFunction then
	                local RecoilData = debug.getupvalue(RecoilFunction, 13)
	                if RecoilData then
	                    if Flags["combat_hook_no_bullet_recoil"].Value then
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
	                    AmmoData["Ammo"] = Flags["combat_hook_inf_ammo"].Value and 99998 or 20
	                end
	            end
	
	            if AdsFunction then
	                local AdsData = debug.getupvalue(AdsFunction, 3)
	                if AdsData then
	                    AdsData["Bullets"] = Flags["combat_hook_bullet_multiplier"].Value and 10 or 1
	                    AdsData["BulletDrop"] = Flags["combat_hook_no_bullet_drop"].Value and 0 or 0.25
	                    AdsData["BulletPenetration"] = Flags["combat_hook_magic_bullet"].Value and math.huge or 75
	                end
	            end
	
	            if BulletSpreadFunction then
	                local BulletSpreadData = debug.getupvalue(BulletSpreadFunction, 2)
	                if BulletSpreadData and BulletSpreadData["MaxSpread"] then
	                    BulletSpreadData["MaxSpread"] = Flags["combat_hook_no_bullet_spread"].Value and 0 or 0.75
	                    BulletSpreadData["MinSpread"] = Flags["combat_hook_no_bullet_spread"].Value and 0 or 0.75
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
	-- wasn't that so bad right?
end)()

