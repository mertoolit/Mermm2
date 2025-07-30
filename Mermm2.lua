-- Mer Hub MM2 Advanced Script Part 1/3
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Window = Rayfield:CreateWindow({
    Name = "Mer Hub | Murder Mystery 2",
    LoadingTitle = "Mer Hub MM2",
    LoadingSubtitle = "by Mer",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MerHubMM2",
        FileName = "Settings"
    },
    KeySystem = false
})

-- Utils
local function getCharacter() return Player.Character or Player.CharacterAdded:Wait() end
local function getHumanoid() local c = getCharacter() return c and c:FindFirstChildOfClass("Humanoid") end
local function getGunDrop()
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name == "GunDrop" and obj:FindFirstChild("TouchInterest") then return obj end
    end
    return nil
end
local function getCoins()
    local coins = {}
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name == "Coin" or obj.Name == "GoldCoin" then table.insert(coins, obj) end
    end
    return coins
end
local function getMurderers()
    local murderers = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character and plr.Character:FindFirstChild("Knife") then table.insert(murderers, plr) end
    end
    return murderers
end

-- Toggles
local toggles = {}

-- === Main Tab ===
local MainTab = Window:CreateTab("Main")

MainTab:CreateToggle({
    Name = "Auto Get Gun",
    CurrentValue = false,
    Flag = "AutoGun",
    Callback = function(state)
        toggles.AutoGun = state
        spawn(function()
            while toggles.AutoGun do
                local gunDrop = getGunDrop()
                local char = getCharacter()
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if gunDrop and hrp then
                    hrp.CFrame = gunDrop.CFrame + Vector3.new(0,3,0)
                end
                wait(0.4)
            end
        end)
    end
})

MainTab:CreateToggle({
    Name = "Auto Shoot Murderer (Sheriff Only)",
    CurrentValue = false,
    Flag = "AutoShootMurderer",
    Callback = function(state)
        toggles.AutoShootMurderer = state
        spawn(function()
            while toggles.AutoShootMurderer do
                local char = getCharacter()
                local gun = char and char:FindFirstChild("Gun")
                if gun then
                    local murderers = getMurderers()
                    for _, murd in pairs(murderers) do
                        local hrp = murd.Character and murd.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            pcall(function()
                                workspace.Remote:FireServer("Shoot", hrp.Position)
                            end)
                        end
                    end
                end
                wait(0.3)
            end
        end)
    end
})

MainTab:CreateButton({
    Name = "Break Gun (Remove GunDrop)",
    Callback = function()
        local gunDrop = getGunDrop()
        if gunDrop then
            gunDrop:Destroy()
            Rayfield:Notify({Title="Gun Broken", Content="GunDrop removed.", Duration=3})
        else
            Rayfield:Notify({Title="No Gun", Content="No GunDrop found.", Duration=3})
        end
    end
})

local function createFakeKnife()
    if Player.Backpack:FindFirstChild("Knife") or (Player.Character and Player.Character:FindFirstChild("Knife")) then return end
    local fakeKnife = Instance.new("Tool")
    fakeKnife.Name = "Knife"
    fakeKnife.RequiresHandle = true
    fakeKnife.CanBeDropped = false

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.2, 1.2, 0.3)
    handle.BrickColor = BrickColor.new("Really black")
    handle.Material = Enum.Material.Metal
    handle.CanCollide = false
    handle.Parent = fakeKnife

    local blade = Instance.new("WedgePart")
    blade.Name = "Blade"
    blade.Size = Vector3.new(0.2, 0.6, 0.3)
    blade.BrickColor = BrickColor.new("Medium stone grey")
    blade.Material = Enum.Material.Metal
    blade.CanCollide = false
    blade.Parent = fakeKnife

    blade.CFrame = handle.CFrame * CFrame.new(0, 0.7, 0) * CFrame.Angles(math.rad(90), 0, 0)

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = handle
    weld.Part1 = blade
    weld.Parent = handle

    fakeKnife.Parent = Player.Backpack
end

MainTab:CreateToggle({
    Name = "Fake Knife (Better Model)",
    CurrentValue = false,
    Flag = "FakeKnife",
    Callback = function(state)
        if state then
            createFakeKnife()
        else
            local knife1 = Player.Backpack:FindFirstChild("Knife")
            if knife1 then knife1:Destroy() end
            local char = Player.Character
            if char then
                local knife2 = char:FindFirstChild("Knife")
                if knife2 then knife2:Destroy() end
            end
        end
    end
})

