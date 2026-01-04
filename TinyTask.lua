local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local points = {}
local isRecording = false
local isPlaying = false
local loop = true
local themeIndex = 1

-- 1. HÀM ÂM THANH
local function PlayClickSound()
    local sound = Instance.new("Sound", SoundService)
    sound.SoundId = "rbxassetid://6895079853"
    sound.Volume = 0.5
    sound:Play()
    sound.Stopped:Connect(function() sound:Destroy() end)
end

local themes = {
    {Name = "DARK", Main = Color3.fromRGB(25, 25, 25), Accent = Color3.fromRGB(45, 45, 45), Text = Color3.fromRGB(255, 255, 255)},
    {Name = "OCEAN", Main = Color3.fromRGB(10, 35, 65), Accent = Color3.fromRGB(0, 100, 220), Text = Color3.fromRGB(200, 255, 255)},
    {Name = "NEON", Main = Color3.fromRGB(45, 5, 45), Accent = Color3.fromRGB(220, 0, 220), Text = Color3.fromRGB(255, 200, 255)},
    {Name = "FOREST", Main = Color3.fromRGB(15, 40, 15), Accent = Color3.fromRGB(50, 180, 50), Text = Color3.fromRGB(210, 255, 210)}
}

-- 2. GIAO DIỆN CHÍNH
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
ScreenGui.Name = "TINYCLICK_ByCat"

local GlowFrame = Instance.new("Frame", ScreenGui)
GlowFrame.Size = UDim2.new(0, 204, 0, 284)
GlowFrame.Position = UDim2.new(0.5, -102, 0.2, -2)
GlowFrame.BackgroundColor3 = Color3.new(1, 1, 1)
GlowFrame.BorderSizePixel = 0
Instance.new("UICorner", GlowFrame)

task.spawn(function()
    while GlowFrame.Parent do
        for i = 0, 1, 0.005 do
            if not GlowFrame.Parent then break end
            GlowFrame.BackgroundColor3 = Color3.fromHSV(i, 0.6, 1)
            task.wait(0.04)
        end
    end
end)

local Main = Instance.new("Frame", GlowFrame)
Main.Size = UDim2.new(0, 200, 0, 280)
Main.Position = UDim2.new(0, 2, 0, 2)
Main.BackgroundColor3 = themes[1].Main
Main.ClipsDescendants = true
Instance.new("UICorner", Main)

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = themes[1].Accent
Instance.new("UICorner", Header)

-- 3. LOGIC DI CHUYỂN (Drag)
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
    dragHandle.InputEnded:Connect(function(input) dragging = false end)
end

MakeDraggable(GlowFrame, Header)

-- 4. TIÊU ĐỀ MỚI: TINYCLICK by CAT
local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0.65, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.Text = "TINYCLICK by CAT :3"
Title.TextColor3 = themes[1].Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- 5. NÚT WINDOWS & ICON MÈO DI CHUYỂN
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(0.85, 0, 0.15, 0)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", CloseBtn)

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(0.7, 0, 0.15, 0)
MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", MinBtn)

local CatMin = Instance.new("TextButton", ScreenGui)
CatMin.Size = UDim2.new(0, 50, 0, 50)
CatMin.Visible = false
CatMin.Text = ":3"
CatMin.Font = Enum.Font.GothamBold
CatMin.TextColor3 = Color3.new(1, 1, 1)
CatMin.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", CatMin).CornerRadius = UDim.new(1, 0)

MakeDraggable(CatMin, CatMin)

MinBtn.MouseButton1Click:Connect(function() PlayClickSound() GlowFrame.Visible = false CatMin.Visible = true CatMin.Position = GlowFrame.Position end)
CatMin.MouseButton1Click:Connect(function() 
    PlayClickSound() 
    if CatMin.Position ~= GlowFrame.Position then GlowFrame.Position = CatMin.Position end
    CatMin.Visible = false GlowFrame.Visible = true 
end)
CloseBtn.MouseButton1Click:Connect(function() PlayClickSound() ScreenGui:Destroy() end)

-- 6. TẠO CÁC NÚT CHỨC NĂNG
local function createBtn(text, pos, color)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0, 86, 0, 35)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(PlayClickSound)
    return btn
end

