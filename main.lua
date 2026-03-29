

--[[
    Azurion Hub - Elite Loader (Universal Support)
    Professional Interface with Modern Design, Draggable UI & Game List Support
    Updated: Added GameId (UniverseId) support for universal IDs like 994732206
]]

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

-- Script Database (Suporta PlaceId ou GameId/UniverseId)
local scripts = {
    [18667984660] = "https://raw.githubusercontent.com/azuriondeve/krnl/refs/heads/main/games/flexyourfps.lua",
    [994732206] = "https://raw.githubusercontent.com/azuriondeve/krnl/refs/heads/main/games/bf.lua", -- Exemplo de GameId

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

-- List of Supported Games
local ListFrame = Instance.new("ScrollingFrame")
ListFrame.Name = "ListFrame"
ListFrame.Size = UDim2.new(1, 0, 0, 140)
ListFrame.Position = UDim2.new(0, 0, 1, 10)
ListFrame.BackgroundTransparency = 1
ListFrame.ScrollBarThickness = 2
ListFrame.ScrollBarImageColor3 = Theme.Accent
ListFrame.Visible = false
ListFrame.Parent = Content

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ListFrame

local function closeUI()
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 340, 0, 0), Position = UDim2.new(0.5, -170, 0.5, 0)}):Play()
    task.wait(0.5)
    ScreenGui:Destroy()
end

local function executeScript(url)
    StatusLabel.Text = Text.LoadingManual
    StatusLabel.TextColor3 = Theme.Success
    task.wait(0.5)
    closeUI()
    loadstring(game:HttpGet(url))()
end

local function createGameEntry(id, url)
    local success, info = pcall(function() return MarketplaceService:GetProductInfo(id) end)
    local name = success and info.Name or "Game ID: "..id
    
    local Entry = Instance.new("TextButton")
    Entry.Size = UDim2.new(1, -5, 0, 35)
    Entry.BackgroundColor3 = Theme.Secondary
    Entry.Text = "  " .. name
    Entry.TextColor3 = Theme.SubText
    Entry.TextXAlignment = Enum.TextXAlignment.Left
    Entry.Font = Enum.Font.Gotham
    Entry.TextSize = 12
    Entry.AutoButtonColor = true
    Entry.Parent = ListFrame
    Instance.new("UICorner", Entry).CornerRadius = UDim.new(0, 6)

    local RunIcon = Instance.new("TextLabel")
    RunIcon.Size = UDim2.new(0, 60, 1, 0)
    RunIcon.Position = UDim2.new(1, -65, 0, 0)
    RunIcon.BackgroundTransparency = 1
    RunIcon.Text = "RODAR >"
    RunIcon.TextColor3 = Theme.Accent
    RunIcon.Font = Enum.Font.GothamBold
    RunIcon.TextSize = 10
    RunIcon.Parent = Entry

    Entry.MouseButton1Click:Connect(function()
        executeScript(url)
    end)
end

-- Functions
local function animateProgress(target, speed)
    TweenService:Create(ProgressFill, TweenInfo.new(speed or 1, Enum.EasingStyle.Quart), {Size = UDim2.new(target, 0, 1, 0)}):Play()
end

-- Main Logic
task.spawn(function()
    animateProgress(0.4, 1.5)
    StatusLabel.Text = Text.Verifying
    task.wait(1.2)
    
    local placeId = game.PlaceId
    local gameId = game.GameId -- Universal ID
    
    -- Checa se o PlaceId ou o GameId está no banco de dados
    local targetScript = scripts[placeId] or scripts[gameId]

    if targetScript then
        StatusLabel.Text = Text.Supported
        StatusLabel.TextColor3 = Theme.Success
        animateProgress(1, 0.8)
        task.wait(1)
        executeScript(targetScript)
    else
        -- Expand UI for Manual Selection
        StatusLabel.Text = Text.NotSupported .. placeId .. ")"
        StatusLabel.TextColor3 = Theme.Error
        task.wait(0.5)
        
        TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 340, 0, 350)}):Play()
        TweenService:Create(Content, TweenInfo.new(0.6), {Size = UDim2.new(1, -40, 0, 280)}):Play()
        
        task.wait(0.3)
        ProgressBG.Visible = false
        StatusLabel.Text = Text.SupportedGames
        StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        ListFrame.Visible = true
        TweenService:Create(ListFrame, TweenInfo.new(0.5), {Position = UDim2.new(0, 0, 0, 40)}):Play()
        
        for id, url in pairs(scripts) do
            task.spawn(function() createGameEntry(id, url) end)
        end
        
        local CloseBtn = Instance.new("TextButton")
        CloseBtn.Size = UDim2.new(1, 0, 0, 35)
        CloseBtn.Position = UDim2.new(0, 0, 0.85, 0)
        CloseBtn.BackgroundColor3 = Theme.Tertiary
        CloseBtn.Text = Text.Close
        CloseBtn.TextColor3 = Theme.Text
        CloseBtn.Font = Enum.Font.GothamBold
        CloseBtn.Parent = Content
        Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
        
        CloseBtn.MouseButton1Click:Connect(closeUI)
    end
end)
