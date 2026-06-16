--// ANTI-BUG STATIC ADMIN PANEL (NO TOGGLES, DIRECT RENDER) //--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Полная зачистка старых панелей перед стартом
if playerGui:FindFirstChild("StaticAdminPanel") then
    playerGui.StaticAdminPanel:Destroy()
end

--// 1. МГНОВЕННЫЙ ВЫВОД GUI В ИГРУ //--
local gui = Instance.new("ScreenGui")
gui.Name = "StaticAdminPanel"
gui.ResetOnSpawn = false
gui.Parent = playerGui

--// 2. СОЗДАНИЕ СТАТИЧНОГО ОКНА //--
-- Разместил чуть левее (0.1), чтобы панель не перекрывала центр экрана мобилки
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 240, 0, 290)
frame.Position = UDim2.new(0.1, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 0, 40)
frame.Active = true
frame.Draggable = true -- Можно двигать пальцем в любое место экрана
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

-- Простой статичный заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "⚡ ADMIN PANEL ⚡"
title.TextColor3 = Color3.fromRGB(190, 80, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

--// 3. ШАБЛОН ДЛЯ ПРЯМОЙ ОТРИСОВКИ КНОПОК //--
local function createMenuButton(text, yPos)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 200, 0, 38)
    b.Position = UDim2.new(0, 20, 0, yPos)
    b.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.Text = text
    b.Parent = frame -- Кнопка парентится сразу в активный фрейм
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = b
    
    return b
end

--// ПЕРЕМЕННЫЕ ФУНКЦИЙ //--
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

--// РАССТАНОВКА КНОПОК БЕЗ ЛИШНИХ СЛОЕВ //--

-- 1. FLY (Y = 45)
local flyBtn = createMenuButton("Fly: OFF", 45)
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

-- 2. NOCLIP (Y = 90)
local noclipBtn = createMenuButton("Noclip: OFF", 90)
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

-- 3. SPIN FLING (Y = 135)
local flingBtn = createMenuButton("Fling (Spin): OFF", 135)
flingBtn.MouseButton1Click:Connect(function()
    spinning = not spinning
    local _, hrp, _ = getCharacterData()

    if spinning and hrp then
        flingBtn.Text = "Fling: ON"
        flingBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)

        spinVelocity = Instance.new("BodyAngularVelocity")
        spinVelocity.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        spinVelocity.AngularVelocity = Vector3.new(0, 850, 0)
        spinVelocity.Parent = hrp
    else
        flingBtn.Text = "Fling: OFF"
        flingBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
        if spinVelocity then spinVelocity:Destroy() spinVelocity = nil end
    end
end)

-- 4. ESP HIGHLIGHT (Y = 180)
local espBtn = createMenuButton("ESP: OFF", 180)
espBtn.MouseButton1Click:Connect(function()
    esp = not esp
    if esp then
        espBtn.Text = "ESP: ON"
        espBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
    else
        espBtn.Text = "ESP: OFF"
        espBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
        for _, h in pairs(highlights) do if h then pcall(function() h:Destroy() end) end end
        highlights = {}
    end
end)

-- 5. FUN BOOST (Y = 225)
local funnyBtn = createMenuButton("😂 FUN SPEED/JUMP", 225)
funnyBtn.MouseButton1Click:Connect(function()
    local _, _, hum = getCharacterData()
    if hum then
        hum.WalkSpeed = 120
        hum.JumpPower = 180
        pcall(function() hum.UseJumpPower = true end)
    end
end)

--// СИСТЕМНЫЕ ПОТОКИ ФУНКЦИЙ //--
RunService.Stepped:Connect(function()
    -- Обработка полета через камеру и джойстик
    if flying then
        local _, hrp, _ = getCharacterData()
        if hrp then
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
    end

    -- Обработка Ноклипа
    local char, _, _ = getCharacterData()
    if noclip and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Поток обновления ESP
task.spawn(function()
    while true do
        if esp then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and not highlights[p.Character] then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local h = Instance.new("Highlight")
                        h.FillColor = Color3.fromRGB(180, 0, 255)
                        h.OutlineColor = Color3.fromRGB(255, 255, 255)
                        h.FillTransparency = 0.5
                        h.Parent = p.Character
                        highlights[p.Character] = h
                    end
                end
            end
        else
            for _, h in pairs(highlights) do if h then pcall(function() h:Destroy() end) end end
            highlights = {}
        end
        task.wait(1.5)
    end
end)
