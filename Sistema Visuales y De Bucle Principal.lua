local function IsVisible(part)
    local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
    local result = Workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, params)
    return not result
end

local function GetTargetPart(char)
    if not char then return nil end
    if State.TargetPart == "HEAD" then return char:FindFirstChild("Head")
    elseif State.TargetPart == "CHEST" then return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    else 
        local parts = {char:FindFirstChild("Head"), char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")}
        return parts[math.random(1, 2)]
    end
end

local function GetClosestPlayer()
    local closest, shortestMetric = nil, math.huge
    local centerPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
            if State.TeamCheck and v.Team == LocalPlayer.Team then continue end
            if State.WallCheck and not IsVisible(v.Character.Head) then continue end
            local part = GetTargetPart(v.Character) or v.Character.Head
            local headPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local screenDist = (Vector2.new(headPos.X, headPos.Y) - centerPos).Magnitude
                if screenDist < State.FOVSize then
                    if State.DistanceCheck then
                        local worldDist = (part.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if worldDist < State.AimbotRange and worldDist < shortestMetric then shortestMetric = worldDist; closest = part end
                    else
                        if screenDist < shortestMetric then shortestMetric = screenDist; closest = part end
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function(dt)
    if not ScriptRunning then return end 
    
    local target = GetClosestPlayer()
    local anyVisiblePlayer = false
    
    SilentTarget = State.SilentAim and target or nil
    
    if State.ESPVisibilityColor then
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
                if State.TeamCheck and v.Team == LocalPlayer.Team then continue end
                
                local headPos, onScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
                if onScreen then
                    local screenDist = (Vector2.new(headPos.X, headPos.Y) - center).Magnitude
                    if screenDist < State.FOVSize then
                        if IsVisible(v.Character.Head) then
                            anyVisiblePlayer = true
                        end
                    end
                end
            end
        end
    end
    
    local function GetESPColor(targetPart)
        if State.RGBESP then return GetRGB() end
        if State.ESPVisibilityColor then
            return IsVisible(targetPart) and THEME.Success or THEME.Danger
        end
        return THEME.Accent
    end
    
    FOVFrame.Visible = State.ShowFOV and State.PanelVisible and not State.EditingHUD
    FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local currentFOVColor = THEME.Accent
    if State.RGBESP then 
        currentFOVColor = GetRGB() 
    elseif State.ESPVisibilityColor then
        currentFOVColor = anyVisiblePlayer and THEME.Success or THEME.Danger
    end
    FOVStroke.Color = currentFOVColor
    
    if State.XRay then
        local descendants = Workspace:GetDescendants()
        for i = 1, #descendants do
            local obj = descendants[i]
            if obj:IsA("BasePart") and not obj:IsDescendantOf(Camera) then
                local isCharacter = obj.Parent and obj.Parent:FindFirstChild("Humanoid")
                if not isCharacter and not XRayParts[obj] then
                    XRayParts[obj] = obj.LocalTransparencyModifier
                    obj.LocalTransparencyModifier = State.XRayTransparency
                end
            end
        end
    else
        for part, original in pairs(XRayParts) do
            if part then part.LocalTransparencyModifier = 0 end
        end
        XRayParts = {}
    end
    
    for p, _ in pairs(Tracers) do
        if not p or not p.Parent then
            if Tracers[p] then Tracers[p]:Remove(); Tracers[p] = nil end
            if Labels[p] then Labels[p]:Remove(); Labels[p] = nil end
            if HealthBars[p] then HealthBars[p]:Remove(); HealthBars[p] = nil end
        end
    end

    for p, v in pairs(Crosshairs) do
        if not p or not p.Parent then
            if v.Circle then v.Circle:Remove() end
            if v.LineH then v.LineH:Remove() end
            if v.LineV then v.LineV:Remove() end
            Crosshairs[p] = nil
        end
    end
    
    for _, box in pairs(BoxFolder:GetChildren()) do
        local playerName = box.Name:gsub("_DarkBox", "")
        if not Players:FindFirstChild(playerName) then box:Destroy() end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            local char = p.Character
            local hrp = char.HumanoidRootPart
            local hum = char.Humanoid
            local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local espColor = GetESPColor(hrp)
            
            local currentDist = (Camera.CFrame.Position - hrp.Position).Magnitude
            local withinRange = currentDist <= State.ESPRenderDistance

            if onScreen and hum.Health > 0 and State.PanelVisible and withinRange and not State.EditingHUD then
                if State.TeamCheck and p.Team == LocalPlayer.Team then 
                    if Tracers[p] then Tracers[p].Visible = false end
                    if Crosshairs[p] then
                        Crosshairs[p].Circle.Visible = false
                        Crosshairs[p].LineH.Visible = false
                        Crosshairs[p].LineV.Visible = false
                    end
                    continue 
                end

                local topWorld = (hrp.CFrame * CFrame.new(0, 3, 0)).Position
                local bottomWorld = (hrp.CFrame * CFrame.new(0, -3.5, 0)).Position
                local topPtr = Camera:WorldToViewportPoint(topWorld)
                local bottomPtr = Camera:WorldToViewportPoint(bottomWorld)
                local h = math.abs(topPtr.Y - bottomPtr.Y)
                local w = h / 2

                local boxName = p.Name .. "_DarkBox"
                local box = BoxFolder:FindFirstChild(boxName)
                if State.ESPBox then
                    if not box then box = Instance.new("Frame", BoxFolder); box.Name = boxName; box.BackgroundTransparency = 1; box.BorderSizePixel = 0; local stroke = Instance.new("UIStroke", box); stroke.Thickness = 1.0 end
                    box.UIStroke.Color = espColor
                    box.Position = UDim2.new(0, vector.X - (w/2), 0, vector.Y - (h/2)); box.Size = UDim2.new(0, w, 0, h); box.Visible = true
                elseif box then box.Visible = false end

                if State.ESPLine then
                    local line = Tracers[p] or CreateDrawing("Line", {Thickness = 1})
                    line.Color = espColor
                    Tracers[p] = line
                    
                    local lineStartPoint = Vector2.new(Camera.ViewportSize.X / 2, 0) 
                    local lineTargetPoint = Vector2.new(vector.X, topPtr.Y) 

                    if State.ESPLinePos == "CENTER" then
                        lineStartPoint = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        lineTargetPoint = Vector2.new(vector.X, vector.Y) 
                    elseif State.ESPLinePos == "BOTTOM" then
                        lineStartPoint = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        lineTargetPoint = Vector2.new(bottomPtr.X, bottomPtr.Y) 
                    else 
                        local head = char:FindFirstChild("Head")
                        if head then
                            local hPos = Camera:WorldToViewportPoint(head.Position)
                            lineTargetPoint = Vector2.new(hPos.X, hPos.Y)
                        end
                    end
                    
                    line.From = lineStartPoint; line.To = lineTargetPoint; line.Visible = true
                elseif Tracers[p] then Tracers[p].Visible = false end

                if State.ESPInfo then
                    local label = Labels[p] or CreateDrawing("Text", {Size = 14, Center = true, Outline = true})
                    label.Color = espColor
                    Labels[p] = label
                    label.Text = string.format("%s\n[%d m]", p.Name, math.floor(currentDist))
                    label.Position = Vector2.new(vector.X, vector.Y - (h/2) - 30); label.Visible = true
                elseif Labels[p] then Labels[p].Visible = false end

                if State.ESPHealth then
                    local bar = HealthBars[p] or CreateDrawing("Line", {Thickness = 2})
                    HealthBars[p] = bar
                    local hpPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    bar.From = Vector2.new(vector.X - (w/2) - 5, vector.Y + (h/2))
                    bar.To = Vector2.new(vector.X - (w/2) - 5, bar.From.Y - (h * hpPct))
                    bar.Color = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), hpPct); bar.Visible = true
                elseif HealthBars[p] then HealthBars[p].Visible = false end

                if State.ESPCrosshair then
                    if not Crosshairs[p] then
                        Crosshairs[p] = {
                            Circle = CreateDrawing("Circle", {Radius = 8, Thickness = 2, NumSides = 18, Filled = false}),
                            LineH = CreateDrawing("Line", {Thickness = 2.5}),
                            LineV = CreateDrawing("Line", {Thickness = 2.5})
                        }
                    end
                    local elements = Crosshairs[p]
                    local radius = math.clamp(15 - (currentDist / 10), 6, 15)
                    elements.Circle.Color = espColor
                    elements.Circle.Radius = radius
                    elements.Circle.Position = Vector2.new(vector.X, vector.Y)
                    elements.Circle.Visible = true

                    local crossSize = radius * 0.7
                    elements.LineH.Color = espColor
                    elements.LineH.From = Vector2.new(vector.X - crossSize, vector.Y)
                    elements.LineH.To = Vector2.new(vector.X + crossSize, vector.Y)
                    elements.LineH.Visible = true

                    elements.LineV.Color = espColor
                    elements.LineV.From = Vector2.new(vector.X, vector.Y - crossSize)
                    elements.LineV.To = Vector2.new(vector.X, vector.Y + crossSize)
                    elements.LineV.Visible = true
                elseif Crosshairs[p] then
                    Crosshairs[p].Circle.Visible = false
                    Crosshairs[p].LineH.Visible = false
                    Crosshairs[p].LineV.Visible = false
                end
            else
                if Tracers[p] then Tracers[p].Visible = false end
                if Labels[p] then Labels[p].Visible = false end
                if HealthBars[p] then HealthBars[p].Visible = false end
                if Crosshairs[p] then
                    Crosshairs[p].Circle.Visible = false
                    Crosshairs[p].LineH.Visible = false
                    Crosshairs[p].LineV.Visible = false
                end
                local box = BoxFolder:FindFirstChild(p.Name .. "_DarkBox")
                if box then box.Visible = false end
            end
        end
    end

    if State.Orbiting and State.OrbitTarget and State.OrbitTarget.Character and State.OrbitTarget.Character:FindFirstChild("HumanoidRootPart") and State.OrbitTarget.Character.Humanoid.Health > 0 and not State.EditingHUD then
        local targetPart = State.OrbitTarget.Character.HumanoidRootPart
        State.OrbitAngle = State.OrbitAngle + (dt * State.OrbitSpeed)
        local offset = Vector3.new(math.cos(State.OrbitAngle) * State.OrbitDistance, 1, math.sin(State.OrbitAngle) * State.OrbitDistance)
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPart.Position + offset, targetPart.Position)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
    elseif State.BackTP and not State.EditingHUD then
        if not State.BackTPTarget or not State.BackTPTarget.Character or State.BackTPTarget.Character.Humanoid.Health <= 0 then
            local closest, dist = nil, math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                    local d = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if d < dist then dist = d; closest = p end
                end
            end
            State.BackTPTarget = closest
        elseif State.BackTPTarget and State.BackTPTarget.Character and State.BackTPTarget.Character:FindFirstChild("HumanoidRootPart") then
            local targetPart = State.BackTPTarget.Character.HumanoidRootPart
            local offset = CFrame.new(0, 10, 0)
            if State.BackTPMode == "ABOVE" then offset = CFrame.new(0, 10, 0)
            elseif State.BackTPMode == "BELOW" then offset = CFrame.new(0, -5.8, 0)
            elseif State.BackTPMode == "BEHIND" then offset = CFrame.new(0, 0, 5)
            elseif State.BackTPMode == "FRONT" then offset = CFrame.new(0, 0, -5)
            elseif State.BackTPMode == "RIGHT" then offset = CFrame.new(5, 0, 0)
            elseif State.BackTPMode == "LEFT" then offset = CFrame.new(-5, 0, 0)
            end
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetPart.CFrame * offset
            LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            LocalPlayer.Character.HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
        end
    end

    if State.AimbotMobile and not State.Orbiting and not State.EditingHUD then
        if target then
            CurrentTargetPart = target
            local lerpSpeed = (State.AimbotMode == "LEGIT" and 0.05) or (State.AimbotMode == "BLATANT" and 1.0) or 0.25
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), lerpSpeed)
        else
            CurrentTargetPart = nil
        end
    else
        CurrentTargetPart = nil
    end
    
    if State.SpinHack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and not State.EditingHUD then
        local root = LocalPlayer.Character.HumanoidRootPart
        root.CFrame = root.CFrame * CFrame.fromEulerAnglesXYZ(0, math.rad(State.SpinSpeed), 0)
    end
