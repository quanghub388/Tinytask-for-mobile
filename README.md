local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

local inset = GuiService:GetGuiInset().Y 
local points = {}
local isRecording, isPlaying, loop = false, false, true

-- 1. MÀU SẮC HIỆN ĐẠI
local COLORS = {
    Main = Color3.fromRGB(15, 15, 15),     -- Đen sâu
    Secondary = Color3.fromRGB(25, 25, 25),-- Đen xám
    Accent = Color3.fromRGB(0, 150, 255),  -- Xanh ánh sáng (Modern Blue)
    Text = Color3.fromRGB(240, 240, 240),  -- Trắng khói
    Point = Color3.fromRGB(0, 255, 150)    -- Xanh lá neon cho điểm click
}

-- 2. GIAO DIỆN CHÍNH
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
ScreenGui.Name = "TINYCLICK_V12"

-- Glow viền xanh hiện đại
local OuterFrame = Instance.new("Frame", ScreenGui)
OuterFrame.Size = UDim2.new(0, 210, 0, 310)
OuterFrame.Position = UDim2.new(0.5, -105, 0.3, -155)
OuterFrame.BackgroundColor3 = COLORS.Accent
OuterFrame.BorderSizePixel = 0
local Corner1 = Instance.new("UICorner", OuterFrame)
Corner1.CornerRadius = UDim.new(0, 15)

local Main = Instance.new("Frame", OuterFrame)
Main.Size = UDim2.new(1, -4, 1, -4)
Main.Position = UDim2.new(0, 2, 0, 2)
Main.BackgroundColor3 = COLORS.Main
local Corner2 = Instance.new("UICorner", Main)
Corner2.CornerRadius = UDim.new(0, 13)
Main.ClipsDescendants = true

-- Header tinh tế
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = COLORS.Secondary
Header.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0.08, 0, 0, 0)
Title.Text = "TINYCLICK **by CAT**"
Title.RichText = true
Title.TextColor3 = COLORS.Text
Title.Font = Enum.Font.GothamMedium
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- Nút đóng & thu nhỏ (Hiện đại)
local function createTopBtn(text, pos, color)
    local btn = Instance.new("TextButton", Header)
    btn.Size = UDim2.new(0, 28, 0, 28)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local CloseBtn = createTopBtn("×", UDim2.new(0.84, 0, 0.2, 0), Color3.fromRGB(255, 80, 80))
local MinBtn = createTopBtn("-", UDim2.new(0.68, 0, 0.2, 0), Color3.fromRGB(60, 60, 60))

-- 3. HÀM TẠO NÚT HIỆN ĐẠI (Với hiệu ứng di chuột)
local function createModernBtn(text, pos, sizeX)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0, sizeX or 85, 0, 38)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = COLORS.Secondary
    btn.TextColor3 = COLORS.Text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 10)
    
    -- Hiệu ứng Hover
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Accent}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Secondary}):Play()
    end)
    
    return btn
end

local RecBtn = createModernBtn("RECORD", UDim2.new(0.05, 0, 0.22, 0))
local PlayBtn = createModernBtn("PLAY", UDim2.new(0.52, 0, 0.22, 0))
local ClearBtn = createModernBtn("CLEAR ALL", UDim2.new(0.05, 0, 0.4, 0), 180)
local LoopBtn = createModernBtn("LOOP: ON", UDim2.new(0.05, 0, 0.58, 0), 180)
local SupportBtn = createModernBtn("DISCORD / SUPPORT", UDim2.new(0.05, 0, 0.76, 0), 180)

-- 4. ICON MÈO :3 (Hiện đại hơn)
local CatMin = Instance.new("TextButton", ScreenGui)
CatMin.Size = UDim2.new(0, 55, 0, 55)
CatMin.Visible = false
CatMin.Text = ":3"
CatMin.TextSize = 20
CatMin.TextColor3 = COLORS.Accent
CatMin.BackgroundColor3 = COLORS.Main
CatMin.BorderSizePixel = 2
local CatCorner = Instance.new("UICorner", CatMin)
CatCorner.CornerRadius = UDim.new(1, 0)
local CatStroke = Instance.new("UIStroke", CatMin)
CatStroke.Color = COLORS.Accent
CatStroke.Thickness = 2

-- 5. LOGIC DI CHUYỂN
local function MakeDraggable(obj, dragHandle)
    local dragging, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    dragHandle.InputEnded:Connect(function() dragging = false end)
end

MakeDraggable(OuterFrame, Header)
MakeDraggable(CatMin, CatMin)

-- Thu nhỏ / Đóng
MinBtn.MouseButton1Click:Connect(function() OuterFrame.Visible = false CatMin.Visible = true CatMin.Position = OuterFrame.Position end)
CatMin.MouseButton1Click:Connect(function() OuterFrame.Position = CatMin.Position CatMin.Visible = false OuterFrame.Visible = true end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- 6. LOGIC CLICK (FIX LỆCH TÂM)
local function CreatePoint(pos, index)
    local dot = Instance.new("Frame", ScreenGui)
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = UDim2.new(0, pos.X - 5, 0, pos.Y - 5)
    dot.BackgroundColor3 = COLORS.Point
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", dot).Color = Color3.new(1, 1, 1)
    return dot
end

Mouse.Button1Down:Connect(function()
    if isRecording then
        local idx = #points + 1
        points[idx] = {pos = Vector2.new(Mouse.X, Mouse.Y), delay = 0.5}
        points[idx].ui = CreatePoint(points[idx].pos, idx)
    end
end)

RecBtn.MouseButton1Click:Connect(function()
    isRecording = not isRecording
    RecBtn.Text = isRecording and "STOP" or "RECORD"
    RecBtn.TextColor3 = isRecording and Color3.fromRGB(255, 100, 100) or COLORS.Text
end)

PlayBtn.MouseButton1Click:Connect(function()
    if #points == 0 then return end
    isPlaying = not isPlaying
    PlayBtn.Text = isPlaying and "STOP" or "PLAY"
    PlayBtn.TextColor3 = isPlaying and Color3.fromRGB(255, 100, 100) or COLORS.Text
    task.spawn(function()
        while isPlaying do
            for _, p in ipairs(points) do
                if not isPlaying then break end
                local t = TweenService:Create(p.ui, TweenInfo.new(0.1), {Size = UDim2.new(0, 15, 0, 15), BackgroundColor3 = Color3.new(1,1,1)})
                t:Play()
                VirtualInputManager:SendMouseButtonEvent(p.pos.X, p.pos.Y + inset, 0, true, game, 1)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(p.pos.X, p.pos.Y + inset, 0, false, game, 1)
                task.wait(0.1)
                TweenService:Create(p.ui, TweenInfo.new(0.1), {Size = UDim2.new(0, 10, 0, 10), BackgroundColor3 = COLORS.Point}):Play()
                task.wait(p.delay)
            end
            if not loop then isPlaying = false break end
            task.wait(0.1)
        end
        PlayBtn.Text = "PLAY"
    end)
end)

ClearBtn.MouseButton1Click:Connect(function() for _, v in pairs(points) do v.ui:Destroy() end points = {} isPlaying = false PlayBtn.Text = "PLAY" end)
LoopBtn.MouseButton1Click:Connect(function() loop = not loop LoopBtn.Text = loop and "LOOP: ON" or "LOOP: OFF" LoopBtn.TextColor3 = loop and COLORS.Text or Color3.fromRGB(150, 150, 150) end)
SupportBtn.MouseButton1Click:Connect(function() setclipboard("https://discord.com/users/1199321278637678655") end)
