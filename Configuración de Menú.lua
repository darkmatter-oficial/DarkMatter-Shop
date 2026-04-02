local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -80)
Container.Position = UDim2.new(0, 10, 0, 75)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 3
Container.ScrollBarImageColor3 = THEME.Accent
Container.Parent = MainFrame
local UIList = Instance.new("UIListLayout"); UIList.Parent = Container; UIList.Padding = UDim.new(0, 8); UIList.SortOrder = Enum.SortOrder.LayoutOrder 

UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Container.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 10)
end)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 30)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = THEME.TopBar
TabBar.Parent = MainFrame

local TabList = Instance.new("UIListLayout")
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Parent = TabBar

local currentActiveTab = "COMBAT"
local CategoryFrames = {}

local function CreateTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.20, 0, 1, 0)
    btn.BackgroundColor3 = THEME.TopBar
    btn.Text = name
    btn.TextColor3 = THEME.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.LayoutOrder = order
    btn.Parent = TabBar

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = THEME.Accent
    stroke.Thickness = 1

    btn.MouseButton1Click:Connect(function()
        currentActiveTab = name
        for tabName, tabBtn in pairs(CategoryFrames) do
            if tabName == name then
                tabBtn.BackgroundColor3 = THEME.Accent
                tabBtn.TextColor3 = THEME.TopBar
            else
                tabBtn.BackgroundColor3 = THEME.TopBar
                tabBtn.TextColor3 = THEME.Text
            end
        end
        if _G.UpdateCategoryVisibility then _G.UpdateCategoryVisibility() end
    end)

    CategoryFrames[name] = btn
    return btn
end

CreateTab("COMBAT", 1)
CreateTab("VISUALS", 2)
CreateTab("MOVEMENT", 3)
CreateTab("MISC", 4)
CreateTab("INFORMATION", 5)

local ConfirmFrame = Instance.new("Frame")
ConfirmFrame.Size = UDim2.new(0, 280, 0, 140)
ConfirmFrame.Position = UDim2.new(0.5, -140, 0.5, -70)
ConfirmFrame.BackgroundColor3 = THEME.Background; ConfirmFrame.Visible = false; ConfirmFrame.ZIndex = 600; ConfirmFrame.Parent = ScreenGui; Instance.new("UICorner", ConfirmFrame).CornerRadius = UDim.new(0, 10)
local ConfirmStroke = Instance.new("UIStroke", ConfirmFrame); ConfirmStroke.Color = THEME.Accent; ConfirmStroke.Thickness = 2

local ConfirmTitle = Instance.new("TextLabel")
ConfirmTitle.Size = UDim2.new(1, 0, 0, 70); ConfirmTitle.BackgroundTransparency = 1; ConfirmTitle.Text = "Close DARKMATTER?\n(All processes will be disabled)"; ConfirmTitle.TextColor3 = THEME.Text; ConfirmTitle.Font = Enum.Font.GothamBold; ConfirmTitle.TextSize = 14; ConfirmTitle.ZIndex = 601; ConfirmTitle.Parent = ConfirmFrame

local YesBtn = Instance.new("TextButton")
YesBtn.Size = UDim2.new(0, 110, 0, 40); YesBtn.Position = UDim2.new(0, 20, 1, -55); YesBtn.BackgroundColor3 = THEME.Accent; YesBtn.Text = "YES, CLOSE"; YesBtn.TextColor3 = THEME.Text; YesBtn.Font = Enum.Font.GothamBold; YesBtn.ZIndex = 601; YesBtn.Parent = ConfirmFrame; Instance.new("UICorner", YesBtn).CornerRadius = UDim.new(0, 6)

local NoBtn = Instance.new("TextButton")
NoBtn.Size = UDim2.new(0, 110, 0, 40); NoBtn.Position = UDim2.new(1, -130, 1, -55); NoBtn.BackgroundColor3 = THEME.ElementBG; NoBtn.Text = "CANCEL"; NoBtn.TextColor3 = THEME.Text; NoBtn.Font = Enum.Font.GothamBold; NoBtn.ZIndex = 601; NoBtn.Parent = ConfirmFrame; Instance.new("UICorner", NoBtn).CornerRadius = UDim.new(0, 6)

local function ClearAllVisuals()
    BoxFolder:ClearAllChildren()
    for p, _ in pairs(Tracers) do if Tracers[p] then Tracers[p]:Remove(); Tracers[p] = nil end end
    for p, _ in pairs(Labels) do if Labels[p] then Labels[p]:Remove(); Labels[p] = nil end end
    for p, _ in pairs(HealthBars) do if HealthBars[p] then HealthBars[p]:Remove(); HealthBars[p] = nil end end
    for p, _ in pairs(Crosshairs) do
        if Crosshairs[p] then
            if Crosshairs[p].Circle then Crosshairs[p].Circle:Remove() end
            if Crosshairs[p].LineH then Crosshairs[p].LineH:Remove() end
            if Crosshairs[p].LineV then Crosshairs[p].LineV:Remove() end
            Crosshairs[p] = nil
        end
    end
    FOVFrame.Visible = false
    for part, _ in pairs(XRayParts) do
        if part then part.LocalTransparencyModifier = 0 end
    end
    XRayParts = {}
end

