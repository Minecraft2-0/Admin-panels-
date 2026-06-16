--// ADMIN PANEL + ESP + FUN SYSTEM (EXE COMPATIBLE) //--

-- Защита от повторного запуска (удаляем старый GUI, если он был)
if game.CoreGui:FindFirstChild("AdminPanel") then
    game.CoreGui.AdminPanel:Destroy()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Функция для безопасного получения HumanoidRootPart
local function getHRP()
    local c = player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- Remote (для server-side команд)
local remote = ReplicatedStorage:FindFirstChild("AdminEvent")
if not remote and pcall(function() return game:GetService("NetworkClient") end) then
    -- Создаем remote только если есть права (в приватке)
    remote = Instance.new("RemoteEvent", ReplicatedStorage)
    remote.Name = "AdminEvent"
end

--// GUI //--
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "AdminPanel"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 270, 0, 460)
frame.Position = UDim2.new(0.05, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 0, 40)
frame.Active = true
frame.Draggable = true -- Для мобильных эмуляторов лучше использовать кастомный драг, но пока оставим стандартный

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "⚡ ADMIN PANEL ⚡"
title.TextColor3 = Color3.fromRGB(190, 80, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

local function createButton(text, y)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0.9,0,0,32)
    b.Position = UDim2.new(0.05,0,0,y)
    b.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.Text = text
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    return b
end

--// STATES //--
local flying = false
local noclip = false
local esp = false
local flyVel

local highlights = {}

--// FLY SYSTEM //--
local function updateFly()
    if not flying then return end
    local hrp = getHRP()
    if not hrp then return end

    local cam = workspace.CurrentCamera
    local move = Vector3.new(0,0,0)

    if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end

    if flyVel and flyVel.Parent == hrp then
        flyVel.Velocity = move * 80 -- Немного ускорил флай
    else
        -- Если BodyVelocity пропал (после респавна), создаем заново
        flyVel = Instance.new("BodyVelocity", hrp)
        flyVel.MaxForce = Vector3.new(1e9,1e9,1e9)
    end
end

--// ESP SYSTEM //--
local function addESP(character)
    if highlights[character] then return end
    if not character:FindFirstChild("HumanoidRootPart") then return end

    local h = Instance.new("Highlight")
    h.FillColor = Color3.fromRGB(180, 0, 255)
    h.OutlineColor = Color3.fromRGB(255,255,255)
    h.FillTransparency = 0.5
    h.Parent = character

    highlights[character] = h
end

local function clearESP()
    for char, h in pairs(highlights) do
        if h then pcall(function() h:Destroy() end) end
    end
    highlights = {}
end

local function refreshESP()
    if not esp then return end

    -- Игроки
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            addESP(p.Character)
        end
    end

    -- Обычные NPC (если есть в игре)
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
            addESP(obj)
        end
    end
end

--// КНОПКИ //--

local flyBtn = createButton("Fly", 50)
flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    local hrp = getHRP()
    
    if flying and hrp then
        flyVel = Instance.new("BodyVelocity", hrp)
        flyVel.MaxForce = Vector3.new(1e9,1e9,1e9)
        flyBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
    else
        if flyVel then flyVel:Destroy() end
        flyBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
    end
end)

local noclipBtn = createButton("Noclip", 90)
noclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    if noclip then
        noclipBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
    else
        noclipBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
    end
end)

local flingBtn = createButton("Fling", 130)
flingBtn.MouseButton1Click:Connect(function()
    local hrp = getHRP()
    if hrp then
        hrp.Velocity = Vector3.new(math.random(-150,150), 200, math.random(-150,150))
    end
end)

local bangBtn = createButton("Bang (test)", 170)
bangBtn.MouseButton1Click:Connect(function()
    if remote then
        remote:FireServer("bang", "playername")
    end
end)

local espBtn = createButton("ESP Toggle", 210)
espBtn.MouseButton1Click:Connect(function()
    esp = not esp
    if esp then
        espBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
    else
        espBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
        clearESP()
    end
end)

local funnyBtn = createButton("😂 FUN BOOST", 250)
funnyBtn.MouseButton1Click:Connect(function()
    local hrp = getHRP()
    if hrp then
        hrp.Velocity = Vector3.new(0, 300, 0)
    end
end)

--// ЦИКЛЫ //--

-- Основной цикл для Fly и Noclip
RunService.Stepped:Connect(function()
    updateFly()

    if noclip and player.Character then
        for _, v in pairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end
end)

-- Отдельный поток для обновления ESP
task.spawn(function()
    while true do
        if esp then
            refreshESP()
        else
            clearESP()
        end
        task.wait(1.5) -- Оптимальный интервал для мобилок
    end
end)
# Admin-panels-