MainTab:CreateToggle({
    Name = "Auto Collect Coins",
    CurrentValue = false,
    Flag = "AutoCollectCoins",
    Callback = function(state)
        toggles.AutoCollectCoins = state
        spawn(function()
            while toggles.AutoCollectCoins do
                local char = getCharacter()
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local coins = getCoins()
                    for _, coin in pairs(coins) do
                        if coin and coin.Parent then
                            hrp.CFrame = coin.CFrame + Vector3.new(0,2,0)
                            wait(0.2)
                        end
                    end
                end
                wait(0.5)
            end
        end)
    end
})

MainTab:CreateButton({
    Name = "Reveal Roles",
    Callback = function()
        for _, plr in pairs(Players:GetPlayers()) do
            local role = "Innocent"
            if plr.Character then
                if plr.Character:FindFirstChild("Knife") then
                    role = "Murderer"
                elseif plr.Character:FindFirstChild("Gun") then
                    role = "Sheriff"
                end
            end
            Rayfield:Notify({Title = plr.Name, Content = "Role: "..role, Duration = 4})
        end
    end
})

-- Movement Tab
local MovementTab = Window:CreateTab("Movement")

MovementTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 100},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(value)
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = value end
    end
})

MovementTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 200},
    Increment = 1,
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(value)
        local hum = getHumanoid()
        if hum then hum.JumpPower = value end
    end
})

MovementTab:CreateToggle({
    Name = "Anti Fling",
    CurrentValue = false,
    Flag = "AntiFling",
    Callback = function(state)
        toggles.AntiFling = state
        local char = getCharacter()
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if state then
                hrp.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            else
                hrp.CustomPhysicalProperties = nil
            end
        end
    end
})-- Mer Hub MM2 Advanced Script Part 2/3: Troll Tab
local TrollTab = Window:CreateTab("Troll")

local layingBack = false
local layingFront = false
local spinning = false
local spinConnection
local danceConnection
local chatSpamConnection

TrollTab:CreateToggle({
    Name = "Lay On Back",
    CurrentValue = false,
    Callback = function(state)
        local char = getCharacter()
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChildOfClass("Humanoid") then return end
        local hrp = char.HumanoidRootPart
        if state then
            layingBack = true
            hrp.Anchored = true
            hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(90), 0, 0)
            local hum = char:FindFirstChildOfClass("Humanoid")
            local conn
            conn = hum.Jumping:Connect(function(active)
                if active and layingBack then
                    hrp.Anchored = false
                    layingBack = false
                    TrollTab:SetToggle("Lay On Back", false)
                    conn:Disconnect()
                end
            end)
        else
            if layingBack then
                layingBack = false
                hrp.Anchored = false
            end
        end
    end
})

TrollTab:CreateToggle({
    Name = "Lay On Front",
    CurrentValue = false,
    Callback = function(state)
        local char = getCharacter()
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChildOfClass("Humanoid") then return end
        local hrp = char.HumanoidRootPart
        if state then
            layingFront = true
            hrp.Anchored = true
            hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(-90), 0, 0)
            local hum = char:FindFirstChildOfClass("Humanoid")
            local conn
            conn = hum.Jumping:Connect(function(active)
                if active and layingFront then
                    hrp.Anchored = false
                    layingFront = false
                    TrollTab:SetToggle("Lay On Front", false)
                    conn:Disconnect()
                end
            end)
        else
            if layingFront then
                layingFront = false
                hrp.Anchored = false
            end
        end
    end
})

TrollTab:CreateToggle({
    Name = "Spin Character",
    CurrentValue = false,
    Callback = function(state)
        local char = getCharacter()
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp = char.HumanoidRootPart

        if state then
            spinning = true
            spinConnection = RunService.Heartbeat:Connect(function(deltaTime)
                if spinning then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(360) * deltaTime, 0)
                end
            end)
        else
            spinning = false
            if spinConnection then spinConnection:Disconnect() end
        end
    end
})

TrollTab:CreateToggle({
    Name = "Invisible Character",
    CurrentValue = false,
    Callback = function(state)
        local char = getCharacter()
        if not char then return end

        if state then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 1
                elseif part:IsA("Decal") then
                    part.Transparency = 1
                end
            end
        else
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 0
                elseif part:IsA("Decal") then
                    part.Transparency = 0
                end
            end
        end
    end
})

TrollTab:CreateToggle({
    Name = "Chat Spam",
    CurrentValue = false,
    Callback = function(state)
        local chat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if not chat then return end
        local sayMessage = chat:FindFirstChild("SayMessageRequest")
        if not sayMessage then return end

        if state then
            chatSpamConnection = RunService.Heartbeat:Connect(function()
                if chatSpamConnection and math.random() < 0.02 then
                    sayMessage:FireServer("You got trolled!", "All")
                end
            end)
        else
            if chatSpamConnection then chatSpamConnection:Disconnect() end
        end
    end
})

