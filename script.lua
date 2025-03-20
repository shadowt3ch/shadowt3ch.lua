local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

-- Hack States
local speedEnabled = false
local flyEnabled = false
local invisibleEnabled = false
local godModeEnabled = false
local espEnabled = false
local aimbotEnabled = false
local noClipEnabled = false
local dupeEnabled = false
local flySpeed = 50
local walkSpeed = 32
local aimbotRange = 100
local bodyVelocity, bodyGyro = nil, nil
local espObjects = {}
local dupeClone = nil
local isJumping = false

-- Main UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
print("ScreenGui initialized")

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local TitleAccent = Instance.new("Frame")
TitleAccent.Parent = TitleBar
TitleAccent.Size = UDim2.new(1, 0, 0, 2)
TitleAccent.Position = UDim2.new(0, 0, 1, -2)
TitleAccent.BackgroundColor3 = Color3.fromRGB(138, 43, 226)

local Title = Instance.new("TextLabel")
Title.Parent = TitleBar
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 5, 0, 0)
Title.Text = "ShadowT3ch | Beta | Universal | Delta"
Title.TextColor3 = Color3.fromRGB(200, 200, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local URLLabel = Instance.new("TextLabel")
URLLabel.Parent = TitleBar
URLLabel.Size = UDim2.new(0.3, -5, 1, 0)
URLLabel.Position = UDim2.new(0.7, 0, 0, 0)
URLLabel.Text = "Version: 1.0"
URLLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
URLLabel.Font = Enum.Font.Gotham
URLLabel.TextSize = 12
URLLabel.BackgroundTransparency = 1
URLLabel.TextXAlignment = Enum.TextXAlignment.Right

local TabFrame = Instance.new("Frame")
TabFrame.Parent = MainFrame
TabFrame.Size = UDim2.new(1, 0, 0, 30)
TabFrame.Position = UDim2.new(0, 0, 0, 30)
TabFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)

local TabAccent = Instance.new("Frame")
TabAccent.Parent = TabFrame
TabAccent.Size = UDim2.new(1, 0, 0, 2)
TabAccent.Position = UDim2.new(0, 0, 1, -2)
TabAccent.BackgroundColor3 = Color3.fromRGB(138, 43, 226)

