if game.PlaceId ~= 142823291 then return end

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/UI-Libraries/Rayfield/main/source'))()

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Mouse = LocalPlayer:GetMouse()

-- State variables
local EspSettings = {
    ShowNames = true,
    ShowMurderer = false,
    ShowSheriff = false,
    ShowPlayers = false,
    ESPOn = false,
}

local CoinFarmActive = false
local MurdererName, SheriffName = nil, nil
local ESPFolder = Instance.new("Folder", LocalPlayer.PlayerGui)
ESPFolder.Name = "ESPTrackers"

local FlyActive = false
local NoclipActive = false
local GodmodeActive = false
local XrayActive = false

-- Utility functions --
local function ClearESP()
    for _, gui in pairs(ESPFolder:GetChildren()) do
        gui:Destroy()
    end
end

local function CreateESP(targetPlayer, displayName, color)
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Head") then return end
    if ESPFolder:FindFirstChild(targetPlayer.Name) then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = targetPlayer.Name
    billboard.Adornee = targetPlayer.Character.Head
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = ESPFolder

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true
    label.Text = displayName
end

local function UpdateRolesESP()
    ClearESP()
    MurdererName = nil
    SheriffName = nil

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hasKnife, hasGun = false, false
            for _, item in pairs(plr.Backpack:GetChildren()) do
                if item.Name == "Knife" then hasKnife = true end
                if item.Name == "Gun" or item.Name == "Revolver" then hasGun = true end
            end
            for _, item in pairs(plr.Character:GetChildren()) do
                if item.Name == "Knife" then hasKnife = true end
                if item.Name == "Gun" or item.Name == "Revolver" then hasGun = true end
            end

            if hasKnife then
                MurdererName = plr.Name
                if EspSettings.ShowMurderer then
                    CreateESP(plr, EspSettings.ShowNames and plr.Name or "Murderer", Color3.new(1,0,0))
                end
            elseif hasGun then
                SheriffName = plr.Name
                if EspSettings.ShowSheriff then
                    CreateESP(plr, EspSettings.ShowNames and plr.Name or "Sheriff", Color3.new(0,0,1))
                end
            elseif EspSettings.ShowPlayers then
                CreateESP(plr, EspSettings.ShowNames and plr.Name or "Innocent", Color3.new(0,1,0))
            end
        end
    end
end

-- Auto Farm function (simplified, no octree)
local function FindCoins()
    local map = nil
    for _, m in pairs(Workspace:GetChildren()) do
        if m:IsA("Model") and m.Name == "Base" then
            map = m.Parent
            break
        end
    end
    if not map then return {} end
    local container = map:FindFirstChild("CoinContainer")
    if not container then return {} end

    local coins = {}
    for _, coin in pairs(container:GetDescendants()) do
        if coin:IsA("MeshPart") and coin.Material == Enum.Material.Ice then
            table.insert(coins, coin)
        end
    end
    return coins
end

