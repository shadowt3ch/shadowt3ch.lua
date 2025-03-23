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
local flySpeed = 40 -- Changed from 50 to 40 for slower flight
local walkSpeed = 32
local aimbotRange = 100
local bodyVelocity, bodyGyro = nil, nil
local espObjects = {}
local dupeItems = {}
local isJumping = false
local logs = {}
local MAX_LOGS = 100
local isMinimized = false

-- Main UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
print("ScreenGui initialized")

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(50, 50, 70)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = MainFrame

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 40))
}
Gradient.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
TitleBar.BorderSizePixel = 0

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 15)
TitleCorner.Parent = TitleBar

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 50))
}
TitleGradient.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Parent = TitleBar
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "ShadowT3ch | Beta"
Title.TextColor3 = Color3.fromRGB(100, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Parent = TitleBar
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -70, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
MinimizeButton.BackgroundTransparency = 0.2
MinimizeButton.Text = "–"
MinimizeButton.TextColor3 = Color3.fromRGB(100, 200, 255)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 18
MinimizeButton.BorderSizePixel = 0

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 8)
MinimizeCorner.Parent = MinimizeButton

local CloseButton = Instance.new("TextButton")
CloseButton.Parent = TitleBar
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
CloseButton.BackgroundTransparency = 0.2
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(100, 200, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.BorderSizePixel = 0

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

local MinimizedFrame = Instance.new("Frame")
MinimizedFrame.Parent = ScreenGui
MinimizedFrame.Size = UDim2.new(0, 50, 0, 50)
MinimizedFrame.Position = UDim2.new(0.5, -25, 0.5, -25)
MinimizedFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
MinimizedFrame.BackgroundTransparency = 0.2
MinimizedFrame.Visible = false
MinimizedFrame.Active = true
MinimizedFrame.Draggable = true

local MinimizedCorner = Instance.new("UICorner")
MinimizedCorner.CornerRadius = UDim.new(1, 0)
MinimizedCorner.Parent = MinimizedFrame
MinimizedFrame.BorderSizePixel = 0

local MinimizedGradient = Instance.new("UIGradient")
MinimizedGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 50))
}
MinimizedGradient.Parent = MinimizedFrame

local MinimizedButton = Instance.new("TextButton")
MinimizedButton.Parent = MinimizedFrame
MinimizedButton.Size = UDim2.new(1, 0, 1, 0)
MinimizedButton.BackgroundTransparency = 1
MinimizedButton.Text = "S"
MinimizedButton.TextColor3 = Color3.fromRGB(100, 200, 255)
MinimizedButton.Font = Enum.Font.GothamBold
MinimizedButton.TextSize = 24

local TabFrame = Instance.new("Frame")
TabFrame.Parent = MainFrame
TabFrame.Size = UDim2.new(1, 0, 0, 40)
TabFrame.Position = UDim2.new(0, 0, 0, 40)
TabFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
TabFrame.BorderSizePixel = 0

local TabGradient = Instance.new("UIGradient")
TabGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 50))
}
TabGradient.Parent = TabFrame

