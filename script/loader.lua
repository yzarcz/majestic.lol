--> Load UI
local Fluent, SaveManager, InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/yzarcz/fluentsomehow/refs/heads/main/releases.lua", true))()

local Window = Fluent:CreateWindow({
    Title = "Majestic",
    SubTitle = "Fish It!",
    TabWidth = 160,
    Size = UDim2.fromOffset(570, 390),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift
})

--> Load Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    World = Window:AddTab({ Title = "World", Icon = "globe" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

--> Load Sub-Vars
local Section
local Section2
local Dropdown

--> Load Vars
local TPLoc = {
    ["Fisherman"] = CFrame.new(-26.10, 9.53, 2805.19),
    ["Kohana Island"] = CFrame.new(-643.32, 16.04, 614.43),
    ["Kohana Volcano"] = CFrame.new(-678.60, 55.50, 180.71),
    ["Coral Reef"] = CFrame.new(-2783.03, 4.01, 2143.41),
    ["Esoteric Island"] = CFrame.new(2026.93, 27.40, 1392.11),
    ["Esoteric Depths"] = CFrame.new(2974.25, -1302.73, 1518.90),
    ["Tropical Grove"] = CFrame.new(-2030.78, 6.27, 3676.14),
    ["Crater"] = CFrame.new(971.11, 7.36, 4874.94),
    ["Lost Isle"] = CFrame.new(-3646.68, 5.41, -1054.68),
    ["Ancient Jungle"] = CFrame.new(1242.64, 7.97, -133.84),
    ["Mount Hallow"] = CFrame.new(1820.73, 22.87, 3083.80),
    ["Sisyphus Statue"] = CFrame.new(-3698.65, -135.57, -1015.54),
    ["Treasure Room"] = CFrame.new(-3597.71, -275.74, -1642.42),
    ["Weather Machine"] = CFrame.new(-1518.44, 6.49, 1882.42),
}
local Player = game.Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()
local LocationNames = {}
for name in pairs(TPLoc) do
    table.insert(LocationNames, name)
end
table.sort(LocationNames)

Section = Tabs.Main:AddSection("Fishing", "axe")

local FishStatus = Section:AddParagraph({
    Title = "Fishing Status",
    Content = "<b>Idle</b>",
    RichText = true,
})

Section:AddToggle("", {
    Title = "Auto Equip Rod",
    Description = "Auto equips your selected rod.",
    Default = false,
    Callback = function(state)
        _G.AutoEquipRod = state
        while _G.AutoEquipRod do
            task.wait()
            if _G.AutoEquipRod then
                if not Char:FindFirstChild("!!!EQUIPPED_TOOL!!!") then
                    game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipToolFromHotbar"]:FireServer(1)
                end
            end
        end
    end
})

local AutoFishKeybind = Section:AddKeybind("AutoFishKeybind", {
    Title = "Auto Fish",
    Description = "Auto casts and spams reel clicks for you.",
    Mode = "Toggle",
    Default = "Z",
    Callback = function(Value)
        _G.AutoFish = Value

        local VIM = game:GetService("VirtualInputManager")
        local Mouse = Player:GetMouse()

        local function SimulateClick()
            local s, e, = pcall(function()
                VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game)
                task.wait()
                VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game)
            end)
        end

        local function IsFishingActive()
            local F = Player:FindFirstChild("PlayerGui"):FindFirstChild("Fishing")
            local M = F:FindFirstChild("Main")

            return M.Visible and M.Position == UDim2.new(0.5, 0, 0.5, 0)
        end

        if Value then
            task.spawn(function()
                while _G.AutoFish do
                    task.wait()
                    local F = Player:FindFirstChild("PlayerGui"):FindFirstChild("Fishing")
                    local M = F:FindFirstChild("Main")

                    if not IsFishingActive() then
                        _G.Casting = true
                        _G.Reeling = false
                        SimulateClick()
                        task.wait()
                        _G.Casting = false
                    else
                        _G.Casting = false
                        _G.Reeling = true
                        while _G.AutoFish and IsFishingActive() do
                            SimulateClick()
                            task.wait()
                        end
                        _G.Reeling = false
                        task.wait()
                    end
                end
                _G.Casting = false
                _G.Reeling = false
            end)
        else
            _G.Casting = false
            _G.Reeling = false
        end
    end,
    ChangedCallback = function(New)

    end
})

