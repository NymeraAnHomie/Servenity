local network = game:service("NetworkClient")
network:SetOutgoingKBPSLimit(0)

setfpscap(getgenv().maxfps or 0)

local PingStat = game:service("Stats").PerformanceStats.Ping
local function GetLatency()
	return PingStat:GetValue() / 1000
end

getgenv().Loaded = false

if getgenv().Loaded then
	return
else
	getgenv().Loaded = true
end 

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local main_color = Color3.fromRGB(109, 116, 163)

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Camera = Workspace.CurrentCamera
local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
local RootPart = Character.HumanoidRootPart
local IsHoldingTool = false

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/NymeraAnHomie/Library/refs/heads/main/OrionLib/Source.lua')))()
local Hydroxide = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Upbolt/Hydroxide/revision/ohaux.lua"))()

local Window = OrionLib:MakeWindow({
	Name = "Servenity",
	IntroEnabled = false,
	SaveConfig = true,
	ConfigFolder = "Servenity"
})
OrionLib.SelectedTheme = "Default"

local Utility = {} do
	Utility.Generate_Random_String = function(length)
		local characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
		local random_string = ""

		for i = 1, length do
			local random_index = math.random(1, #characters);
			random_string = random_string .. string.sub(characters, random_index, random_index);
		end

		return random_string
	end
end
local Client = {} do
	Client.Remotes = {} do
	    Client.Remotes.Spot = function(user)
	        ReplicatedStorage.PlayerEvents.SpotPlayer:FireServer(user)
	    end
	    Client.Remotes.CollectCash = function()
	        ReplicatedStorage.CollectCashEvent:FireServer()
	    end
	    Client.Remotes.Prestige = function()
	        ReplicatedStorage.RequestPrestigeEvent:FireServer()
	    end
	    Client.Remotes.Purchase = function(name)
	        ReplicatedStorage.RequestPurchaseEvent:FireServer(name.ButtonPart)
	    end
	    Client.Remotes.PurchaseVehicle = function(names)
	        ReplicatedStorage.RequestVehiclePurchaseEvent:FireServer(names)
	    end
	end
	Client.Exploits = {} do
		Client.Exploits.Name = function(example, example2)
	    
	    end
	end
end

local Combat = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998"})
local Misc = Window:MakeTab({Name = "Misc", Icon = "rbxassetid://10734920149"})
local AA = Window:MakeTab({Name = "Anti Aim", Icon = "rbxassetid://137296469153995"})
local Visual = Window:MakeTab({Name = "Visual", Icon = "rbxassetid://10723346959"})
local World = Window:MakeTab({Name = "World", Icon = "rbxassetid://7744394245"})

--// Combat
Combat:AddSection({Name = "Checks"})
Combat:AddToggle({Name = "Team", Flag = "combat_checks_team", Save = true})

Combat:AddSection({Name = "Hitbox Extender"})
Combat:AddToggle({Name = "Enabled", Flag = "combat_hitboxextend_main_toggle", Save = true})
Combat:AddSlider({Name = "Size", Max = 100, Default = 14, Flag = "combat_hitboxextend_size", Save = true})
Combat:AddSlider({Name = "Transparency", Max = 1, Increment = 0.01, Default = 0.4, Flag = "combat_hitboxextend_transparency", Save = true})
Combat:AddColorpicker({Name = "Color", Default = main_color, Flag = "combat_hitboxextend_color", Save = true})

Combat:AddSection({Name = "Hooks"})
Combat:AddToggle({Name = "Infinite Ammo", Flag = "combat_hook_inf_ammo", Save = true})
Combat:AddToggle({Name = "Bullet Multiplier", Flag = "combat_hook_bullet_multiplier", Save = true})
Combat:AddToggle({Name = "Magic Bullet", Flag = "combat_hook_magic_bullet", Save = true})
Combat:AddToggle({Name = "Always Air Kill", Flag = "combat_hooks_airkill", Save = true})
Combat:AddToggle({Name = "Always No Scope", Flag = "combat_hooks_no_scope", Save = true})
Combat:AddButton({Name = "Force Spot Everyone", Callback = function()
	for _, Player in pairs(Players:GetPlayers()) do
	    Client.Remotes.Spot(Player)
	end
end})

--// Miscellaneous
Misc:AddSection({Name = "Miscellaneous"})
Misc:AddToggle({Name = "Auto Sprint", Flag = "miscellaneous_auto_sprint", Save = true})

Misc:AddSection({Name = "Base"})
Misc:AddToggle({Name = "Auto Collect Cash", Flag = "base_auto_collect_cash", Save = true})
Misc:AddToggle({Name = "Auto Buy", Flag = "base_auto_buy", Save = true})
--Misc:AddParagraph("Read me", "Auto Buy is a one-time use, which means you can't turn it off once enabled.")
Misc:AddToggle({Name = "Auto Prestige", Flag = "base_auto_prestige", Save = true})

Misc:AddSection({Name = "CFrame"})
Misc:AddToggle({Name = "Enabled", Flag = "cframe_speed_main_toggle", Save = true})
Misc:AddSlider({Name = "Amount", Max = 10, Default = 3, Flag = "cframe_speed_amount", Save = true})

Misc:AddSection({Name = "Flight"})
Misc:AddToggle({Name = "Enabled", Flag = "flight_main_toggle", Save = true})
Misc:AddSlider({Name = "Amount", Max = 5000, Default = 1000, Flag = "flight_speed_amount", Save = true})

--// World

--// Anti Aim

RunService.RenderStepped:Connect(function()
	if Character then
        for _, Child in pairs(Character:GetChildren()) do
            if Child:IsA("Tool") then
                IsHoldingTool = true
                break
            else
                IsHoldingTool = false
            end
        end
    end
    
    --// Misc
	do
	    local SpeedMainToggle = OrionLib.Flags["cframe_speed_main_toggle"].Value
	    local SpeedAmount = OrionLib.Flags["cframe_speed_amount"].Value
	    local FlightMainToggle = OrionLib.Flags["flight_main_toggle"].Value
	    local FlightSpeedAmount = OrionLib.Flags["flight_speed_amount"].Value
	    
	    if SpeedMainToggle and Character then
		    LocalPlayer.Character.HumanoidRootPart.CFrame = 
		        RootPart.CFrame + 
		        LocalPlayer.Character.Humanoid.MoveDirection * 
		        SpeedAmount * 
		        1
		end
	    
	    if FlightMainToggle then
	        
	    end
	end
	
	--// Combat
	do
		local Teamcheck = OrionLib.Flags["combat_checks_team"].Value
		
		--// Hitbox Extender
		do
			local HitboxExtenderMainToggle = OrionLib.Flags["combat_hitboxextend_main_toggle"].Value
			local HitboxExtenderSize = OrionLib.Flags["combat_hitboxextend_size"].Value
			local HitboxExtenderColor = OrionLib.Flags["combat_hitboxextend_color"].Value
			local HitboxExtenderTransparency = OrionLib.Flags["combat_hitboxextend_transparency"].Value
			
			if HitboxExtenderMainToggle then 
				for _, Player in next, Players:GetPlayers() do 
					if Player.Name ~= Players.LocalPlayer.Name then 
						if not Teamcheck or Player.Team ~= Players.LocalPlayer.Team then
							pcall(function() 
								if Player.Character and Player.Character:FindFirstChild("Head") then
									Player.Character.Head.Size = Vector3.new(
										HitboxExtenderSize,
										HitboxExtenderSize,
										HitboxExtenderSize
									)
									Player.Character.Head.Transparency = HitboxExtenderTransparency 
									Player.Character.Head.BrickColor = BrickColor.new(HitboxExtenderColor)
									Player.Character.Head.Material = "Neon" 
									Player.Character.Head.CanCollide = false 
									Player.Character.Head.Massless = true 
								end
							end) 
						end
					end 
				end 
			end 
		end
	end
end)

RunService.RenderStepped:Connect(function()
    local BaseAutoCollectCash = OrionLib.Flags["base_auto_collect_cash"].Value
    local BaseAutoBuy = OrionLib.Flags["base_auto_buy"].Value
    local BaseAutoPrestige = OrionLib.Flags["base_auto_prestige"].Value
    local AssociatedTycoon = LocalPlayer.AssociatedTycoon.Value
    local VehiclePath = ReplicatedStorage.Vehicles
    local VehicleNames = {}
    
    for _, child in pairs(VehiclePath:GetChildren()) do
        table.insert(VehicleNames, child.Name)
    end

    if BaseAutoCollectCash then
        Client.Remotes.CollectCash()
    end
    
    if BaseAutoBuy then
        for _, child in pairs(Workspace[AssociatedTycoon].BuyButtons:GetChildren()) do
            if child:FindFirstChild("ButtonPart") then
                Client.Remotes.Purchase(child)
            end
        end
        Client.Remotes.PurchaseVehicle(VehicleNames)
    end
    
    if BaseAutoPrestige then
        Client.Remotes.Prestige()
    end
end)

local last_tick_hook = tick()
RunService.RenderStepped:Connect(function()
    local hook_tick = tick()
    
    if hook_tick - last_tick_hook >= 4 then
        lastExecuted = currentTime
        
        local CombatHookInfAmmo = OrionLib.Flags["combat_hook_inf_ammo"].Value
        local CombatHookBulletMultiplier = OrionLib.Flags["combat_hook_bullet_multiplier"].Value
        local CombatHookMagicBullet = OrionLib.Flags["combat_hook_magic_bullet"].Value
        local AlwaysAirKill = OrionLib.Flags["combat_hooks_airkill"].Value
        local AlwaysNoscopeKill = OrionLib.Flags["combat_hooks_no_scope"].Value
        
        if AlwaysAirKill then
            ReplicatedStorage.ACS_Engine.Events.EditKillConditions:FireServer("InAir", true)
        end
        if AlwaysNoscopeKill then
            ReplicatedStorage.ACS_Engine.Events.EditKillConditions:FireServer("Aiming", false)
        end
        
        local PlayerWeapon = workspace[LocalPlayer.Name].ACS_Client.ACS_Framework
        local ReloadFunction = Hydroxide.searchClosure(PlayerWeapon, "Reload", 1, {
            [1] = "Type", [2] = "Gun", [3] = "Stinger", [4] = "Launcher", [5] = "Grapple Hook", [6] = "Ammo"
        })
        local AdsFunction = Hydroxide.searchClosure(PlayerWeapon, "ADS", 3, {
            [1] = "IsAimingDownSights", [2] = "IsTurret", [3] = "setInProgress", [4] = "ADS", [5] = "canAim", [6] = 0.2
        })
        
        if ReloadFunction then
            local AmmoData = debug.getupvalue(ReloadFunction, 1)
            if AmmoData then
                if CombatHookInfAmmo then
                    AmmoData["Ammo"] = 9999
                else
                    AmmoData["Ammo"] = 1
                end
            end
        end

        if AdsFunction then
            if CombatHookBulletMultiplier then
                local BulletsData = debug.getupvalue(AdsFunction, 3)
                if BulletsData then
                    BulletsData["Bullets"] = 10
                else
                    BulletsData["Bullets"] = 1
                end
            end

            if CombatHookNoBulletDrop then
                local BulletDropData = debug.getupvalue(AdsFunction, 3)
                if BulletDropData then
                    BulletDropData["BulletDrop"] = 0
                else
                    BulletDropData["BulletDrop"] = 0.25
                end
            end

            if CombatHookMagicBullet then
                local BulletPenetrationData = debug.getupvalue(AdsFunction, 3)
                if BulletPenetrationData then
                    BulletPenetrationData["BulletPenetration"] = math.huge
                else
                    BulletPenetrationData["BulletPenetration"] = 75
                end
            end
        end
    end
end)

local WindowMobToggle = OrionLib:WindowMobileToggle({})

-- Workspace.Airdrops.thingy.Bottom
-- Workspace.Drops
