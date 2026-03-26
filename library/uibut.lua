-- =============================================
-- BOTÃO RIGHT SHIFT - Arrastável (PC + Mobile)
-- Coloque isso como LocalScript no executor
-- =============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")  -- Usado em muitos executores

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Cria a ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RightShiftButton"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Cria o botão
local button = Instance.new("TextButton")
button.Name = "ShiftBtn"
button.Size = UDim2.new(0, 90, 0, 90)
button.Position = UDim2.new(0, 50, 0, 50)
button.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
button.Text = "RIGHT\nSHIFT"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextScaled = true
button.Font = Enum.Font.GothamBold
button.BorderSizePixel = 0
button.BackgroundTransparency = 0
button.Parent = screenGui

-- Cantos arredondados
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 20)
corner.Parent = button

-- Sombra suave
local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 0, 0))
}
uiGradient.Rotation = 45
uiGradient.Parent = button

-- Variáveis para drag
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

-- Função que simula pressionar Right Shift (melhor método em executores)
local function pressRightShift()
    -- Feedback visual
    button.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    button.Size = UDim2.new(0, 82, 0, 82)
    
    -- Simula a tecla Right Shift
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.RightShift, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightShift, false, game)
    end)
    
    -- Volta ao normal
    task.wait(0.1)
    button.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
    button.Size = UDim2.new(0, 90, 0, 90)
end

-- ====================== DRAG (Mouse + Touch) ======================
button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = button.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Clique no botão (executa o Right Shift)
button.MouseButton1Click:Connect(function()
    pressRightShift()
end)

-- Suporte extra para touch (alguns executores mobile)
button.TouchTap:Connect(function()
    pressRightShift()
end)

print("✅ Botão Right Shift criado com sucesso! Arraste e clique para usar.")