local AutoFarmCoroutine = nil
local function AutoFarm()
    if AutoFarmCoroutine then
        coroutine.close(AutoFarmCoroutine)
        AutoFarmCoroutine = nil
    end
    AutoFarmCoroutine = coroutine.create(function()
        while CoinFarmActive do
            local coins = FindCoins()
            table.sort(coins, function(a,b)
                return (a.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < (b.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            end)
            for _, coin in pairs(coins) do
                if not CoinFarmActive then break end
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(coin.Position) + Vector3.new(0,3,0)
                    task.wait(0.3)
                end
            end
            task.wait(0.5)
        end
    end)
    coroutine.resume(AutoFarmCoroutine)
end

-- Rayfield UI Setup --
local Window = Rayfield:CreateWindow({
    Name = "MM2 Multi-Tool",
    LoadingTitle = "Loading MM2 Script...",
    LoadingSubtitle = "by ChatGPT + User",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MM2MultiToolConfigs",
        FileName = "UserConfig"
    },
    Discord = {
        Enabled = false,
    }
})

local MainTab = Window:CreateTab("Main")

-- ESP Toggles
MainTab:CreateToggle({
    Name = "Show Murderer ESP",
    CurrentValue = false,
    Flag = "MurdererESP",
    Callback = function(value)
        EspSettings.ShowMurderer = value
        EspSettings.ESPOn = value or EspSettings.ShowSheriff or EspSettings.ShowPlayers
        UpdateRolesESP()
    end,
})

MainTab:CreateToggle({
    Name = "Show Sheriff ESP",
    CurrentValue = false,
    Flag = "SheriffESP",
    Callback = function(value)
        EspSettings.ShowSheriff = value
        EspSettings.ESPOn = value or EspSettings.ShowMurderer or EspSettings.ShowPlayers
        UpdateRolesESP()
    end,
})

MainTab:CreateToggle({
    Name = "Show Other Players ESP",
    CurrentValue = false,
    Flag = "PlayersESP",
    Callback = function(value)
        EspSettings.ShowPlayers = value
        EspSettings.ESPOn = value or EspSettings.ShowMurderer or EspSettings.ShowSheriff
        UpdateRolesESP()
    end,
})

MainTab:CreateToggle({
    Name = "Show Names on ESP",
    CurrentValue = true,
    Flag = "NamesOnESP",
    Callback = function(value)
        EspSettings.ShowNames = value
        UpdateRolesESP()
    end,
})

MainTab:CreateToggle({
    Name = "Turn Off ESP",
    CurrentValue = false,
    Flag = "EspOff",
    Callback = function(value)
        if value then
            EspSettings.ShowMurderer = false
            EspSettings.ShowSheriff = false
            EspSettings.ShowPlayers = false
            EspSettings.ESPOn = false
            ClearESP()
            -- Reset toggles visually
            Window:UpdateToggle("MurdererESP", false)
            Window:UpdateToggle("SheriffESP", false)
            Window:UpdateToggle("PlayersESP", false)
        end
    end,
})

-- Coin Auto Farm toggle
MainTab:CreateToggle({
    Name = "Auto Coin Farm",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(value)
        CoinFarmActive = value
        if value then
            AutoFarm()
        else
            if AutoFarmCoroutine then
                coroutine.close(AutoFarmCoroutine)
                AutoFarmCoroutine = nil
            end
        end
    end,
})

-- Fly Toggle (simplified fly)
local FlyBodyGyro, FlyBodyVelocity
local function StartFly()
    if FlyActive then return end
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    FlyBodyGyro = Instance.new("BodyGyro", hrp)
    FlyBodyGyro.P = 9e4
    FlyBodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyGyro.cframe = hrp.CFrame

    FlyBodyVelocity = Instance.new("BodyVelocity", hrp)
    FlyBodyVelocity.velocity = Vector3.new(0,0,0)
    FlyBodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)

    FlyActive = true

    local SPEED = 50
    local CONTROL = {F=0,B=0,L=0,R=0}

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 1 end
        if input.KeyCode == Enum.KeyCode.S then CONTROL.B = -1 end
        if input.KeyCode == Enum.KeyCode.A then CONTROL.L = -1 end
        if input.KeyCode == Enum.KeyCode.D then CONTROL.R = 1 end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 0 end
        if input.KeyCode == Enum.KeyCode.S then CONTROL.B = 0 end
        if input.KeyCode == Enum.KeyCode.A then CONTROL.L = 0 end
        if input.KeyCode == Enum.KeyCode.D then CONTROL.R = 0 end
    end)

    RunService:BindToRenderStep("FlyControl", Enum.RenderPriority.Character.Value, function()
        if not FlyActive then return end
        local moveDirection = (Workspace.CurrentCamera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + (Workspace.CurrentCamera.CFrame.RightVector * (CONTROL.R + CONTROL.L))
        FlyBodyVelocity.velocity = moveDirection * SPEED
        FlyBodyGyro.cframe = Workspace.CurrentCamera.CFrame
    end)
end

local function StopFly()
    FlyActive = false
    RunService:UnbindFromRenderStep("FlyControl")
    if FlyBodyGyro then FlyBodyGyro:Destroy() FlyBodyGyro = nil end
    if FlyBodyVelocity then FlyBodyVelocity:Destroy() FlyBodyVelocity = nil end
end

MainTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(value)
        if value then StartFly() else StopFly() end
    end,
})

-- Noclip (toggle)
local function SetNoclip(enabled)
    NoclipActive = enabled
end

RunService.Stepped:Connect(function()
    if NoclipActive then
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

MainTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(value)
        SetNoclip(value)
    end,
})

-- Godmode, Xray, BringGun features can be added similarly if you want

-- Keybinds for toggling features quickly
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.C then -- CoinFarm toggle
        CoinFarmActive = not CoinFarmActive
        Window:UpdateToggle("AutoFarm", CoinFarmActive)
        if CoinFarmActive then AutoFarm() else if AutoFarmCoroutine then coroutine.close(AutoFarmCoroutine) AutoFarmCoroutine=nil end end
    elseif input.KeyCode == Enum.KeyCode.M then -- Murderer ESP toggle
        EspSettings.ShowMurderer = not EspSettings.ShowMurderer
        Window:UpdateToggle("MurdererESP", EspSettings.ShowMurderer)
        UpdateRolesESP()
    elseif input.KeyCode == Enum.KeyCode.Q then -- Players ESP toggle
        EspSettings.ShowPlayers = not EspSettings.ShowPlayers
        Window:UpdateToggle("PlayersESP", EspSettings.ShowPlayers)
        UpdateRolesESP()
    elseif input.KeyCode == Enum.KeyCode.B then -- ESP off toggle
        EspSettings.ShowMurderer = false
        EspSettings.ShowSheriff = false
        EspSettings.ShowPlayers = false
        Window:UpdateToggle("MurdererESP", false)
        Window:UpdateToggle("SheriffESP", false)
        Window:UpdateToggle("PlayersESP", false)
        ClearESP()
    elseif input.KeyCode == Enum.KeyCode.F then -- Fly toggle
        FlyActive = not FlyActive
        Window:UpdateToggle("FlyToggle", FlyActive)
        if FlyActive then StartFly() else StopFly() end
    elseif input.KeyCode == Enum.KeyCode.R then -- Noclip toggle
        NoclipActive = not NoclipActive
        Window:UpdateToggle("NoclipToggle", NoclipActive)
    end
end)

-- Periodically update roles ESP to keep things accurate
spawn(function()
    while true do
        if EspSettings.ESPOn then
            UpdateRolesESP()
        end
        task.wait(2)
    end
end)
