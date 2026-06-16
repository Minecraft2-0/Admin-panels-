--// ULTIMATE REWRITTEN ADMIN PANEL (IMMEDIATE PARENTING FIX) //--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Жесткое удаление старых копий перед запуском нового кода
if playerGui:FindFirstChild("AdminPanel") then
    playerGui.AdminPanel:Destroy()
end

--// 1. МГНОВЕННОЕ СОЗДАНИЕ И ПОДКЛЮЧЕНИЕ ОСНОВЫ GUI //--
local gui = Instance.new("ScreenGui")
gui.Name = "AdminPanel"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui -- Сразу отправляем в игру!

--// 2. МГНОВЕННОЕ СОЗДАНИЕ ГЛАВНОГО ОКНА //--
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 240, 0, 340)
frame.Position = UDim2.new(0.35, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 0, 40)
frame.Active = true
frame.Draggable = true
frame.ZIndex = 1
frame.Parent = gui -- Сразу активируем отображение фрейма!

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 14)
frameCorner.Parent = frame

-- Заголовок панели
local title = Instance.new("TextLabel")
title.Name = "TitleLabel"
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.Text = "⚡ ADMIN PANEL ⚡"
title.TextColor3 = Color3.fromRGB(190, 80, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.ZIndex = 2
title.Parent = frame

-- Кнопка закрытия (Крестик)
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 7)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.ZIndex = 3
closeBtn.Parent = frame

-- Круглая плавающая кнопка открытия (Молния)
local openIndicator = Instance.new("TextButton")
openIndicator.Name = "OpenIndicator"
openIndicator.Size = UDim2.new(0, 55, 0, 55)
openIndicator.Position = UDim2.new(0, 15, 0, 15)
openIndicator.BackgroundColor3 = Color3.fromRGB(25, 0, 40)
openIndicator.Text = "⚡"
openIndicator.TextColor3 = Color3.fromRGB(190, 80, 255)
openIndicator.Font = Enum.Font.GothamBold
openIndicator.TextSize = 26
openIndicator.Visible = false
openIndicator.ZIndex = 5
openIndicator.Parent = gui

local indicatorCorner = Instance.new("UICorner")
indicatorCorner.CornerRadius = UDim.new(1, 0)
indicatorCorner.Parent = openIndicator

local indicatorStroke = Instance.new("UIStroke")
indicatorStroke.Color = Color3.fromRGB(190, 80, 255)
indicatorStroke.Width = 2
indicatorStroke.Parent = openIndicator

-- Логика сворачивания интерфейса
closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    openIndicator.Visible = true
end)

openIndicator.MouseButton1Click:Connect(function()
    frame.Visible = true
    openIndicator.Visible = false
end)

--// ФУНКЦИЯ СОЗДАНИЯ КНОПОК ВНУТРИ АКТИВНОГО ФРЕЙМА //--
local function createMenuButton(text, yPos)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 200, 0, 40)
    b.Position = UDim2.new(0, 20, 0, yPos)
    b.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Text = text
    b.ZIndex = 10
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = b
    
    b.Parent = frame -- Кнопка рендерится мгновенно
    return b
end

--// НАСТРОЙКИ СИСТЕМ ИЛОГИКА ФУНКЦИЙ //--
local flying = false
local noclip = false
local esp = false
local spinning = false

local flyVel = nil
local flyGyro = nil
local spinVelocity = nil
local highlights = {}

local function getCharacterData()
    local c = player.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    return c, hrp, hum
end

-- Мобильный полет (Fly) по вектору камеры
local function handleFlyLogic()
    if not flying then return end
    local _, hrp, _ = getCharacterData()
    if not hrp then return end

    local cam = workspace.CurrentCamera
    
    if not flyVel or flyVel.Parent ~= hrp then
        flyVel = Instance.new("BodyVelocity")
        flyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        flyVel.Parent = hrp
    end
    if not flyGyro or flyGyro.Parent ~= hrp then
        flyGyro = Instance.new("BodyGyro")
        flyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        flyGyro.Parent = hrp
    end

    flyGyro.CFrame = cam.CFrame

    local moveVector = UIS:GetMoveVector()
    if moveVector.Magnitude > 0 then
        local direction = (cam.CFrame.RightVector * moveVector.X) + (cam.CFrame.LookVector * -moveVector.Z)
        flyVel.Velocity = direction.Unit * 80
    else
        flyVel.Velocity = Vector3.new(0, 0, 0)
    end