Section:AddToggle("", {
    Title = "Instant Bobber",
    Description = "Makes when you fish the bobber automatically teleports beneath you.",
    Default = false,
    Callback = function(state)
        _G.InstantBobber = state
        
        if _G.InstantBobber then
            task.spawn(function()
                local RS = game:GetService("RunService")
                local connection
                local lastWaterCheck = 0
                local cachedWaterPos = nil
                
                connection = RS.Heartbeat:Connect(function()
                    if not _G.InstantBobber then
                        connection:Disconnect()
                        return
                    end
                    
                    pcall(function()
                        if not Char:FindFirstChild("HumanoidRootPart") then return end
                        local hrp = Char.HumanoidRootPart
                        
                        local currentTime = tick()
                        if currentTime - lastWaterCheck > 2 then
                            cachedWaterPos = Vector3.new(hrp.Position.X, -1.5, hrp.Position.Z)
                            lastWaterCheck = currentTime
                        end

                        local bobber = workspace.CosmeticFolder:FindFirstChild(tostring(Player.UserId))
                        if bobber and cachedWaterPos then
                            bobber.CFrame = CFrame.new(cachedWaterPos)
                        end
                    end)
                end)
            end)
        end
    end
})

Section:AddDivider()

local Platform
local PlatformLoop

Section:AddToggle("", {
    Title = "Platform",
    Description = "Makes a platform beneath you.",
    Default = false,
    Callback = function(state)
        _G.Platform = state
        if _G.Platform then
            Platform = Instance.new("Part", workspace)
            Platform.Size = Vector3.new(6, 1, 6)
            Platform.Color = Color3.fromRGB(171, 86, 219)
            Platform.Anchored = true

            PlatformLoop = game:GetService("RunService").Heartbeat:Connect(function()
                if Platform then
                    Platform.CFrame = Char.HumanoidRootPart.CFrame - Vector3.new(0, 3.5, 0)
                end
            end)
        else
            if PlatformLoop then
                PlatformLoop:Disconnect()
                PlatformLoop = nil
            end
            if Platform then
                Platform:Destroy()
                Platform = nil
            end
        end
    end
})

Section2 = Tabs.Main:AddSection("Selling", "dollar-sign")

local Slider

Section2:AddToggle("", {
    Title = "Prefer Threshold Check",
    Description = "Prefer threshold check?",
    Default = false,
    Callback = function(state)
        _G.PreferSellThreshold = state
        if _G.PreferSellThreshold then
            if not Slider then
                Slider = Section2:AddSlider("", {
                    Title = "Threshold",
                    Description = "Selects the threshold theres gonna be in sell.",
                    Default = 20,
                    Min = 0,
                    Max = 1000,
                    Rounding = 1,
                    Callback = function(Value)
                        _G.SellThreshold = Value
                    end
                })
            end
        else
            if Slider then
                Slider:Destroy()
                Slider = nil
            end
        end
    end
})

Section2:AddToggle("", {
    Title = "Auto Sell Shit",
    Description = "Auto sell all your shit.",
    Default = false,
    Callback = function(state)
        _G.AutoSellAll = state
        while _G.AutoSellAll do
            task.wait()
            if _G.AutoSellAll then
                if _G.PreferSellThreshold then
                    game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RF/SellAllItems"]:InvokeServer()
                    task.wait(_G.SellThreshold)
                else
                    game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RF/SellAllItems"]:InvokeServer()
                end
            end
        end
    end
})

Section2:AddDivider()