local function InitFreecam()
    local playerScripts = LocalPlayer:WaitForChild("PlayerScripts")
    local PlayerModule = require(playerScripts:WaitForChild("PlayerModule"))
    FreecamSystem.Controls = PlayerModule:GetControls()

    local fcGui = Instance.new("ScreenGui")
    fcGui.Name = "DarkMatter_FreecamUI"
    fcGui.ResetOnSpawn = false
    fcGui.Enabled = false
    fcGui.Parent = (gethui and gethui()) or CoreGui
    FreecamSystem.UI = fcGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 180, 0, 210) 
    mainFrame.Position = UDim2.new(0, 20, 0.5, -105)
    mainFrame.BackgroundColor3 = THEME.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = fcGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", mainFrame); stroke.Color = THEME.Accent; stroke.Thickness = 2

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "FREECAM MENU"
    titleLabel.TextColor3 = THEME.Text
    titleLabel.Font = Enum.Font.Code
    titleLabel.TextSize = 14
    titleLabel.Parent = mainFrame

    local miniBtn = Instance.new("TextButton")
    miniBtn.Size = UDim2.new(0, 25, 0, 25)
    miniBtn.Position = UDim2.new(1, -30, 0, 2.5)
    miniBtn.BackgroundColor3 = THEME.ElementBG
    miniBtn.BorderSizePixel = 0
    miniBtn.Text = "-"
    miniBtn.TextColor3 = THEME.Text
    miniBtn.Font = Enum.Font.SourceSansBold
    miniBtn.TextSize = 20
    miniBtn.Parent = mainFrame
    Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 5)

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 150, 0, 40)
    toggleBtn.Position = UDim2.new(0.5, -75, 0, 40)
    toggleBtn.BackgroundColor3 = THEME.ElementBG
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "FREECAM: OFF"
    toggleBtn.TextColor3 = THEME.Danger
    toggleBtn.Font = Enum.Font.Code
    toggleBtn.TextSize = 14
    toggleBtn.Parent = mainFrame
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 5)

    local tpBtn = Instance.new("TextButton")
    tpBtn.Size = UDim2.new(0, 150, 0, 40)
    tpBtn.Position = UDim2.new(0.5, -75, 0, 85)
    tpBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    tpBtn.BorderSizePixel = 0
    tpBtn.Text = "TELEPORT"
    tpBtn.TextColor3 = Color3.fromRGB(100, 100, 100)
    tpBtn.Font = Enum.Font.Code
    tpBtn.TextSize = 14
    tpBtn.Parent = mainFrame
    Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 5)

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0, 150, 0, 60)
    sliderFrame.Position = UDim2.new(0.5, -75, 0, 135)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = mainFrame

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, 0, 0, 20)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "SPEED: " .. tostring(FreecamSystem.speed)
    speedLabel.TextColor3 = THEME.Text
    speedLabel.Font = Enum.Font.Code
    speedLabel.TextSize = 12
    speedLabel.Parent = sliderFrame

    local barBG = Instance.new("Frame")
    barBG.Size = UDim2.new(1, 0, 0, 6)
    barBG.Position = UDim2.new(0, 0, 0.7, 0)
    barBG.BackgroundColor3 = Color3.fromRGB(40,40,40)
    barBG.Parent = sliderFrame
    Instance.new("UICorner", barBG).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(FreecamSystem.speed / 10, 0, 1, 0)
    fill.BackgroundColor3 = THEME.Accent
    fill.Parent = barBG
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - barBG.AbsolutePosition.X) / barBG.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor((pos * 10) * 10) / 10 
        if val < 0.1 then val = 0.1 end
        FreecamSystem.speed = val
        speedLabel.Text = "SPEED: " .. tostring(val)
    end

    local sliding = false
    barBG.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = true; updateSlider(i) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end end)
    UserInputService.InputChanged:Connect(function(i) if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then updateSlider(i) end end)

    local isMinimized = false
    miniBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            mainFrame:TweenSize(UDim2.new(0, 180, 0, 30), "Out", "Quad", 0.3, true)
            toggleBtn.Visible = false
            tpBtn.Visible = false
            sliderFrame.Visible = false
            miniBtn.Text = "+"
        else
            toggleBtn.Visible = true
            tpBtn.Visible = true
            sliderFrame.Visible = true
            mainFrame:TweenSize(UDim2.new(0, 180, 0, 210), "Out", "Quad", 0.3, true)
            miniBtn.Text = "-"
        end
    end)

    local function disableFreecam()
        FreecamSystem.isFreecam = false
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        toggleBtn.Text = "FREECAM: OFF"
        toggleBtn.TextColor3 = THEME.Danger
        stroke.Color = THEME.Accent
        tpBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        tpBtn.TextColor3 = Color3.fromRGB(100, 100, 100)
        Camera.CameraType = Enum.CameraType.Custom
        if hrp then hrp.Anchored = false end
    end
    
    _G.ForceDisableFreecamLogic = disableFreecam

    tpBtn.MouseButton1Click:Connect(function()
        if not FreecamSystem.isFreecam then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(FreecamSystem.cameraPos)
            disableFreecam()
        end
    end)

    toggleBtn.MouseButton1Click:Connect(function()
        if FreecamSystem.isFreecam then
            disableFreecam()
        else
            FreecamSystem.isFreecam = true
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            toggleBtn.Text = "FREECAM: ON"
            toggleBtn.TextColor3 = THEME.Success
            stroke.Color = THEME.Success
            tpBtn.BackgroundColor3 = THEME.ElementBG
            tpBtn.TextColor3 = THEME.Text
            FreecamSystem.cameraPos = Camera.CFrame.Position
            local x, y, z = Camera.CFrame:ToOrientation()
            FreecamSystem.cameraRot = Vector2.new(x, y)
            Camera.CameraType = Enum.CameraType.Scriptable
            if hrp then hrp.Anchored = true end
        end
    end)

    RunService.RenderStepped:Connect(function(dt)
        if not FreecamSystem.isFreecam or not ScriptRunning or FreecamSystem.internalDisable then return end
        local moveVector = FreecamSystem.Controls:GetMoveVector()
        if moveVector.Magnitude > 0 then
            local currentRotation = CFrame.Angles(0, FreecamSystem.cameraRot.Y, 0) * CFrame.Angles(FreecamSystem.cameraRot.X, 0, 0)
            local forward = currentRotation.LookVector * -moveVector.Z
            local right = currentRotation.RightVector * moveVector.X
            local moveDir = (forward + right)
            FreecamSystem.cameraPos = FreecamSystem.cameraPos + (moveDir * FreecamSystem.speed)
        end
        Camera.CFrame = CFrame.new(FreecamSystem.cameraPos) * CFrame.Angles(0, FreecamSystem.cameraRot.Y, 0) * CFrame.Angles(FreecamSystem.cameraRot.X, 0, 0)
    end)

    UserInputService.InputChanged:Connect(function(input, processed)
        if not FreecamSystem.isFreecam or processed or not ScriptRunning or FreecamSystem.internalDisable then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Delta
            FreecamSystem.cameraRot = FreecamSystem.cameraRot + Vector2.new(-delta.Y * 0.007, -delta.X * 0.007)
        end
    end)
    
    return fcGui
end

local FreecamGuiObject = InitFreecam()

local bv, bg
local function ToggleFly(v)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then 
        return 
    end
    
    if v then
        bv = Instance.new("BodyVelocity", char.HumanoidRootPart)
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = Vector3.new(0,0,0)
        bg = Instance.new("BodyGyro", char.HumanoidRootPart)
        bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bg.P = 10000
        bg.CFrame = char.HumanoidRootPart.CFrame
        
        local playerScripts = LocalPlayer:WaitForChild("PlayerScripts")
        local PlayerModule = require(playerScripts:WaitForChild("PlayerModule"))
        local Controls = PlayerModule:GetControls()

        task.spawn(function()
            while State.Fly and ScriptRunning do 
                RunService.RenderStepped:Wait()
                if not bv or not bg or not char.HumanoidRootPart then break end
                
                local lookVector = Camera.CFrame.LookVector
                local rightVector = Camera.CFrame.RightVector
                local moveVector = Controls:GetMoveVector()
                
                local finalVelocity = (lookVector * -moveVector.Z + rightVector * moveVector.X).Unit
                if moveVector.Magnitude > 0 then
                    bv.Velocity = finalVelocity * State.FlySpeed
                else
                    bv.Velocity = Vector3.new(0, 0, 0)
                end
                
                bg.CFrame = Camera.CFrame
                char.Humanoid.PlatformStand = true 
            end
        end)
    else 
        if bv then bv:Destroy(); bv = nil end
        if bg then bg:Destroy(); bg = nil end
        if char and char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false end 
    end
end

UserInputService.JumpRequest:Connect(function()
    if State.MultiJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    if State.Fly then
        task.wait(0.5)
        ToggleFly(true)
    end
end)

local function ResetAllStates()
    for k, v in pairs(State) do
        if type(v) == "boolean" then
            State[k] = false
        end
    end
    
    local ItemsModule = game:GetService("ReplicatedStorage"):FindFirstChild("Modules") and game:GetService("ReplicatedStorage").Modules:FindFirstChild("ItemLibrary")
    if ItemsModule then
        local Items = require(ItemsModule).Items
        for id, data in pairs(Items) do
            if typeof(data) == "table" and OriginalFireRates[id] then
                data.ShootCooldown = OriginalFireRates[id].sc
                data.ShootBurstCooldown = OriginalFireRates[id].sbc
            end
        end
    end
    
    ClearAllVisuals()
    ToggleFly(false)
    Camera.FieldOfView = 70
    
    if FreecamGuiObject then FreecamGuiObject.Enabled = false end
    FreecamSystem.isFreecam = false
    Camera.CameraType = Enum.CameraType.Custom
    
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("DarkESP") then
            p.Character.DarkESP:Destroy()
        end
    end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = 16
        char.Humanoid.JumpPower = 50
        char.Humanoid.PlatformStand = false
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

local function ShutdownPanel()
    ScriptRunning = false 
    ResetAllStates()
    ScreenGui:Destroy()
    if FreecamGuiObject then FreecamGuiObject:Destroy() end
end

CloseBtn.MouseButton1Click:Connect(function() ConfirmFrame.Visible = true end)
NoBtn.MouseButton1Click:Connect(function() ConfirmFrame.Visible = false end)
YesBtn.MouseButton1Click:Connect(function() ShutdownPanel() end)

MinBtn.MouseButton1Click:Connect(function()
    State.IsMinimized = not State.IsMinimized
    if State.IsMinimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.4), {Size = UDim2.new(0, 400, 0, 40)}):Play()
        MinBtn.Text = "▼"; Container.Visible = false
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.4), {Size = UDim2.new(0, 400, 0, 350)}):Play()
        MinBtn.Text = "▲"; task.delay(0.1, function() Container.Visible = true end)
    end