-- Tabs Setup
local Tabs = {"Speed", "Fly", "Invis", "God", "Teleport", "ESP", "Aimbot", "NoClip", "Dupe"}
local ContentFrames = {}
for i, tabName in ipairs(Tabs) do
	local TabButton = Instance.new("TextButton")
	TabButton.Parent = TabFrame
	TabButton.Size = UDim2.new(1/#Tabs, -2, 1, 0)
	TabButton.Position = UDim2.new((i - 1) * (1/#Tabs), 0, 0, 0)
	TabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	TabButton.Text = tabName
	TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
	TabButton.Font = Enum.Font.Gotham
	TabButton.TextSize = 12
	TabButton.BorderSizePixel = 0

	TabButton.MouseEnter:Connect(function()
		TabButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
	end)
	TabButton.MouseLeave:Connect(function()
		if ContentFrames[tabName] and ContentFrames[tabName].Visible then
			TabButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
		else
			TabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		end
	end)

	local ContentFrame = Instance.new("Frame")
	ContentFrame.Parent = MainFrame
	ContentFrame.Size = UDim2.new(1, 0, 1, -60)
	ContentFrame.Position = UDim2.new(0, 0, 0, 60)
	ContentFrame.BackgroundTransparency = 1
	ContentFrame.Visible = (i == 1)
	ContentFrames[tabName] = ContentFrame

	TabButton.MouseButton1Click:Connect(function()
		for _, frame in pairs(ContentFrames) do
			frame.Visible = false
		end
		for _, btn in pairs(TabFrame:GetChildren()) do
			if btn:IsA("TextButton") then
				btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			end
		end
		ContentFrame.Visible = true
		TabButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
	end)
	print("Tab '" .. tabName .. "' initialized")
end

-- Hack Functions
local function toggleSpeed()
	if not humanoid then warn("Speed: Humanoid not found"); return end
	speedEnabled = not speedEnabled
	local toggleButton = ContentFrames["Speed"]:FindFirstChild("ToggleButton")
	if speedEnabled then
		humanoid.WalkSpeed = walkSpeed
		toggleButton.Text = "Speed: ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	else
		humanoid.WalkSpeed = 16
		toggleButton.Text = "Speed: OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	end
end

local function toggleFly()
	if not rootPart or not humanoid then warn("Fly: Character parts not found"); return end
	flyEnabled = not flyEnabled
	local toggleButton = ContentFrames["Fly"]:FindFirstChild("ToggleButton")
	if flyEnabled then
		humanoid.WalkSpeed = 0
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bodyVelocity.Parent = rootPart
		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.P = 3000
		bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bodyGyro.CFrame = rootPart.CFrame
		bodyGyro.Parent = rootPart
		toggleButton.Text = "Fly: ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	else
		humanoid.WalkSpeed = 16
		if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
		if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
		toggleButton.Text = "Fly: OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	end
end

local function updateFlight()
	if flyEnabled and rootPart and bodyVelocity and bodyGyro then
		local direction = Vector3.new()
		local camLook = camera.CFrame.LookVector
		local moveDir = humanoid.MoveDirection

		if moveDir.Magnitude > 0 then direction = direction + moveDir end
		if isJumping then direction = direction + Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction + Vector3.new(0, -1, 0) end

		if direction.Magnitude > 0 then direction = direction.Unit * flySpeed end
		bodyVelocity.Velocity = direction
		bodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + camLook)
	end
end

local function toggleInvisible()
	if not character or not humanoid then warn("Invis: Character not found"); return end
	invisibleEnabled = not invisibleEnabled
	local toggleButton = ContentFrames["Invis"]:FindFirstChild("ToggleButton")

	if invisibleEnabled then
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("MeshPart") then
				part.Transparency = 1
				part.LocalTransparencyModifier = 1
			end
			if part:IsA("Decal") then
				part.Transparency = 1
			end
			if part:IsA("Accessory") then
				local handle = part:FindFirstChild("Handle")
				if handle then
					handle.Transparency = 1
					handle.LocalTransparencyModifier = 1
				end
			end
		end
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		toggleButton.Text = "Invis: ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	else
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("MeshPart") then
				part.Transparency = 0
				part.LocalTransparencyModifier = 0
			end
			if part:IsA("Decal") then
				part.Transparency = part.Name == "face" and 0 or 1
			end
			if part:IsA("Accessory") then
				local handle = part:FindFirstChild("Handle")
				if handle then
					handle.Transparency = 0
					handle.LocalTransparencyModifier = 0
				end
			end
		end
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
		toggleButton.Text = "Invis: OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	end
end

local function toggleGodMode()
	if not humanoid then warn("God: Humanoid not found"); return end
	godModeEnabled = not godModeEnabled
	local toggleButton = ContentFrames["God"]:FindFirstChild("ToggleButton")
	if godModeEnabled then
		humanoid.MaxHealth = math.huge
		humanoid.Health = math.huge
		humanoid.HealthChanged:Connect(function(health)
			if godModeEnabled and health < math.huge then
				humanoid.Health = math.huge
			end
		end)
		toggleButton.Text = "God: ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	else
		humanoid.MaxHealth = 100
		humanoid.Health = 100
		toggleButton.Text = "God: OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	end
end

local function teleportToPlayer(targetInput)
	if not rootPart then warn("Teleport: RootPart not found"); return end
	targetInput = targetInput:lower():gsub("%s+", "")
	if targetInput == "" then warn("Teleport: No input provided"); return end

	local target = nil
	for _, p in pairs(game.Players:GetPlayers()) do
		local usernameLower = p.Name:lower():gsub("%s+", "")
		local displayNameLower = p.DisplayName:lower():gsub("%s+", "")
		if usernameLower == targetInput or displayNameLower == targetInput then
			target = p
			break
		end
	end

	if not target then
		warn("Teleport: No exact match for '" .. targetInput .. "'")
		return
	end

	local targetCharacter = target.Character or target.CharacterAdded:Wait()
	local targetRoot = targetCharacter:WaitForChild("HumanoidRootPart", 5)
	if not targetRoot then
		warn("Teleport: Target's HumanoidRootPart not found")
		return
	end

	local success, error = pcall(function()
		rootPart.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
	end)

	if success then
		print("Teleported to " .. target.DisplayName .. "(@" .. target.Name .. ")")
	else
		warn("Teleport failed: " .. error)
	end
end

local function createESP(targetPlayer)
	if targetPlayer == player or not targetPlayer.Character then return end
	local head = targetPlayer.Character:WaitForChild("Head", 5)
	if not head then return end

	local esp = {}
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESPBillboard"
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 100, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = targetPlayer.Character

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = targetPlayer.DisplayName .. " (@" .. targetPlayer.Name .. ")"
	nameLabel.TextColor3 = Color3.fromRGB(138, 43, 226)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 14
	nameLabel.Parent = billboard

	local distanceLabel = Instance.new("TextLabel")
	distanceLabel.Name = "DistanceLabel"
	distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
	distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
	distanceLabel.BackgroundTransparency = 1
	distanceLabel.Text = "0 studs"
	distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	distanceLabel.Font = Enum.Font.Gotham
	distanceLabel.TextSize = 12
	distanceLabel.Parent = billboard

	local highlight = Instance.new("Highlight")
	highlight.Name = "ESPHighlight"
	highlight.Adornee = targetPlayer.Character
	highlight.FillTransparency = 1
	highlight.OutlineColor = Color3.fromRGB(138, 43, 226)
	highlight.Parent = targetPlayer.Character

	esp.billboard = billboard
	esp.distanceLabel = distanceLabel
	esp.highlight = highlight
	espObjects[targetPlayer] = esp
end

local function toggleESP()
	espEnabled = not espEnabled
	local toggleButton = ContentFrames["ESP"]:FindFirstChild("ToggleButton")
	if espEnabled then
		for _, targetPlayer in pairs(game.Players:GetPlayers()) do
			createESP(targetPlayer)
		end
		toggleButton.Text = "ESP: ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	else
		for _, esp in pairs(espObjects) do
			if esp.billboard then esp.billboard:Destroy() end
			if esp.highlight then esp.highlight:Destroy() end
		end
		espObjects = {}
		toggleButton.Text = "ESP: OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	end
end

local function updateESP()
	if espEnabled and rootPart then
		for targetPlayer, esp in pairs(espObjects) do
			if targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
				local targetHead = targetPlayer.Character.Head
				local distance = (rootPart.Position - targetHead.Position).Magnitude
				esp.distanceLabel.Text = math.floor(distance) .. " studs"
			else
				esp.distanceLabel.Text = "N/A"
			end
		end
	end
end

local function getNearestPlayer()
	if not rootPart then return end
	local closestPlayer = nil
	local shortestDistance = aimbotRange

	for _, target in pairs(game.Players:GetPlayers()) do
		if target ~= player and target.Character and target.Character:FindFirstChild("Head") then
			local targetHead = target.Character.Head
			local distance = (rootPart.Position - targetHead.Position).Magnitude
			if distance < shortestDistance then
				closestPlayer = target
				shortestDistance = distance
			end
		end
	end

	return closestPlayer
end

local function toggleAimbot()
	aimbotEnabled = not aimbotEnabled
	local toggleButton = ContentFrames["Aimbot"]:FindFirstChild("ToggleButton")
	if aimbotEnabled then
		toggleButton.Text = "Aimbot: ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	else
		toggleButton.Text = "Aimbot: OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	end
end

local function updateAimbot()
	if aimbotEnabled and rootPart then
		local target = getNearestPlayer()
		if target and target.Character and target.Character:FindFirstChild("Head") then
			local targetPos = target.Character.Head.Position
			local cameraCFrame = CFrame.new(camera.CFrame.Position, targetPos)
			camera.CFrame = camera.CFrame:Lerp(cameraCFrame, 0.5)
		end
	end
end

local function toggleNoClip()
	if not character or not humanoid then warn("NoClip: Character not found"); return end
	noClipEnabled = not noClipEnabled
	local toggleButton = ContentFrames["NoClip"]:FindFirstChild("ToggleButton")
	if noClipEnabled then
		toggleButton.Text = "NoClip: ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	else
		toggleButton.Text = "NoClip: OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	end
end

local function updateNoClip()
	if noClipEnabled and character then
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("MeshPart") then
				part.CanCollide = false
			end
		end
	else
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("MeshPart") then
				part.CanCollide = true
			end
		end
	end
end

local function toggleDupe()
	if not character or not rootPart then 
		warn("Dupe: Character or RootPart not found")
		return 
	end
	dupeEnabled = not dupeEnabled
	local toggleButton = ContentFrames["Dupe"]:FindFirstChild("ToggleButton")

	if dupeEnabled then
		print("Attempting to create dupe clone...")
		local success, err = pcall(function()
			dupeClone = character:Clone()
			if not dupeClone then
				warn("Dupe: Cloning failed")
				return
			end
			dupeClone.Parent = workspace
			dupeClone.Name = player.Name .. "_Dupe"
			local cloneRoot = dupeClone:FindFirstChild("HumanoidRootPart")
			if cloneRoot then
				cloneRoot.CFrame = rootPart.CFrame * CFrame.new(3, 0, 0)
				cloneRoot.Anchored = true -- Anchor initially to ensure visibility
			else
				warn("Dupe: No HumanoidRootPart in clone")
			end
			local cloneHumanoid = dupeClone:FindFirstChild("Humanoid")
			if cloneHumanoid then
				cloneHumanoid.WalkSpeed = 0
				cloneHumanoid.JumpPower = 0
				cloneHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			end
			for _, part in pairs(dupeClone:GetDescendants()) do
				if part:IsA("BasePart") or part:IsA("MeshPart") then
					part.CanCollide = false
					part.Transparency = 0 -- Ensure visibility
				end
			end
			print("Dupe clone created at " .. tostring(cloneRoot and cloneRoot.Position))
		end)
		if not success then
			warn("Dupe error: " .. err)
			dupeClone = nil
			dupeEnabled = false
			toggleButton.Text = "Dupe: OFF"
			toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			return
		end
		toggleButton.Text = "Dupe: ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	else
		if dupeClone then
			dupeClone:Destroy()
			dupeClone = nil
			print("Dupe clone destroyed")
		end
		toggleButton.Text = "Dupe: OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	end
end

local function updateDupe()
	if dupeEnabled and dupeClone and rootPart then
		local cloneRoot = dupeClone:FindFirstChild("HumanoidRootPart")
		if cloneRoot then
			cloneRoot.Anchored = false -- Unanchor to follow
			cloneRoot.CFrame = rootPart.CFrame * CFrame.new(3, 0, 0)
		end
	end
end

-- Slider Logic
local function createSlider(parent, posY, min, max, default, callback)
	local SliderFrame = Instance.new("Frame")
	SliderFrame.Size = UDim2.new(0.9, 0, 0, 20)
	SliderFrame.Position = UDim2.new(0.05, 0, 0, posY)
	SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	SliderFrame.Parent = parent
	SliderFrame.ClipsDescendants = true

	local SliderKnob = Instance.new("Frame")
	SliderKnob.Size = UDim2.new(0, 10, 1, 0)
	SliderKnob.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
	SliderKnob.Parent = SliderFrame
	SliderKnob.Position = UDim2.new((default - min) / (max - min), 0, 0, 0)

	SliderFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			MainFrame.Draggable = false
			local connection
			connection = UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					local sliderWidth = SliderFrame.AbsoluteSize.X
					local newX = math.clamp(input.Position.X - SliderFrame.AbsolutePosition.X, 0, sliderWidth)
					SliderKnob.Position = UDim2.new(0, newX, 0, 0)
					local value = min + (newX / sliderWidth) * (max - min)
					callback(math.floor(value))
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					connection:Disconnect()
					MainFrame.Draggable = true
				end
			end)
		end
	end)
