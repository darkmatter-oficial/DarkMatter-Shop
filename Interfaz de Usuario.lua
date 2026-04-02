local function CreateDrawing(type, props)
    local obj = Drawing.new(type)
    for i, v in pairs(props) do obj[i] = v end
    return obj
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DarkMatter_V4.1"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true 
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = CoreGui end

local SelectorFrame = Instance.new("Frame")
SelectorFrame.Name = "GameSelector"
SelectorFrame.Size = UDim2.new(0, 350, 0, 320)
SelectorFrame.Position = UDim2.new(0.5, -175, 0.5, -160)
SelectorFrame.BackgroundColor3 = THEME.Background
SelectorFrame.Parent = ScreenGui
Instance.new("UICorner", SelectorFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", SelectorFrame).Color = THEME.Accent; SelectorFrame.UIStroke.Thickness = 2

local SelectorTabContainer = Instance.new("Frame")
SelectorTabContainer.Size = UDim2.new(1, 0, 0, 40)
SelectorTabContainer.BackgroundColor3 = THEME.TopBar
SelectorTabContainer.Parent = SelectorFrame
Instance.new("UICorner", SelectorTabContainer).CornerRadius = UDim.new(0, 10)

local GamesTabBtn = Instance.new("TextButton")
GamesTabBtn.Size = UDim2.new(0.5, 0, 1, 0)
GamesTabBtn.BackgroundTransparency = 1
GamesTabBtn.Text = "GAME SELECTION"
GamesTabBtn.TextColor3 = THEME.Accent
GamesTabBtn.Font = Enum.Font.GothamBold
GamesTabBtn.TextSize = 12
GamesTabBtn.Parent = SelectorTabContainer

local SettingsTabBtn = Instance.new("TextButton")
SettingsTabBtn.Size = UDim2.new(0.5, 0, 1, 0)
SettingsTabBtn.Position = UDim2.new(0.5, 0, 0, 0)
SettingsTabBtn.BackgroundTransparency = 1
SettingsTabBtn.Text = "SETTINGS"
SettingsTabBtn.TextColor3 = THEME.Text
SettingsTabBtn.Font = Enum.Font.GothamBold
SettingsTabBtn.TextSize = 12
SettingsTabBtn.Parent = SelectorTabContainer

local GamesPage = Instance.new("Frame")
GamesPage.Size = UDim2.new(1, 0, 1, -40)
GamesPage.Position = UDim2.new(0, 0, 0, 40)
GamesPage.BackgroundTransparency = 1
GamesPage.Parent = SelectorFrame

local SettingsPage = Instance.new("Frame")
SettingsPage.Size = UDim2.new(1, 0, 1, -40)
SettingsPage.Position = UDim2.new(0, 0, 0, 40)
SettingsPage.BackgroundTransparency = 1
SettingsPage.Visible = false
SettingsPage.Parent = SelectorFrame

local UniversalBtn = Instance.new("TextButton")
UniversalBtn.Size = UDim2.new(0.8, 0, 0, 50)
UniversalBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
UniversalBtn.BackgroundColor3 = THEME.ElementBG
UniversalBtn.Text = "UNIVERSAL MODE"
UniversalBtn.TextColor3 = THEME.Text
UniversalBtn.Font = Enum.Font.GothamBold
UniversalBtn.Parent = GamesPage
Instance.new("UICorner", UniversalBtn).CornerRadius = UDim.new(0, 6)

local RivalsBtn = Instance.new("TextButton")
RivalsBtn.Size = UDim2.new(0.8, 0, 0, 50)
RivalsBtn.Position = UDim2.new(0.1, 0, 0.5, 0)
RivalsBtn.BackgroundColor3 = THEME.TopBar
RivalsBtn.Text = "RIVALS MODE"
RivalsBtn.TextColor3 = THEME.Accent
RivalsBtn.Font = Enum.Font.GothamBold
RivalsBtn.Parent = GamesPage
Instance.new("UICorner", RivalsBtn).CornerRadius = UDim.new(0, 6)

local function CreateSelectorSlider(text, min, max, default, stateKey, parent, pos)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0.9, 0, 0, 60)
    Frame.Position = pos
    Frame.BackgroundColor3 = THEME.ElementBG
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    
    local Lbl = Instance.new("TextLabel")
    Lbl.Text = text
    Lbl.Size = UDim2.new(1, -10, 0, 30)
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.TextColor3 = THEME.Text
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 12
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Frame
    
    local Val = Instance.new("TextLabel")
    Val.Text = tostring(default)
    Val.Size = UDim2.new(0, 50, 0, 30)
    Val.Position = UDim2.new(1, -60, 0, 0)
    Val.BackgroundTransparency = 1
    Val.TextColor3 = THEME.Accent
    Val.Font = Enum.Font.Code
    Val.TextSize = 12
    Val.Parent = Frame

    local BarBG = Instance.new("Frame")
    BarBG.Size = UDim2.new(1, -20, 0, 6)
    BarBG.Position = UDim2.new(0, 10, 0, 40)
    BarBG.BackgroundColor3 = Color3.fromRGB(40,40,40)
    BarBG.Parent = Frame
    Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = THEME.Accent
    Fill.Parent = BarBG
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function Update(input)
        local delta = math.clamp((input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1)
        local realVal = math.floor((delta * (max - min)) + min)
        State[stateKey] = realVal
        Val.Text = tostring(realVal)
        Fill.Size = UDim2.new(delta, 0, 1, 0)
    end

    BarBG.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; Update(i) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Update(i) end end)