end)

local function MakeDraggable(guiObject, target)
    local dragging, dragStart, startPos
    guiObject.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = target.Position end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart; target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y); GhostBtn.Position = target.Position + UDim2.new(0, 325, 0, 5) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end
MakeDraggable(TitleBar, MainFrame)

FloatAimbotBtn.MouseButton1Click:Connect(function()
    if State.EditingHUD then return end
    
    local allActive = State.AimbotMobile and State.ShowFOV
    local newState = not allActive
    
    if ToggleUpdaters["AimbotMobile"] then ToggleUpdaters["AimbotMobile"](newState) end
    if ToggleUpdaters["ShowFOV"] then ToggleUpdaters["ShowFOV"](newState) end
    
    StrokeAimbot.Color = (State.AimbotMobile and State.ShowFOV) and THEME.Success or THEME.Accent
end)

FloatESPBtn.MouseButton1Click:Connect(function()
    if State.EditingHUD then return end
    
    local allActive = State.ESP and State.ESPLine and State.ESPBox and State.ESPInfo and State.ESPHealth
    local newState = not allActive
    
    if ToggleUpdaters["ESP"] then ToggleUpdaters["ESP"](newState) end
    if ToggleUpdaters["ESPLine"] then ToggleUpdaters["ESPLine"](newState) end
    if ToggleUpdaters["ESPBox"] then ToggleUpdaters["ESPBox"](newState) end
    if ToggleUpdaters["ESPInfo"] then ToggleUpdaters["ESPInfo"](newState) end
    if ToggleUpdaters["ESPHealth"] then ToggleUpdaters["ESPHealth"](newState) end
    
    if not newState then BoxFolder:ClearAllChildren() end
    StrokeESP.Color = (State.ESP and State.ESPLine and State.ESPBox and State.ESPInfo and State.ESPHealth) and THEME.Success or THEME.Accent
end)

FloatFlyBtn.MouseButton1Click:Connect(function()
    if State.EditingHUD then return end
    local newState = not State.Fly
    if ToggleUpdaters["Fly"] then ToggleUpdaters["Fly"](newState) end
    StrokeFly.Color = State.Fly and THEME.Success or THEME.Accent
end)

local layoutIdx = 0
local function getNextOrder() layoutIdx = layoutIdx + 1; return layoutIdx end

local function CreateToggle(text, stateKey, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 40); Frame.BackgroundColor3 = THEME.ElementBG; Frame.Parent = Container; Frame.LayoutOrder = getNextOrder()
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    local Lbl = Instance.new("TextLabel"); Lbl.Text = "  " .. text; Lbl.Size = UDim2.new(0.7, 0, 1, 0); Lbl.BackgroundTransparency = 1; Lbl.TextColor3 = THEME.Text; Lbl.Font = Enum.Font.GothamSemibold; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Frame
    local Switch = Instance.new("TextButton"); Switch.Text = ""; Switch.Size = UDim2.new(0, 40, 0, 20); Switch.Position = UDim2.new(1, -50, 0.5, -10); Switch.BackgroundColor3 = State[stateKey] and THEME.Accent or Color3.fromRGB(50,50,50); Switch.Parent = Frame; Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
    local Dot = Instance.new("Frame"); Dot.Size = UDim2.new(0, 16, 0, 16); Dot.Position = State[stateKey] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8); Dot.BackgroundColor3 = THEME.Text; Dot.Parent = Switch; Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    
    local function UpdateVisuals()
        TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = State[stateKey] and THEME.Accent or Color3.fromRGB(50,50,50)}):Play()
        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = State[stateKey] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        
        if stateKey == "AimbotMobile" or stateKey == "ShowFOV" then
            StrokeAimbot.Color = (State.AimbotMobile and State.ShowFOV) and THEME.Success or THEME.Accent
        elseif stateKey == "ESP" or stateKey == "ESPLine" or stateKey == "ESPBox" or stateKey == "ESPInfo" or stateKey == "ESPHealth" then
            StrokeESP.Color = (State.ESP and State.ESPLine and State.ESPBox and State.ESPInfo and State.ESPHealth) and THEME.Success or THEME.Accent
        elseif stateKey == "Fly" then
            StrokeFly.Color = State.Fly and THEME.Success or THEME.Accent
        end
    end

    ToggleUpdaters[stateKey] = function(forceState)
        if forceState ~= nil then
            State[stateKey] = forceState
        else
            State[stateKey] = not State[stateKey]
        end
        UpdateVisuals()
        if callback then callback(State[stateKey]) end
    end

    Switch.MouseButton1Click:Connect(function()
        ToggleUpdaters[stateKey]()
    end)
    return Frame
end

local function CreateButton(text, callback, parent)
    local Btn = Instance.new("TextButton")
    Btn.Text = text; Btn.Size = UDim2.new(1, -10, 0, 35); Btn.BackgroundColor3 = THEME.ElementBG; Btn.TextColor3 = THEME.Text; Btn.Font = Enum.Font.GothamBold; Btn.Parent = parent or Container; Btn.LayoutOrder = getNextOrder()
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(function() callback() end)
    return Btn
end

local function CreateSlider(text, min, max, default, callback, parent, stateKey)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 55); Frame.BackgroundColor3 = THEME.ElementBG; Frame.Parent = parent or Container; Frame.LayoutOrder = getNextOrder()
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    local Lbl = Instance.new("TextLabel"); Lbl.Text = "  " .. text; Lbl.Size = UDim2.new(0.5, 0, 0, 25); Lbl.BackgroundTransparency = 1; Lbl.TextColor3 = THEME.Text; Lbl.Font = Enum.Font.GothamSemibold; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Frame
    local Val = Instance.new("TextLabel"); Val.Text = tostring(default); Val.Size = UDim2.new(0.5, -10, 0, 25); Val.Position = UDim2.new(0.5, 0, 0, 0); Val.BackgroundTransparency = 1; Val.TextColor3 = THEME.Accent; Val.Font = Enum.Font.Code; Val.TextXAlignment = Enum.TextXAlignment.Right; Val.Parent = Frame
    local BarBG = Instance.new("Frame"); BarBG.Size = UDim2.new(1, -20, 0, 6); BarBG.Position = UDim2.new(0, 10, 0, 35); BarBG.BackgroundColor3 = Color3.fromRGB(40,40,40); BarBG.Parent = Frame; Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1, 0)
    local Fill = Instance.new("Frame"); Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0); Fill.BackgroundColor3 = THEME.Accent; Fill.Parent = BarBG; Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    
    local function UpdateVisuals(v)
        local pos = (v - min) / (max - min)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        Val.Text = tostring(v)
    end

    if stateKey then
        SliderUpdaters[stateKey] = function(newVal)
            UpdateVisuals(newVal)
            callback(newVal)
        end
    end

    local dragging = false
    local function Update(input)
        local pos = math.clamp((input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1)
        local realValue = math.floor((pos * (max - min)) + min)
        UpdateVisuals(realValue)
        callback(realValue)
    end
    BarBG.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; Update(i) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Update(i) end end)
    return Frame
end

local Section1 = Instance.new("TextLabel"); Section1.Text = "  COMBAT & VISUALS"; Section1.Size = UDim2.new(1,0,0,20); Section1.TextColor3 = THEME.Accent; Section1.BackgroundTransparency = 1; Section1.Font = Enum.Font.GothamBlack; Section1.Parent = Container; Section1.LayoutOrder = getNextOrder()

CreateToggle("📦 ESP BOX (DARK)", "ESPBox", function(v) if not v then BoxFolder:ClearAllChildren() end end)
CreateToggle("📏 ESP DISTANCE & NAME", "ESPInfo", nil)
CreateToggle("❤️ ESP LIFE BAR", "ESPHealth", nil)
CreateToggle("🚩 ESP LINE (MOD)", "ESPLine", nil)

