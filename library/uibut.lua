-- Draggable Key Button Lib (Loadingstring Ready)
-- Cole tudo isso de uma vez no seu executor

local DraggableKeyButtonLib = {}

local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local function makeDraggable(gui)
	local dragging, dragInput, dragStart, startPos

	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	gui.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

function DraggableKeyButtonLib:Create(config)
	config = config or {}

	-- Evita criar várias ScreenGuis
	local screenGui = game:GetService("CoreGui"):FindFirstChild("DraggableKeyLib") 
		or Instance.new("ScreenGui")
	screenGui.Name = "DraggableKeyLib"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = game:GetService("CoreGui")

	local btn = Instance.new("ImageButton")
	btn.Name = config.Name or "KeyButton"
	btn.BackgroundTransparency = 1
	btn.Size = config.Size or UDim2.new(0, 100, 0, 100)
	btn.Position = config.Position or UDim2.new(0.5, -50, 0.5, -50)
	btn.Image = config.Image or "rbxassetid://357249130"
	btn.Parent = screenGui

	-- Suavidade das bordas (20 é bem suave e bonito)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = config.CornerRadius or UDim.new(0, 20)
	corner.Parent = btn

	makeDraggable(btn)

	-- Clique → simula tecla
	btn.MouseButton1Click:Connect(function()
		local key = config.KeyCode or Enum.KeyCode.E

		VirtualInputManager:SendKeyEvent(true, key, false, game)
		task.wait(0.07)
		VirtualInputManager:SendKeyEvent(false, key, false, game)
	end)

	print("✅ Botão criado com sucesso! Tecla: " .. tostring(config.KeyCode))
	return btn
end

-- =======================
-- EXEMPLO DE USO (depois da lib)
-- =======================

--[[
DraggableKeyButtonLib:Create({
	Image = "rbxassetid://SEU_ID_AQUI",      -- ← coloque seu rbxassetid aqui
	KeyCode = Enum.KeyCode.F,                -- tecla que vai apertar (mude aqui)
	CornerRadius = UDim.new(0, 25),          -- quanto mais alto = mais redondo
	Size = UDim2.new(0, 85, 0, 85),
	Position = UDim2.new(0, 350, 0, 250),
	Name = "BotaoF"
})
]]
