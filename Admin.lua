--// ULTIMATE RGB ADMIN PANEL V2 (STABILIZED & EXPANDED) //--

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

local targetGui = pcall(function() return CoreGui end) and CoreGui or player:WaitForChild("PlayerGui")

if targetGui:FindFirstChild("RGBAdminPanel") then
    targetGui.RGBAdminPanel:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "RGBAdminPanel"
gui.ResetOnSpawn = false
gui.Parent = targetGui

--// КНОПКА ОТКРЫТИЯ/ЗАКРЫТИЯ МЕНЮ //--
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Position = UDim2.new(0, 10, 0.5, -22) -- Слева по центру
toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 10, 65)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 24
toggleBtn.Text = "⚡"
toggleBtn.Parent = gui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 10)
toggleCorner.Parent = toggleBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Thickness = 2
toggleStroke.Parent = toggleBtn

--// ОСНОВНОЙ ФРЕЙМ //--
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 380)
frame.Position = UDim2.new(0.15, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(45, 10, 65)
frame.Active = true
frame.Draggable = true
frame.Visible = false -- Изначально скрыто, надо нажать на ⚡
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

local rgbStroke = Instance.new("UIStroke")
rgbStroke.Thickness = 3
rgbStroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "⚡ RGB ADMIN V2 ⚡"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

local titleStroke = Instance.new("UIStroke")
titleStroke.Thickness = 1
titleStroke.Parent = title

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -10, 1, -50)
scroll.Position = UDim2.new(0, 5, 0, 40)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0, 0, 0, 560) -- Увеличил место под новые кнопки
scroll.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = scroll

--// ЛОГИКА ОТКРЫТИЯ/ЗАКРЫТИЯ //--
toggleBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

--// ГЕНЕРАТОР КНОПОК //--
local function createBtn(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(80, 20, 110)
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

--// СОЗДАНИЕ КНОПОК //--
local flyBtn = createBtn("Fly: OFF")
local noclipBtn = createBtn("Noclip: OFF")
local flingBtn = createBtn("Stable Fling: OFF")
local espBtn = createBtn("ESP Boxes: OFF")
local infJumpBtn = createBtn("Inf Jump: OFF")
local hitboxBtn = createBtn("Big Hitboxes: OFF")
local fovBtn = createBtn("FOV 120: OFF")
local antiFlingBtn = createBtn("Anti-Fling: OFF")
local antiRagdollBtn = createBtn("Anti-Ragdoll: OFF")
local gravityBtn = createBtn("Moon Gravity: OFF")
local speedBtn = createBtn("⚡ Boost Speed/Jump")
local btoolsBtn = createBtn("🛠️ Give Btools")

--// ПЕРЕМЕННЫЕ ЛОГИКИ //--
local flying, noclip, esp, spinning, infJump, bigHitboxes, wideFov, antiFling, antiRagdoll, moonGravity = false, false, false, false, false, false, false, false, false, false
local flyVel, flyGyro
local espBoxes = {}

--// ЛОГИКА ФУНКЦИЙ //--
local function toggleState(btn, state, name)
    btn.Text = name .. ": " .. (state and "ON" or "OFF")
    btn.BackgroundColor3 = state and Color3.fromRGB(120, 40, 160) or Color3.fromRGB(80, 20, 110)
end

flyBtn.MouseButton1Click:Connect(function() flying = not flying; toggleState(flyBtn, flying, "Fly") end)
noclipBtn.MouseButton1Click:Connect(function() noclip = not noclip; toggleState(noclipBtn, noclip, "Noclip") end)
flingBtn.MouseButton1Click:Connect(function() spinning = not spinning; toggleState(flingBtn, spinning, "Stable Fling") end)
infJumpBtn.MouseButton1Click:Connect(function() infJump = not infJump; toggleState(infJumpBtn, infJump, "Inf Jump") end)
antiFlingBtn.MouseButton1Click:Connect(function() antiFling = not antiFling; toggleState(antiFlingBtn, antiFling, "Anti-Fling") end)
antiRagdollBtn.MouseButton1Click:Connect(function() antiRagdoll = not antiRagdoll; toggleState(antiRagdollBtn, antiRagdoll, "Anti-Ragdoll") end)

gravityBtn.MouseButton1Click:Connect(function()
    moonGravity = not moonGravity
    toggleState(gravityBtn, moonGravity, "Moon Gravity")
    workspace.Gravity = moonGravity and 50 or 196.2
end)

fovBtn.MouseButton1Click:Connect(function()
    wideFov = not wideFov
    toggleState(fovBtn, wideFov, "FOV 120")
    workspace.CurrentCamera.FieldOfView = wideFov and 120 or 70
end)

espBtn.MouseButton1Click:Connect(function()
    esp = not esp
    toggleState(espBtn, esp, "ESP Boxes")
    if not esp then
        for _, box in pairs(espBoxes) do if box then box:Destroy() end end
        espBoxes = {}
    end
end)

hitboxBtn.MouseButton1Click:Connect(function()
    bigHitboxes = not bigHitboxes
    toggleState(hitboxBtn, bigHitboxes, "Big Hitboxes")
    if not bigHitboxes then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                p.Character.HumanoidRootPart.Transparency = 1
            end
        end
    end
end)

speedBtn.MouseButton1Click:Connect(function()
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 120 hum.JumpPower = 150 pcall(function() hum.UseJumpPower = true end) end
end)

btoolsBtn.MouseButton1Click:Connect(function()
    for _, tool in pairs({"Clone", "Hammer", "Grab"}) do
        local bin = Instance.new("HopperBin")
        bin.BinType = Enum.BinType[tool]
        bin.Parent = player.Backpack
    end
end)

UIS.JumpRequest:Connect(function()
    if infJump and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

--// ФИЗИЧЕСКИЙ ЦИКЛ (ИДЕАЛЬНО ДЛЯ НОКЛИПА) //--
RunService.Stepped:Connect(function()
    local char = player.Character
    if char and noclip then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

--// ЦИКЛ ПОВЕДЕНИЯ (STABLE FLING И ANTI-FLING) //--
RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    -- Стабильный Флинг: крутит жестко, но не ломает физику твоего перса
    if spinning and hrp then
        hrp.RotVelocity = Vector3.new(0, 3500, 0)
    end

    -- Анти-Флинг: сбрасывает скорость, если кто-то пытается укинуть тебя за карту
    if antiFling and hrp then
        if hrp.Velocity.Magnitude > 250 or hrp.RotVelocity.Magnitude > 250 then
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

--// ЦИКЛ РЕНДЕРА И РГБ //--
local hue = 0
RunService.RenderStepped:Connect(function(dt)
    hue = hue + dt * 0.3
    if hue > 1 then hue = 0 end
    local rainbow = Color3.fromHSV(hue, 1, 1)
    rgbStroke.Color = rainbow
    titleStroke.Color = rainbow
    toggleStroke.Color = rainbow

    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    -- Мобильный Флай
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
        
        if hum.MoveDirection.Magnitude > 0 then
            flyVel.Velocity = cam.CFrame.LookVector * 65
        else
            flyVel.Velocity = Vector3.new(0, 0, 0)
        end
    else
        if hum and
                
