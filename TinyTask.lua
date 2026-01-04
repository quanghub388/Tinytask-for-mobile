local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()

local points = {} -- Lưu {pos, delay, ui}
local isRecording = false
local isPlaying = false
local loop = true

-- GIAO DIỆN CHÍNH
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
ScreenGui.Name = "TinyDelta_Macro_V3"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 180, 0, 130)
Main.Position = UDim2.new(0.5, -90, 0.1, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "MACRO PRO V3"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1

local function createBtn(text, pos, color)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0, 80, 0, 35)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamMedium
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local RecBtn = createBtn("REC", UDim2.new(0.05, 0, 0.3, 0), Color3.fromRGB(180, 40, 40))
local PlayBtn = createBtn("PLAY", UDim2.new(0.5, 0, 0.3, 0), Color3.fromRGB(40, 150, 40))
local ClearBtn = createBtn("CLEAR", UDim2.new(0.05, 0, 0.65, 0), Color3.fromRGB(60, 60, 60))
local LoopBtn = createBtn("LOOP: ON", UDim2.new(0.5, 0, 0.65, 0), Color3.fromRGB(0, 100, 180))

-- HÀM TẠO ĐIỂM ĐÁNH DẤU CÓ THỂ CHỈNH SỬA
local function CreateEditablePoint(pos, index)
    local dot = Instance.new("TextButton", ScreenGui)
    dot.Size = UDim2.new(0, 20, 0, 20)
    dot.Position = UDim2.new(0, pos.X - 10, 0, pos.Y - 10)
    dot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    dot.Text = tostring(index)
    dot.TextColor3 = Color3.new(1, 1, 1)
    dot.Font = Enum.Font.GothamBold
    dot.ZIndex = 10
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local delayText = Instance.new("TextLabel", dot)
    delayText.Size = UDim2.new(0, 40, 0, 20)
    delayText.Position = UDim2.new(1, 2, 0, 0)
    delayText.Text = points[index].delay .. "s"
    delayText.TextColor3 = Color3.new(1, 1, 0)
    delayText.BackgroundTransparency = 1
    delayText.Font = Enum.Font.Gotham
    delayText.TextSize = 10

    -- Khi bấm vào chấm đỏ để chỉnh giây
    dot.MouseButton1Click:Connect(function()
        local inputFrame = Instance.new("Frame", ScreenGui)
        inputFrame.Size = UDim2.new(0, 100, 0, 50)
        inputFrame.Position = UDim2.new(0, pos.X - 50, 0, pos.Y - 60)
        inputFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Instance.new("UICorner", inputFrame)

        local box = Instance.new("TextBox", inputFrame)
        box.Size = UDim2.new(0.8, 0, 0.6, 0)
        box.Position = UDim2.new(0.1, 0, 0.2, 0)
        box.Text = tostring(points[index].delay)
        box.TextColor3 = Color3.new(1, 1, 1)
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

-- GHI ĐIỂM
Mouse.Button1Down:Connect(function()
    if isRecording then
        local p = Vector2.new(Mouse.X, Mouse.Y)
        local index = #points + 1
        points[index] = {pos = p, delay = 0.5, ui = nil}
        points[index].ui = CreateEditablePoint(p, index)
    end
end)

-- ĐIỀU KHIỂN
RecBtn.MouseButton1Click:Connect(function()
    isRecording = not isRecording
    RecBtn.Text = isRecording and "STOP" or "REC"
    if isRecording then
        for _, v in ipairs(points) do v.ui:Destroy() end
        points = {}
    end
end)

PlayBtn.MouseButton1Click:Connect(function()
    if #points == 0 then return end
    isPlaying = not isPlaying
    PlayBtn.Text = isPlaying and "STOP" or "PLAY"
    
    task.spawn(function()
        while isPlaying do
            for i, data in ipairs(points) do
                if not isPlaying then break end
                -- Hiệu ứng nháy khi click
                data.ui.BackgroundColor3 = Color3.new(1, 1, 1)
                VirtualInputManager:SendMouseButtonEvent(data.pos.X, data.pos.Y, 0, true, game, 1)
                task.wait(0.02)
                VirtualInputManager:SendMouseButtonEvent(data.pos.X, data.pos.Y, 0, false, game, 1)
                task.wait(0.1)
                data.ui.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                
                task.wait(data.delay) -- DÙNG DELAY RIÊNG CỦA TỪNG ĐIỂM
            end
            if not loop then isPlaying = false break end
            task.wait(0.1)
        end
        PlayBtn.Text = "PLAY"
    end)
end)

ClearBtn.MouseButton1Click:Connect(function()
    for _, v in ipairs(points) do v.ui:Destroy() end
    points = {}
    isPlaying = false
end)

LoopBtn.MouseButton1Click:Connect(function()
    loop = not loop
    LoopBtn.Text = loop and "LOOP: ON" or "LOOP: OFF"
end)
