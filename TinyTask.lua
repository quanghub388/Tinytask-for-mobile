local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()

local points = {}
local isRecording = false
local isPlaying = false
local loop = true
local visualDots = {} -- Lưu các chấm đỏ để xóa sau này

-- GIAO DIỆN HIỆN ĐẠI
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
ScreenGui.Name = "TinyDelta_Pro"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 160)
Main.Position = UDim2.new(0.5, -100, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

-- Bo góc cho Menu
local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 10)

-- Thanh tiêu đề
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Header.BorderSizePixel = 0
local HeaderCorner = Instance.new("UICorner", Header)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "TINYDELTA PRO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.BackgroundTransparency = 1

-- Hàm tạo nút hiện đại
local function createBtn(text, pos, color)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.44, 0, 0, 40)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = true
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 6)
    return btn
end

local RecBtn = createBtn("REC", UDim2.new(0.04, 0, 0.28, 0), Color3.fromRGB(200, 50, 50))
local PlayBtn = createBtn("PLAY", UDim2.new(0.52, 0, 0.28, 0), Color3.fromRGB(50, 150, 50))
local ResetBtn = createBtn("CLEAR", UDim2.new(0.04, 0, 0.62, 0), Color3.fromRGB(70, 70, 70))
local LoopBtn = createBtn("LOOP: ON", UDim2.new(0.52, 0, 0.62, 0), Color3.fromRGB(0, 120, 200))

-- HIỆU ỨNG KHI GHI (Chấm đỏ cố định)
local function CreateVisualPoint(pos)
    local dot = Instance.new("Frame", ScreenGui)
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = UDim2.new(0, pos.X - 5, 0, pos.Y - 5)
    dot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    dot.ZIndex = 10
    local c = Instance.new("UICorner", dot)
    c.CornerRadius = UDim.new(1, 0)
    table.insert(visualDots, dot)
end

-- HIỆU ỨNG KHI CLICK (Vòng sóng lan tỏa)
local function ClickEffect(pos)
    local ring = Instance.new("Frame", ScreenGui)
    ring.Size = UDim2.new(0, 10, 0, 10)
    ring.Position = UDim2.new(0, pos.X - 5, 0, pos.Y - 5)
    ring.BackgroundColor3 = Color3.new(1, 1, 1)
    ring.BackgroundTransparency = 0.5
    local c = Instance.new("UICorner", ring)
    c.CornerRadius = UDim.new(1, 0)
    
    -- Tween hiệu ứng to dần và mờ đi
    task.spawn(function()
        for i = 1, 10 do
            ring.Size = ring.Size + UDim2.new(0, 4, 0, 4)
            ring.Position = ring.Position - UDim2.new(0, 2, 0, 2)
            ring.BackgroundTransparency = ring.BackgroundTransparency + 0.05
            task.wait(0.02)
        end
        ring:Destroy()
    end)
end

-- LOGIC CHÍNH
Mouse.Button1Down:Connect(function()
    if isRecording then
        local p = Vector2.new(Mouse.X, Mouse.Y)
        table.insert(points, p)
        CreateVisualPoint(p)
    end
end)

RecBtn.MouseButton1Click:Connect(function()
    isRecording = not isRecording
    if isRecording then
        for _, v in pairs(visualDots) do v:Destroy() end
        visualDots = {}
        points = {}
        RecBtn.Text = "STOP"
        RecBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    else
        RecBtn.Text = "REC"
        RecBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

PlayBtn.MouseButton1Click:Connect(function()
    if #points == 0 then return end
    isPlaying = not isPlaying
    PlayBtn.Text = isPlaying and "STOP" or "PLAY"
    PlayBtn.BackgroundColor3 = isPlaying and Color3.fromRGB(200, 150, 0) or Color3.fromRGB(50, 150, 50)
    
    task.spawn(function()
        while isPlaying do
            for _, pos in ipairs(points) do
                if not isPlaying then break end
                ClickEffect(pos) -- Hiện vòng sóng
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
                task.wait(0.7) -- Tốc độ click
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
    LoopBtn.BackgroundColor3 = loop and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(70, 70, 70)
end)

ResetBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(visualDots) do v:Destroy() end
    visualDots = {}
    points = {}
    isPlaying = false
    isRecording = false
    PlayBtn.Text = "PLAY"
    RecBtn.Text = "REC"
end)
