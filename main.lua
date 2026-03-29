--[[
    Azurion Hub - Elite Loader (Universal Support)
    Versão com Suporte a Configurações Globais (getgenv/_G)
]]

-- 1. Definição das Configurações Globais (Serão aplicadas antes de qualquer script)
local function applyGlobalConfigs()
    -- Você pode usar _G ou getgenv() conforme sua preferência
    getgenv().AzurionConfig = {
        AutoFarm = false,
        FarmDistance = 20,
        AutoCastleRaid = false,
        AttackNearest = false,
        AutoFarmRaid = false,
        TweenSpeed = 200,
        SelectedWeapon = "Melee",
        HitboxExpander = false,
        HitboxSize = 60,
        ViewHitbox = false,
        WaterWalking = true,
        SpeedValue = 1,
        AutoBuso = true,
        IsMoving = false,
        AutoStatus = false,
        SelectedStats = { "Melee" },
        Amount = 1,
        SelectedPlayer = nil,
        TweenToPlayer = false,
        DistanceLimit = 70,
        AutoPressU = false
    }
    
    -- Exemplo de compatibilidade com seu _G atual
    _G.Config = getgenv().AzurionConfig 
end

-- Chamar a função de configuração imediatamente
applyGlobalConfigs()

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")

-- Language Configuration
local lang = getgenv().language or "pt"
local Localization = {
    ["pt"] = {
        Initializing = "Inicializando...",
        Verifying = "Verificando Compatibilidade...",
        Supported = "Jogo Suportado! Carregando Hub...",
        NotSupported = "Jogo não Suportado (ID: ",
        SupportedGames = "Jogos Suportados (Clique para Rodar):",
        Close = "Fechar",
        LoadingManual = "Carregando Script Selecionado..."
    },
    ["en"] = {
        Initializing = "Initializing...",
        Verifying = "Verifying Compatibility...",
        Supported = "Game Supported! Fetching Hub...",
        NotSupported = "Game Not Supported (ID: ",
        SupportedGames = "Supported Games (Click to Run):",
        Close = "Close",
        LoadingManual = "Loading Selected Script..."
    }
}

local Text = Localization[lang] or Localization["pt"]

-- Configuration
local Config = {
    HubName = "KRNL Hub",
    Version = "v1"
}

-- Script Database
local scripts = {
    [18667984660] = "https://raw.githubusercontent.com/azuriondeve/krnl/refs/heads/main/games/flexyourfps.lua",
    [994732206] = "https://raw.githubusercontent.com/azuriondeve/krnl/refs/heads/main/games/bf.lua", 
}

-- Theme
local Theme = {
    Background = Color3.fromRGB(12, 10, 18),
    Accent = Color3.fromRGB(138, 43, 226),
    Secondary = Color3.fromRGB(25, 20, 35),
    Tertiary = Color3.fromRGB(35, 30, 50),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(160, 160, 160),
    Error = Color3.fromRGB(255, 60, 60),
    Success = Color3.fromRGB(80, 255, 120)
}

-- Cleanup
if CoreGui:FindFirstChild("AzurionLoader") then CoreGui.AzurionLoader:Destroy() end

-- UI Construction
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AzurionLoader"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 180)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -90)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 2
Stroke.Color = Theme.Accent
Stroke.Parent = MainFrame

-- Draggable Logic
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(MainFrame)

-- Header
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = Config.HubName .. " " .. Config.Version
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = MainFrame

-- Content Container
local Content = Instance.new("CanvasGroup")
Content.Size = UDim2.new(1, -40, 0, 100)
Content.Position = UDim2.new(0, 20, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0.2, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = Text.Initializing
StatusLabel.TextColor3 = Theme.SubText
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 14
StatusLabel.Parent = Content

local ProgressBG = Instance.new("Frame")
ProgressBG.Size = UDim2.new(1, 0, 0, 6)
ProgressBG.Position = UDim2.new(0, 0, 0.6, 0)
ProgressBG.BackgroundColor3 = Theme.Secondary
ProgressBG.Parent = Content

local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Theme.Accent
ProgressFill.Parent = ProgressBG
Instance.new("UICorner", ProgressFill).CornerRadius = UDim.new(1, 0)

-- List Frame
local ListFrame = Instance.new("ScrollingFrame")
ListFrame.Name = "ListFrame"
ListFrame.Size = UDim2.new(1, 0, 0, 140)
ListFrame.Position = UDim2.new(0, 0,
