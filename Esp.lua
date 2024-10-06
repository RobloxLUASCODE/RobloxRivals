local colourTable = {
    Green = Color3.fromRGB(0, 255, 0),
    Blue = Color3.fromRGB(0, 0, 255),
    Yellow = Color3.fromRGB(255, 255, 0),
    Orange = Color3.fromRGB(255, 165, 0),
    Purple = Color3.fromRGB(128, 0, 128)
}
local colourChosen = colourTable.Green -- Change to any color you prefer (not red)
_G.ESPToggle = true -- Variable for enabling/disabling ESP

-- Services and local player
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local function getCharacter(player)
    return Workspace:FindFirstChild(player.Name)
end

-- Add highlights, name tags, and tracers to players
local function addHighlightToCharacter(player, character)
    if player == LocalPlayer then return end  -- Skip local player
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart and not humanoidRootPart:FindFirstChild("Highlight") then
        local highlightClone = Instance.new("Highlight")  -- Create a new Highlight instance
        highlightClone.Name = "Highlight"
        highlightClone.Adornee = character
        highlightClone.Parent = humanoidRootPart
        highlightClone.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlightClone.FillColor = colourChosen -- Set fill color (no red)
        highlightClone.OutlineColor = Color3.fromRGB(255, 255, 255) -- White outline
        highlightClone.FillTransparency = 1 -- Set fill transparency to 1 (fully transparent)
        highlightClone.OutlineTransparency = 0 -- Ensure the outline is visible
        
        -- Create name tag
        local nameTag = Instance.new("BillboardGui")
        nameTag.Name = "NameTag"
        nameTag.Size = UDim2.new(0, 100, 0, 50)
        nameTag.StudsOffset = Vector3.new(0, 3, 0) -- Adjust height above the player
        nameTag.AlwaysOnTop = true
        nameTag.Parent = humanoidRootPart

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text
        nameLabel.BackgroundTransparency = 1 -- Make background transparent
        nameLabel.Font = Enum.Font.SourceSansBold -- Set font to bold
        nameLabel.TextSize = 14 -- Adjust text size as needed
        nameLabel.Parent = nameTag

        -- Create tracer
        local tracer = Instance.new("Part")
        tracer.Name = "Tracer"
        tracer.Size = Vector3.new(0.1, 0.1, 0.1) -- Thickness of the tracer
        tracer.Color = colourChosen
        tracer.Anchored = true
        tracer.CanCollide = false
        tracer.Parent = Workspace

        -- Update tracer's position every frame
        RunService.RenderStepped:Connect(function()
            if _G.ESPToggle and humanoidRootPart then
                local screenPosition = Workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
                tracer.Position = Vector3.new(screenPosition.X, game.Workspace.CurrentCamera.ViewportSize.Y, 0) -- Bottom of the screen
                tracer.Position = Vector3.new(screenPosition.X, screenPosition.Y, 0) -- Adjust to connect to the player
                tracer.CFrame = CFrame.new(tracer.Position, Vector3.new(screenPosition.X, 0, 0)) -- Look towards the bottom
            else
                tracer:Destroy()
            end
        end)
    end
end

-- Remove highlights, name tags, and tracers from player
local function removeHighlightFromCharacter(character)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local highlightInstance = humanoidRootPart:FindFirstChild("Highlight")
        if highlightInstance then
            highlightInstance:Destroy()
        end
        
        local nameTag = humanoidRootPart:FindFirstChild("NameTag")
        if nameTag then
            nameTag:Destroy()
        end

        local tracer = Workspace:FindFirstChild(humanoidRootPart.Name .. "Tracer")
        if tracer then
            tracer:Destroy()
        end
    end
end

-- Function to update highlights based on the value of _G.ESPToggle
local function updateHighlights()
    for _, player in pairs(Players:GetPlayers()) do
        local character = getCharacter(player)
        if character then
            if _G.ESPToggle then
                addHighlightToCharacter(player, character)
            else
                removeHighlightFromCharacter(character)
            end
        end
    end
end

-- Connect events through RenderStepped to loop
RunService.RenderStepped:Connect(function()
    updateHighlights()
end)

-- Add highlight and name tag to joining players
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if _G.ESPToggle then
            addHighlightToCharacter(player, character)
        end
    end)
end)

-- Remove highlights, name tags, and tracers from leaving players
Players.PlayerRemoving:Connect(function(playerRemoved)
    local character = playerRemoved.Character
    if character then
        removeHighlightFromCharacter(character)
    end
end)

-- Keybind to toggle ESP
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightBracket and not gameProcessed then -- Toggle ESP using the "]" key
        _G.ESPToggle = not _G.ESPToggle
    end
end)
