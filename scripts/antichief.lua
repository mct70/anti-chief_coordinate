-- by 31k_MertYT
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AntiFlingDynamicHUD"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success = pcall(function()
	screenGui.Parent = CoreGui
end)

if not success then
	screenGui.Parent = player:WaitForChild("PlayerGui")
end

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleFlingUI"
toggleBtn.Size = UDim2.new(0, 100, 0, 42)
toggleBtn.Position = UDim2.new(0, 480, 0, 13)
toggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
toggleBtn.BackgroundTransparency = 0.10
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "Anti Chief"
toggleBtn.TextSize = 14
toggleBtn.TextColor3 = Color3.fromRGB(245, 245, 245)
toggleBtn.Font = Enum.Font.GothamMedium
toggleBtn.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = toggleBtn

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(255, 255, 255)
btnStroke.Transparency = 0.8
btnStroke.Thickness = 1
btnStroke.Parent = toggleBtn

local mainContainer = Instance.new("ScrollingFrame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(0, 260, 0, 48)
mainContainer.Position = UDim2.new(0, 16, 0, 65)
mainContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainContainer.BackgroundTransparency = 0.25
mainContainer.BorderSizePixel = 0
mainContainer.Visible = false
mainContainer.ClipsDescendants = true
mainContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
mainContainer.ScrollBarThickness = 4
mainContainer.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
mainContainer.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainContainer

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(255, 255, 255)
mainStroke.Transparency = 0.8
mainStroke.Thickness = 1
mainStroke.Parent = mainContainer

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 6)
listLayout.Parent = mainContainer

local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, 8)
uiPadding.PaddingBottom = UDim.new(0, 8)
uiPadding.PaddingLeft = UDim.new(0, 8)
uiPadding.PaddingRight = UDim.new(0, 8)
uiPadding.Parent = mainContainer

local emptyLabel = Instance.new("TextLabel")
emptyLabel.Name = "EmptyLabel"
emptyLabel.Size = UDim2.new(1, 0, 0, 32)
emptyLabel.BackgroundTransparency = 1
emptyLabel.Font = Enum.Font.GothamMedium
emptyLabel.TextSize = 13
emptyLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
emptyLabel.Text = "Empty List"
emptyLabel.Parent = mainContainer

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	mainContainer.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 16)
end)

local isUIOpen = false
toggleBtn.MouseButton1Click:Connect(function()
	isUIOpen = not isUIOpen
	mainContainer.Visible = isUIOpen
end)

local flaggedPlayers = {}
local playerTimers = {}
local VELOCITY_THRESHOLD = 350
local ROT_THRESHOLD = 700
local REMOVE_DELAY = 10

local function updateContainerSize()
	local count = 0
	for _ in pairs(flaggedPlayers) do
		count = count + 1
	end
	
	if count == 0 then
		emptyLabel.Visible = true
		mainContainer.Size = UDim2.new(0, 260, 0, 48)
	else
		emptyLabel.Visible = false
		local displayCount = math.min(count, 5)
		mainContainer.Size = UDim2.new(0, 260, 0, (displayCount * 52) + 16)
	end
end

local function removeCard(otherPlayer)
	if flaggedPlayers[otherPlayer] then
		local card = mainContainer:FindFirstChild("Card_" .. otherPlayer.UserId)
		if card then
			card:Destroy()
		end
		flaggedPlayers[otherPlayer] = nil
		playerTimers[otherPlayer] = nil
		updateContainerSize()
	end
end

local function addOrRefreshCard(otherPlayer)
	playerTimers[otherPlayer] = tick() + REMOVE_DELAY

	local card = mainContainer:FindFirstChild("Card_" .. otherPlayer.UserId)
	if not card then
		card = Instance.new("Frame")
		card.Name = "Card_" .. otherPlayer.UserId
		card.Size = UDim2.new(1, 0, 0, 46)
		card.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		card.BackgroundTransparency = 0.4
		card.BorderSizePixel = 0
		card.Parent = mainContainer

		local cCorner = Instance.new("UICorner")
		cCorner.CornerRadius = UDim.new(0, 8)
		cCorner.Parent = card

		local avatar = Instance.new("ImageLabel")
		avatar.Name = "Avatar"
		avatar.Size = UDim2.new(0, 34, 0, 34)
		avatar.Position = UDim2.new(0, 6, 0, 6)
		avatar.BackgroundTransparency = 1
		avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. otherPlayer.UserId .. "&w=150&h=150"
		avatar.Parent = card

		local aCorner = Instance.new("UICorner")
		aCorner.CornerRadius = UDim.new(1, 0)
		aCorner.Parent = avatar

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "NameLabel"
		nameLabel.Size = UDim2.new(1, -46, 0, 18)
		nameLabel.Position = UDim2.new(0, 46, 0, 6)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 12
		nameLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Text = otherPlayer.DisplayName
		nameLabel.Parent = card

		local userLabel = Instance.new("TextLabel")
		userLabel.Name = "UserLabel"
		userLabel.Size = UDim2.new(1, -46, 0, 14)
		userLabel.Position = UDim2.new(0, 46, 0, 24)
		userLabel.BackgroundTransparency = 1
		userLabel.Font = Enum.Font.Gotham
		userLabel.TextSize = 10
		userLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
		userLabel.TextXAlignment = Enum.TextXAlignment.Left
		userLabel.Text = "@" .. otherPlayer.Name
		userLabel.Parent = card

		local barBg = Instance.new("Frame")
		barBg.Name = "BarBg"
		barBg.Size = UDim2.new(1, -12, 0, 3)
		barBg.Position = UDim2.new(0, 6, 1, -5)
		barBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		barBg.BorderSizePixel = 0
		barBg.Parent = card

		local barFill = Instance.new("Frame")
		barFill.Name = "BarFill"
		barFill.Size = UDim2.new(1, 0, 1, 0)
		barFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
		barFill.BorderSizePixel = 0
		barFill.Parent = barBg

		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(1, 0)
		fillCorner.Parent = barFill
	end

	local cardObj = mainContainer:FindFirstChild("Card_" .. otherPlayer.UserId)
	if cardObj then
		local fill = cardObj:FindFirstChild("BarBg", true):FindFirstChild("BarFill")
		if fill then
			fill.Size = UDim2.new(1, 0, 1, 0)
			TweenService:Create(fill, TweenInfo.new(REMOVE_DELAY, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()
		end
	end

	updateContainerSize()
end

RunService.Stepped:Connect(function()
	local currentTime = tick()

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			if hrp and hum then
				local realVel = hrp.AssemblyLinearVelocity.Magnitude
				local realRotVel = hrp.AssemblyAngularVelocity.Magnitude

				local isFlinging = (realVel > VELOCITY_THRESHOLD or realRotVel > ROT_THRESHOLD)

				if isFlinging then
					if not flaggedPlayers[p] then
						flaggedPlayers[p] = true
						addOrRefreshCard(p)
					else
						playerTimers[p] = currentTime + REMOVE_DELAY
					end
				end

				if flaggedPlayers[p] then
					for _, part in ipairs(p.Character:GetDescendants()) do
						if part:IsA("BasePart") then
							part.CanCollide = false
						end
					end
				end
			end
		end
	end

	for p, removeTime in pairs(playerTimers) do
		if currentTime >= removeTime then
			removeCard(p)
		end
	end
end)

Players.PlayerRemoving:Connect(function(p)
	removeCard(p)
end)