Section2:AddButton({
    Title = "Sell Shit",
    Description = "Sells all your shit.",
    Callback = function()
        game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RF/SellAllItems"]:InvokeServer()
    end
})

Section = Tabs.Main:AddSection("Teleporting", "globe-2")

Dropdown = Section:AddDropdown("", {
    Title = "Select Location",
    Description = "Select the location you want to teleport.",
    Values = LocationNames,
    Multi = false,
})

Dropdown:OnChanged(function(Value)
    _G.Location = TPLoc[Value]
end)

Section:AddButton({
    Title = "Teleport",
    Description = "Teleports you to the selected location.",
    Callback = function()
        if _G.Location then
            Char:MoveTo(_G.Location.Position)
        end
    end
})

Section:AddDivider()

Section = Tabs.Main:AddSection("Enchanting", "book")

Dropdown = Section:AddDropdown("", {
    Title = "Select Enchant:",
    Description = "Select the enchant you want.",
    Values = {"Stargazer I", "Stormhunter I", "XPerienced I", "Cursed I", "Reeler I", "Leprechaun I", "Mutation Hunter II", "Glistening I", "Prismatic I", "Mutation Hunter I", "Big Hunter I", "Gold Digger I", "Empowered I", "Leprechaun II"},
    Multi = false,
})

Section:AddToggle("", {
    Title = "Auto Enchant",
    Description = "Auto enchants your rod.",
    Default = false,
    Callback = function(state)
        _G.AutoEnchant = state
        while _G.AutoEnchant do
            task.wait()
            if _G.AutoEnchant then
                local EnchantLabel = Player:WaitForChild("PlayerGui"):WaitForChild("Roll Enchant"):WaitForChild("Inside"):WaitForChild("Top"):WaitForChild("EnchantLabel")
                repeat
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RE/ActivateEnchantingAltar"):FireServer()
                until EnchantLabel.Text == _G.SelectedEnchant
                if EnchantLabel.Text == _G.SelectedEnchant then
                    Fluent:Notify({
                            Title = "Majestic",
                            Content = "Auto Enchant",
                            SubContent = "You got the right enchantment!",
                            Duration = 5
                    })
                end
            end
        end
    end
})

Section = Tabs.Main:AddSection("Miscellaneous", "wrench")

Section:AddDivider()

Section:AddToggle("", {
    Title = "Radar",
    Description = "Activates and deactivates the fish radar (radar).",
    Default = false,
    Callback = function(state)
        _G.Radar = state
        if _G.Radar then
            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/UpdateFishingRadar"):InvokeServer(true)
        else
            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/UpdateFishingRadar"):InvokeServer(false)
        end
    end
})

local WaterPart

Section:AddToggle("", {
    Title = "Walk on Water",
    Description = "Creates an invisible platform under you so you can walk infinitely on water.",
    Default = false,
    Callback = function(state)
        _G.WalkOnWater = state

        if _G.WalkOnWater then
            if not WaterPart then
                WaterPart = Instance.new("Part")
                WaterPart.Anchored = true
                WaterPart.Size = Vector3.new(2048, 1, 2048)
                WaterPart.Transparency = 0.5
                WaterPart.Name = "WaterPart"
                WaterPart.Parent = workspace
            end

            game:GetService("RunService").Heartbeat:Connect(function()
                if _G.WalkOnWater and WaterPart and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
                    WaterPart.CFrame = CFrame.new(Vector3.new(hrp.Position.X, -1.50, hrp.Position.Z))
                end
            end)
        else
            if WaterPart then
                WaterPart:Destroy()
                WaterPart = nil
            end
        end
    end
})