end

CreateSelectorSlider("ESP RENDER DISTANCE", 50, 2000, 500, "ESPRenderDistance", SettingsPage, UDim2.new(0.05, 0, 0.1, 0))
CreateSelectorSlider("AIMBOT GRAB DISTANCE", 50, 1500, 400, "AimbotRange", SettingsPage, UDim2.new(0.05, 0, 0.4, 0))

GamesTabBtn.MouseButton1Click:Connect(function()
    GamesPage.Visible = true
    SettingsPage.Visible = false
    GamesTabBtn.TextColor3 = THEME.Accent
    SettingsTabBtn.TextColor3 = THEME.Text
end)

SettingsTabBtn.MouseButton1Click:Connect(function()
    GamesPage.Visible = false
    SettingsPage.Visible = true
    SettingsTabBtn.TextColor3 = THEME.Accent
    GamesTabBtn.TextColor3 = THEME.Text
end)

local BoxFolder = Instance.new("Folder", ScreenGui)
BoxFolder.Name = "ESP_Boxes"

local FlyBtnUp = {Visible = false} 
local FlyBtnDown = {Visible = false} 

local EditHUDFrame = Instance.new("Frame")
EditHUDFrame.Size = UDim2.new(0, 320, 0, 50)
EditHUDFrame.Position = UDim2.new(0.5, -160, 1, -80)
EditHUDFrame.BackgroundTransparency = 1
EditHUDFrame.Visible = false
EditHUDFrame.ZIndex = 500 
EditHUDFrame.Parent = ScreenGui

local SaveHUDBtn = Instance.new("TextButton")
SaveHUDBtn.Size = UDim2.new(0.48, 0, 1, 0)
SaveHUDBtn.Position = UDim2.new(0, 0, 0, 0)
SaveHUDBtn.BackgroundColor3 = THEME.Success
SaveHUDBtn.TextColor3 = THEME.Background
SaveHUDBtn.Font = Enum.Font.GothamBold
SaveHUDBtn.TextSize = 14
SaveHUDBtn.Text = "SAVE HUD"
SaveHUDBtn.ZIndex = 501 
SaveHUDBtn.Parent = EditHUDFrame
Instance.new("UICorner", SaveHUDBtn).CornerRadius = UDim.new(0, 6)

local CancelHUDBtn = Instance.new("TextButton")
CancelHUDBtn.Size = UDim2.new(0.48, 0, 1, 0)
CancelHUDBtn.Position = UDim2.new(0.52, 0, 0, 0)
CancelHUDBtn.BackgroundColor3 = THEME.Danger
CancelHUDBtn.TextColor3 = THEME.Text
CancelHUDBtn.Font = Enum.Font.GothamBold
CancelHUDBtn.TextSize = 14
CancelHUDBtn.Text = "CANCEL EDIT"
CancelHUDBtn.ZIndex = 501 
CancelHUDBtn.Parent = EditHUDFrame
Instance.new("UICorner", CancelHUDBtn).CornerRadius = UDim.new(0, 6)

local MainFrameVisibilityBackup = true

local function MakeDraggableFloat(guiObject)
    local dragging, dragStart, startPos
    guiObject.InputBegan:Connect(function(input) 
        if not State.EditingHUD then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = true; dragStart = input.Position; startPos = guiObject.Position 
        end 
    end)
    UserInputService.InputChanged:Connect(function(input) 
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then 
            local delta = input.Position - dragStart; 
            guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) 
        end 
    end)
    UserInputService.InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = false 
        end 
    end)
end

local function CreateFloatingButton(text, pos)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 45, 0, 45)
    Btn.Position = pos
    Btn.BackgroundColor3 = THEME.ElementBG
    Btn.TextColor3 = THEME.Text
    Btn.Text = text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Btn.Visible = false
    Btn.ZIndex = 10 
    Btn.Parent = ScreenGui
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
    local Stroke = Instance.new("UIStroke", Btn)
    Stroke.Color = THEME.Accent
    Stroke.Thickness = 2
    MakeDraggableFloat(Btn)
    return Btn, Stroke
end

local ToggleUpdaters = {}
local SliderUpdaters = {}

