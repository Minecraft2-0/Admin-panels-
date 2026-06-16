--// FULL UNABRIDGED FIXED ADMIN PANEL (DIRECT RENDERING FOR MOBILE) //--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Полная очистка предыдущих копий GUI, чтобы не наслаивались
if playerGui:FindFirstChild("AdminPanel") then
    playerGui.AdminPanel:Destroy()
end

--// ИНИЦИАЛИЗАЦИЯ ИНТЕРФЕЙСА //--
local gui = Instance.new("ScreenGui", playerGui)
gui.Name = "AdminPanel"
gui.ResetOnSpawn = false

-- Главный фрейм панели (Размеры оптимизированы, чтобы вместить все кнопки)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 320)
frame.Position = UDim2.new(0.35, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 0, 40)
frame.Active = true
frame.Draggable = true

local frameCorner = Instance.new("UICorner", frame)
frameCorner.CornerRadius = UDim.new(0, 14)

-- Заголовок панели
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.Text = "⚡ ADMIN PANEL ⚡"
title.TextColor3 = Color3.fromRGB(190, 80, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- Кнопка закрытия (Крестик)
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 7)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20

-- Иконка открытия (Маленькая круглая кнопка-молния на экране)
local openIndicator = Instance.new("TextButton", gui)
openIndicator.Size = UDim2.new(0, 55, 0, 55)
openIndicator.Position = UDim2.new(0, 15, 0, 15)
openIndicator.BackgroundColor3 = Color3.fromRGB(25, 0, 40)
openIndicator.Text = "⚡"
openIndicator.TextColor3 = Color3.fromRGB(190, 80, 255)
openIndicator.Font = Enum.Font.GothamBold
openIndicator.TextSize = 26
openIndicator.Visible = false

local indicatorCorner = Instance.new("UICorner", openIndicator)
indicatorCorner.CornerRadius = UDim.new(1, 0)

local indicatorStroke = Instance.new("UIStroke", openIndicator)
indicatorStroke.Color = Color3.fromRGB(190, 80, 255)
indicatorStroke.Width = 2

-- Логика скрытия и показа основного окна
closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    openIndicator.Visible = true
end)

openIndicator.MouseButton1Click:Connect(function()
    frame.Visible = true
    openIndicator.Visible = false
end)

-- Функция создания кнопок НАПРЯМУЮ во Frame (Защита от багов мобильного рендера)
local function createButton(text, yPosition)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0.9, 0, 0, 40)
    b.Position = UDim2.new(0.05, 0, 0, yPosition)
    b.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Text = text
    
    local buttonCorner = Instance.new("UICorner", b)
    buttonCorner.CornerRadius = UDim.new(0, 10)
    
    return b
end

--// ИГРОВЫЕ ПЕРЕМЕННЫЕ И СОСТОЯНИЯ //--
local flying = false
local noclip = false
local esp = false
local spinning = false

local flyVel = nil
local flyGyro = nil
local spinVelocity = nil
local highlights = {}

-- Поиск компонентов персонажа
local function getCharAndParts()
    local c = player.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    return c, hrp, hum
end

--// ПОЛНАЯ МОБИЛЬНАЯ ЛОГИКА ПОЛЕТА (FLY) //--
local function handleFlying()
    if not flying then return end
    local _, hrp, _ = getCharAndParts()
    if not hrp then return end

    local cam = workspace.CurrentCamera
    
    if not flyVel or flyVel.Parent ~= hrp then
        flyVel = Instance.new("BodyVelocity", hrp)
        flyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    end
    if not flyGyro or flyGyro.Parent ~= hrp then
        flyGyro = Instance.new("BodyGyro", hrp)
        flyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
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

--// ЛОГИКА СИСТЕМЫ ESP //--
local function addESP(char)
    if highlights[char] then return end
    if not char:FindFirstChild("HumanoidRootPart") then return end

    local h = Instance.new("Highlight")
    h.FillColor = Color3.fromRGB(180, 0, 255)
    h.OutlineColor = Color3.fromRGB(255, 255, 255)
    h.FillTransparency = 0.5
    h.Parent = char

    highlights[char] = h
end

local function clearESP()
    for _, h in pairs(highlights) do
        if h then pcall(function() h:Destroy() end) end
    end
    highlights = {}
end

local function refreshESP()
    if not esp then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            addESP(p.Character)
        end
    end
end

--// СОЗДАНИЕ КНОПОК НА ПРЯМЫХ КООРДИНАТАХ Y //--

-- 1. Кнопка Полета
local flyBtn = createButton("Fly: OFF", 50)
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

-- 2. Кнопка Ноклипа
local noclipBtn = createButton("Noclip: OFF", 100)
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

-- 3. Кнопка Жесткого Флинга (Крутилка торса)
local flingBtn = createButton("Fling (Spin): OFF", 150)
flingBtn.MouseButton1Click:Connect(function()
    spinning = not spinning
    local _, hrp, _ = getCharAndParts()

    if spinning and hrp then
        flingBtn.Text = "Fling: ON"
        flingBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)

        spinVelocity = Instance.new("AngularVelocity", hrp)
        spinVelocity.Attachment0 = hrp:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", hrp)
        spinVelocity.AngularVelocity = Vector3.new(0, 600, 0)
        spinVelocity.MaxTorque = 1e9
    else
        flingBtn.Text = "Fling: OFF"
        flingBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
        if spinVelocity then spinVelocity:Destroy() spinVelocity = nil end
    end
end)

-- 4. Кнопка Системы ESP
local espBtn = createButton("ESP: OFF", 200)
espBtn.MouseButton1Click:Connect(function()
    esp = not esp
    if esp then
        espBtn.Text = "ESP: ON"
        espBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
    else
        espBtn.Text = "ESP: OFF"
        espBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
        clearESP()
    end
end)

-- 5. Кнопка Кастомного Fun Набора
local funnyBtn = createButton("😂 FUN SPEED/JUMP", 250)
funnyBtn.MouseButton1Click:Connect(function()
    local _, _, hum = getCharAndParts()
    if hum then
        hum.WalkSpeed = 120
        hum.JumpPower = 180
        pcall(function() hum.UseJumpPower = true end)
    end
end)

--// СИСТЕМНЫЕ ЦИКЛЫ //--

RunService.Stepped:Connect(function()
    handleFlying()
    
    local char, _, _ = getCharAndParts()
    if noclip and char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

task.spawn(function()
    while true do
        if esp then 
            refreshESP() 
        else 
            clearESP() 
        end
        task.wait(1.5)
    end
end)
