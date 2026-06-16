--// ULTIMATE RGB ADMIN PANEL //--

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Пытаемся закинуть в CoreGui, если экзекутор не дает - кидаем в PlayerGui
local targetGui = pcall(function() return CoreGui end) and CoreGui or player:WaitForChild("PlayerGui")

if targetGui:FindFirstChild("RGBAdminPanel") then
    targetGui.RGBAdminPanel:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "RGBAdminPanel"
gui.ResetOnSpawn = false
gui.Parent = targetGui

--// 1. ДИЗАЙН: ОСНОВНОЙ ФРЕЙМ //--
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 360)
frame.Position = UDim2.new(0.1, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(45, 10, 65) -- Сочный темно-фиолетовый фон
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Скругления
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

-- РГБ Обводка
local rgbStroke = Instance.new("UIStroke")
rgbStroke.Thickness = 3
rgbStroke.Parent = frame

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "⚡ RGB ADMIN ⚡"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

local titleStroke = Instance.new("UIStroke")
titleStroke.Thickness = 1
titleStroke.Parent = title

-- Скроллинг для кнопок (чтобы вместилось вообще всё)
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -10, 1, -50)
scroll.Position = UDim2.new(0, 5, 0, 40)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0, 0, 0, 400) -- Место под будущие кнопки
scroll.Parent = frame

-- Автоматическая расстановка кнопок
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = scroll

--// 2. ГЕНЕРАТОР КНОПОК //--
local function createBtn(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(80, 20, 110) -- Светло-фиолетовый
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Text = text
    btn.Parent = scroll
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    return btn
end

-- Создаем кнопки
local flyBtn = createBtn("Fly: OFF")
local noclipBtn = createBtn("Noclip: OFF")
local espBtn = createBtn("ESP Boxes: OFF")
local flingBtn = createBtn("Spin Fling: OFF")
local infJumpBtn = createBtn("Inf Jump: OFF")
local hitboxBtn = createBtn("Big Hitboxes: OFF")
local speedBtn = createBtn("⚡ Boost Speed/Jump")
local btoolsBtn = createBtn("🛠️ Give Btools")

--// 3. ЛОГИКА ФУНКЦИЙ //--
local flying, noclip, esp, spinning, infJump, bigHitboxes = false, false, false, false, false, false
local flyVel, flyGyro, spinVel
local espBoxes = {}

-- FLY (Адаптирован под мобильный джойстик)
flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    flyBtn.Text = "Fly: " .. (flying and "ON" or "OFF")
    flyBtn.BackgroundColor3 = flying and Color3.fromRGB(120, 40, 160) or Color3.fromRGB(80, 20, 110)
end)

-- NOCLIP
noclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    noclipBtn.Text = "Noclip: " .. (noclip and "ON" or "OFF")
    noclipBtn.BackgroundColor3 = noclip and Color3.fromRGB(120, 40, 160) or Color3.fromRGB(80, 20, 110)
end)

-- ESP BOXES
espBtn.MouseButton1Click:Connect(function()
    esp = not esp
    espBtn.Text = "ESP Boxes: " .. (esp and "ON" or "OFF")
    espBtn.BackgroundColor3 = esp and Color3.fromRGB(120, 40, 160) or Color3.fromRGB(80, 20, 110)
    if not esp then
        for _, box in pairs(espBoxes) do if box then box:Destroy() end end
        espBoxes = {}
    end
end)

-- SPIN FLING
flingBtn.MouseButton1Click:Connect(function()
    spinning = not spinning
    flingBtn.Text = "Spin Fling: " .. (spinning and "ON" or "OFF")
    flingBtn.BackgroundColor3 = spinning and Color3.fromRGB(120, 40, 160) or Color3.fromRGB(80, 20, 110)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if spinning and hrp then
        spinVel = Instance.new("BodyAngularVelocity", hrp)
        spinVel.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        spinVel.AngularVelocity = Vector3.new(0, 1200, 0)
    else
        if spinVel then spinVel:Destroy() spinVel = nil end
    end
end)

