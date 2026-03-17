--[[ 
    TINYCLICK v13.1 - PROFESSIONAL EDITION
    Developed by: CAT (Quang)
    Status: FULL VERSION (No Cut)
]]

local VIM = game:GetService("VirtualInputManager")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- == HỆ THỐNG CẤU HÌNH ==
local Config = {
    Enabled = false,
    CPS = 10,
    Theme = Color3.fromRGB(88, 101, 242), -- Màu xanh Discord ngầu lòi
    Dragging = false
}

-- == KHỞI TẠO UI CHÍNH ==
local ScreenGui = Instance.new("ScreenGui", LP.PlayerGui)
ScreenGui.Name = "TINYCLICK_V13_FULL"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 380, 0, 280)
Main.Position = UDim2.new(0.5, -190, 0.4, -140)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
local MainCorner = Instance.new("UICorner", Main)

-- Sidebar (Thanh bên)
local Side = Instance.new("Frame", Main)
Side.Size = UDim2.new(0, 100, 1, 0)
Side.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", Side)

local Title = Instance.new("TextLabel", Side)
Title.Text = "TINYCLICK"
Title.Size = UDim2.new(1, 0, 0, 45)
Title.TextColor3 = Config.Theme
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BackgroundTransparency = 1

-- Page Container (Nơi chứa các trang)
local PageContainer = Instance.new("Frame", Main)
PageContainer.Size = UDim2.new(1, -110, 1, -10)
PageContainer.Position = UDim2.new(0, 105, 0, 5)
PageContainer.BackgroundTransparency = 1

-- == HỆ THỐNG TAB & PAGE ==
local Pages = {}
local TabButtons = {}

local function CreatePage(name, isDefault)
    local Page = Instance.new("ScrollingFrame", PageContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = isDefault or false
    Page.ScrollBarThickness = 0
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local Layout = Instance.new("UIListLayout", Page)
    Layout.Padding = UDim.new(0, 8)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    local TabBtn = Instance.new("TextButton", Side)
    TabBtn.Size = UDim2.new(1, -10, 0, 35)
    TabBtn.Position = UDim2.new(0, 5, 0, 50 + (#TabButtons * 40))
    TabBtn.Text = name
    TabBtn.BackgroundColor3 = isDefault and Config.Theme or Color3.fromRGB(40, 40, 40)
    TabBtn.TextColor3 = Color3.new(1,1,1)
    TabBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", TabBtn)
    
    TabButtons[name] = TabBtn
    Pages[name] = Page

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in pairs(TabButtons) do b.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
        Page.Visible = true
        TabBtn.BackgroundColor3 = Config.Theme
    end)
    
    return Page
end

-- == COMPONENTS (Toggle & Slider) ==
local function AddToggle(parent, text, callback)
    local TBtn = Instance.new("TextButton", parent)
    TBtn.Size = UDim2.new(1, 0, 0, 40)
    TBtn.Text = "  " .. text .. " : OFF"
    TBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TBtn.TextColor3 = Color3.new(1,1,1)
    TBtn.Font = Enum.Font.Gotham
    TBtn.TextXAlignment = "Left"
    Instance.new("UICorner", TBtn)
    
    local state = false
    TBtn.MouseButton1Click:Connect(function()
        state = not state
        TBtn.Text = "  " .. text .. (state and " : ON" or " : OFF")
        TweenService:Create(TBtn, TweenInfo.new(0.3), {BackgroundColor3 = state and Config.Theme or Color3.fromRGB(45, 45, 45)}):Play()
        callback(state)
    end)
end

local function AddSlider(parent, text, min, max, def, callback)
    local SFrame = Instance.new("Frame", parent)
    SFrame.Size = UDim2.new(1, 0, 0, 55); SFrame.BackgroundTransparency = 1
    
    local Lbl = Instance.new("TextLabel", SFrame)
    Lbl.Text = text .. ": " .. def; Lbl.Size = UDim2.new(1,0,0,25); Lbl.TextColor3 = Color3.new(1,1,1); Lbl.BackgroundTransparency = 1; Lbl.Font = Enum.Font.Gotham
    
    local SliderBG = Instance.new("Frame", SFrame)
    SliderBG.Size = UDim2.new(1,-10,0,8); SliderBG.Position = UDim2.new(0,5,0,30); SliderBG.BackgroundColor3 = Color3.fromRGB(60,60,60)
    Instance.new("UICorner", SliderBG)
    
    local Fill = Instance.new("Frame", SliderBG)
    Fill.Size = UDim2.new((def-min)/(max-min),0,1,0); Fill.BackgroundColor3 = Config.Theme
    Instance.new("UICorner", Fill)
    
    local Btn = Instance.new("TextButton", SliderBG)
    Btn.Size = UDim2.new(1,0,1,0); Btn.BackgroundTransparency = 1; Btn.Text = ""
    
    local function UpdateSlider(input)
        local p = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(p, 0, 1, 0)
        local v = math.floor(min + (max-min)*p)
        Lbl.Text = text .. ": " .. v
        callback(v)
    end

    local dragging = false
    Btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateSlider(input)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end

-- == LOGIC CLICKER (Tối ưu theo kiểu Pro) ==
local function StartClicking()
    task.spawn(function()
        while Config.Enabled do
            VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 1)
            task.wait(0.01) -- Click cực nhanh
            VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 1)
            task.wait(1/Config.CPS)
        end
    end)
end

-- == DRAGGABLE (Kéo thả mượt mà) ==
local dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Config.Dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if Config.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Config.Dragging = false end end)

-- == THIẾT LẬP TRANG & TÍNH NĂNG ==
local MainPage = CreatePage("Main", true)
local OptionPage = CreatePage("Settings", false)

AddToggle(MainPage, "Auto Click", function(v)
    Config.Enabled = v
    if v then StartClicking() end
end)

AddSlider(OptionPage, "Tốc độ (CPS)", 1, 60, 10, function(v)
    Config.CPS = v
end)

-- Nút thu nhỏ (Minimize)
local MinBtn = Instance.new("TextButton", ScreenGui)
MinBtn.Size = UDim2.new(0, 45, 0, 45)
MinBtn.Position = UDim2.new(0, 10, 0.5, -22)
MinBtn.Text = "CAT"
MinBtn.Visible = false
MinBtn.BackgroundColor3 = Config.Theme
MinBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1, 0)

local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.Text = "—"
Close.TextColor3 = Color3.new(1,1,1)
Close.BackgroundTransparency = 1
Close.MouseButton1Click:Connect(function()
    Main.Visible = false
    MinBtn.Visible = true
end)

MinBtn.MouseButton1Click:Connect(function()
    Main.Visible = true
    MinBtn.Visible = false
end)

print("TINYCLICK v13.1 PRO LOADED SUCCESSFULLY!")
