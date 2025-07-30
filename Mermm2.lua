-- Mermm2 GUI Script Part 1: UI + Core Setup local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

local Window = Rayfield:CreateWindow({ Name = "Mermm2 | MM2 GUI", LoadingTitle = "Mermm2 Hub", LoadingSubtitle = "by Mer", ConfigurationSaving = { Enabled = true, FolderName = "Mermm2", FileName = "Mermm2Config" }, Discord = { Enabled = false }, KeySystem = false })

local Tabs = { Main = Window:CreateTab("Main", 4483362458), ESP = Window:CreateTab("ESP", 4483362458), Troll = Window:CreateTab("Troll", 4483362458), Utility = Window:CreateTab("Utility", 4483362458), Settings = Window:CreateTab("Settings", 4483362458) }

-- Mermm2 GUI Script Part 2: Main Features Tabs.Main:CreateToggle({ Name = "Auto Shoot Murderer", CurrentValue = false, Callback = function(Value) getgenv().AutoShoot = Value while getgenv().AutoShoot do task.wait(0.1) local players = game:GetService("Players"):GetPlayers() for _, plr in ipairs(players) do if plr.Character and plr.Character:FindFirstChild("Knife") then game:GetService("ReplicatedStorage")._network:FireServer("ShootGun", plr.Character:FindFirstChild("HumanoidRootPart").Position) end end end end })

Tabs.Main:CreateButton({ Name = "Teleport to Gun", Callback = function() for _,v in ipairs(workspace:GetChildren()) do if v.Name == "GunDrop" then game.Players.LocalPlayer.Character:PivotTo(v.CFrame) end end end })

Tabs.Main:CreateToggle({ Name = "Auto Collect Coins", CurrentValue = false, Callback = function(state) getgenv().AutoCollect = state while getgenv().AutoCollect do task.wait() for _, obj in pairs(workspace:GetChildren()) do if obj.Name == "Coin" then game.Players.LocalPlayer.Character:PivotTo(obj.CFrame) end end end end })

-- Mermm2 GUI Script Part 3: ESP + Troll Features Tabs.ESP:CreateToggle({ Name = "Enable ESP", CurrentValue = false, Callback = function(bool) for _, v in pairs(game.Players:GetPlayers()) do if v ~= game.Players.LocalPlayer then local char = v.Character if char and not char:FindFirstChild("ESP") then local esp = Instance.new("Highlight") esp.Name = "ESP" esp.FillColor = Color3.new(1, 0, 0) esp.FillTransparency = 0.5 esp.OutlineColor = Color3.new(1, 1, 1) esp.OutlineTransparency = 0 esp.Adornee = char esp.Parent = char end end end end })