-- Tabs Setup
local Tabs = {"Home", "Player", "Settings", "Misc", "Logs"}
local ContentFrames = {}
for i, tabName in ipairs(Tabs) do
    local TabButton = Instance.new("TextButton")
    TabButton.Parent = TabFrame
    TabButton.Size = UDim2.new(1/#Tabs, -2, 1, -4)
    TabButton.Position = UDim2.new((i - 1) * (1/#Tabs), 1, 0, 2)
    TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    TabButton.BackgroundTransparency = 0.2
    TabButton.Text = tabName
    TabButton.TextColor3 = Color3.fromRGB(100, 200, 255)
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 16
    TabButton.BorderSizePixel = 0
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabButton

    TabButton.MouseEnter:Connect(function()
        TabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    end)
    TabButton.MouseLeave:Connect(function()
        if ContentFrames[tabName] and ContentFrames[tabName].Visible then
            TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        else
            TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        end
    end)

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Parent = MainFrame
    ContentFrame.Size = UDim2.new(1, -20, 1, -90)
    ContentFrame.Position = UDim2.new(0, 10, 0, 90)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    ContentFrame.BackgroundTransparency = 0.2
    ContentFrame.Visible = (i == 1)
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 10)
    ContentCorner.Parent = ContentFrame
    
    local ContentGradient = Instance.new("UIGradient")
    ContentGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 50))
    }
    ContentGradient.Parent = ContentFrame
    
    ContentFrames[tabName] = ContentFrame

    TabButton.MouseButton1Click:Connect(function()
        for _, frame in pairs(ContentFrames) do
            frame.Visible = false
        end
        for _, btn in pairs(TabFrame:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
            end
        end
        ContentFrame.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    end)
    print("Tab '" .. tabName .. "' initialized")
end

-- Log Function
local function addLog(message, isError)
    local timestamp = os.date("%X")
    local logEntry = {
        text = string.format("[%s] %s", timestamp, message),
        isError = isError or false,
        time = os.time()
    }
    table.insert(logs, logEntry)
    if #logs > MAX_LOGS then
        table.remove(logs, 1)
    end
    
    if ContentFrames["Logs"] and ContentFrames["Logs"].Visible then
        local LogFrame = ContentFrames["Logs"]:FindFirstChild("LogFrame")
        if LogFrame then
            local yOffset = (#logs - 1) * 20
            local LogLabel = Instance.new("TextLabel")
            LogLabel.Name = "Log" .. #logs
            LogLabel.Size = UDim2.new(1, -10, 0, 20)
            LogLabel.Position = UDim2.new(0, 5, 0, yOffset)
            LogLabel.BackgroundTransparency = 1
            LogLabel.Text = logEntry.text
            LogLabel.TextColor3 = logEntry.isError and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(150, 200, 255)
            LogLabel.Font = Enum.Font.SourceSansBold
            LogLabel.TextSize = 14
            LogLabel.TextXAlignment = Enum.TextXAlignment.Left
            LogLabel.LayoutOrder = #logs
            LogLabel.Parent = LogFrame
            LogFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 20)
        end
    end
    return logEntry
end

-- Override print and warn
local oldPrint = print
print = function(...)
    local message = table.concat({...}, " ")
    addLog(message, false)
    oldPrint(...)
end

local oldWarn = warn
warn = function(...)
    local message = table.concat({...}, " ")
    addLog(message, true)
    oldWarn(...)
end

-- Minimize/Expand Functionality
CloseButton.MouseButton1Click:Connect(function()
    isMinimized = true
    MainFrame.Visible = false
    MinimizedFrame.Position = MainFrame.Position
    MinimizedFrame.Visible = true
    print("Menu minimized")
end)

MinimizedButton.MouseButton1Click:Connect(function()
    isMinimized = false
    MainFrame.Position = MinimizedFrame.Position
    MainFrame.Visible = true
    MinimizedFrame.Visible = false
    print("Menu expanded")
end)

-- Hack Functions
local function toggleSpeed()
    if not humanoid then warn("Speed: Humanoid not found"); return end
    speedEnabled = not speedEnabled
    local toggleButton = ContentFrames["Player"]:FindFirstChild("SpeedToggle")
    if speedEnabled then
        humanoid.WalkSpeed = walkSpeed
        toggleButton.Text = "✦ Speed: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        print("Speed hack enabled - Speed set to " .. walkSpeed)
    else
        humanoid.WalkSpeed = 16
        toggleButton.Text = "✦ Speed: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        print("Speed hack disabled - Speed reset to 16")
    end
end

local function toggleFly()
    if not rootPart or not humanoid then warn("Fly: Character parts not found"); return end
    flyEnabled = not flyEnabled
    local toggleButton = ContentFrames["Home"]:FindFirstChild("FlyToggle")
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
        toggleButton.Text = "✈ Fly: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        print("Fly hack enabled - Fly speed set to " .. flySpeed)
    else
        humanoid.WalkSpeed = 16
        if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        toggleButton.Text = "✈ Fly: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        print("Fly hack disabled")
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
    local toggleButton = ContentFrames["Player"]:FindFirstChild("InvisToggle")
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
        toggleButton.Text = "👻 Invis: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        print("Invisibility hack enabled")
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
        toggleButton.Text = "👻 Invis: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        print("Invisibility hack disabled")
    end
end

local function toggleGodMode()
    if not humanoid then warn("God: Humanoid not found"); return end
    godModeEnabled = not godModeEnabled
    local toggleButton = ContentFrames["Home"]:FindFirstChild("GodToggle")
    
    if godModeEnabled then
        -- Set infinite health
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        
        -- Add a ForceField to prevent damage
        local forceField = Instance.new("ForceField")
        forceField.Name = "GodModeForceField"
        forceField.Visible = false
        forceField.Parent = character
        
        -- Disable death state
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        
        -- Monitor health changes
        if humanoid.HealthChangedConnection then
            humanoid.HealthChangedConnection:Disconnect()
        end
        humanoid.HealthChangedConnection = humanoid.HealthChanged:Connect(function(health)
            if godModeEnabled and health < math.huge then
                humanoid.Health = math.huge
            end
        end)
        
        toggleButton.Text = "⚡ God: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        print("God mode enabled - Invincibility activated")
    else
        -- Reset health
        humanoid.MaxHealth = 100
        humanoid.Health = 100
        
        -- Remove ForceField
        local forceField = character:FindFirstChild("GodModeForceField")
        if forceField then
            forceField:Destroy()
        end
        
        -- Re-enable death state
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        
        -- Disconnect health monitoring
        if humanoid.HealthChangedConnection then
            humanoid.HealthChangedConnection:Disconnect()
            humanoid.HealthChangedConnection = nil
        end
        
        toggleButton.Text = "⚡ God: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        print("God mode disabled - Health reset to 100")
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
    nameLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Parent = billboard

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "0 studs"
    distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextSize = 12
    distanceLabel.Parent = billboard

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.Adornee = targetPlayer.Character
    highlight.FillTransparency = 1
    highlight.OutlineColor = Color3.fromRGB(100, 200, 255)
    highlight.Parent = targetPlayer.Character

    esp.billboard = billboard
    esp.distanceLabel = distanceLabel
    esp.highlight = highlight
    espObjects[targetPlayer] = esp
end

local function toggleESP()
    espEnabled = not espEnabled
    local toggleButton = ContentFrames["Home"]:FindFirstChild("ESPToggle")
    if espEnabled then
        for _, targetPlayer in pairs(game.Players:GetPlayers()) do
            createESP(targetPlayer)
        end
        toggleButton.Text = "👁 ESP: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        print("ESP hack enabled")
    else
        for _, esp in pairs(espObjects) do
            if esp.billboard then esp.billboard:Destroy() end
            if esp.highlight then esp.highlight:Destroy() end
        end
        espObjects = {}
        toggleButton.Text = "👁 ESP: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        print("ESP hack disabled")
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
    local toggleButton = ContentFrames["Misc"]:FindFirstChild("AimbotToggle")
    if aimbotEnabled then
        toggleButton.Text = "🎯 Aimbot: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        print("Aimbot hack enabled - Range set to " .. aimbotRange)
    else
        toggleButton.Text = "🎯 Aimbot: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        print("Aimbot hack disabled")
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
    local toggleButton = ContentFrames["Home"]:FindFirstChild("NoClipToggle")
    if noClipEnabled then
        toggleButton.Text = "🚪 NoClip: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        print("NoClip hack enabled")
    else
        toggleButton.Text = "🚪 NoClip: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        print("NoClip hack disabled")
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
    local toggleButton = ContentFrames["Player"]:FindFirstChild("DupeToggle")
    if dupeEnabled then
        print("Attempting to duplicate equipped tool...")
        local success, err = pcall(function()
            local equippedTool = character:FindFirstChildOfClass("Tool")
            if not equippedTool then
                warn("Dupe: No tool equipped")
                return
            end
            
            local dupeTool = equippedTool:Clone()
            if not dupeTool then
                warn("Dupe: Tool cloning failed")
                return
            end
            
            dupeTool.Parent = workspace
            dupeTool.Name = equippedTool.Name .. "_Dupe_" .. tostring(math.random(1000, 9999))
            local toolHandle = dupeTool:FindFirstChild("Handle")
            if toolHandle then
                toolHandle.CFrame = rootPart.CFrame * CFrame.new(5, 0, 5)
                toolHandle.Anchored = false
                toolHandle.CanCollide = true
            else
                warn("Dupe: No Handle in cloned tool")
                dupeTool:Destroy()
                return
            end
            
            table.insert(dupeItems, dupeTool)
            
            task.spawn(function()
                local originalParent = dupeTool.Parent
                dupeTool.Parent = nil
                wait(0.1)
                dupeTool.Parent = originalParent
            end)
            
            print("Duplicated tool '" .. equippedTool.Name .. "' dropped at " .. tostring(toolHandle.Position))
        end)
        
        if not success then
            warn("Dupe error: " .. err)
            dupeEnabled = false
            toggleButton.Text = "📦 Dupe: OFF"
            toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            return
        end
        
        toggleButton.Text = "📦 Dupe: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        print("Dupe hack enabled - Tool duplicated")
    else
        toggleButton.Text = "📦 Dupe: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        print("Dupe hack disabled - Existing duped items remain")
    end
end

local function updateDupe()
    -- No continuous update needed
end

local function createSlider(parent, posY, labelText, min, max, default, callback)
    local SliderContainer = Instance.new("Frame")
    SliderContainer.Size = UDim2.new(0.9, 0, 0, 50)
    SliderContainer.Position = UDim2.new(0.05, 0, 0, posY)
    SliderContainer.BackgroundTransparency = 1
    SliderContainer.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = Color3.fromRGB(150, 200, 255)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 14
    Label.Parent = SliderContainer

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 40, 0, 20)
    ValueLabel.Position = UDim2.new(1, -40, 0, 25)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    ValueLabel.Font = Enum.Font.Gotham
    ValueLabel.TextSize = 12
    ValueLabel.Parent = SliderContainer

    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 10)
    SliderFrame.Position = UDim2.new(0, 0, 0, 25)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    SliderFrame.BackgroundTransparency = 0.2
    SliderFrame.Parent = SliderContainer
    SliderFrame.ClipsDescendants = true
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 5)
    SliderCorner.Parent = SliderFrame

    local SliderKnob = Instance.new("Frame")
    SliderKnob.Size = UDim2.new(0, 15, 1, 0)
    SliderKnob.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    SliderKnob.Parent = SliderFrame
    SliderKnob.Position = UDim2.new((default - min) / (max - min), 0, 0, 0)
    
    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(0, 5)
    KnobCorner.Parent = SliderKnob

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
                    ValueLabel.Text = tostring(math.floor(value))
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
    if tabName == "Home" then
        local GodToggle = Instance.new("TextButton")
        GodToggle.Name = "GodToggle"
        GodToggle.Size = UDim2.new(0.45, 0, 0, 50)
        GodToggle.Position = UDim2.new(0.05, 0, 0, 20)
        GodToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        GodToggle.BackgroundTransparency = 0.2
        GodToggle.Text = "⚡ God: OFF"
        GodToggle.TextColor3 = Color3.fromRGB(150, 200, 255)
        GodToggle.Font = Enum.Font.GothamBold
        GodToggle.TextSize = 16
        GodToggle.Parent = ContentFrame
        GodToggle.MouseButton1Click:Connect(toggleGodMode)
        local GodCorner = Instance.new("UICorner")
        GodCorner.CornerRadius = UDim.new(0, 10)
        GodCorner.Parent = GodToggle

        local FlyToggle = Instance.new("TextButton")
        FlyToggle.Name = "FlyToggle"
        FlyToggle.Size = UDim2.new(0.45, 0, 0, 50)
        FlyToggle.Position = UDim2.new(0.5, 0, 0, 20)
        FlyToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        FlyToggle.BackgroundTransparency = 0.2
        FlyToggle.Text = "✈ Fly: OFF"
        FlyToggle.TextColor3 = Color3.fromRGB(150, 200, 255)
        FlyToggle.Font = Enum.Font.GothamBold
        FlyToggle.TextSize = 16
        FlyToggle.Parent = ContentFrame
        FlyToggle.MouseButton1Click:Connect(toggleFly)
        local FlyCorner = Instance.new("UICorner")
        FlyCorner.CornerRadius = UDim.new(0, 10)
        FlyCorner.Parent = FlyToggle

        local ESPToggle = Instance.new("TextButton")
        ESPToggle.Name = "ESPToggle"
        ESPToggle.Size = UDim2.new(0.45, 0, 0, 50)
        ESPToggle.Position = UDim2.new(0.05, 0, 0, 80)
        ESPToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        ESPToggle.BackgroundTransparency = 0.2
        ESPToggle.Text = "👁 ESP: OFF"
        ESPToggle.TextColor3 = Color3.fromRGB(150, 200, 255)
        ESPToggle.Font = Enum.Font.GothamBold
        ESPToggle.TextSize = 16
        ESPToggle.Parent = ContentFrame
        ESPToggle.MouseButton1Click:Connect(toggleESP)
        local ESPCorner = Instance.new("UICorner")
        ESPCorner.CornerRadius = UDim.new(0, 10)
        ESPCorner.Parent = ESPToggle

        local NoClipToggle = Instance.new("TextButton")
        NoClipToggle.Name = "NoClipToggle"
        NoClipToggle.Size = UDim2.new(0.45, 0, 0, 50)
        NoClipToggle.Position = UDim2.new(0.5, 0, 0, 80)
        NoClipToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        NoClipToggle.BackgroundTransparency = 0.2
        NoClipToggle.Text = "🚪 NoClip: OFF"
        NoClipToggle.TextColor3 = Color3.fromRGB(150, 200, 255)
        NoClipToggle.Font = Enum.Font.GothamBold
        NoClipToggle.TextSize = 16
        NoClipToggle.Parent = ContentFrame
        NoClipToggle.MouseButton1Click:Connect(toggleNoClip)
        local NoClipCorner = Instance.new("UICorner")
        NoClipCorner.CornerRadius = UDim.new(0, 10)
        NoClipCorner.Parent = NoClipToggle
    elseif tabName == "Player" then
        local SpeedToggle = Instance.new("TextButton")
        SpeedToggle.Name = "SpeedToggle"
        SpeedToggle.Size = UDim2.new(0.45, 0, 0, 50)
        SpeedToggle.Position = UDim2.new(0.05, 0, 0, 20)
        SpeedToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        SpeedToggle.BackgroundTransparency = 0.2
        SpeedToggle.Text = "✦ Speed: OFF"
        SpeedToggle.TextColor3 = Color3.fromRGB(150, 200, 255)
        SpeedToggle.Font = Enum.Font.GothamBold
        SpeedToggle.TextSize = 16
        SpeedToggle.Parent = ContentFrame
        SpeedToggle.MouseButton1Click:Connect(toggleSpeed)
        local SpeedCorner = Instance.new("UICorner")
        SpeedCorner.CornerRadius = UDim.new(0, 10)
        SpeedCorner.Parent = SpeedToggle

        local InvisToggle = Instance.new("TextButton")
        InvisToggle.Name = "InvisToggle"
        InvisToggle.Size = UDim2.new(0.45, 0, 0, 50)
        InvisToggle.Position = UDim2.new(0.05, 0, 0, 80)
        InvisToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        InvisToggle.BackgroundTransparency = 0.2
        InvisToggle.Text = "👻 Invis: OFF"
        InvisToggle.TextColor3 = Color3.fromRGB(150, 200, 255)
        InvisToggle.Font = Enum.Font.GothamBold
        InvisToggle.TextSize = 16
        InvisToggle.Parent = ContentFrame
        InvisToggle.MouseButton1Click:Connect(toggleInvisible)
        local InvisCorner = Instance.new("UICorner")
        InvisCorner.CornerRadius = UDim.new(0, 10)
        InvisCorner.Parent = InvisToggle

        local TeleportFrame = Instance.new("Frame")
        TeleportFrame.Size = UDim2.new(0.45, 0, 0, 50)
        TeleportFrame.Position = UDim2.new(0.5, 0, 0, 20)
        TeleportFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        TeleportFrame.BackgroundTransparency = 0.2
        TeleportFrame.Parent = ContentFrame
        local TeleportCorner = Instance.new("UICorner")
        TeleportCorner.CornerRadius = UDim.new(0, 10)
        TeleportCorner.Parent = TeleportFrame

        local TeleportBox = Instance.new("TextBox")
        TeleportBox.Name = "TeleportBox"
        TeleportBox.Size = UDim2.new(0.65, 0, 0, 30)
        TeleportBox.Position = UDim2.new(0.05, 0, 0.15, 0)
        TeleportBox.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        TeleportBox.BackgroundTransparency = 0.2
        TeleportBox.TextColor3 = Color3.fromRGB(150, 200, 255)
        TeleportBox.Font = Enum.Font.Gotham
        TeleportBox.TextSize = 14
        TeleportBox.PlaceholderText = "Username"
        TeleportBox.PlaceholderColor3 = Color3.fromRGB(100, 150, 200)
        TeleportBox.Parent = TeleportFrame
        local TeleportBoxCorner = Instance.new("UICorner")
        TeleportBoxCorner.CornerRadius = UDim.new(0, 8)
        TeleportBoxCorner.Parent = TeleportBox

        local TeleportButton = Instance.new("TextButton")
        TeleportButton.Name = "TeleportButton"
        TeleportButton.Size = UDim2.new(0.25, 0, 0, 30)
        TeleportButton.Position = UDim2.new(0.7, 5, 0.15, 0)
        TeleportButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        TeleportButton.BackgroundTransparency = 0.2
        TeleportButton.Text = "TP"
        TeleportButton.TextColor3 = Color3.fromRGB(150, 200, 255)
        TeleportButton.Font = Enum.Font.GothamBold
        TeleportButton.TextSize = 14
        TeleportButton.Parent = TeleportFrame
        TeleportButton.MouseButton1Click:Connect(function()
            if TeleportBox.Text ~= "" then
                teleportToPlayer(TeleportBox.Text)
            else
                warn("Teleport: Please enter a username.")
            end
        end)
        local TeleportButtonCorner = Instance.new("UICorner")
        TeleportButtonCorner.CornerRadius = UDim.new(0, 8)
        TeleportButtonCorner.Parent = TeleportButton

        TeleportBox.FocusLost:Connect(function(enterPressed)
            if enterPressed and TeleportBox.Text ~= "" then
                teleportToPlayer(TeleportBox.Text)
            end
        end)

        local DupeToggle = Instance.new("TextButton")
        DupeToggle.Name = "DupeToggle"
        DupeToggle.Size = UDim2.new(0.45, 0, 0, 50)
        DupeToggle.Position = UDim2.new(0.5, 0, 0, 80)
        DupeToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        DupeToggle.BackgroundTransparency = 0.2
        DupeToggle.Text = "📦 Dupe: OFF"
        DupeToggle.TextColor3 = Color3.fromRGB(150, 200, 255)
        DupeToggle.Font = Enum.Font.GothamBold
        DupeToggle.TextSize = 16
        DupeToggle.Parent = ContentFrame
        DupeToggle.MouseButton1Click:Connect(toggleDupe)
        local DupeCorner = Instance.new("UICorner")
        DupeCorner.CornerRadius = UDim.new(0, 10)
        DupeCorner.Parent = DupeToggle
    elseif tabName == "Settings" then
        createSlider(ContentFrame, 20, "Walk Speed", 16, 100, walkSpeed, function(value)
            walkSpeed = value
            if speedEnabled then humanoid.WalkSpeed = walkSpeed end
        end)
        createSlider(ContentFrame, 80, "Fly Speed", 10, 125, flySpeed, function(value)
            flySpeed = value
        end)
        createSlider(ContentFrame, 140, "Aimbot Range", 50, 500, aimbotRange, function(value)
            aimbotRange = value
        end)
    elseif tabName == "Misc" then
        local AimbotToggle = Instance.new("TextButton")
        AimbotToggle.Name = "AimbotToggle"
        AimbotToggle.Size = UDim2.new(0.45, 0, 0, 50)
        AimbotToggle.Position = UDim2.new(0.275, 0, 0, 20)
        AimbotToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        AimbotToggle.BackgroundTransparency = 0.2
        AimbotToggle.Text = "🎯 Aimbot: OFF"
        AimbotToggle.TextColor3 = Color3.fromRGB(150, 200, 255)
        AimbotToggle.Font = Enum.Font.GothamBold
        AimbotToggle.TextSize = 16
        AimbotToggle.Parent = ContentFrame
        AimbotToggle.MouseButton1Click:Connect(toggleAimbot)
        local AimbotCorner = Instance.new("UICorner")
        AimbotCorner.CornerRadius = UDim.new(0, 10)
        AimbotCorner.Parent = AimbotToggle
    elseif tabName == "Logs" then
        local LogHeader = Instance.new("TextLabel")
        LogHeader.Size = UDim2.new(1, 0, 0, 30)
        LogHeader.Position = UDim2.new(0, 0, 0, 0)
        LogHeader.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        LogHeader.BackgroundTransparency = 0.2
        LogHeader.Text = "Logs"
        LogHeader.TextColor3 = Color3.fromRGB(150, 200, 255)
        LogHeader.Font = Enum.Font.GothamBold
        LogHeader.TextSize = 16
        LogHeader.Parent = ContentFrame
        local LogHeaderCorner = Instance.new("UICorner")
        LogHeaderCorner.CornerRadius = UDim.new(0, 8)
        LogHeaderCorner.Parent = LogHeader

        local LogFrame = Instance.new("ScrollingFrame")
        LogFrame.Name = "LogFrame"
        LogFrame.Size = UDim2.new(0.95, 0, 0, 250)
        LogFrame.Position = UDim2.new(0.025, 0, 0, 40)
        LogFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
        LogFrame.BackgroundTransparency = 0.2
        LogFrame.BorderSizePixel = 0
        LogFrame.ScrollBarThickness = 6
        LogFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 200)
        LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        LogFrame.Parent = ContentFrame
        
        local LogCorner = Instance.new("UICorner")
        LogCorner.CornerRadius = UDim.new(0, 8)
        LogCorner.Parent = LogFrame

        local LogList = Instance.new("UIListLayout")
        LogList.SortOrder = Enum.SortOrder.LayoutOrder
        LogList.Parent = LogFrame

        ContentFrame:GetPropertyChangedSignal("Visible"):Connect(function()
            if ContentFrame.Visible then
                for _, child in pairs(LogFrame:GetChildren()) do
                    if child:IsA("TextLabel") then
                        child:Destroy()
                    end
                end
                
                local yOffset = 0
                for i, log in ipairs(logs) do
                    local LogLabel = Instance.new("TextLabel")
                    LogLabel.Name = "Log" .. i
                    LogLabel.Size = UDim2.new(1, -10, 0, 20)
                    LogLabel.Position = UDim2.new(0, 5, 0, yOffset)
                    LogLabel.BackgroundTransparency = 1
                    LogLabel.Text = log.text
                    LogLabel.TextColor3 = log.isError and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(150, 200, 255)
                    LogLabel.Font = Enum.Font.SourceSansBold
                    LogLabel.TextSize = 14
                    LogLabel.TextXAlignment = Enum.TextXAlignment.Left
                    LogLabel.LayoutOrder = i
                    LogLabel.Parent = LogFrame
                    yOffset = yOffset + 20
                end
                LogFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
            end
        end)
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
        -- Reapply God Mode on character respawn
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        local forceField = Instance.new("ForceField")
        forceField.Name = "GodModeForceField"
        forceField.Visible = false
        forceField.Parent = character
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        if humanoid.HealthChangedConnection then
            humanoid.HealthChangedConnection:Disconnect()
        end
        humanoid.HealthChangedConnection = humanoid.HealthChanged:Connect(function(health)
            if godModeEnabled and health < math.huge then
                humanoid.Health = math.huge
            end
        end)
    end
    if noClipEnabled then toggleNoClip() end
    if dupeEnabled then 
        toggleDupe()
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
