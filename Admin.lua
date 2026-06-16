--// ULTIMATE RAW ADMIN PANEL (ZERO BULLSHIT EDITION) //--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- Пытаемся закинуть в CoreGui (защита от античита и багов), если не выйдет — в PlayerGui
local targetGui = nil
pcall(function() targetGui = CoreGui end)
if not targetGui then
    targetGui = player:WaitForChild("PlayerGui")
end

-- Жесткая зачистка
if targetGui:FindFirstChild("RawAdminPanel") then
    targetGui.RawAdminPanel:Destroy()
end

--// 1. СОЗДАЕМ ВСЁ В ПАМЯТИ (БЕЗ ВЫВОДА НА ЭКРАН) //--
local gui = Instance.new("ScreenGui")
gui.Name = "RawAdminPanel"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 220, 0, 320)
frame.Position = UDim2.new(0.1, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderColor3 = Color3.fromRGB(255, 0, 0) -- Красная рамка для стиля
frame.BorderSizePixel = 2
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ADMIN PANEL"
title.TextColor3 = Color3.fromRGB(255, 0, 0)
title.Font = Enum.Font.SourceSansBold -- Самый базовый шрифт, который не крашнет
title.TextSize = 20
title.Parent = frame

--// 2. ХАРДКОДИМ КАЖДУЮ КНОПКУ ОТДЕЛЬНО //--

-- Кнопка Fly
local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(0, 180, 0, 40)
flyBtn.Position = UDim2.new(0, 20, 0, 50)
flyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyBtn.Text = "Fly: OFF"
flyBtn.Font = Enum.Font.SourceSansBold
flyBtn.TextSize = 16
flyBtn.Parent = frame

-- Кнопка Noclip
local noclipBtn = Instance.new("TextButton")
noclipBtn.Size = UDim2.new(0, 180, 0, 40)
noclipBtn.Position = UDim2.new(0, 20, 0, 100)
noclipBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
noclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
noclipBtn.Text = "Noclip: OFF"
noclipBtn.Font = Enum.Font.SourceSansBold
noclipBtn.TextSize = 16
noclipBtn.Parent = frame

-- Кнопка Fling
local flingBtn = Instance.new("TextButton")
flingBtn.Size = UDim2.new(0, 180, 0, 40)
flingBtn.Position = UDim2.new(0, 20, 0, 150)
flingBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
flingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flingBtn.Text = "Spin Fling: OFF"
flingBtn.Font = Enum.Font.SourceSansBold
flingBtn.TextSize = 16
flingBtn.Parent = frame

-- Кнопка ESP
local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(0, 180, 0, 40)
espBtn.Position = UDim2.new(0, 20, 0, 200)
espBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
espBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espBtn.Text = "ESP: OFF"
espBtn.Font = Enum.Font.SourceSansBold
espBtn.TextSize = 16
espBtn.Parent = frame

-- Кнопка Speed/Jump
local funnyBtn = Instance.new("TextButton")
funnyBtn.Size = UDim2.new(0, 180, 0, 40)
funnyBtn.Position = UDim2.new(0, 20, 0, 250)
funnyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
funnyBtn.TextColor3 = Color3.fromRGB(255, 210, 0)
funnyBtn.Text = "SPEED & JUMP BOOST"
funnyBtn.Font = Enum.Font.SourceSansBold
funnyBtn.TextSize = 16
funnyBtn.Parent = frame

--// 3. ВЫВОД НА ЭКРАН (ТОЛЬКО ПОСЛЕ ТОГО, КАК ВСЁ СОБРАНО) //--
gui.Parent = targetGui

--// 4. ЛОГИКА ЧИТОВ И ПЕРЕМЕННЫЕ //--
local flying = false
local noclip = false
local spinning = false
local esp = false

local flyVel = nil
local flyGyro = nil
local spinVel = nil
local espBoxes = {}

-- Fly Логика
flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        flyBtn.Text = "Fly: ON"
        flyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        flyBtn.Text = "Fly: OFF"
        flyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        if flyVel then flyVel:Destroy() flyVel = nil end
        if flyGyro then flyGyro:Destroy() flyGyro = nil end
    end
end)

-- Noclip Логика
noclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    if noclip then
        noclipBtn.Text = "Noclip: ON"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        noclipBtn.Text = "Noclip: OFF"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

-- Fling Логика
flingBtn.MouseButton1Click:Connect(function()
    spinning = not spinning
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if spinning and hrp then
        flingBtn.Text = "Spin Fling: ON"
        flingBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        spinVel = Instance.new("BodyAngularVelocity")
        spinVel.MaxTorque = Vector3.new(100000, 100000, 100000)
        spinVel.AngularVelocity = Vector3.new(0, 1000, 0)
        spinVel.Parent = hrp
    else
        flingBtn.Text = "Spin Fling: OFF"
        flingBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        if spinVel then spinVel:Destroy() spinVel = nil end
    end
end)

-- ESP Логика (Безопасная версия без Highlight, который тоже может крашить)
espBtn.MouseButton1Click:Connect(function()
    esp = not esp
    if esp then
        espBtn.Text = "ESP: ON"
        espBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        espBtn.Text = "ESP: OFF"
        espBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        for _, box in pairs(espBoxes) do
            if box then box:Destroy() end
        end
        espBoxes = {}
    end
end)

-- Speed Логика
funnyBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = 100
        hum.JumpPower = 150
        pcall(function() hum.UseJumpPower = true end)
    end
end)

--// 5. РАБОЧИЕ ЦИКЛЫ //--
RunService.RenderStepped:Connect(function()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    -- Fly
    if flying and hrp then
        local cam = workspace.CurrentCamera
        if not flyVel or not flyVel.Parent then
            flyVel = Instance.new("BodyVelocity")
            flyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            flyVel.Parent = hrp
        end
        if not flyGyro or not flyGyro.Parent then
            flyGyro = Instance.new("BodyGyro")
            flyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            flyGyro.Parent = hrp
        end
        
        flyGyro.CFrame = cam.CFrame
        local moveVector = UIS:GetMoveVector()
        if moveVector.Magnitude > 0 then
            local dir = (cam.CFrame.RightVector * moveVector.X) + (cam.CFrame.LookVector * -moveVector.Z)
            flyVel.Velocity = dir.Unit * 80
        else
            flyVel.Velocity = Vector3.new(0, 0, 0)
        end
    end
    
    -- Noclip
    if noclip then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ESP Цикл (создает BillboardGui вместо Highlight для максимальной совместимости)
task.spawn(function()
    while task.wait(1) do
        if esp then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    if not hrp:FindFirstChild("ESP_BOX") then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "ESP_BOX"
                        billboard.Size = UDim2.new(4, 0, 5.5, 0)
                        billboard.AlwaysOnTop = true
                        
                        local frame = Instance.new("Frame")
                        frame.Size = UDim2.new(1, 0, 1, 0)
                        frame.BackgroundTransparency = 0.5
                        frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                        frame.Parent = billboard
                        
                        billboard.Parent = hrp
                        table.insert(espBoxes, billboard)
                    end
                end
            end
        end
    end
end)
