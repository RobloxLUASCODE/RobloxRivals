-- Wait for the player and character to load
repeat wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:findFirstChild("Head")

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character
local torso = character:WaitForChild("Head")
local flying = false
local noclip = false
local ctrl = {f = 0, b = 0, l = 0, r = 0} 
local speed = 250 -- Default speed

local gui = Instance.new("ScreenGui")
local mainFrame = Instance.new("Frame")
local flyNoclipButton = Instance.new("TextButton")
local speedTextBox = Instance.new("TextBox")

-- GUI properties
gui.Parent = player.PlayerGui
mainFrame.Size = UDim2.new(0, 200, 0, 125) -- Adjusted height to fit both button and text box
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -75) -- Centered vertically and horizontally
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui
mainFrame.Visible = false -- Start with the GUI hidden

-- Make GUI draggable
local dragging = false
local dragInput
local dragStart
local startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateInput(input)
    end
end)

-- Rounded edges for the main frame
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0.1, 0) -- Adjust the radius for rounding corners
frameCorner.Parent = mainFrame

-- Fly and No-Clip Button
flyNoclipButton.Size = UDim2.new(0, 180, 0, 40) -- Same size as speed text box
flyNoclipButton.Position = UDim2.new(0, 10, 0, 10)
flyNoclipButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White color
flyNoclipButton.TextColor3 = Color3.fromRGB(0, 0, 0) -- Black text
flyNoclipButton.Text = "Toggle Fly / No-Clip"
flyNoclipButton.Font = Enum.Font.SourceSansBold -- Less pixelated font
flyNoclipButton.TextSize = 20 -- Same size as text box
flyNoclipButton.Parent = mainFrame

-- Rounded edges for the button
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0.1, 0) -- Adjust the radius for rounding corners
buttonCorner.Parent = flyNoclipButton

-- Speed TextBox
speedTextBox.Size = UDim2.new(0, 180, 0, 40)
speedTextBox.Position = UDim2.new(0, 10, 0, 70) -- Positioned below the button
speedTextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White color
speedTextBox.TextColor3 = Color3.fromRGB(0, 0, 0) -- Black text
speedTextBox.Text = "Speed: 250" -- Default text
speedTextBox.Font = Enum.Font.SourceSansBold -- Less pixelated font
speedTextBox.TextSize = 20 -- Font size matches the button
speedTextBox.Parent = mainFrame

-- Rounded edges for the text box
local textBoxCorner = Instance.new("UICorner")
textBoxCorner.CornerRadius = UDim.new(0.1, 0) -- Adjust the radius for rounding corners
textBoxCorner.Parent = speedTextBox

-- Function to enable flying
function Fly()
    local bg = Instance.new("BodyGyro", torso)
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = torso.CFrame
    
    local bv = Instance.new("BodyVelocity", torso)
    bv.velocity = Vector3.new(0, 0.1, 0)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    
    repeat wait()
        character.Humanoid.PlatformStand = true
        
        -- Handle no-clip functionality
        if noclip then
            for _, v in pairs(character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        else
            for _, v in pairs(character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end

        -- Calculate the direction of movement
        local direction = (game.Workspace.CurrentCamera.CFrame.LookVector * (ctrl.f + ctrl.b)) +
                          ((game.Workspace.CurrentCamera.CFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 0.2, 0).p) - game.Workspace.CurrentCamera.CFrame.p)
        
        bv.Velocity = direction * speed
        bg.CFrame = game.Workspace.CurrentCamera.CFrame * CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50 * speed / 5000), 0, 0)
    until not flying
    
    -- Clean up flying
    ctrl = {f = 0, b = 0, l = 0, r = 0}
    bv.Velocity = Vector3.new(0, 0, 0) -- Stop moving when not flying
    bg:Destroy()
    bv:Destroy()
    character.Humanoid.PlatformStand = false

    -- Restore collisions when flying stops
    for _, v in pairs(character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = true
        end
    end
end

-- Button function
flyNoclipButton.MouseButton1Click:Connect(function()
    flying = not flying
    noclip = flying -- Enable no-clip when flying is activated
    
    if flying then
        Fly() -- Call the Fly function when activated
    else
        -- If flying is turned off, reset the character state
        character.Humanoid.PlatformStand = false
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = true
            end
        end
    end
end)

-- Speed input handling
speedTextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local inputSpeed = tonumber(speedTextBox.Text:match("%d+")) -- Extract the number from the text
        if inputSpeed then
            speed = inputSpeed -- Update the speed if valid
            speedTextBox.Text = "Speed: " .. speed -- Update the text box
        else
            speedTextBox.Text = "Invalid Speed" -- Handle invalid input
        end
    end
end)

-- Key controls for movement
mouse.KeyDown:Connect(function(key)
    if key:lower() == "w" then
        ctrl.f = 1
    elseif key:lower() == "s" then
        ctrl.b = -1
    elseif key:lower() == "a" then
        ctrl.l = -1
    elseif key:lower() == "d" then
        ctrl.r = 1
    elseif key:lower() == "[" then
        mainFrame.Visible = not mainFrame.Visible -- Toggle GUI visibility
    end
end)

mouse.KeyUp:Connect(function(key)
    if key:lower() == "w" then
        ctrl.f = 0
    elseif key:lower() == "s" then
        ctrl.b = 0
    elseif key:lower() == "a" then
        ctrl.l = 0
    elseif key:lower() == "d" then
        ctrl.r = 0
    end
end)
