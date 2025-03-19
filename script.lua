local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local UserInputService = game:GetService("UserInputService")

-- Hack States
local speedEnabled = false
local flyEnabled = false
local invisibleEnabled = false
local godModeEnabled = false
local flySpeed = 50
local walkSpeed = 32
local bodyVelocity, bodyGyro = nil, nil

-- Main UI Setup
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local URLLabel = Instance.new("TextLabel")
local TabFrame = Instance.new("Frame")
local TitleAccent = Instance.new("Frame")
local TabAccent = Instance.new("Frame")

ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Main Frame Properties
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

-- Title Bar
TitleBar.Parent = MainFrame
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

-- Title Accent Line
TitleAccent.Parent = TitleBar
TitleAccent.Size = UDim2.new(1, 0, 0, 2)
TitleAccent.Position = UDim2.new(0, 0, 1, -2)
TitleAccent.BackgroundColor3 = Color3.fromRGB(138, 43, 226)

-- Title
Title.Parent = TitleBar
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 5, 0, 0)
Title.Text = "ShadowT3ch | Beta | Universal | Delta"
Title.TextColor3 = Color3.fromRGB(200, 200, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

-- URL Label (optional, repurposed as version info)
URLLabel.Parent = TitleBar
URLLabel.Size = UDim2.new(0.3, -5, 1, 0)
URLLabel.Position = UDim2.new(0.7, 0, 0, 0)
URLLabel.Text = "Version: 1.0"
URLLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
URLLabel.Font = Enum.Font.Gotham
URLLabel.TextSize = 12
URLLabel.BackgroundTransparency = 1
URLLabel.TextXAlignment = Enum.TextXAlignment.Right

-- Tab Frame
TabFrame.Parent = MainFrame
TabFrame.Size = UDim2.new(1, 0, 0, 30)
TabFrame.Position = UDim2.new(0, 0, 0, 30)
TabFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)

-- Tab Accent Line
TabAccent.Parent = TabFrame
TabAccent.Size = UDim2.new(1, 0, 0, 2)
TabAccent.Position = UDim2.new(0, 0, 1, -2)
TabAccent.BackgroundColor3 = Color3.fromRGB(138, 43, 226)

-- Tabs Setup
local Tabs = {"Speed", "Fly", "Invis", "God"}
local ContentFrames = {}
for i, tabName in ipairs(Tabs) do
	local TabButton = Instance.new("TextButton")
	TabButton.Parent = TabFrame
	TabButton.Size = UDim2.new(0.25, -2, 1, 0) -- Adjusted for 4 tabs
	TabButton.Position = UDim2.new((i - 1) * 0.25, 0, 0, 0)
	TabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	TabButton.Text = tabName
	TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
	TabButton.Font = Enum.Font.Gotham
	TabButton.TextSize = 12

	-- Hover Effect
	TabButton.MouseEnter:Connect(function()
		TabButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
	end)
	TabButton.MouseLeave:Connect(function()
		if ContentFrames[tabName].Visible then
			TabButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
		else
			TabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		end
	end)

	-- Content Frames
	local ContentFrame = Instance.new("Frame")
	ContentFrame.Parent = MainFrame
	ContentFrame.Size = UDim2.new(1, 0, 1, -60)
	ContentFrame.Position = UDim2.new(0, 0, 0, 60)
	ContentFrame.BackgroundTransparency = 1
	ContentFrame.Visible = (i == 1)
	ContentFrames[tabName] = ContentFrame

	-- Tab Switching
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
end

-- Hack Functions
local function toggleSpeed()
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
		local camera = workspace.CurrentCamera
		local direction = Vector3.new()
		local camLook = camera.CFrame.LookVector
		local moveDir = humanoid.MoveDirection
		if moveDir.Magnitude > 0 then direction = direction + moveDir end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction + Vector3.new(0, -1, 0) end
		if direction.Magnitude > 0 then direction = direction.Unit * flySpeed end
		bodyVelocity.Velocity = direction
		bodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + camLook)
	end
end

local function toggleInvisible()
	invisibleEnabled = not invisibleEnabled
	local toggleButton = ContentFrames["Invis"]:FindFirstChild("ToggleButton")
	if invisibleEnabled then
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("Decal") then
				part.Transparency = 1
			end
			if part:IsA("Accessory") then
				local handle = part:FindFirstChild("Handle")
				if handle then handle.Transparency = 1 end
			end
		end
		toggleButton.Text = "Invis: ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	else
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("Decal") then
				part.Transparency = 0
			end
			if part:IsA("Accessory") then
				local handle = part:FindFirstChild("Handle")
				if handle then handle.Transparency = 0 end
			end
		end
		toggleButton.Text = "Invis: OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	end
end

local function toggleGodMode()
	godModeEnabled = not godModeEnabled
	local toggleButton = ContentFrames["God"]:FindFirstChild("ToggleButton")
	if godModeEnabled then
		humanoid.MaxHealth = math.huge
		humanoid.Health = math.huge
		toggleButton.Text = "God: ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	else
		humanoid.MaxHealth = 100
		humanoid.Health = 100
		toggleButton.Text = "God: OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	end
end

-- Slider Logic
local function createSlider(parent, posY, min, max, default, callback)
	local SliderFrame = Instance.new("Frame")
	SliderFrame.Size = UDim2.new(0.9, 0, 0, 20)
	SliderFrame.Position = UDim2.new(0.05, 0, 0, posY)
	SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	SliderFrame.Parent = parent

	local SliderKnob = Instance.new("Frame")
	SliderKnob.Size = UDim2.new(0, 10, 1, 0)
	SliderKnob.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
	SliderKnob.Parent = SliderFrame
	SliderKnob.Position = UDim2.new((default - min) / (max - min), 0, 0, 0)

	SliderFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
				end
			end)
		end
	end)
end

-- Add Content for Each Tab
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
		InfoLabel.Text = "Controls: WASD, Space (up), Shift (down)"
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
	end
end

-- Create content for tabs
for tabName, frame in pairs(ContentFrames) do
	createTabContent(tabName, frame)
end

-- Updates
game:GetService("RunService").RenderStepped:Connect(function()
	updateFlight()
	if godModeEnabled and humanoid.Health < math.huge then humanoid.Health = math.huge end
end)

player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
	if speedEnabled then toggleSpeed() toggleSpeed() end
	if flyEnabled then toggleFly() toggleFly() end
	if invisibleEnabled then toggleInvisible() toggleInvisible() end
	if godModeEnabled then toggleGodMode() toggleGodMode() end
end)
