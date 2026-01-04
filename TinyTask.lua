local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()

local points = {}
local isRecording = false
local isPlaying = false
local loop = true
local themeIndex = 1

-- 1. DANH SÁCH THEMES
local themes = {
    {Name = "DARK", Main = Color3.fromRGB(25, 25, 25), Accent = Color3.fromRGB(45, 45, 45), Text = Color3.fromRGB(255, 255, 255)},
    {Name = "OCEAN", Main = Color3.fromRGB(10, 35, 65), Accent = Color3.fromRGB(0, 100, 220), Text = Color3.fromRGB(200, 255, 255)},
    {Name = "NEON", Main = Color3.fromRGB(45, 5, 45), Accent = Color3.fromRGB(220, 0, 220), Text = Color3.fromRGB(255, 200, 255)},
    {Name = "FOREST", Main = Color3.fromRGB(15, 40, 15), Accent = Color3.fromRGB(50, 180, 50), Text = Color3.fromRGB(210, 255, 210)}
}

-- 2. GIAO DIỆN CHÍNH
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
ScreenGui.Name = "TinyDelta_V4_Full"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 220)
Main.Position = UDim2.new(0.5, -100, 0.2, 0)
Main.BackgroundColor3 = themes[1].Main
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = themes[1].Accent
Instance.new("UICorner", Header)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "TINYDELTA V4 PRO"
Title.TextColor3 = themes[1].Text
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1

-- 3. HÀM TẠO ĐIỂM ĐÁNH DẤU (CÓ THỂ CHỈNH GIÂY)
local function CreateEditablePoint(pos, index)
    local dot = Instance.new("TextButton", ScreenGui)
    dot.Size = UDim2.new(0, 22, 0, 22)
    dot.Position = UDim2.new(0, pos.X - 11, 0, pos.Y - 11)
    dot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    dot.Text = tostring(index)
    dot.TextColor3 = Color3.new(1, 1, 1)
    dot.Font = Enum.Font.GothamBold
    dot.ZIndex = 10
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local delayText = Instance.new("TextLabel", dot)
    delayText.Size = UDim2.new(0, 45, 0, 20)
    delayText.Position = UDim2.new(1, 2, 0, 0)
    delayText.Text = points[index].delay .. "s"
    delayText.TextColor3 = Color3.new(1, 1, 0)
    delayText.BackgroundTransparency = 1
    delayText.Font = Enum.Font.GothamBold
    delayText.TextSize = 11

    -- Bấm vào chấm đỏ để chỉnh giây
    dot.MouseButton1Click:Connect(function()
        local inputFrame = Instance.new("Frame", ScreenGui)
        inputFrame.Size = UDim2.new(0, 100, 0, 50)
        inputFrame.Position = UDim2.new(0, pos.X - 50, 0, pos.Y - 65)
        inputFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        inputFrame.ZIndex = 11
        Instance.new("UICorner", inputFrame)

        local box = Instance.new("TextBox", inputFrame)
        box.Size = UDim2.new(0.8, 0, 0.6, 0)
        box.Position = UDim2.new(0.1, 0, 0.2, 0)
        box.Text = tostring(points[index].delay)
        box.TextColor3 = Color3.new(1, 1, 1)
        box.Font = Enum.Font.Gotham
        box.ClearTextOnFocus = true

        box.FocusLost:Connect(function()
            local val = tonumber(box.Text)
            if val then
                points[index].delay = val
                delayText.Text = val .. "s"
            end
            inputFrame:Destroy()
        end)
    end)
    return dot
end

-- 4. ĐIỀU KHIỂN THEME
local ThemeBtn = Instance.new("TextButton", Main)
ThemeBtn.Size = UDim2.new(0.9, 0, 0, 30)
ThemeBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
ThemeBtn.Text = "THEME: DARK"
ThemeBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
ThemeBtn.TextColor3 = Color3.new(1, 1, 1)
ThemeBtn.Font = Enum.Font.GothamMedium
Instance.new("UICorner", ThemeBtn)

ThemeBtn.MouseButton1Click:Connect(function()
    themeIndex = themeIndex + 1
    if themeIndex > #themes then themeIndex = 1 end
    local current = themes[themeIndex]
    ThemeBtn.Text = "THEME: " .. current.Name
    Main.BackgroundColor3 = current.Main
    Header.BackgroundColor3 = current.Accent
    Title.TextColor3 = current.Text
end)

-- 5. CÁC NÚT CHỨC NĂNG
local function createBtn(text, pos, color)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0, 86, 0, 35)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn)
    return btn
end

local RecBtn = createBtn("REC", UDim2.new(0.05, 0, 0.4, 0), Color3.fromRGB(180, 50, 50))
local PlayBtn = createBtn("PLAY", UDim2.new(0.52, 0, 0.4, 0), Color3.fromRGB(50, 150, 50))
local ClearBtn = createBtn("CLEAR", UDim2.new(0.05, 0, 0.65, 0), Color3.fromRGB(70, 70, 70))
local LoopBtn = createBtn("LOOP: ON", UDim2.new(0.52, 0, 0.65, 0), Color3.fromRGB(0, 110, 190))

-- 6. LOGIC GHI VÀ CHẠY
Mouse.Button1Down:Connect(function()
    if isRecording then
        local p = Vector2.new(Mouse.X, Mouse.Y)
        local index = #points + 1
        points[index] = {pos = p, delay = 0.5, ui = nil}
        points[index].ui = CreateEditablePoint(p, index)
    end
end)

RecBtn.MouseButton1Click:Connect(function()
    isRecording = not isRecording
    RecBtn.Text = isRecording and "STOP REC" or "REC"
    RecBtn.BackgroundColor3 = isRecording and Color3.fromRGB(100, 0, 0) or Color3.fromRGB(180, 50, 50)
    if isRecording then
        for _, v in ipairs(points) do if v.ui then v.ui:Destroy() end end
        points = {}
    end
end)

PlayBtn.MouseButton1Click:Connect(function()
    if #points == 0 then return end
    isPlaying = not isPlaying
    PlayBtn.Text = isPlaying and "STOP" or "PLAY"
    PlayBtn.BackgroundColor3 = isPlaying and Color3.fromRGB(200, 150, 0) or Color3.fromRGB(50, 150, 50)
    
    task.spawn(function()
        while isPlaying do
            for i, data in ipairs(points) do
                if not isPlaying then break end
                -- Hiệu ứng nháy
                data.ui.BackgroundColor3 = Color3.new(1, 1, 1)
                VirtualInputManager:SendMouseButtonEvent(data.pos.X, data.pos.Y, 0, true, game, 1)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(data.pos.X, data.pos.Y, 0, false, game, 1)
                task.wait(0.1)
                data.ui.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                
                task.wait(data.delay) -- Chờ theo giây đã chỉnh
            end
            if not loop then isPlaying = false break end
            task.wait(0.1)
        end
        PlayBtn.Text = "PLAY"
        PlayBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    end)
end)

LoopBtn.MouseButton1Click:Connect(function()
    loop = not loop
    LoopBtn.Text = loop and "LOOP: ON" or "LOOP: OFF"
    LoopBtn.BackgroundColor3 = loop and Color3.fromRGB(0, 110, 190) or Color3.fromRGB(60, 60, 60)
end)

ClearBtn.MouseButton1Click:Connect(function()
    for _, v in ipairs(points) do if v.ui then v.ui:Destroy() end end
    points = {}
    isPlaying = false
    PlayBtn.Text = "PLAY"
end)