local function CreatePoint(pos, index)
    local dot = Instance.new("TextButton", ScreenGui)
    dot.Size = UDim2.new(0, 22, 0, 22)
    dot.Position = UDim2.new(0, pos.X - 11, 0, pos.Y - 11)
    dot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    dot.Text = tostring(index)
    dot.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local dlText = Instance.new("TextLabel", dot)
    dlText.Size = UDim2.new(0, 40, 0, 20)
    dlText.Position = UDim2.new(1, 2, 0, 0)
    dlText.Text = points[index].delay .. "s"
    dlText.TextColor3 = Color3.new(1, 1, 0)
    dlText.BackgroundTransparency = 1
    dot.MouseButton1Click:Connect(function()
        local box = Instance.new("TextBox", ScreenGui)
        box.Size = UDim2.new(0, 60, 0, 30)
        box.Position = UDim2.new(0, pos.X - 30, 0, pos.Y - 50)
        box.Text = tostring(points[index].delay)
        box.FocusLost:Connect(function()
            local v = tonumber(box.Text)
            if v then points[index].delay = v dlText.Text = v .. "s" end
            box:Destroy()
        end)
    end)
    return dot
end

local ThemeBtn = createBtn("THEME", UDim2.new(0.05, 0, 0.18, 0), Color3.fromRGB(60, 60, 60))
ThemeBtn.Size = UDim2.new(0.9, 0, 0, 30)
ThemeBtn.MouseButton1Click:Connect(function()
    themeIndex = (themeIndex % #themes) + 1
    local t = themes[themeIndex]
    Main.BackgroundColor3 = t.Main Header.BackgroundColor3 = t.Accent Title.TextColor3 = t.Text ThemeBtn.Text = "THEME: "..t.Name
end)

local RecBtn = createBtn("REC", UDim2.new(0.05, 0, 0.35, 0), Color3.fromRGB(180, 50, 50))
local PlayBtn = createBtn("PLAY", UDim2.new(0.52, 0, 0.35, 0), Color3.fromRGB(50, 150, 50))
local ClearBtn = createBtn("CLEAR", UDim2.new(0.05, 0, 0.55, 0), Color3.fromRGB(80, 80, 80))
local LoopBtn = createBtn("LOOP: ON", UDim2.new(0.52, 0, 0.55, 0), Color3.fromRGB(0, 110, 190))

-- 7. LOGIC MACRO FULL
Mouse.Button1Down:Connect(function()
    if isRecording then
        local idx = #points + 1
        points[idx] = {pos = Vector2.new(Mouse.X, Mouse.Y), delay = 0.5}
        points[idx].ui = CreatePoint(points[idx].pos, idx)
    end
end)

RecBtn.MouseButton1Click:Connect(function()
    isRecording = not isRecording
    RecBtn.Text = isRecording and "STOP" or "REC"
    if isRecording then for _, v in pairs(points) do if v.ui then v.ui:Destroy() end end points = {} end
end)

PlayBtn.MouseButton1Click:Connect(function()
    if #points == 0 then return end
    isPlaying = not isPlaying
    PlayBtn.Text = isPlaying and "STOP" or "PLAY"
    task.spawn(function()
        while isPlaying do
            for _, p in ipairs(points) do
                if not isPlaying then break end
                p.ui.BackgroundColor3 = Color3.new(1, 1, 1)
                VirtualInputManager:SendMouseButtonEvent(p.pos.X, p.pos.Y, 0, true, game, 1)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(p.pos.X, p.pos.Y, 0, false, game, 1)
                task.wait(0.1)
                p.ui.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                task.wait(p.delay)
            end
            if not loop then isPlaying = false break end
            task.wait(0.1)
        end
        PlayBtn.Text = "PLAY"
    end)
end)

ClearBtn.MouseButton1Click:Connect(function() for _, v in pairs(points) do if v.ui then v.ui:Destroy() end end points = {} isPlaying = false PlayBtn.Text = "PLAY" end)
LoopBtn.MouseButton1Click:Connect(function() loop = not loop LoopBtn.Text = loop and "LOOP: ON" or "LOOP: OFF" end)

local SupportBtn = createBtn("SUPPORT", UDim2.new(0.05, 0, 0.8, 0), Color3.fromRGB(88, 101, 242))
SupportBtn.Size = UDim2.new(0.9, 0, 0, 35)
SupportBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.com/users/1199321278637678655")
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "TINYCLICK", Text = "COPIED :3", Duration = 3})
end)