TrollTab:CreateButton({
    Name = "Cancel All Trolls",
    Callback = function()
        local char = getCharacter()
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Anchored = false
        end
        layingBack = false
        layingFront = false
        spinning = false
        if spinConnection then spinConnection:Disconnect() end
        if danceConnection then danceConnection:Disconnect() end
        if chatSpamConnection then chatSpamConnection:Disconnect() end
        TrollTab:SetToggle("Lay On Back", false)
        TrollTab:SetToggle("Lay On Front", false)
        TrollTab:SetToggle("Spin Character", false)
        TrollTab:SetToggle("Chat Spam", false)
    end
})-- Mer Hub MM2 Advanced Script Part 2/3: Troll Tab
local TrollTab = Window:CreateTab("Troll")

local layingBack = false
local layingFront = false
local spinning = false
local spinConnection
local danceConnection
local chatSpamConnection

TrollTab:CreateToggle({
    Name = "Lay On Back",
    CurrentValue = false,
    Callback = function(state)
        local char = getCharacter()
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChildOfClass("Humanoid") then return end
        local hrp = char.HumanoidRootPart
        if state then
            layingBack = true
            hrp.Anchored = true
            hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(90), 0, 0)
            local hum = char:FindFirstChildOfClass("Humanoid")
            local conn
            conn = hum.Jumping:Connect(function(active)
                if active and layingBack then
                    hrp.Anchored = false
                    layingBack = false
                    TrollTab:SetToggle("Lay On Back", false)
                    conn:Disconnect()
                end
            end)
        else
            if layingBack then
                layingBack = false
                hrp.Anchored = false
            end
        end
    end
})

TrollTab:CreateToggle({
    Name = "Lay On Front",
    CurrentValue = false,
    Callback = function(state)
        local char = getCharacter()
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChildOfClass("Humanoid") then return end
        local hrp = char.HumanoidRootPart
        if state then
            layingFront = true
            hrp.Anchored = true
            hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(-90), 0, 0)
            local hum = char:FindFirstChildOfClass("Humanoid")
            local conn
            conn = hum.Jumping:Connect(function(active)
                if active and layingFront then
                    hrp.Anchored = false
                    layingFront = false
                    TrollTab:SetToggle("Lay On Front", false)
                    conn:Disconnect()
                end
            end)
        else
            if layingFront then
                layingFront = false
                hrp.Anchored = false
            end
        end
    end
})

TrollTab:CreateToggle({
    Name = "Spin Character",
    CurrentValue = false,
    Callback = function(state)
        local char = getCharacter()
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp = char.HumanoidRootPart

        if state then
            spinning = true
            spinConnection = RunService.Heartbeat:Connect(function(deltaTime)
                if spinning then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(360) * deltaTime, 0)
                end
            end)
        else
            spinning = false
            if spinConnection then spinConnection:Disconnect() end
        end
    end
})

TrollTab:CreateToggle({
    Name = "Invisible Character",
    CurrentValue = false,
    Callback = function(state)
        local char = getCharacter()
        if not char then return end

        if state then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 1
                elseif part:IsA("Decal") then
                    part.Transparency = 1
                end
            end
        else
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 0
                elseif part:IsA("Decal") then
                    part.Transparency = 0
                end
            end
        end
    end
})

TrollTab:CreateToggle({
    Name = "Chat Spam",
    CurrentValue = false,
    Callback = function(state)
        local chat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if not chat then return end
        local sayMessage = chat:FindFirstChild("SayMessageRequest")
        if not sayMessage then return end

        if state then
            chatSpamConnection = RunService.Heartbeat:Connect(function()
                if chatSpamConnection and math.random() < 0.02 then
                    sayMessage:FireServer("You got trolled!", "All")
                end
            end)
        else
            if chatSpamConnection then chatSpamConnection:Disconnect() end
        end
    end
})

TrollTab:CreateButton({
    Name = "Cancel All Trolls",
    Callback = function()
        local char = getCharacter()
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Anchored = false
        end
        layingBack = false
        layingFront = false
        spinning = false
        if spinConnection then spinConnection:Disconnect() end
        if danceConnection then danceConnection:Disconnect() end
        if chatSpamConnection then chatSpamConnection:Disconnect() end
        TrollTab:SetToggle("Lay On Back", false)
        TrollTab:SetToggle("Lay On Front", false)
        TrollTab:SetToggle("Spin Character", false)
        TrollTab:SetToggle("Chat Spam", false)
    end
})
