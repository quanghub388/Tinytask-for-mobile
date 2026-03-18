-- [[ TINYCLICK - MODERN UI EDITION ]] --
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Points = {}
local Recording = false
local Playing = false
local Loop = true
local _WaitTime = 0.1

-- 1. TẠO GIAO DIỆN (GUI)
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
ScreenGui.Name = "TINYCLICK_BY_CAT"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 180, 0, 240)
Main.Position = UDim2.new(0.5, -90, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "TINYCLICK"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

-- 2. HÀM KÉO DI CHUYỂN (DRAGGABLE)
local dragging, dragInput, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- 3. HÀM TẠO NÚT BẤM (HELPER)
local function CreateBtn(name, pos, color)
    local btn = Instance.new("TextButton", Main)
    btn.Name = name
    btn.Size = UDim2.new(0, 150, 0, 35)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.AutoButtonColor = true
    Instance.new("UICorner", btn)
    return btn
end

local RecordBtn = CreateBtn("RECORD: OFF", UDim2.new(0, 15, 0, 50), Color3.fromRGB(50, 50, 50))
local PlayBtn = CreateBtn("PLAY: OFF", UDim2.new(0, 15, 0, 95), Color3.fromRGB(50, 50, 50))
local LoopBtn = CreateBtn("LOOP: ON", UDim2.new(0, 15, 0, 140), Color3.fromRGB(0, 120, 0))
local ClearBtn = CreateBtn("CLEAR POINTS", UDim2.new(0, 15, 0, 185), Color3.fromRGB(120, 0, 0))

-- 4. LOGIC XỬ LÝ
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if Recording and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        table.insert(Points, {x = input.Position.X, y = input.Position.Y})
        RecordBtn.Text = "POINTS: "..#Points
    end
end)

RecordBtn.MouseButton1Click:Connect(function()
    Recording = not Recording
    RecordBtn.Text = Recording and "RECORDING..." or "RECORD: OFF"
    RecordBtn.BackgroundColor3 = Recording and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(50, 50, 50)
end)

local function RunPlayback()
    Playing = true
    PlayBtn.Text = "PLAYING..."
    PlayBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    
    repeat
        for i, p in pairs(Points) do
            if not Playing then break end
            VIM:SendMouseButtonEvent(p.x, p.y, 0, true, game, 0)
            VIM:SendMouseButtonEvent(p.x, p.y, 0, false, game, 0)
            task.wait(_WaitTime)
        end
    until not Loop or not Playing
    
    Playing = false
    PlayBtn.Text = "PLAY: OFF"
    PlayBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end

PlayBtn.MouseButton1Click:Connect(function()
    if #Points == 0 then return end
    if Playing then
        Playing = false
    else
        task.spawn(RunPlayback)
    end
end)

LoopBtn.MouseButton1Click:Connect(function()
    Loop = not Loop
    LoopBtn.Text = Loop and "LOOP: ON" or "LOOP: OFF"
    LoopBtn.BackgroundColor3 = Loop and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(80, 80, 80)
end)

ClearBtn.MouseButton1Click:Connect(function()
    table.clear(Points)
    RecordBtn.Text = "RECORD: OFF"
    Playing = false
end)
