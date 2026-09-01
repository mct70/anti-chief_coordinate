-- by 31k_MertYT
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DynamicBarHUD"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success = pcall(function()
	screenGui.Parent = CoreGui
end)

if not success then
	screenGui.Parent = player:WaitForChild("PlayerGui")
end

local container = Instance.new("Frame")
container.Name = "HUDContainer"
container.Size = UDim2.new(0, 300, 0, 42)
container.Position = UDim2.new(0, 173, 0, 13)
container.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
container.BackgroundTransparency = 0.10
container.BorderSizePixel = 0
container.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = container

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Transparency = 1
stroke.Thickness = 1
stroke.Parent = container

local label = Instance.new("TextLabel")
label.Name = "InfoLabel"
label.Size = UDim2.new(1, -20, 1, 0)
label.Position = UDim2.new(0, 10, 0, 0)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamMedium
label.TextSize = 14
label.TextColor3 = Color3.fromRGB(245, 245, 245)
label.TextXAlignment = Enum.TextXAlignment.Center
label.TextYAlignment = Enum.TextYAlignment.Center
label.Parent = container

local lastUpdate = 0
local updateInterval = 0.2
local lastPos = nil
local lastTick = tick()
local lastCFrame = nil

RunService.RenderStepped:Connect(function()
	local currentTime = tick()
	if currentTime - lastUpdate < updateInterval then
		return
	end
	
	local deltaTime = currentTime - lastTick
	lastTick = currentTime
	lastUpdate = currentTime

	local character = player.Character
	local speedVal = 0
	local rotSpeedVal = 0
	local xVal, yVal, zVal = 0, 0, 0

	if character then
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			local currentPos = rootPart.Position
			xVal = math.floor(currentPos.X + 0.5)
			yVal = math.floor(currentPos.Y + 0.5)
			zVal = math.floor(currentPos.Z + 0.5)

			if lastPos and deltaTime > 0 then
				local displacement = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(lastPos.X, 0, lastPos.Y)).Magnitude
				speedVal = math.floor((displacement / deltaTime) + 0.5)
			end
			lastPos = Vector2.new(currentPos.X, currentPos.Z)

			local currentCF = rootPart.CFrame
			if lastCFrame and deltaTime > 0 then
				local _, currentYRot = currentCF:ToEulerAnglesYXZ()
				local _, lastYRot = lastCFrame:ToEulerAnglesYXZ()
				local angleDiff = math.abs(currentYRot - lastYRot)
				if angleDiff > math.pi then
					angleDiff = (math.pi * 2) - angleDiff
				end
				rotSpeedVal = math.floor(((angleDiff / deltaTime) * (180 / math.pi)) + 0.5)
			end
			lastCFrame = currentCF
		end
	end

	label.Text = string.format("Speed: %d | Rot: %d | X: %d Y: %d Z: %d", speedVal, rotSpeedVal, xVal, yVal, zVal)
end)
