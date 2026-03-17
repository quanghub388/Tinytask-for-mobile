--[[ 
    TINYCLICK v13.0 - ULTIMATE EDITION
    Developed by: CAT (Quang)
    Features: UI Library, Tab System, Smooth Toggles, High-Speed Clicker
]]

local VIM = game:GetService("VirtualInputManager")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- == CONFIG ==
local Config = {
    Enabled = false,
    CPS = 10,
    CurrentTab = "Main",
    Theme = Color3.fromRGB(88, 101, 242) -- Discord Blue
}

-- == UI CONSTRUCT ==
local ScreenGui = Instance.new("ScreenGui", LP.PlayerGui)
ScreenGui.Name = "TINYCLICK_V13"
ScreenGui.ResetOnSpawn = false

-- Main Frame
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 350, 0, 250)
Main.Position = UDim2.new(0.5, -175, 0.4, -125)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
local MainCorner = Instance.new("UICorner", Main)

-- Sidebar (Tabs)
local Side = Instance.new("Frame", Main)
Side.Size = UDim2.new(0, 80, 1, 0)
Side.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", Side)

local Title = Instance.new("TextLabel", Side)
Title.Text = "CAT"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.TextColor3 = Config.Theme
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BackgroundTransparency = 1

-- Container for Pages
local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, -90, 1, -10)
Container.Position = UDim2.new(0, 85, 0, 5)
Container.BackgroundTransparency = 1

-- == UI DRAGGABLE ==
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
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- == FUNCTIONS ==
local function CreateToggle(parent, text, default, callback)
    local TFrame = Instance.new("TextButton", parent)
    TFrame.Size = UDim2.new(1, 0, 0, 35)
    TFrame.BackgroundTransparency = 1
    TFrame.Text = ""

    local Label = Instance.new("TextLabel", TFrame)
    Label.Text = text
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = "Left"
    Label.BackgroundTransparency = 1

    local BG = Instance.new("Frame", TFrame)
    BG.Size = UDim2.new(0, 35, 0, 18)
    BG.Position = UDim2.new(1, -40, 0.5, -9)
    BG.BackgroundColor3 = default and Config.Theme or Color3.fromRGB(60, 60, 60)
    Instance.new("UICorner", BG).CornerRadius = UDim.new(1, 0)

    local Circ = Instance.new("Frame", BG)
    Circ.Size = UDim2.new(0, 14, 0, 14)
    Circ.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    Circ.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", Circ).CornerRadius = UDim.new(1, 0)

    local state = default
    TFrame.MouseButton1Click:Connect(function()
        state = not state
        BG:TweenBackgroundColor3(state and Config.Theme or Color3.fromRGB(60, 60, 60), "Out", "Quad", 0.2)
        Circ:TweenPosition(state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), "Out", "Quad", 0.2)
        callback(state)
    end)
end

-- == MAIN LOGIC (CLICKER) ==
task.spawn(function()
    while true do
        if Config.Enabled then
            VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 1)
            task.wait(0.02) -- Anti-lag
            VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 1)
            task.wait(1/Config.CPS)
        else
            task.wait(0.1)
        end
    end
end)

-- == PAGES ==
CreateToggle(Container, "Auto Clicker", false, function(v)
    Config.Enabled = v
end)

-- Thêm một nút Clear đơn giản
local ClearBtn = Instance.new("TextButton", Container)
ClearBtn.Text = "Clear All Points"
ClearBtn.Size = UDim2.new(1, 0, 0, 35)
ClearBtn.Position = UDim2.new(0, 0, 0, 45)
ClearBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ClearBtn.TextColor3 = Color3.new(1,1,1)
ClearBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ClearBtn)

-- == MINIMIZE SYSTEM ==
local MinBtn = Instance.new("TextButton", ScreenGui)
MinBtn.Size = UDim2.new(0, 45, 0, 45)
MinBtn.Position = UDim2.new(0, 10, 0.5, -22)
MinBtn.Text = "CAT"
MinBtn.Visible = false
MinBtn.BackgroundColor3 = Config.Theme
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1, 0)

-- Close Button logic (Hide to MinBtn)
local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0, 20, 0, 20)
Close.Position = UDim2.new(1, -25, 0, 5)
Close.Text = "X"
Close.TextColor3 = Color3.new(1,0,0)
Close.BackgroundTransparency = 1
Close.MouseButton1Click:Connect(function()
    Main.Visible = false
    MinBtn.Visible = true
end)

MinBtn.MouseButton1Click:Connect(function()
    Main.Visible = true
    MinBtn.Visible = false
end)

print("TINYCLICK v13.0 Loaded Successfully!")