local LinePosFrame = Instance.new("Frame"); LinePosFrame.Size = UDim2.new(1, -10, 0, 40); LinePosFrame.BackgroundColor3 = THEME.ElementBG; LinePosFrame.Parent = Container; LinePosFrame.LayoutOrder = getNextOrder()
Instance.new("UICorner", LinePosFrame).CornerRadius = UDim.new(0, 6)
local LPLbl = Instance.new("TextLabel"); LPLbl.Text = "  LINE POSITION:"; LPLbl.Size = UDim2.new(0.4, 0, 1, 0); LPLbl.BackgroundTransparency = 1; LPLbl.TextColor3 = THEME.Text; LPLbl.Font = Enum.Font.GothamSemibold; LPLbl.TextXAlignment = Enum.TextXAlignment.Left; LPLbl.Parent = LinePosFrame
local LPBtn = Instance.new("TextButton"); LPBtn.Size = UDim2.new(0.55, 0, 0.7, 0); LPBtn.Position = UDim2.new(0.42, 0, 0.15, 0); LPBtn.BackgroundColor3 = THEME.TopBar; LPBtn.Text = State.ESPLinePos; LPBtn.TextColor3 = THEME.Accent; LPBtn.Font = Enum.Font.GothamBold; LPBtn.TextSize = 12; LPBtn.Parent = LinePosFrame; Instance.new("UICorner", LPBtn).CornerRadius = UDim.new(0, 4)
local LineModes = {"TOP", "CENTER", "BOTTOM"}
local currentLPIdx = 1
LPBtn.MouseButton1Click:Connect(function() currentLPIdx = currentLPIdx + 1; if currentLPIdx > #LineModes then currentLPIdx = 1 end; State.ESPLinePos = LineModes[currentLPIdx]; LPBtn.Text = State.ESPLinePos end)

CreateToggle("👁️ ESP BORDERS (HIGHLIGHT)", "ESP", nil)
CreateToggle("✨ ESP FILLING (NO BORDERS)", "ESPRelleno", nil)
CreateToggle("🎯 ESP CROSSHAIR", "ESPCrosshair", nil)
CreateToggle("👁️‍🗨️ X-RAY (SEEING THROUGH WALLS)", "XRay", function(v) 
    if not v then ClearAllVisuals() end 
end)

local SectionVisualConfig = Instance.new("TextLabel"); SectionVisualConfig.Text = "  VISUAL SETTINGS"; SectionVisualConfig.Size = UDim2.new(1,0,0,20); SectionVisualConfig.TextColor3 = THEME.Accent; SectionVisualConfig.BackgroundTransparency = 1; SectionVisualConfig.Font = Enum.Font.GothamBlack; SectionVisualConfig.Parent = Container; SectionVisualConfig.LayoutOrder = getNextOrder()
CreateToggle("🌈 RGB ESP (RAINBOW MODE)", "RGBESP", nil)
CreateToggle("🟢/🔴 VISIBILITY (GREEN/RED)", "ESPVisibilityColor", nil)

CreateSlider("X-RAY TRANSPARENCY", 10, 100, State.XRayTransparency * 100, function(v) 
    State.XRayTransparency = v/100 
    if State.XRay then
        for part, _ in pairs(XRayParts) do
            if part then part.LocalTransparencyModifier = State.XRayTransparency end
        end
    end
end, nil, "XRayTransparency")

CreateSlider("FIELD OF VIEW (FOV)", 10, 120, State.FieldOfView, function(v) 
    State.FieldOfView = v
    if Camera then Camera.FieldOfView = v end
end, nil, "FieldOfView")

CreateToggle("📱 AIMBOT (MOBILE - Auto Lock)", "AimbotMobile", nil)

local BodyPartFrame = Instance.new("Frame"); BodyPartFrame.Size = UDim2.new(1, -10, 0, 40); BodyPartFrame.BackgroundColor3 = THEME.ElementBG; BodyPartFrame.Parent = Container; BodyPartFrame.LayoutOrder = getNextOrder()
Instance.new("UICorner", BodyPartFrame).CornerRadius = UDim.new(0, 6)
local BPLbl = Instance.new("TextLabel"); BPLbl.Text = " TARGET:"; BPLbl.Size = UDim2.new(0.4, 0, 1, 0); BPLbl.BackgroundTransparency = 1; BPLbl.TextColor3 = THEME.Text; BPLbl.Font = Enum.Font.GothamSemibold; BPLbl.TextXAlignment = Enum.TextXAlignment.Left; BPLbl.Parent = BodyPartFrame
local BPBtn = Instance.new("TextButton"); BPBtn.Size = UDim2.new(0.55, 0, 0.7, 0); BPBtn.Position = UDim2.new(0.42, 0, 0.15, 0); BPBtn.BackgroundColor3 = THEME.TopBar; BPBtn.Text = State.TargetPart; BPBtn.TextColor3 = THEME.Accent; BPBtn.Font = Enum.Font.GothamBold; BPBtn.TextSize = 12; BPBtn.Parent = BodyPartFrame; Instance.new("UICorner", BPBtn).CornerRadius = UDim.new(0, 4)
local BPModes = {"HEAD", "CHEST", "RANDOM"}
local currentBPIdx = 1

local function SetTargetPart(mode)
    State.TargetPart = mode
    BPBtn.Text = mode
    for i, v in ipairs(BPModes) do if v == mode then currentBPIdx = i break end end
end

BPBtn.MouseButton1Click:Connect(function() currentBPIdx = currentBPIdx + 1; if currentBPIdx > #BPModes then currentBPIdx = 1 end; SetTargetPart(BPModes[currentBPIdx]) end)

local RapidFireToggle = CreateToggle("🔥 RAPID FIRE", "RapidFire", nil)
local NoRecoilToggle = CreateToggle("🚫 NO RECOIL", "NoRecoil", nil)
local SilentAimToggle = CreateToggle("🎯 SILENT AIM", "SilentAim", nil)

local AimModeFrame = Instance.new("Frame"); AimModeFrame.Size = UDim2.new(1, -10, 0, 40); AimModeFrame.BackgroundColor3 = THEME.ElementBG; AimModeFrame.Parent = Container; AimModeFrame.LayoutOrder = getNextOrder()
Instance.new("UICorner", AimModeFrame).CornerRadius = UDim.new(0, 6)
local ModeLabel = Instance.new("TextLabel"); ModeLabel.Text = " AIMBOT TYPE:"; ModeLabel.Size = UDim2.new(0.4, 0, 1, 0); ModeLabel.BackgroundTransparency = 1; ModeLabel.TextColor3 = THEME.Text; ModeLabel.Font = Enum.Font.GothamSemibold; ModeLabel.TextXAlignment = Enum.TextXAlignment.Left; ModeLabel.Parent = AimModeFrame
local ModeBtn = Instance.new("TextButton"); ModeBtn.Size = UDim2.new(0.55, 0, 0.7, 0); ModeBtn.Position = UDim2.new(0.42, 0, 0.15, 0); ModeBtn.BackgroundColor3 = THEME.TopBar; ModeBtn.Text = State.AimbotMode; ModeBtn.TextColor3 = THEME.Accent; ModeBtn.Font = Enum.Font.GothamBold; ModeBtn.TextSize = 12; ModeBtn.Parent = AimModeFrame; Instance.new("UICorner", ModeBtn).CornerRadius = UDim.new(0, 4)
local AimModes = {"LEGIT", "BLATANT", "SMOOTH"}
local currentModeIdx = 1
ModeBtn.MouseButton1Click:Connect(function() currentModeIdx = currentModeIdx + 1; if currentModeIdx > #AimModes then currentModeIdx = 1 end; State.AimbotMode = AimModes[currentModeIdx]; ModeBtn.Text = State.AimbotMode end)

CreateToggle("🔍 WALL CHECK", "WallCheck", nil)
CreateToggle("📏 DISTANCE CHECK", "DistanceCheck", nil)
CreateToggle("🛡️ TEAM CHECK", "TeamCheck", nil)
CreateToggle("⭕ SHOW FOV", "ShowFOV", function(v) FOVFrame.Visible = v end)
CreateSlider("FOV Size", 10, 400, State.FOVSize, function(val) State.FOVSize = val; FOVFrame.Size = UDim2.new(0, val*2, 0, val*2) end, nil, "FOVSize")

local SectionOrbit = Instance.new("TextLabel"); SectionOrbit.Text = "  ORBIT SYSTEM"; SectionOrbit.Size = UDim2.new(1,0,0,20); SectionOrbit.TextColor3 = THEME.Accent; SectionOrbit.BackgroundTransparency = 1; SectionOrbit.Font = Enum.Font.GothamBlack; SectionOrbit.Parent = Container; SectionOrbit.LayoutOrder = getNextOrder()
local MainOrbitToggle = CreateToggle("🌀 ACTIVATE ORBIT", "Orbiting", function(v) if _G.OrbitContainer then _G.OrbitContainer.Visible = v end; if not v then State.OrbitTarget = nil end end)
local OrbitGroup = Instance.new("Frame"); OrbitGroup.Name = "OrbitGroup"; OrbitGroup.Size = UDim2.new(1, 0, 0, 210); OrbitGroup.BackgroundTransparency = 1; OrbitGroup.Visible = false; OrbitGroup.Parent = Container; OrbitGroup.LayoutOrder = MainOrbitToggle.LayoutOrder + 1; _G.OrbitContainer = OrbitGroup
local OrbitGroupLayout = Instance.new("UIListLayout"); OrbitGroupLayout.Parent = OrbitGroup; OrbitGroupLayout.Padding = UDim.new(0, 8)
local OrbitListFrame = Instance.new("Frame"); OrbitListFrame.Size = UDim2.new(1, -10, 0, 100); OrbitListFrame.BackgroundColor3 = THEME.ElementBG; OrbitListFrame.Parent = OrbitGroup; Instance.new("UICorner", OrbitListFrame).CornerRadius = UDim.new(0, 6)
local OrbitScroll = Instance.new("ScrollingFrame"); OrbitScroll.Size = UDim2.new(1, -10, 1, -10); OrbitScroll.Position = UDim2.new(0, 5, 0, 5); OrbitScroll.BackgroundTransparency = 1; OrbitScroll.ScrollBarThickness = 2; OrbitScroll.Parent = OrbitListFrame
local OrbitListLayout = Instance.new("UIListLayout"); OrbitListLayout.Parent = OrbitScroll; OrbitListLayout.Padding = UDim.new(0, 2)
OrbitListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() OrbitScroll.CanvasSize = UDim2.new(0, 0, 0, OrbitListLayout.AbsoluteContentSize.Y + 5) end)

local function UpdateOrbitList()
    for _, child in pairs(OrbitScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then local pBtn = Instance.new("TextButton"); pBtn.Size = UDim2.new(1, 0, 0, 20); pBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25); pBtn.Text = p.Name; pBtn.TextColor3 = THEME.Text; pBtn.Font = Enum.Font.Gotham; pBtn.TextSize = 12; pBtn.Parent = OrbitScroll; Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4); pBtn.MouseButton1Click:Connect(function() State.OrbitTarget = p; State.Orbiting = true; if _G.OrbitContainer then _G.OrbitContainer.Visible = true end end) end end
end
UpdateOrbitList(); Players.PlayerAdded:Connect(UpdateOrbitList); Players.PlayerRemoving:Connect(UpdateOrbitList)
CreateSlider("Distance", 2, 50, State.OrbitDistance, function(v) State.OrbitDistance = v end, OrbitGroup, "OrbitDistance")
CreateSlider("Spin Speed", 1, 50, State.OrbitSpeed, function(v) State.OrbitSpeed = v end, OrbitGroup, "OrbitSpeed")

local Section2 = Instance.new("TextLabel"); Section2.Text = "  MOVEMENT & TP"; Section2.Size = UDim2.new(1,0,0,20); Section2.TextColor3 = THEME.Accent; Section2.BackgroundTransparency = 1; Section2.Font = Enum.Font.GothamBlack; Section2.Parent = Container; Section2.LayoutOrder = getNextOrder()

CreateToggle("🎥 FREE CAM MENU", "FreecamEnabled", function(v)
    if FreecamGuiObject then
        FreecamGuiObject.Enabled = v and State.PanelVisible
    end
end)

CreateToggle("🧱 WALLHACK", "Wallhack", function(v)
    if not v and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end)
CreateToggle("🕊️ FLY HACK (FREECAM MODE)", "Fly", function(v) ToggleFly(v) end)
CreateSlider("Fly Speed", 10, 300, State.FlySpeed, function(val) State.FlySpeed = val end, nil, "FlySpeed")
CreateToggle("⚡ SPEED HACK", "SpeedHack", nil)
CreateSlider("Speed", 16, 250, State.Speed, function(val) State.Speed = val end, nil, "Speed")
CreateToggle("🐰 JUMP HACK", "JumpHack", function(v)
    if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = 50
    end
end)
CreateToggle("⏫ MULTI-JUMP", "MultiJump", nil)
CreateSlider("Jump", 50, 500, State.Jump, function(val) State.Jump = val end, nil, "Jump")
CreateToggle("🌀 SPIN HACK", "SpinHack", nil)
CreateSlider("Spin Speed", 1, 50, State.SpinSpeed, function(val) State.SpinSpeed = val end, nil, "SpinSpeed")
CreateToggle("🔙 TELEPORT ENEMY", "BackTP", function(v) 
    if not v then 
        State.BackTPTarget = nil 
        if LocalPlayer.Character then
            if LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.PlatformStand = false
            end
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end 
end)

local TPModeFrame = Instance.new("Frame"); TPModeFrame.Size = UDim2.new(1, -10, 0, 40); TPModeFrame.BackgroundColor3 = THEME.ElementBG; TPModeFrame.Parent = Container; TPModeFrame.LayoutOrder = getNextOrder()
Instance.new("UICorner", TPModeFrame).CornerRadius = UDim.new(0, 6)
local TPLbl = Instance.new("TextLabel"); TPLbl.Text = "  TP POSITION:"; TPLbl.Size = UDim2.new(0.4, 0, 1, 0); TPLbl.BackgroundTransparency = 1; TPLbl.TextColor3 = THEME.Text; TPLbl.Font = Enum.Font.GothamSemibold; TPLbl.TextXAlignment = Enum.TextXAlignment.Left; TPLbl.Parent = TPModeFrame
local TPBtn = Instance.new("TextButton"); TPBtn.Size = UDim2.new(0.55, 0, 0.7, 0); TPBtn.Position = UDim2.new(0.42, 0, 0.15, 0); TPBtn.BackgroundColor3 = THEME.TopBar; TPBtn.Text = State.BackTPMode; TPBtn.TextColor3 = THEME.Accent; TPBtn.Font = Enum.Font.GothamBold; TPBtn.TextSize = 12; TPBtn.Parent = TPModeFrame; Instance.new("UICorner", TPBtn).CornerRadius = UDim.new(0, 4)
local TPModes = {"ABOVE", "BELOW", "BEHIND", "FRONT", "RIGHT", "LEFT"}
local currentTPIdx = 1
TPBtn.MouseButton1Click:Connect(function() currentTPIdx = currentTPIdx + 1; if currentTPIdx > #TPModes then currentTPIdx = 1 end; State.BackTPMode = TPModes[currentTPIdx]; TPBtn.Text = State.BackTPMode end)

CreateButton("📍 SAVE POSITION", function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then State.SavedCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame end end)
CreateButton("🚀 TELEPORT SAVE", function() if State.SavedCFrame and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = State.SavedCFrame end end)

local SectionBotones = Instance.new("TextLabel"); SectionBotones.Text = "  FLOATING BUTTONS"; SectionBotones.Size = UDim2.new(1,0,0,20); SectionBotones.TextColor3 = THEME.Accent; SectionBotones.BackgroundTransparency = 1; SectionBotones.Font = Enum.Font.GothamBlack; SectionBotones.Parent = Container; SectionBotones.LayoutOrder = getNextOrder()
CreateToggle("🔘 FLOATING: AIMBOT", "FloatAimbot", function(v) FloatAimbotBtn.Visible = v end)
CreateToggle("🔘 FLOATING: ESP", "FloatESP", function(v) FloatESPBtn.Visible = v end)
CreateToggle("🔘 FLOATING: FLY", "FloatFly", function(v) FloatFlyBtn.Visible = v end)

local HUDSection = Instance.new("Frame"); HUDSection.Size = UDim2.new(1, -10, 0, 40); HUDSection.BackgroundColor3 = THEME.ElementBG; HUDSection.Parent = Container; HUDSection.LayoutOrder = getNextOrder()
Instance.new("UICorner", HUDSection).CornerRadius = UDim.new(0, 6)
local HUDLbl = Instance.new("TextLabel"); HUDLbl.Text = "  HUD EDIT MODE"; HUDLbl.Size = UDim2.new(0.5, 0, 1, 0); HUDLbl.BackgroundTransparency = 1; HUDLbl.TextColor3 = THEME.Text; HUDLbl.Font = Enum.Font.GothamSemibold; HUDLbl.TextXAlignment = Enum.TextXAlignment.Left; HUDLbl.Parent = HUDSection
local EditBtn = Instance.new("TextButton"); EditBtn.Text = "EDIT"; EditBtn.Size = UDim2.new(0.4, 0, 0.7, 0); EditBtn.Position = UDim2.new(0.55, 0, 0.15, 0); EditBtn.BackgroundColor3 = THEME.Accent; EditBtn.TextColor3 = THEME.Text; EditBtn.Font = Enum.Font.GothamBold; EditBtn.Parent = HUDSection; Instance.new("UICorner", EditBtn).CornerRadius = UDim.new(0, 6)
EditBtn.MouseButton1Click:Connect(function() EnableHUDEdit(true) end)

SaveHUDBtn.MouseButton1Click:Connect(function()
    SaveHUDPosition(FloatAimbotBtn.Position, "FloatAimbot")
    SaveHUDPosition(FloatESPBtn.Position, "FloatESP")
    SaveHUDPosition(FloatFlyBtn.Position, "FloatFly")
    EnableHUDEdit(false)
end)

CancelHUDBtn.MouseButton1Click:Connect(function()
    local posAimbot = LoadHUDPosition("FloatAimbot")
    if posAimbot then FloatAimbotBtn.Position = posAimbot else FloatAimbotBtn.Position = UDim2.new(0, 15, 0.3, 0) end
    
    local posESP = LoadHUDPosition("FloatESP")
    if posESP then FloatESPBtn.Position = posESP else FloatESPBtn.Position = UDim2.new(0, 15, 0.4, 0) end
    
    local posFly = LoadHUDPosition("FloatFly")
    if posFly then FloatFlyBtn.Position = posFly else FloatFlyBtn.Position = UDim2.new(0, 15, 0.5, 0) end
    
    EnableHUDEdit(false)
end)

local SectionInfo = Instance.new("TextLabel"); SectionInfo.Text = "  PANEL STATISTICS"; SectionInfo.Size = UDim2.new(1,0,0,20); SectionInfo.TextColor3 = THEME.Accent; SectionInfo.BackgroundTransparency = 1; SectionInfo.Font = Enum.Font.GothamBlack; SectionInfo.Parent = Container; SectionInfo.LayoutOrder = getNextOrder()

local InfoFrame = Instance.new("Frame")
InfoFrame.Size = UDim2.new(1, -10, 0, 40); InfoFrame.BackgroundColor3 = THEME.ElementBG; InfoFrame.Parent = Container; InfoFrame.LayoutOrder = getNextOrder()
Instance.new("UICorner", InfoFrame).CornerRadius = UDim.new(0, 6)

local KeysLabel = Instance.new("TextLabel"); KeysLabel.Text = "ACTIVE KEYS: Loading..."; KeysLabel.Size = UDim2.new(1, -20, 1, 0); KeysLabel.Position = UDim2.new(0, 10, 0, 0); KeysLabel.BackgroundTransparency = 1; KeysLabel.TextColor3 = THEME.Success; KeysLabel.Font = Enum.Font.GothamBold; KeysLabel.TextXAlignment = Enum.TextXAlignment.Left; KeysLabel.Parent = InfoFrame

local ConfigSectionLabel = Instance.new("TextLabel"); ConfigSectionLabel.Text = "  SETTINGS (JSON)"; ConfigSectionLabel.Size = UDim2.new(1,0,0,20); ConfigSectionLabel.TextColor3 = THEME.Accent; ConfigSectionLabel.BackgroundTransparency = 1; ConfigSectionLabel.Font = Enum.Font.GothamBlack; ConfigSectionLabel.Parent = Container; ConfigSectionLabel.LayoutOrder = getNextOrder()

local ConfigManagerFrame = Instance.new("Frame")
ConfigManagerFrame.Size = UDim2.new(1, -10, 0, 120); ConfigManagerFrame.BackgroundColor3 = THEME.ElementBG; ConfigManagerFrame.Parent = Container; ConfigManagerFrame.LayoutOrder = getNextOrder()
Instance.new("UICorner", ConfigManagerFrame).CornerRadius = UDim.new(0, 6)

local ConfigNameInput = Instance.new("TextBox")
ConfigNameInput.Size = UDim2.new(0.9, 0, 0, 30); ConfigNameInput.Position = UDim2.new(0.05, 0, 0.1, 0); ConfigNameInput.BackgroundColor3 = THEME.TopBar; ConfigNameInput.TextColor3 = THEME.Text; ConfigNameInput.Font = Enum.Font.GothamBold; ConfigNameInput.PlaceholderText = "Name (4-15 characters)"; ConfigNameInput.Text = ""; ConfigNameInput.Parent = ConfigManagerFrame; Instance.new("UICorner", ConfigNameInput).CornerRadius = UDim.new(0, 4)

ConfigNameInput:GetPropertyChangedSignal("Text"):Connect(function()
    if #ConfigNameInput.Text > 15 then
        ConfigNameInput.Text = string.sub(ConfigNameInput.Text, 1, 15)
    end
end)

local SaveConfigBtn = Instance.new("TextButton")
SaveConfigBtn.Size = UDim2.new(0.9, 0, 0, 35); SaveConfigBtn.Position = UDim2.new(0.05, 0, 0.5, 0); SaveConfigBtn.BackgroundColor3 = THEME.Accent; SaveConfigBtn.TextColor3 = THEME.Text; SaveConfigBtn.Font = Enum.Font.GothamBold; SaveConfigBtn.Text = "💾 SAVE SETTINGS"; SaveConfigBtn.Parent = ConfigManagerFrame; Instance.new("UICorner", SaveConfigBtn).CornerRadius = UDim.new(0, 6)

local ConfigListFrame = Instance.new("ScrollingFrame")
ConfigListFrame.Size = UDim2.new(1, -10, 0, 100); ConfigListFrame.BackgroundColor3 = THEME.ElementBG; ConfigListFrame.ScrollBarThickness = 2; ConfigListFrame.Parent = Container; ConfigListFrame.LayoutOrder = getNextOrder()
Instance.new("UICorner", ConfigListFrame).CornerRadius = UDim.new(0, 6)
local ConfigListLayout = Instance.new("UIListLayout"); ConfigListLayout.Parent = ConfigListFrame; ConfigListLayout.Padding = UDim.new(0, 4)

local function GetConfigList()
    if isfolder and not isfolder("DarkMatter_Configs") then
        makefolder("DarkMatter_Configs")
    end
    return listfiles("DarkMatter_Configs")
end

local function LoadConfig(name)
    local path = "DarkMatter_Configs/" .. name .. ".json"
    if isfile(path) then
        local data = HttpService:JSONDecode(readfile(path))
        for key, value in pairs(data) do
            if key ~= "Orbiting" and key ~= "OrbitTarget" and key ~= "OrbitSpeed" and key ~= "OrbitDistance" and key ~= "OrbitAngle" then
                if State[key] ~= nil then
                    if type(value) == "boolean" and ToggleUpdaters[key] then
                        ToggleUpdaters[key](value)
                    elseif type(value) == "number" and SliderUpdaters[key] then
                        SliderUpdaters[key](value)
                    elseif key == "TargetPart" then
                        SetTargetPart(value)
                    else
                        State[key] = value
                    end
                end
            end
        end
        State.Orbiting = false
        State.OrbitTarget = nil
        if ToggleUpdaters["Orbiting"] then
            ToggleUpdaters["Orbiting"](false)
        end
    end
end

local isConfirmingAction = false

local function UpdateConfigUIList()
    for _, child in pairs(ConfigListFrame:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    local files = GetConfigList()
    for _, file in pairs(files) do
        local fileName = file:match("([^/]+)%.json$")
        if fileName then
            local ItemFrame = Instance.new("Frame")
            ItemFrame.Size = UDim2.new(1, -10, 0, 40); ItemFrame.BackgroundTransparency = 1; ItemFrame.Parent = ConfigListFrame
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.72, 0, 0, 30); btn.Position = UDim2.new(0.02, 0, 0, 5); btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35); btn.TextColor3 = THEME.Text; btn.Font = Enum.Font.Gotham; btn.Text = " 📂 " .. fileName; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.Parent = ItemFrame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            
            local delBtn = Instance.new("TextButton")
            delBtn.Size = UDim2.new(0.2, 0, 0, 30); delBtn.Position = UDim2.new(0.76, 0, 0, 5); delBtn.BackgroundColor3 = THEME.Danger; delBtn.TextColor3 = THEME.Text; delBtn.Font = Enum.Font.GothamBold; delBtn.Text = "X"; delBtn.Parent = ItemFrame
            Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 4)

            btn.MouseButton1Click:Connect(function()
                if isConfirmingAction then return end
                isConfirmingAction = true
                
                local confirm = Instance.new("Frame")
                confirm.Size = UDim2.new(0, 200, 0, 100); confirm.Position = UDim2.new(0.5, -100, 0.5, -50); confirm.BackgroundColor3 = THEME.Background; confirm.ZIndex = 700; confirm.Parent = ScreenGui; Instance.new("UICorner", confirm).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", confirm).Color = THEME.Accent
                local txt = Instance.new("TextLabel"); txt.Size = UDim2.new(1, 0, 0, 60); txt.Text = "Load " .. fileName .. "?"; txt.TextColor3 = THEME.Text; txt.ZIndex = 701; txt.BackgroundTransparency = 1; txt.Parent = confirm
                local y = Instance.new("TextButton")
                y.Size = UDim2.new(0.4, 0, 0, 30); y.Position = UDim2.new(0.05, 0, 0.6, 0); y.BackgroundColor3 = THEME.Success; y.Text = "YES"; y.ZIndex = 701; y.Parent = confirm
                local n = Instance.new("TextButton")
                n.Size = UDim2.new(0.4, 0, 0, 30); n.Position = UDim2.new(0.55, 0, 0.6, 0); n.BackgroundColor3 = THEME.Danger; n.Text = "NO"; n.ZIndex = 701; n.Parent = confirm
                y.MouseButton1Click:Connect(function() LoadConfig(fileName); confirm:Destroy(); isConfirmingAction = false end)
                n.MouseButton1Click:Connect(function() confirm:Destroy(); isConfirmingAction = false end)
            end)
            
            delBtn.MouseButton1Click:Connect(function()
                if isConfirmingAction then return end
                isConfirmingAction = true
                
                local confirm1 = Instance.new("Frame")
                confirm1.Size = UDim2.new(0, 200, 0, 100); confirm1.Position = UDim2.new(0.5, -100, 0.5, -50); confirm1.BackgroundColor3 = THEME.Background; confirm1.ZIndex = 700; confirm1.Parent = ScreenGui; Instance.new("UICorner", confirm1).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", confirm1).Color = THEME.Accent
                local txt1 = Instance.new("TextLabel"); txt1.Size = UDim2.new(1, 0, 0, 60); txt1.Text = "Delete " .. fileName .. "?"; txt1.TextColor3 = THEME.Text; txt1.ZIndex = 701; txt1.BackgroundTransparency = 1; txt1.Parent = confirm1
                local y1 = Instance.new("TextButton"); y1.Size = UDim2.new(0.4, 0, 0, 30); y1.Position = UDim2.new(0.05, 0, 0.6, 0); y1.BackgroundColor3 = THEME.Success; y1.Text = "YES"; y1.ZIndex = 701; y1.Parent = confirm1
                local n1 = Instance.new("TextButton"); n1.Size = UDim2.new(0.4, 0, 0, 30); n1.Position = UDim2.new(0.55, 0, 0.6, 0); n1.BackgroundColor3 = THEME.Danger; n1.Text = "NO"; n1.ZIndex = 701; n1.Parent = confirm1

                y1.MouseButton1Click:Connect(function()
                    confirm1:Destroy()
                    
                    local confirm2 = Instance.new("Frame")
                    confirm2.Size = UDim2.new(0, 200, 0, 100); confirm2.Position = UDim2.new(0.5, -100, 0.5, -50); confirm2.BackgroundColor3 = THEME.Background; confirm2.ZIndex = 700; confirm2.Parent = ScreenGui; Instance.new("UICorner", confirm2).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", confirm2).Color = THEME.Accent
                    local txt2 = Instance.new("TextLabel"); txt2.Size = UDim2.new(1, 0, 0, 60); txt2.Text = "Are you REALLY sure?"; txt2.TextColor3 = THEME.Danger; txt2.ZIndex = 701; txt2.BackgroundTransparency = 1; txt2.Parent = confirm2
                    local y2 = Instance.new("TextButton"); y2.Size = UDim2.new(0.4, 0, 0, 30); y2.Position = UDim2.new(0.05, 0, 0.6, 0); y2.BackgroundColor3 = THEME.Danger; y2.Text = "YES, DELETE"; y2.ZIndex = 701; y2.Parent = confirm2
                    local n2 = Instance.new("TextButton"); n2.Size = UDim2.new(0.4, 0, 0, 30); n2.Position = UDim2.new(0.55, 0, 0.6, 0); n2.BackgroundColor3 = THEME.ElementBG; n2.Text = "CANCEL"; n2.ZIndex = 701; n2.Parent = confirm2

                    y2.MouseButton1Click:Connect(function()
                        if delfile then
                            delfile(file)
                            UpdateConfigUIList()
                        end
                        confirm2:Destroy()
                        isConfirmingAction = false
                    end)
                    n2.MouseButton1Click:Connect(function()
                        confirm2:Destroy()
                        isConfirmingAction = false
                    end)
                end)
                
                n1.MouseButton1Click:Connect(function()
                    confirm1:Destroy()
                    isConfirmingAction = false
                end)
            end)
        end
    end
    ConfigListFrame.CanvasSize = UDim2.new(0, 0, 0, ConfigListLayout.AbsoluteContentSize.Y + 5)
