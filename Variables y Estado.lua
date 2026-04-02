local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local ScriptRunning = true 

local IsRivals = (game.PlaceId == 17625359962 or game.PlaceId == 11349125045)
local ManualModeSelected = false 

local CurrentTargetPart = nil
local SilentTarget = nil

local State = {
    SavedCFrame = nil,
    Wallhack = false,
    ESP = false, 
    ESPRelleno = false, 
    ESPCrosshair = false, 
    ESPBox = false,
    ESPLine = false, 
    ESPLinePos = "TOP", 
    ESPInfo = false, 
    ESPHealth = false, 
    RGBESP = false,
    ESPVisibilityColor = false,
    XRay = false, 
    XRayTransparency = 0.5, 
    AimbotMobile = false,
    SilentAim = false, 
    NoRecoil = false, 
    AimbotMode = IsRivals and "BLATANT" or "LEGIT", 
    TargetPart = "HEAD", 
    RapidFire = false, 
    TeamCheck = false,
    WallCheck = true,
    DistanceCheck = true,
    ShowFOV = false,
    FOVSize = 150,
    FieldOfView = 70,
    Fly = false,
    FlySpeed = 50,
    SpeedHack = false,
    Speed = 50,
    JumpHack = false,
    MultiJump = false,
    Jump = 100,
    SpinHack = false,
    SpinSpeed = 10,
    IsMinimized = false,
    PanelVisible = true,
    FlyingUp = false,
    FlyingDown = false,
    Orbiting = false,
    OrbitTarget = nil,
    OrbitSpeed = 5,
    OrbitDistance = 5,
    OrbitAngle = 0,
    BackTP = false,
    BackTPMode = "ABOVE",
    BackTPTarget = nil,
    FloatAimbot = false,
    FloatESP = false,
    FloatFly = false,
    EditingHUD = false,
    FreecamEnabled = false, 
    ESPRenderDistance = 500, 
    AimbotRange = 400 
}

local THEME = {
    Background = Color3.fromRGB(10, 10, 12),
    TopBar = Color3.fromRGB(20, 0, 40),
    Accent = Color3.fromRGB(170, 0, 255),
    Text = Color3.fromRGB(255, 255, 255),
    ElementBG = Color3.fromRGB(25, 25, 30),
    Danger = Color3.fromRGB(255, 0, 50),
    Success = Color3.fromRGB(0, 255, 100)
}

local HUDFileName = "DarkMatter_HUD_Save.json"

local function SaveHUDPosition(pos, name)
    if writefile then
        pcall(function()
            local data = {
                XScale = pos.X.Scale,
                XOffset = pos.X.Offset,
                YScale = pos.Y.Scale,
                YOffset = pos.Y.Offset
            }
            writefile("DarkMatter_Pos_" .. name .. ".json", HttpService:JSONEncode(data))
        end)
    end
end

local function LoadHUDPosition(name)
    if isfile and isfile("DarkMatter_Pos_" .. name .. ".json") and readfile then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile("DarkMatter_Pos_" .. name .. ".json"))
        end)
        if success and result then
            return UDim2.new(result.XScale, result.XOffset, result.YScale, result.YOffset)
        end
    end
    return nil
end

local function GetRGB()
    return Color3.fromHSV(tick() % 5 / 5, 1, 1)
end

local Tracers = {}
local Labels = {}
local HealthBars = {}
local Crosshairs = {}
local XRayParts = {} 
local OriginalFireRates = {} 
