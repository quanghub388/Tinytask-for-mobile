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

-- 2. GIAO DIỆN & VIỀN PHÁT SÁNG NHẸ
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
ScreenGui.Name = "TinyDelta_V8_Pro"

local GlowFrame = Instance.new("Frame", ScreenGui)
GlowFrame.Size = UDim2.new(0, 204, 0, 284)
GlowFrame.Position = UDim2.new(0.5, -102, 0.2, -2)
GlowFrame.BackgroundColor3 = Color3.new(1, 1, 1)
GlowFrame.BorderSizePixel = 0
Instance.new("UICorner", GlowFrame)

-- Hiệu ứng phát sáng viền mềm mại
task.spawn(function()
    while GlowFrame.Parent do
        for i = 0, 1, 0.005 do
            if not GlowFrame.Parent then break end
            GlowFrame.BackgroundColor3 = Color3.fromHSV(i, 0.6, 1) -- Màu nhạt hơn cho dịu mắt
            task.wait(0.05)
        end
    end
end)

local Main = Instance.new("Frame", GlowFrame)
Main.Size = UDim2.new(0, 200, 0, 280)
Main.Position = UDim2.new(0, 2, 0, 2)
Main.BackgroundColor3 = themes[1].Main
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main)

-- 3. LOGIC DI CHUYỂN TỰ DO (DRAGGABLE)
local dragging, dragInput, dragStart, startPos
Header = Instance.new("Frame", Main) -- Cần khai báo Header trước để dùng cho Drag
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = themes[1].Accent
Instance.new("UICorner", Header)

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = GlowFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        GlowFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- [Các nút Close, Min, CatMin giữ nguyên logic nhưng cập nhật âm thanh...]
-- (Ông dán tiếp phần nút REC, PLAY, THEME từ bản v7 vào đây nhé)

-- 4. NÚT SUPPORT VỚI THÔNG BÁO MỚI
local SupportBtn = Instance.new("TextButton", Main)
SupportBtn.Size = UDim2.new(0.9, 0, 0, 35)
SupportBtn.Position = UDim2.new(0.05, 0, 0.8, 0)
SupportBtn.Text = "SUPPORT"
SupportBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
SupportBtn.TextColor3 = Color3.new(1, 1, 1)
SupportBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", SupportBtn)

SupportBtn.MouseButton1Click:Connect(function()
    PlayClickSound()
    setclipboard("https://discord.com/users/1199321278637678655")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "TINYDELTA",
        Text = "COPIED :3",
        Duration = 3
    })
end)