end

SaveConfigBtn.MouseButton1Click:Connect(function()
    local name = ConfigNameInput.Text
    if #name >= 4 and #name <= 15 then
        local data = {}
        for k, v in pairs(State) do 
            if type(v) ~= "userdata" and k ~= "SavedCFrame" and k ~= "Orbiting" and k ~= "OrbitTarget" and k ~= "OrbitSpeed" and k ~= "OrbitDistance" and k ~= "OrbitAngle" then 
                data[k] = v 
            end 
        end
        if writefile then
            if not isfolder("DarkMatter_Configs") then makefolder("DarkMatter_Configs") end
            writefile("DarkMatter_Configs/" .. name .. ".json", HttpService:JSONEncode(data))
            UpdateConfigUIList()
            ConfigNameInput.Text = ""
        end
    else
        SaveConfigBtn.Text = "INVALID NAME LENGTH!"
        task.wait(1)
        SaveConfigBtn.Text = "💾 SAVE SETTINGS"
    end
end)

UpdateConfigUIList()

local function parseDate(str)
    local Y, M, D, h, m, s = str:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
    if Y then return os.time({year=Y, month=M, day=D, hour=h, min=m, sec=s}) end
    return 0
end

task.spawn(function()
    while ScriptRunning do
        local success, result = pcall(function()
            local url = "https://key-sistem-roblox-dm-default-rtdb.firebaseio.com/keys.json"
            local HttpServiceReq = game:GetService("HttpService")
            local req = game:HttpGet(url)
            local data = HttpServiceReq:JSONDecode(req)
            local activeCount = 0
            local currentTime = os.time()
            for k, v in pairs(data) do
                if type(v) == "table" and v.expira then
                    local expTime = parseDate(v.expira)
                    if expTime > currentTime then
                        activeCount = activeCount + 1
                    end
                end
            end
            return activeCount
        end)
        
        if success then
            KeysLabel.Text = "ACTIVE KEYS: " .. tostring(result)
        else
            KeysLabel.Text = "ACTIVE KEYS: Error..."
        end
        task.wait(5)
    end
end)

