--// FULL ADMIN PANEL + ESP + FUN SYSTEM (MOBILE EXE COMPATIBLE) //--

local success, err = pcall(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UIS = game:GetService("UserInputService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    -- Функция для безопасного поиска HumanoidRootPart и Персонажа
    local function getCharAndHRP()
        local c = player.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        return c, hrp
    end

    -- Удаляем старый GUI, если скрипт запускается повторно
    if playerGui:FindFirstChild("AdminPanel") then
        playerGui.AdminPanel:Destroy()
    end

    -- Попытка создать RemoteEvent (только если есть права в приватке)
    local remote = ReplicatedStorage:FindFirstChild("AdminEvent")
    if not remote then
        pcall(function()
            remote = Instance.new("RemoteEvent", ReplicatedStorage)
            remote.Name = "AdminEvent"
        end)
    end

    --// СУПЕР GUI (В PlayerGui для стабильности на мобилках) //--
    local gui = Instance.new("ScreenGui", playerGui)
    gui.Name = "AdminPanel"
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 270, 0, 400) -- Немного уменьшил высоту под мобильные экраны
    frame.Position = UDim2.new(0.1, 0, 0.2, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 0, 40)
    frame.Active = true
    frame.Draggable = true -- Базовое перетаскивание

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "⚡ ADMIN PANEL ⚡"
    title.TextColor3 = Color3.fromRGB(190, 80, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18

    -- Контейнер для кнопок, чтобы они не вылезали
    local container = Instance.new("ScrollingFrame", frame)
    container.Size = UDim2.new(1, 0, 1, -45)
    container.Position = UDim2.new(0, 0, 0, 40)
    container.BackgroundTransparency = 1
    container.CanvasSize = UDim2.new(0, 0, 0, 320)
    container.ScrollBarThickness = 4

    local function createButton(text, y)
        local b = Instance.new("TextButton", container)
        b.Size = UDim2.new(0.9, 0, 0, 35)
        b.Position = UDim2.new(0.05, 0, 0, y)
        b.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 14
        b.Text = text
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        return b
    end

    --// НАСТРОЙКИ ФУНКЦИЙ //--
    local flying = false
    local noclip = false
    local esp = false
    local flyVel = nil
    local highlights = {}

    --// FLY ЛОГИКА //--
    local function updateFly()
        if not flying then return end
        local _, hrp = getCharAndHRP()
        if not hrp then return end

        local cam = workspace.CurrentCamera
        local move = Vector3.new(0,0,0)

        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end

        if flyVel and flyVel.Parent == hrp then
            flyVel.Velocity = move * 80
        else
            flyVel = Instance.new("BodyVelocity", hrp)
            flyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        end
    end

    --// ESP ЛОГИКА //--
    local function addESP(character)
        if highlights[character] then return end
        if not character:FindFirstChild("HumanoidRootPart") then return end

        local h = Instance.new("Highlight")
        h.FillColor = Color3.fromRGB(180, 0, 255)
        h.OutlineColor = Color3.fromRGB(255, 255, 255)
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
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                addESP(p.Character)
            end
        end
    end

    --// КНОПКИ //--
    local flyBtn = createButton("Fly: OFF", 10)
    flyBtn.MouseButton1Click:Connect(function()
        flying = not flying
        local _, hrp = getCharAndHRP()
        if flying and hrp then
            flyVel = Instance.new("BodyVelocity", hrp)
            flyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            flyBtn.Text = "Fly: ON"
            flyBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
        else
            if flyVel then flyVel:Destroy() end
            flyBtn.Text = "Fly: OFF"
            flyBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
        end
    end)

    local noclipBtn = createButton("Noclip: OFF", 55)
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

    local espBtn = createButton("ESP: OFF", 100)
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

    local flingBtn = createButton("Fling (Spam Velocity)", 145)
    flingBtn.MouseButton1Click:Connect(function()
        local _, hrp = getCharAndHRP()
        if hrp then
            hrp.Velocity = Vector3.new(math.random(-200, 200), 250, math.random(-200, 200))
        end
    end)

    local bangBtn = createButton("Bang (Test Event)", 190)
    bangBtn.MouseButton1Click:Connect(function()
        if remote then
            remote:FireServer("bang", "playername")
        end
    end)

    local funnyBtn = createButton("😂 FUN MEGA BOOST", 235)
    funnyBtn.MouseButton1Click:Connect(function()
        local _, hrp = getCharAndHRP()
        if hrp then
            hrp.Velocity = Vector3.new(0, 400, 0)
        end
    end)

    --// ЦИКЛЫ //--
    RunService.Stepped:Connect(function()
        updateFly()
        local char, _ = getCharAndHRP()
        if noclip and char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
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

    print("[Admin Panel]: Скрипт успешно запущен!")
end)

if not success then
    warn("[Admin Panel Ошибка]: " .. tostring(err))
end
