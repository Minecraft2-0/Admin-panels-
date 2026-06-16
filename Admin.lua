--// FULL ADMIN PANEL + ESP + FUN SYSTEM (STABLE FIXED) //--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Удаляем старый GUI при перезапуске
if playerGui:FindFirstChild("AdminPanel") then
    playerGui.AdminPanel:Destroy()
end

--// GUI //--
local gui = Instance.new("ScreenGui", playerGui)
gui.Name = "AdminPanel"
gui.ResetOnSpawn = false

-- Главное окно панели
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 310) -- Оптимальный размер под мобилки
frame.Position = UDim2.new(0.3, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 0, 40)
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

-- Заголовок
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "⚡ ADMIN PANEL ⚡"
title.TextColor3 = Color3.fromRGB(190, 80, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- Кнопка закрытия (Крестик)
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18

-- Иконка открытия (Молния)
local openIndicator = Instance.new("TextButton", gui)
openIndicator.Size = UDim2.new(0, 55, 0, 55)
openIndicator.Position = UDim2.new(0, 15, 0, 15)
openIndicator.BackgroundColor3 = Color3.fromRGB(25, 0, 40)
openIndicator.Text = "⚡"
openIndicator.TextColor3 = Color3.fromRGB(190, 80, 255)
openIndicator.Font = Enum.Font.GothamBold
openIndicator.TextSize = 24
openIndicator.Visible = false
Instance.new("UICorner", openIndicator).CornerRadius = UDim.new(1, 0)

local stroke = Instance.new("UIStroke", openIndicator)
stroke.Color = Color3.fromRGB(190, 80, 255)
stroke.Width = 2

-- Логика скрыть/показать
closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    openIndicator.Visible = true
end)

openIndicator.MouseButton1Click:Connect(function()
    frame.Visible = true
    openIndicator.Visible = false
end)

-- Функция создания кнопок (теперь создаются прямо во Frame!)
local function createButton(text, y)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Text = text
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    return b
end

--// СОСТОЯНИЯ //--
local flying = false
local noclip = false
local esp = false
local spinning = false

local flyVel = nil
local flyGyro = nil
local spinVelocity = nil
local highlights = {}

local function getCharAndHRP()
    local c = player.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    return c, hrp, hum
end

--// FLY //--
local function updateFly()
    if not flying then return end
    local _, hrp, _ = getCharAndHRP()
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

--// ESP //--
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

--// КНОПКИ (С точными координатами Y) //--
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

local flingBtn = createButton("Fling (Spin): OFF", 150)
flingBtn.MouseButton1Click:Connect(function()
    spinning = not spinning
    local _, hrp, _ = getCharAndHRP()

    if spinning and hrp then
        flingBtn.Text = "Fling: ON"
        flingBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)

        spinVelocity = Instance.new("AngularVelocity", hrp)
        spinVelocity.Attachment0 = hrp:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", hrp)
        spinVelocity.AngularVelocity = Vector3.new(0, 500, 0)
        spinVelocity.MaxTorque = 1e9
    else
        flingBtn.Text = "Fling: OFF"
        flingBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
        if spinVelocity then spinVelocity:Destroy() spinVelocity = nil end
    end
end)

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

local funnyBtn = createButton("😂 FUN SPEED/JUMP", 250)
funnyBtn.MouseButton1Click:Connect(function()
    local _, _, hum = getCharAndHRP()
    if hum then
        hum.WalkSpeed = 120
        hum.JumpPower = 180
        pcall(function() hum.UseJumpPower = true end)
    end
end)

--// ЦИКЛЫ //--
RunService.Stepped:Connect(function()
    updateFly()
    local char, _, _ = getCharAndHRP()
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
        if esp then refreshESP() else clearESP() end
        task.wait(1.5)
    end
end)