local FloatAimbotBtn, StrokeAimbot = CreateFloatingButton("AIM", UDim2.new(0, 15, 0.3, 0))
local FloatESPBtn, StrokeESP = CreateFloatingButton("ESP", UDim2.new(0, 15, 0.4, 0))
local FloatFlyBtn, StrokeFly = CreateFloatingButton("FLY", UDim2.new(0, 15, 0.5, 0))

task.spawn(function()
    local posAimbot = LoadHUDPosition("FloatAimbot")
    if posAimbot then FloatAimbotBtn.Position = posAimbot end
    local posESP = LoadHUDPosition("FloatESP")
    if posESP then FloatESPBtn.Position = posESP end
    local posFly = LoadHUDPosition("FloatFly")
    if posFly then FloatFlyBtn.Position = posFly end
end)

local function EnableHUDEdit(v)
    State.EditingHUD = v
    EditHUDFrame.Visible = v
    
    if v then
        MainFrameVisibilityBackup = ScreenGui:FindFirstChild("DarkMatter_V4_Main") and ScreenGui.DarkMatter_V4_Main.Visible or true
        if ScreenGui:FindFirstChild("DarkMatter_V4_Main") then ScreenGui.DarkMatter_V4_Main.Visible = false end
        FloatAimbotBtn.Visible = true
        FloatESPBtn.Visible = true
        FloatFlyBtn.Visible = true
    else
        if ScreenGui:FindFirstChild("DarkMatter_V4_Main") then ScreenGui.DarkMatter_V4_Main.Visible = MainFrameVisibilityBackup end
        FloatAimbotBtn.Visible = State.FloatAimbot
        FloatESPBtn.Visible = State.FloatESP
        FloatFlyBtn.Visible = State.FloatFly
    end
end

local FOVFrame = Instance.new("Frame")
FOVFrame.Name = "DarkMatterFOV"
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0) 
FOVFrame.Size = UDim2.new(0, State.FOVSize * 2, 0, State.FOVSize * 2)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Visible = false
FOVFrame.Parent = ScreenGui
Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(1, 0)
local FOVStroke = Instance.new("UIStroke", FOVFrame); FOVStroke.Color = THEME.Accent; FOVStroke.Thickness = 1.5; FOVStroke.Transparency = 0.2

local MainFrame = Instance.new("Frame")
MainFrame.Name = "DarkMatter_V4_Main"
MainFrame.Size = UDim2.new(0, 400, 0, 350)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
MainFrame.BackgroundColor3 = THEME.Background
MainFrame.ClipsDescendants = true
MainFrame.Visible = false 
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", MainFrame).Color = THEME.Accent; MainFrame.UIStroke.Thickness = 2

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = THEME.TopBar
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = THEME.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Text = "DARKMATTER v4.0"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -115, 0, 5)
MinBtn.BackgroundColor3 = THEME.ElementBG; MinBtn.TextColor3 = THEME.Accent; MinBtn.Font = Enum.Font.GothamBold; MinBtn.TextSize = 18; MinBtn.Text = "▲"; MinBtn.Parent = TitleBar; Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local HideBtn = Instance.new("TextButton")
HideBtn.Size = UDim2.new(0, 30, 0, 30)
HideBtn.Position = UDim2.new(1, -75, 0, 5)
HideBtn.BackgroundColor3 = THEME.ElementBG; HideBtn.TextColor3 = Color3.fromRGB(255, 255, 0); HideBtn.Font = Enum.Font.GothamBold; HideBtn.TextSize = 18; HideBtn.Text = "O"; HideBtn.Parent = TitleBar; Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = THEME.ElementBG; CloseBtn.TextColor3 = THEME.Danger; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 18; CloseBtn.Text = "X"; CloseBtn.Parent = TitleBar; Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local GhostBtn = Instance.new("TextButton")
GhostBtn.Size = UDim2.new(0, 30, 0, 30)
GhostBtn.Position = UDim2.new(0.5, 125, 0.5, -170)
GhostBtn.BackgroundTransparency = 1; GhostBtn.Text = ""; GhostBtn.ZIndex = 999
GhostBtn.Visible = false
GhostBtn.Parent = ScreenGui

local FreecamSystem = {
    isFreecam = false,
    cameraPos = Vector3.new(),
    cameraRot = Vector2.new(),
    speed = 2.0,
    Controls = nil,
    UI = nil,
    internalDisable = false 
}

local function ToggleVisibility(visible)
    State.PanelVisible = visible
    MainFrame.Visible = visible
    GhostBtn.Visible = not visible
    
    if FreecamSystem.UI then
        if not visible then
            FreecamSystem.internalDisable = true
            FreecamSystem.UI.Enabled = false
            if FreecamSystem.isFreecam and _G.ForceDisableFreecamLogic then
                _G.ForceDisableFreecamLogic()
            end
        else
            FreecamSystem.internalDisable = false
            FreecamSystem.UI.Enabled = State.FreecamEnabled
        end
    end
end

HideBtn.MouseButton1Click:Connect(function() ToggleVisibility(false) end)
GhostBtn.MouseButton1Click:Connect(function() ToggleVisibility(true) end)