end)

RunService.Stepped:Connect(function()
    if not ScriptRunning or State.EditingHUD then return end 
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = State.SpeedHack and State.Speed or 16
        if State.JumpHack then char.Humanoid.JumpPower = State.Jump; char.Humanoid.UseJumpPower = true end
        if State.Wallhack or State.BackTP then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end
        if State.BackTP then char.Humanoid.PlatformStand = true end
    end
    
    local ItemsModule = game:GetService("ReplicatedStorage"):FindFirstChild("Modules") and game:GetService("ReplicatedStorage").Modules:FindFirstChild("ItemLibrary")
    if ItemsModule then
        local Items = require(ItemsModule).Items
        if IsRivals then
            for id, data in pairs(Items) do
                if typeof(data) == "table" then
                    if not OriginalFireRates[id] then
                        OriginalFireRates[id] = {
                            sc = data.ShootCooldown or 0.6,
                            sbc = data.ShootBurstCooldown or 0.8,
                            spread = data.ShootSpread or 0,
                            acc = data.ShootAccuracy or 0
                        }
                    end
                    
                    if State.RapidFire then
                        data.ShootCooldown = 0.05
                        data.ShootBurstCooldown = 0.05
                    else
                        data.ShootCooldown = OriginalFireRates[id].sc
                        data.ShootBurstCooldown = OriginalFireRates[id].sbc
                    end
                    
                    if State.NoRecoil then
                        data.ShootSpread = 0
                        data.ShootAccuracy = 0
                    else
                        data.ShootSpread = OriginalFireRates[id].spread
                        data.ShootAccuracy = OriginalFireRates[id].acc
                    end
                end
            end
        end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart") or p.Character.PrimaryPart
            local distance = root and (Camera.CFrame.Position - root.Position).Magnitude or 1000
            
            local showHighlight = (State.ESP or State.ESPRelleno) and State.PanelVisible and (distance <= State.ESPRenderDistance)
            
            if showHighlight then
                local espColor = (State.RGBESP and GetRGB()) or (State.ESPVisibilityColor and (IsVisible(p.Character:FindFirstChild("HumanoidRootPart") or p.Character.PrimaryPart) and THEME.Success or THEME.Danger)) or THEME.Accent
                local h = p.Character:FindFirstChild("DarkESP")
                if not h then h = Instance.new("Highlight", p.Character); h.Name = "DarkESP" end
                h.OutlineColor = espColor
                h.FillColor = espColor
                h.OutlineTransparency = State.ESP and 0 or 1
                h.FillTransparency = State.ESPRelleno and 0.5 or 1
            elseif p.Character:FindFirstChild("DarkESP") then 
                p.Character:FindFirstChild("DarkESP"):Destroy() 
            end
        end
    end
end)

local _idx
_idx = hookmetamethod(game, "__index", newcclosure(function(self, idx, ...)
    if State.AimbotMobile and CurrentTargetPart and not checkcaller() and idx == "ViewportSize" and self == Camera then
        local pos, on = Camera:WorldToViewportPoint(CurrentTargetPart.Position)
        if on then
            return Vector2.new(pos.X * 2, pos.Y * 2)
        end
    end
    
    if State.SilentAim and SilentTarget and not checkcaller() and idx == "ViewportSize" and self == Camera then
        local pos, on = Camera:WorldToViewportPoint(SilentTarget.Position)
        if on then
            return Vector2.new(pos.X * 2, pos.Y * 2)
        end
    end
    
    return _idx(self, idx, ...)
end))