local ElementCategoryMap = {}

local function AssignCat(matchText, category)
    for _, child in pairs(Container:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then
            local itemText = ""
            if child:IsA("TextButton") then
                itemText = child.Text
            else
                local lbl = child:FindFirstChildOfClass("TextLabel")
                if lbl then itemText = lbl.Text end
            end

            if itemText ~= "" and string.find(itemText, matchText, 1, true) then
                ElementCategoryMap[child] = category
            end
        end
    end
end

AssignCat("ESP BOX", "VISUALS")
AssignCat("ESP DISTANCE", "VISUALS")
AssignCat("ESP LIFE BAR", "VISUALS")
AssignCat("ESP LINE", "VISUALS")
AssignCat("LINE POSITION", "VISUALS")
AssignCat("ESP BORDERS", "VISUALS")
AssignCat("ESP FILLING", "VISUALS")
AssignCat("ESP CROSSHAIR", "VISUALS")
AssignCat("X-RAY", "VISUALS")
AssignCat("RGB ESP", "VISUALS")
AssignCat("VISIBILITY", "VISUALS")
AssignCat("X-RAY TRANSPARENCY", "VISUALS")
AssignCat("FIELD OF VIEW", "VISUALS")

AssignCat("AIMBOT (MOBILE", "COMBAT")
AssignCat("TARGET:", "COMBAT")
AssignCat("RAPID FIRE", "COMBAT")
AssignCat("NO RECOIL", "COMBAT")
AssignCat("SILENT AIM", "COMBAT")
AssignCat("AIMBOT TYPE", "COMBAT")
AssignCat("SHOW FOV", "COMBAT")
AssignCat("FOV Size", "COMBAT")

AssignCat("FREE CAM MENU", "MOVEMENT")
AssignCat("WALLHACK", "MOVEMENT")
AssignCat("FLY HACK", "MOVEMENT")
AssignCat("Fly Speed", "MOVEMENT")
AssignCat("SPEED HACK", "MOVEMENT")
AssignCat("Speed", "MOVEMENT")
AssignCat("JUMP HACK", "MOVEMENT")
AssignCat("MULTI-JUMP", "MOVEMENT")
AssignCat("Jump", "MOVEMENT")
AssignCat("SPIN HACK", "MOVEMENT")
AssignCat("Spin Speed", "MOVEMENT")

AssignCat("TELEPORT ENEMY", "MISC")
AssignCat("TP POSITION", "MISC")
AssignCat("SAVE POSITION", "MISC")
AssignCat("TELEPORT SAVE", "MISC")
AssignCat("WALL CHECK", "MISC")
AssignCat("DISTANCE CHECK", "MISC")
AssignCat("TEAM CHECK", "MISC")
AssignCat("ACTIVATE ORBIT", "MISC")
AssignCat("HUD EDIT MODE", "MISC")

AssignCat("FLOATING BUTTONS", "MISC")
AssignCat("FLOATING: AIMBOT", "MISC")
AssignCat("FLOATING: ESP", "MISC")
AssignCat("FLOATING: FLY", "MISC")

AssignCat("ACTIVE KEYS", "INFORMATION")

if Container:FindFirstChild("OrbitGroup") then 
    ElementCategoryMap[Container.OrbitGroup] = "MISC" 
end

if ConfigManagerFrame then ElementCategoryMap[ConfigManagerFrame] = "INFORMATION" end
if ConfigListFrame then ElementCategoryMap[ConfigListFrame] = "INFORMATION" end

for _, child in pairs(Container:GetChildren()) do
    if child:IsA("TextLabel") and (string.find(child.Text, "COMBAT & VISUALS") or string.find(child.Text, "VISUAL SETTINGS") or string.find(child.Text, "ORBIT SYSTEM") or string.find(child.Text, "MOVEMENT & TP") or string.find(child.Text, "PANEL STATISTICS") or string.find(child.Text, "FLOATING BUTTONS")) then
        child.Visible = false
    end
end

UniversalBtn.MouseButton1Click:Connect(function()
    IsRivals = false
    ManualModeSelected = true
    SelectorFrame.Visible = false
    MainFrame.Visible = true
    
    RapidFireToggle.Visible = false
    NoRecoilToggle.Visible = false
    SilentAimToggle.Visible = false
    
    if _G.UpdateCategoryVisibility then _G.UpdateCategoryVisibility() end
end)

RivalsBtn.MouseButton1Click:Connect(function()
    IsRivals = true
    ManualModeSelected = true
    SelectorFrame.Visible = false
    MainFrame.Visible = true
    
    if AimModeFrame then AimModeFrame.Visible = false end
    
    if _G.UpdateCategoryVisibility then _G.UpdateCategoryVisibility() end
end)

_G.UpdateCategoryVisibility = function()
    if not ManualModeSelected then return end
    for element, category in pairs(ElementCategoryMap) do
        local isMatch = (category == currentActiveTab)
        
        if isMatch then
            local isRivalsFeature = (element == RapidFireToggle or element == NoRecoilToggle or element == SilentAimToggle)
            local isUniversalFeature = (element == AimModeFrame)
            
            if not IsRivals and isRivalsFeature then
                element.Visible = false
            elseif IsRivals and isUniversalFeature then
                element.Visible = false
            elseif element == _G.OrbitContainer then
                element.Visible = State.Orbiting
            else
                element.Visible = true
            end
        else
            element.Visible = false
        end
    end
    
    ConfigSectionLabel.Visible = (currentActiveTab == "INFORMATION")
end

if CategoryFrames["COMBAT"] then
    CategoryFrames["COMBAT"].BackgroundColor3 = THEME.Accent
    CategoryFrames["COMBAT"].TextColor3 = THEME.TopBar
end

task.spawn(function()
    local LP = game:GetService("Players").LocalPlayer
    if MainFrame:FindFirstChild("TitleBar") then
        local tb = MainFrame.TitleBar
        local av = tb:FindFirstChild("UserAvatar") or Instance.new("ImageLabel", tb)
        av.Name = "UserAvatar"
        av.Size = UDim2.new(0, 35, 0, 35)
        av.Position = UDim2.new(0, 10, 0.5, -17)
        av.BackgroundColor3 = THEME.ElementBG
        av.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=150&h=150"
        if not av:FindFirstChildOfClass("UICorner") then Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0) end
        
        local un = tb:FindFirstChild("UserName") or Instance.new("TextLabel", tb)
        un.Name = "UserName"
        un.Size = UDim2.new(0, 150, 1, 0)
        un.Position = UDim2.new(0, 55, 0, 0)
        un.BackgroundTransparency = 1
        un.Text = LP.Name:upper()
        un.TextColor3 = THEME.Text
        un.Font = Enum.Font.GothamBold
        un.TextSize = 14
        un.TextXAlignment = Enum.TextXAlignment.Left
    end
end)

_G.UpdateCategoryVisibility()