end

-- Tab Content
local function createTabContent(tabName, ContentFrame)
	if tabName == "Speed" then
		local ToggleButton = Instance.new("TextButton")
		ToggleButton.Name = "ToggleButton"
		ToggleButton.Size = UDim2.new(0.9, 0, 0, 40)
		ToggleButton.Position = UDim2.new(0.05, 0, 0, 20)
		ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		ToggleButton.Text = "Speed: OFF"
		ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		ToggleButton.Font = Enum.Font.Gotham
		ToggleButton.TextSize = 18
		ToggleButton.Parent = ContentFrame
		ToggleButton.MouseButton1Click:Connect(toggleSpeed)

		createSlider(ContentFrame, 70, 16, 100, walkSpeed, function(value)
			walkSpeed = value
			if speedEnabled then humanoid.WalkSpeed = walkSpeed end
		end)
	elseif tabName == "Fly" then
		local ToggleButton = Instance.new("TextButton")
		ToggleButton.Name = "ToggleButton"
		ToggleButton.Size = UDim2.new(0.9, 0, 0, 40)
		ToggleButton.Position = UDim2.new(0.05, 0, 0, 20)
		ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		ToggleButton.Text = "Fly: OFF"
		ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		ToggleButton.Font = Enum.Font.Gotham
		ToggleButton.TextSize = 18
		ToggleButton.Parent = ContentFrame
		ToggleButton.MouseButton1Click:Connect(toggleFly)

		createSlider(ContentFrame, 70, 25, 125, flySpeed, function(value)
			flySpeed = value
		end)

		local InfoLabel = Instance.new("TextLabel")
		InfoLabel.Size = UDim2.new(0.9, 0, 0, 40)
		InfoLabel.Position = UDim2.new(0.05, 0, 0, 120)
		InfoLabel.BackgroundTransparency = 1
		InfoLabel.Text = "Controls: Joystick/WASD, Jump (up), Shift (down)"
		InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		InfoLabel.Font = Enum.Font.Gotham
		InfoLabel.TextSize = 14
		InfoLabel.Parent = ContentFrame
	elseif tabName == "Invis" then
		local ToggleButton = Instance.new("TextButton")
		ToggleButton.Name = "ToggleButton"
		ToggleButton.Size = UDim2.new(0.9, 0, 0, 40)
		ToggleButton.Position = UDim2.new(0.05, 0, 0, 20)
		ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		ToggleButton.Text = "Invis: OFF"
		ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		ToggleButton.Font = Enum.Font.Gotham
		ToggleButton.TextSize = 18
		ToggleButton.Parent = ContentFrame
		ToggleButton.MouseButton1Click:Connect(toggleInvisible)
	elseif tabName == "God" then
		local ToggleButton = Instance.new("TextButton")
		ToggleButton.Name = "ToggleButton"
		ToggleButton.Size = UDim2.new(0.9, 0, 0, 40)
		ToggleButton.Position = UDim2.new(0.05, 0, 0, 20)
		ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		ToggleButton.Text = "God: OFF"
		ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		ToggleButton.Font = Enum.Font.Gotham
		ToggleButton.TextSize = 18
		ToggleButton.Parent = ContentFrame
		ToggleButton.MouseButton1Click:Connect(toggleGodMode)
	elseif tabName == "Teleport" then
		local TextBox = Instance.new("TextBox")
		TextBox.Size = UDim2.new(0.9, 0, 0, 40)
		TextBox.Position = UDim2.new(0.05, 0, 0, 20)
		TextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		TextBox.Font = Enum.Font.Gotham
		TextBox.TextSize = 18
		TextBox.PlaceholderText = "Enter exact username or display name"
		TextBox.Parent = ContentFrame

		local TeleportButton = Instance.new("TextButton")
		TeleportButton.Size = UDim2.new(0.9, 0, 0, 40)
		TeleportButton.Position = UDim2.new(0.05, 0, 0, 70)
		TeleportButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		TeleportButton.Text = "Teleport"
		TeleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		TeleportButton.Font = Enum.Font.Gotham
		TeleportButton.TextSize = 18
		TeleportButton.Parent = ContentFrame
		TeleportButton.MouseButton1Click:Connect(function()
			if TextBox.Text ~= "" then
				teleportToPlayer(TextBox.Text)
			else
				warn("Teleport: Please enter a username or display name.")
			end
		end)

		TextBox.FocusLost:Connect(function(enterPressed)
			if enterPressed and TextBox.Text ~= "" then
				teleportToPlayer(TextBox.Text)
			end
		end)
	elseif tabName == "ESP" then
		local ToggleButton = Instance.new("TextButton")
		ToggleButton.Name = "ToggleButton"
		ToggleButton.Size = UDim2.new(0.9, 0, 0, 40)
		ToggleButton.Position = UDim2.new(0.05, 0, 0, 20)
		ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		ToggleButton.Text = "ESP: OFF"
		ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		ToggleButton.Font = Enum.Font.Gotham
		ToggleButton.TextSize = 18
		ToggleButton.Parent = ContentFrame
		ToggleButton.MouseButton1Click:Connect(toggleESP)
	elseif tabName == "Aimbot" then
		local ToggleButton = Instance.new("TextButton")
		ToggleButton.Name = "ToggleButton"
		ToggleButton.Size = UDim2.new(0.9, 0, 0, 40)
		ToggleButton.Position = UDim2.new(0.05, 0, 0, 20)
		ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		ToggleButton.Text = "Aimbot: OFF"
		ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		ToggleButton.Font = Enum.Font.Gotham
		ToggleButton.TextSize = 18
		ToggleButton.Parent = ContentFrame
		ToggleButton.MouseButton1Click:Connect(toggleAimbot)

		createSlider(ContentFrame, 70, 50, 500, aimbotRange, function(value)
			aimbotRange = value
		end)
	elseif tabName == "NoClip" then
		local ToggleButton = Instance.new("TextButton")
		ToggleButton.Name = "ToggleButton"
		ToggleButton.Size = UDim2.new(0.9, 0, 0, 40)
		ToggleButton.Position = UDim2.new(0.05, 0, 0, 20)
		ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		ToggleButton.Text = "NoClip: OFF"
		ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		ToggleButton.Font = Enum.Font.Gotham
		ToggleButton.TextSize = 18
		ToggleButton.Parent = ContentFrame
		ToggleButton.MouseButton1Click:Connect(toggleNoClip)
	elseif tabName == "Dupe" then
		local ToggleButton = Instance.new("TextButton")
		ToggleButton.Name = "ToggleButton"
		ToggleButton.Size = UDim2.new(0.9, 0, 0, 40)
		ToggleButton.Position = UDim2.new(0.05, 0, 0, 20)
		ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		ToggleButton.Text = "Dupe: OFF"
		ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		ToggleButton.Font = Enum.Font.Gotham
		ToggleButton.TextSize = 18
		ToggleButton.Parent = ContentFrame
		ToggleButton.MouseButton1Click:Connect(toggleDupe)
	end