-- INF JUMP
infJumpBtn.MouseButton1Click:Connect(function()
    infJump = not infJump
    infJumpBtn.Text = "Inf Jump: " .. (infJump and "ON" or "OFF")
    infJumpBtn.BackgroundColor3 = infJump and Color3.fromRGB(120, 40, 160) or Color3.fromRGB(80, 20, 110)
end)

UIS.JumpRequest:Connect(function()
    if infJump and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- BIG HITBOXES (Расширяет врагов)
hitboxBtn.MouseButton1Click:Connect(function()
    bigHitboxes = not bigHitboxes
    hitboxBtn.Text = "Big Hitboxes: " .. (bigHitboxes and "ON" or "OFF")
    hitboxBtn.BackgroundColor3 = bigHitboxes and Color3.fromRGB(120, 40, 160) or Color3.fromRGB(80, 20, 110)
    if not bigHitboxes then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                p.Character.HumanoidRootPart.Transparency = 1
            end
        end
    end
end)

-- SPEED & JUMP BOOST
speedBtn.MouseButton1Click:Connect(function()
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = 120
        hum.JumpPower = 150
        pcall(function() hum.UseJumpPower = true end)
    end
end)

-- BTOOLS
btoolsBtn.MouseButton1Click:Connect(function()
    local tools = {"Clone", "Hammer", "Grab"}
    for _, tool in pairs(tools) do
        local bin = Instance.new("HopperBin")
        bin.BinType = Enum.BinType[tool]
        bin.Parent = player.Backpack
    end
end)

--// 4. ГЛАВНЫЙ ЦИКЛ РЕНДЕРА И РГБ ПЕРЕЛИВАНИЯ //--
local hue = 0
RunService.RenderStepped:Connect(function(dt)
    -- Плавное РГБ переливание рамки
    hue = hue + dt * 0.3
    if hue > 1 then hue = 0 end
    local rainbow = Color3.fromHSV(hue, 1, 1)
    rgbStroke.Color = rainbow
    titleStroke.Color = rainbow

    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    -- Мобильный Флай (Работает от джойстика)
    if flying and hrp and hum then
        hum.PlatformStand = true
        if not flyVel or flyVel.Parent ~= hrp then
            if flyVel then flyVel:Destroy() end
            flyVel = Instance.new("BodyVelocity", hrp)
            flyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        end
        if not flyGyro or flyGyro.Parent ~= hrp then
            if flyGyro then flyGyro:Destroy() end
            flyGyro = Instance.new("BodyGyro", hrp)
            flyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        end
        
        local cam = workspace.CurrentCamera
        flyGyro.CFrame = cam.CFrame
        
        -- Если тянешь джойстик - летишь туда, куда направлена камера
        if hum.MoveDirection.Magnitude > 0 then
            flyVel.Velocity = cam.CFrame.LookVector * 65
        else
            flyVel.Velocity = Vector3.new(0, 0, 0)
        end
    else
        if hum then hum.PlatformStand = false end
        if flyVel then flyVel:Destroy() flyVel = nil end
        if flyGyro then flyGyro:Destroy() flyGyro = nil end
    end

    -- Ноклип
    if noclip then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    -- Гигантские Хитбоксы
    if bigHitboxes then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local eHrp = p.Character.HumanoidRootPart
                eHrp.Size = Vector3.new(15, 15, 15)
                eHrp.Transparency = 0.7
                eHrp.BrickColor = BrickColor.new("Bright blue")
                eHrp.Material = Enum.Material.Neon
                eHrp.CanCollide = false
            end
        end
    end
end)

-- ESP Цикл
task.spawn(function()
    while task.wait(0.5) do
        if esp then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    if not hrp:FindFirstChild("ESP_BOX") then
                        local billboard = Instance.new("BillboardGui", hrp)
                        billboard.Name = "ESP_BOX"
                        billboard.Size = UDim2.new(4, 0, 5.5, 0)
                        billboard.AlwaysOnTop = true
                        
                        local box = Instance.new("Frame", billboard)
                        box.Size = UDim2.new(1, 0, 1, 0)
                        box.BackgroundTransparency = 0.5
                        box.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                        
                        table.insert(espBoxes, billboard)
                    end
                end
            end
        end
    end
end)