Section:AddToggle("", {
    Title = "Infinite Oxygen",
    Description = "Yeah, infinite oxygen, basic thing.",
    Default = false,
    Callback = function(state)
        _G.InfiniteOxygen = state
        while _G.InfiniteOxygen do
            task.wait()
            if _G.InfiniteOxygen then
                if Char.Humanoid.Health > 80 then
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("URE/UpdateOxygen"):FireServer(-20)
                elseif Char.Humanoid.Health > 60 and Char.Humanoid.Health < 80 then
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("URE/UpdateOxygen"):FireServer(-40)
                elseif Char.Humanoid.Health > 40 and Char.Humanoid.Health < 60 then
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("URE/UpdateOxygen"):FireServer(-60)
                elseif Char.Humanoid.Health > 20 and Char.Humanoid.Health < 40 then
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("URE/UpdateOxygen"):FireServer(-80)
                end
            end
        end
    end
})

Section = Tabs.World:AddSection("Hunter", "waves")

Dropdown = Section:AddDropdown("", {
    Title = "Event(s) to farm/tp on:",
    Description = "Select the event(s) you want to farm/tp.",
    Values = {"Megalodon Hunt", "Ghost Shark Hunt", "Shark Hunt"},
    Multi = false,
})

Section:AddDivider()

Dropdown:OnChanged(function(Value)
    _G.EventToHunt = Value
end)

Section:AddToggle("", {
    Title = "Auto Hunt",
    Description = "Auto hunts for the selected event.",
    Default = false,
    Callback = function(state)
        _G.AutoHunt = state
        while _G.AutoHunt do
            task.wait()
            if _G.AutoHunt then
                if _G.EventToHunt then
                    local EventLocation
                    for _, event in pairs(workspace:FindFirstChild("!!! MENU RINGS"):GetChildren()) do
                        if event.Name == "Props" then
                            if event:FindFirstChild(_G.EventToHunt) then
                                EventLocation = event
                            end
                        end
                    end
                    if EventLocation then
                        if _G.EventToHunt == "Shark Hunt" or _G.EventToHunt == "Ghost Shark Hunt" then
                            local Event = EventLocation:FindFirstChild(_G.EventToHunt)
                            local EventPart = Event:FindFirstChild("Part")
                            Char.HumanoidRootPart.CFrame = EventPart.CFrame
                        else
                            local Event = EventLocation:FindFirstChild(_G.EventToHunt)
                            local EventPart = Event:FindFirstChild(_G.EventToHunt)
                            Char.HumanoidRootPart.CFrame = EventPart.CFrame
                        end
                    end
                end
            end
        end
    end
})

Section = Tabs.World:AddSection("Weather Machine", "droplet")

Dropdown = Section:AddDropdown("", {
    Title = "Weather to purchase:",
    Description = "Select the weather you want to purchase.",
    Values = {"Wind", "Cloudy", "Snow", "Storm", "Radiant", "Shark Hunt"},
    Multi = false,
})

Section:AddDivider()

Dropdown:OnChanged(function(Value)
    _G.WeatherToPurchase = Value
end)

Section:AddButton({
    Title = "Purchase",
    Description = "Purchases the selected weather event.",
    Callback = function()
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/PurchaseWeatherEvent"):InvokeServer(_G.WeatherToPurchase)
    end
})

task.spawn(function()
	while task.wait(1) do
		if _G.Casting and _G.AutoFish then
			FishStatus:SetDesc("<b>Casting...</b>")
        elseif _G.Reeling and _G.AutoFish then
			FishStatus:SetDesc("<b>Reeling...</b>")
		else
            FishStatus:SetDesc("<b>Idle</b>")
        end
	end
end)

task.spawn(function()
	while task.wait(1) do
		if Char and Char:FindFirstChildOfClass("Humanoid") then
			local Humanoid = Char:FindFirstChildOfClass("Humanoid")

			if Humanoid.Health > 100 then
				local excess = Humanoid.Health - 100

				game:GetService("ReplicatedStorage")
					:WaitForChild("Packages")
					:WaitForChild("_Index")
					:WaitForChild("sleitnick_net@0.2.0")
					:WaitForChild("net")
					:WaitForChild("URE/UpdateOxygen")
					:FireServer(excess)
			end
		end
	end
end)


SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("Majestic")
SaveManager:SetFolder("Majestic/FishIt")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