Tabs.Troll:CreateButton({ Name = "Lay on Back", Callback = function() local anim = Instance.new("Animation") anim.AnimationId = "rbxassetid://282574440" -- lay down animation local hum = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") hum:LoadAnimation(anim):Play() end })

Tabs.Troll:CreateButton({ Name = "Fake Knife", Callback = function() local fake = Instance.new("Part", game.Players.LocalPlayer.Character) fake.Name = "FakeKnife" fake.Size = Vector3.new(1,1,1) fake.BrickColor = BrickColor.new("Bright red") fake.Material = Enum.Material.Neon fake.CFrame = game.Players.LocalPlayer.Character:FindFirstChild("RightHand").CFrame fake.Anchored = false fake.CanCollide = false fake.Massless = true local weld = Instance.new("WeldConstraint", fake) weld.Part0 = fake weld.Part1 = game.Players.LocalPlayer.Character:FindFirstChild("RightHand") end })

-- Mermm2 GUI Script Part 4: Utility Features Tabs.Utility:CreateToggle({ Name = "Anti Fling", CurrentValue = false, Callback = function(state) getgenv().AntiFling = state while getgenv().AntiFling do task.wait() local root = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if root and (root.Velocity.Magnitude > 100 or root.AssemblyAngularVelocity.Magnitude > 100) then root.Velocity = Vector3.zero root.AssemblyAngularVelocity = Vector3.zero end end end })

Tabs.Utility:CreateButton({ Name = "Low Graphics Mode", Callback = function() for _, v in pairs(game.Lighting:GetChildren()) do if v:IsA("PostEffect") then v.Enabled = false end end game.Lighting.GlobalShadows = false game.Lighting.FogEnd = 100000 end })

-- Mermm2 GUI Script Part 5: Settings + Final Tabs.Settings:CreateButton({ Name = "Destroy GUI", Callback = function() game:GetService("CoreGui"):FindFirstChild("RayfieldLibrary"):Destroy() end })
-- Mermm2 GUI Script Part 2: Advanced Role Logic + More Features

-- Role Revealer Tabs.Main:CreateToggle({ Name = "Reveal Roles", CurrentValue = false, Callback = function(State) getgenv().RevealRoles = State while getgenv().RevealRoles do task.wait(1) for _, plr in pairs(game.Players:GetPlayers()) do if plr.Character then local hasKnife = plr.Backpack:FindFirstChild("Knife") or (plr.Character:FindFirstChild("Knife") and true) local hasGun = plr.Backpack:FindFirstChild("Gun") or (plr.Character:FindFirstChild("Gun") and true) if hasKnife then print(plr.Name .. " is MURDERER") elseif hasGun then print(plr.Name .. " is SHERIFF") else print(plr.Name .. " is INNOCENT") end end end end end })

-- Auto Kill Everyone (Murderer Only) Tabs.Main:CreateToggle({ Name = "Kill All (as Murd)", CurrentValue = false, Callback = function(State) getgenv().KillAll = State while getgenv().KillAll do task.wait(0.2) local plr = game.Players.LocalPlayer if plr.Backpack:FindFirstChild("Knife") or plr.Character:FindFirstChild("Knife") then for _, target in pairs(game.Players:GetPlayers()) do if target ~= plr and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then plr.Character:PivotTo(target.Character.HumanoidRootPart.CFrame) task.wait(0.2) game.ReplicatedStorage._network:FireServer("KnifeHit", target.Character.HumanoidRootPart) end end end end end })

-- Mute Annoying Lobby Music Tabs.Utility:CreateButton({ Name = "Mute Lobby Music", Callback = function() for _, s in pairs(workspace:GetDescendants()) do if s:IsA("Sound") and s.IsPlaying and s.Volume > 0 then s.Volume = 0 end end end })

-- Remove Lobby Fog Tabs.Utility:CreateButton({ Name = "Remove Fog", Callback = function() game.Lighting.FogEnd = 9999999 game.Lighting.FogStart = 0 end })

-- Walkspeed Toggle Tabs.Utility:CreateSlider({ Name = "Walkspeed", Range = {16, 100}, Increment = 1, CurrentValue = 16, Callback = function(Value) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value end })

-- Jump Power Toggle Tabs.Utility:CreateSlider({ Name = "Jump Power", Range = {50, 200}, Increment = 1, CurrentValue = 50, Callback = function(Value) game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value end })

-- Free Camera View Tabs.Utility:CreateButton({ Name = "Free Cam View", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/MerToolIt/FreeCam/main/main.lua"))() end })
-- Mermm2 GUI Script Part 3: ESP, Troll, and Visual Tools

-- ESP Toggle (Box ESP) Tabs.ESP:CreateToggle({ Name = "Player ESP", CurrentValue = false, Callback = function(Value) getgenv().ESPEnabled = Value if Value then local RunService = game:GetService("RunService") getgenv().espConnections = {}

for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "Mermm2ESP"
                billboard.Size = UDim2.new(0, 100, 0, 20)
                billboard.AlwaysOnTop = true
                billboard.Adornee = player.Character:FindFirstChild("Head")

                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.Text = player.DisplayName
                textLabel.BackgroundTransparency = 1
                textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                textLabel.TextStrokeTransparency = 0.5
                textLabel.TextScaled = true
                textLabel.Parent = billboard
                billboard.Parent = player.Character:FindFirstChild("Head")
            end
        end
    else
        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Head") then
                local esp = player.Character.Head:FindFirstChild("Mermm2ESP")
                if esp then
                    esp:Destroy()
                end
            end
        end
    end
end

})

---- Mermm2 GUI Script Part 4: Silent Aim, Auto Tools, Low Graphics

-- Silent Aim (only targets Murderer) Tabs.Main:CreateToggle({ Name = "Silent Aim (Murder Only)", CurrentValue = false, Callback = function(Value) getgenv().SilentAimEnabled = Value end })

-- Hook Gun Tool local old; old = hookmetamethod(game, "__namecall", function(Self, ...) local args = {...} if SilentAimEnabled and getnamecallmethod() == "FireServer" and tostring(Self) == "ShootGun" then local players = game:GetService("Players") local target = nil for _,v in pairs(players:GetPlayers()) do if v ~= players.LocalPlayer and v.Character and v.Character:FindFirstChild("Knife") then target = v.Character:FindFirstChild("HumanoidRootPart") break end end if target then args[2] = target.Position return old(Self, unpack(args)) end end return old(Self, ...) end)

-- Low Graphics Mode (Toggle) Tabs.Utility:CreateToggle({ Name = "Low Graphics Mode", CurrentValue = false, Callback = function(Value) if Value then game:GetService("Lighting").FogEnd = 100 game:GetService("Lighting").Brightness = 1 game:GetService("Lighting").ColorCorrection.Enabled = false for _, v in pairs(workspace:GetDescendants()) do if v:IsA("Texture") or v:IsA("Decal") then v.Transparency = 1 elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end end else game:GetService("Lighting").FogEnd = 1000 game:GetService("Lighting").Brightness = 2 for _, v in pairs(workspace:GetDescendants()) do if v:IsA("Texture") or v:IsA("Decal") then v.Transparency = 0 elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = true end end end end })

-- Auto Tool Grab (Gun only) Tabs.Main:CreateToggle({ Name = "Auto Get Gun", CurrentValue = false, Callback = function(Value) getgenv().AutoGun = Value while AutoGun and wait(1) do local gun = workspace:FindFirstChild("GunDrop") if gun and game.Players.LocalPlayer.Character then game.Players.LocalPlayer.Character:PivotTo(gun.CFrame) end end end })
-- Mermm2 GUI Script Part 3: ESP, Troll, and Visual Tools

-- ESP Toggle (Box ESP) Tabs.ESP:CreateToggle({ Name = "Player ESP", CurrentValue = false, Callback = function(Value) getgenv().ESPEnabled = Value if Value then local RunService = game:GetService("RunService") getgenv().espConnections = {}

for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "Mermm2ESP"
                billboard.Size = UDim2.new(0, 100, 0, 20)
                billboard.AlwaysOnTop = true
                billboard.Adornee = player.Character:FindFirstChild("Head")

                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.Text = player.DisplayName
                textLabel.BackgroundTransparency = 1
                textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                textLabel.TextStrokeTransparency = 0.5
                textLabel.TextScaled = true
                textLabel.Parent = billboard
                billboard.Parent = player.Character:FindFirstChild("Head")
            end
        end
    else
        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Head") then
                local esp = player.Character.Head:FindFirstChild("Mermm2ESP")
                if esp then
                    esp:Destroy()
                end
            end
        end
    end
end

})

-- Troll Tab Features Tabs.Troll:CreateButton({ Name = "Lay Down (Fake Death)", Callback = function() local char = game.Players.LocalPlayer.Character if not char then return end char.Humanoid:ChangeState(Enum.HumanoidStateType.Physics) for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.Anchored = false part.Velocity = Vector3.new(0, -100, 0) end end end })

Tabs.Troll:CreateButton({ Name = "Explode Visual (No Damage)", Callback = function() local part = Instance.new("Part") part.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position part.Anchored = true part.Size = Vector3.new(1,1,1) part.Transparency = 1 part.Parent = workspace local explosion = Instance.new("Explosion") explosion.Position = part.Position explosion.BlastRadius = 0 explosion.BlastPressure = 0 explosion.Parent = part game.Debris:AddItem(part, 2) end })

Tabs.Troll:CreateButton({ Name = "Fake Chat Spam", Callback = function() for i = 1,5 do game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("I'M THE MURDERER!! jk", "All") wait(1.5) end end })
-- Mermm2 GUI Script Part 5: Extra Troll + Anti Features

-- Fake Chat Spammer Tabs.Troll:CreateButton({ Name = "Fake Hacker Spam", Callback = function() local plr = game.Players.LocalPlayer for i = 1, 10 do game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Stop hacking bro wth", "All") wait(1) end end })

-- Explosion Troll (Visual Only) Tabs.Troll:CreateButton({ Name = "Explosion Effect", Callback = function() local boom = Instance.new("Explosion") boom.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position boom.BlastPressure = 0 boom.BlastRadius = 0 boom.Parent = workspace end })

-- Anti AFK local vu = game:GetService("VirtualUser") game:GetService("Players").LocalPlayer.Idled:Connect(function() vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame) wait(1) vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame) end)

-- Anti Fling (Safe) Tabs.Utility:CreateToggle({ Name = "Anti Fling", CurrentValue = false, Callback = function(Value) getgenv().AntiFling = Value while AntiFling do for _,v in pairs(game:GetService("Players"):GetPlayers()) do if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then v.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0) v.Character.HumanoidRootPart.RotVelocity = Vector3.new(0,0,0) end end task.wait(0.5) end end })

-- UI Destroy Button Tabs.Settings:CreateButton({ Name = "Destroy GUI", Callback = function() game:GetService("CoreGui"):FindFirstChild("RayfieldUI"):Destroy() end })