end

-- Create content for tabs
for tabName, frame in pairs(ContentFrames) do
	createTabContent(tabName, frame)
end

-- Jump Detection for Mobile
UserInputService.JumpRequest:Connect(function()
	if flyEnabled then
		isJumping = true
		delay(0.1, function()
			isJumping = false
		end)
	end
end)

-- Updates
RunService.RenderStepped:Connect(function()
	updateFlight()
	updateAimbot()
	updateESP()
	updateNoClip()
	updateDupe()
end)

player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = newCharacter:WaitForChild("Humanoid")
	rootPart = newCharacter:WaitForChild("HumanoidRootPart")
	if speedEnabled then humanoid.WalkSpeed = walkSpeed end
	if flyEnabled then toggleFly() toggleFly() end
	if invisibleEnabled then 
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("MeshPart") then
				part.Transparency = 1
				part.LocalTransparencyModifier = 1
			end
			if part:IsA("Decal") then
				part.Transparency = 1
			end
			if part:IsA("Accessory") then
				local handle = part:FindFirstChild("Handle")
				if handle then
					handle.Transparency = 1
					handle.LocalTransparencyModifier = 1
				end
			end
		end
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end
	if godModeEnabled then 
		humanoid.MaxHealth = math.huge
		humanoid.Health = math.huge
		humanoid.HealthChanged:Connect(function(health)
			if godModeEnabled and health < math.huge then
				humanoid.Health = math.huge
			end
		end)
	end
	if noClipEnabled then toggleNoClip() end
	if dupeEnabled then 
		toggleDupe() -- Turn off and on to recreate clone
		toggleDupe()
	end
end)

game.Players.PlayerAdded:Connect(function(newPlayer)
	if espEnabled then
		newPlayer.CharacterAdded:Connect(function()
			createESP(newPlayer)
		end)
	end
end)

game.Players.PlayerRemoving:Connect(function(leavingPlayer)
	if espObjects[leavingPlayer] then
		if espObjects[leavingPlayer].billboard then espObjects[leavingPlayer].billboard:Destroy() end
		if espObjects[leavingPlayer].highlight then espObjects[leavingPlayer].highlight:Destroy() end
		espObjects[leavingPlayer] = nil
	end
end)

print("Script loaded successfully")