end

-- Система подсветки (ESP)
local function applyESP(char)
    if highlights[char] then return end
    if not char:FindFirstChild("HumanoidRootPart") then return end

    local h = Instance.new("Highlight")
    h.FillColor = Color3.fromRGB(180, 0, 255)
    h.OutlineColor = Color3.fromRGB(255, 255, 255)
    h.FillTransparency = 0.5
    h.Parent = char

    highlights[char] = h
end

local function cleanESP()
    for _, h in pairs(highlights) do
        if h then pcall(function() h:Destroy() end) end
    end
    highlights = {}
end

--// ДОБАВЛЕНИЕ ВСЕХ КНОПОК ПО ФИКСИРОВАННЫМ СЛОЯМ И ВЫСОТЕ //--

-- 1. ПОЛЕТ (Y = 55)
local flyBtn = createMenuButton("Fly: OFF", 55)
flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        flyBtn.Text = "Fly: ON"
        flyBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
    else
        flyBtn.Text = "Fly: OFF"
        flyBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
        if flyVel then flyVel:Destroy() flyVel = nil end
        if flyGyro then flyGyro:Destroy() flyGyro = nil end
    end
end)

-- 2. НОКЛИП (Y = 110)
local noclipBtn = createMenuButton("Noclip: OFF", 110)
noclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    if noclip then
        noclipBtn.Text = "Noclip: ON"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
    else
        noclipBtn.Text = "Noclip: OFF"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
    end
end)

-- 3. КРУТИЛКА-ФЛИНГ (Y = 165)
local flingBtn = createMenuButton("Fling (Spin): OFF", 165)
flingBtn.MouseButton1Click:Connect(function()
    spinning = not spinning
    local _, hrp, _ = getCharacterData()

    if spinning and hrp then
        flingBtn.Text = "Fling: ON"
        flingBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)

        spinVelocity = Instance.new("BodyAngularVelocity")
        spinVelocity.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        spinVelocity.AngularVelocity = Vector3.new(0, 800, 0)
        spinVelocity.Parent = hrp
    else
        flingBtn.Text = "Fling: OFF"
        flingBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
        if spinVelocity then spinVelocity:Destroy() spinVelocity = nil end
    end
end)

-- 4. ЕСП СИСТЕМА (Y = 220)
local espBtn = createMenuButton("ESP: OFF", 220)
espBtn.MouseButton1Click:Connect(function()
    esp = not esp
    if esp then
        espBtn.Text = "ESP: ON"
        espBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
    else
        espBtn.Text = "ESP: OFF"
        espBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
        cleanESP()
    end
end)

-- 5. МЕГА СКОРОСТЬ И ПРЫЖОК (Y = 275)
local funnyBtn = createMenuButton("😂 FUN SPEED/JUMP", 275)
funnyBtn.MouseButton1Click:Connect(function()
    local _, _, hum = getCharacterData()
    if hum then
        hum.WalkSpeed = 120
        hum.JumpPower = 180
        pcall(function() hum.UseJumpPower = true end)
    end
end)

--// ИСПОЛНИТЕЛЬНЫЕ РАБОЧИЕ ЦИКЛЫ //--
RunService.Stepped:Connect(function()
    handleFlyLogic()
    
    local char, _, _ = getCharacterData()
    if noclip and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

task.spawn(function()
    while true do
        if esp then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    applyESP(p.Character)
                end
            end
        else
            cleanESP()
        end
        task.wait(1.5)
    end
end)

print("--- [ADMIN PANEL LOADED SUCCESSFULLY] ---")
