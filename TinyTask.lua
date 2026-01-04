local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()

local points = {}
local isRecording = false
local isPlaying = false
local loop = true
local visualDots = {} 
local clickDelay = 0.5 -- Thời gian mặc định

-- GIAO DIỆN HIỆN ĐẠI
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
ScreenGui.Name = "TinyDelta_Pro_V2"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 210) -- Tăng chiều cao để thêm ô nhập liệu
Main.Position = UDim2.new(0.5, -100, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
local MainCorner = Instance.new("UICorner", Main)

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Header.BorderSizePixel = 0
local HeaderCorner = Instance.new("UICorner", Header)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "TINYDELTA PRO V2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.BackgroundTransparency = 1

-- PHẦN CHỈNH DELAY
local DelayLabel = Instance.new("TextLabel", Main)
DelayLabel.Size = UDim2.new(0, 100, 0, 30)
DelayLabel.Position = UDim2.new(0.04, 0, 0.18, 0)
DelayLabel.Text = "Delay (giây):"
DelayLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
DelayLabel.BackgroundTransparency = 1
DelayLabel.TextXAlignment = Enum.TextXAlignment.Left
DelayLabel.Font = Enum.Font.Gotham

local DelayInput = Instance.new("TextBox", Main)
DelayInput.Size = UDim2.new(0, 70, 0, 25)
DelayInput.Position = UDim2.new(0.55, 0, 0.2, 0)
DelayInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
DelayInput.Text = tostring(clickDelay)
DelayInput.TextColor3 = Color3.new(1, 1, 1)
DelayInput.Font = Enum.Font.Gotham
local DICorner = Instance.new("UICorner", DelayInput)

-- Hàm tạo nút
local function createBtn(text, pos, color)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.44, 0, 0, 35)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    local btnCorner = Instance.new("UICorner", btn)
    return btn
end

local RecBtn = createBtn("REC", UDim2.new(0.04, 0, 0.4, 0), Color3.fromRGB(200, 50, 50))
local PlayBtn = createBtn("PLAY", UDim2.new(0.52, 0, 0.4, 0), Color3.fromRGB(50, 150, 50))
local ResetBtn = createBtn("CLEAR", UDim2.new(0.04, 0, 0.65, 0), Color3.fromRGB(70, 70, 70))
local LoopBtn = createBtn("LOOP: ON", UDim2.new(0.52, 0, 0.65, 0), Color3.fromRGB(0, 120, 200))

-- Cập nhật Delay khi nhập
DelayInput.FocusLost:Connect(function()
    local val = tonumber(DelayInput.Text)
    if val then
        clickDelay = val
        print("Đã chỉnh delay thành: " .. val)
    else
        DelayInput.Text = tostring(clickDelay)
    end
end)

-- LOGIC HIỆU ỨNG & CLICK
local function ClickEffect(pos)
    local ring = Instance.new("Frame", ScreenGui)
    ring.Size = UDim2.new(0, 10, 0, 10)
    ring.Position = UDim2.new(0, pos.X - 5, 0, pos.Y - 5)
    ring.BackgroundColor3 = Color3.new(1, 1, 1)
    ring.BackgroundTransparency = 0.5
    local c = Instance.new("UICorner", ring)
    c.CornerRadius = UDim.new(1, 0)
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

Mouse.Button1Down:Connect(function()
    if isRecording then
        local p = Vector2.new(Mouse.X, Mouse.Y)
        table.insert(points, p)
        local dot = Instance.new("Frame", ScreenGui)
        dot.Size = UDim2.new(0, 8, 0, 8)
        dot.Position = UDim2.new(0, p.X - 4, 0, p.Y - 4)
        dot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        local c = Instance.new("UICorner", dot)
        c.CornerRadius = UDim.new(1, 0)
        table.insert(visualDots, dot)
    end
end)

RecBtn.MouseButton1Click:Connect(function()
    isRecording = not isRecording
    if isRecording then
        for _, v in pairs(visualDots) do v:Destroy() end
        visualDots = {}
        points = {}
        RecBtn.Text = "STOP REC"
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
                ClickEffect(pos)
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                task.wait(0.02)
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
                task.wait(clickDelay) -- SỬ DỤNG DELAY TỪ Ô NHẬP LIỆU
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
end)
