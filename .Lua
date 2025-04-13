--// Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

--// Number to Word Converter (supports 1 to 500)
local function numberToWords(n)
	local ones = { "ZERO", "ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE" }
	local teens = { "TEN", "ELEVEN", "TWELVE", "THIRTEEN", "FOURTEEN", "FIFTEEN", "SIXTEEN", "SEVENTEEN", "EIGHTEEN", "NINETEEN" }
	local tens = { [2]="TWENTY", [3]="THIRTY", [4]="FORTY", [5]="FIFTY", [6]="SIXTY", [7]="SEVENTY", [8]="EIGHTY", [9]="NINETY" }

	if n == 0 then return "ZERO" end
	if n <= 9 then return ones[n + 1] end
	if n <= 19 then return teens[n - 9] end
	if n <= 99 then
		local ten = math.floor(n / 10)
		local one = n % 10
		return tens[ten] .. (one > 0 and "-" .. ones[one + 1] or "")
	end
	if n <= 999 then
		local hundred = math.floor(n / 100)
		local rest = n % 100
		if rest == 0 then return ones[hundred + 1] .. " HUNDRED" end
		return ones[hundred + 1] .. " HUNDRED " .. numberToWords(rest)
	end
	if n == 500 then
		return "FIVE HUNDRED"
	end
	return tostring(n)
end

--// Message Table (up to 500)
local messages = {}
for i = 1, 500 do
	table.insert(messages, numberToWords(i) .. "!")
end

--// Control Variables
local running = false
local stopSignal = false
local uiVisible = true
local currentIndex = 1
local maxJumps = 100

--// UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SSADJumpScriptGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.CoreGui

-- Background
local background = Instance.new("ImageLabel")
background.Size = UDim2.new(1, 0, 1, 0)
background.Position = UDim2.new(0, 0, 0, 0)
background.BackgroundTransparency = 1
background.Image = "rbxassetid://123456789" -- Replace with your own image ID
background.Parent = screenGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 660, 0, 360)
frame.Position = UDim2.new(0.5, -330, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = "SSAD Jump Script"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 22
titleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 200, 0, 50)
toggleButton.Position = UDim2.new(0.5, -100, 0, 50)
toggleButton.Text = "Start"
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 24
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Parent = frame

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -20, 0, 30)
infoText.Position = UDim2.new(0, 10, 0, 110)
infoText.Text = "V = Stop | T = Toggle UI"
infoText.TextColor3 = Color3.new(1, 1, 1)
infoText.Font = Enum.Font.SourceSans
infoText.TextSize = 20
infoText.BackgroundTransparency = 1
infoText.Parent = frame

--// Slider UI
local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(0, 400, 0, 30)
sliderLabel.Position = UDim2.new(0.5, -200, 0, 160)
sliderLabel.Text = "Jump Count: 100"
sliderLabel.Font = Enum.Font.SourceSans
sliderLabel.TextSize = 20
sliderLabel.BackgroundTransparency = 1
sliderLabel.TextColor3 = Color3.new(1, 1, 1)
sliderLabel.Parent = frame

local slider = Instance.new("Frame")
slider.Size = UDim2.new(0, 400, 0, 6)
slider.Position = UDim2.new(0.5, -200, 0, 195)
slider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
slider.Parent = frame

local fill = Instance.new("Frame")
fill.Size = UDim2.new(0, 200, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
fill.Parent = slider

local draggable = Instance.new("TextButton")
draggable.Size = UDim2.new(0, 10, 2, 0)
draggable.Position = UDim2.new(0.5, -5, 0, -6)
draggable.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
draggable.Text = ""
draggable.AutoButtonColor = false
draggable.Parent = slider

-- Drag logic
local dragging = false
local function updateSlider(inputX)
	local relX = math.clamp((inputX - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
	draggable.Position = UDim2.new(relX, -5, 0, -6)
	fill.Size = UDim2.new(relX, 0, 1, 0)
	maxJumps = math.floor(relX * 500)
	sliderLabel.Text = "Jump Count: " .. maxJumps
end

draggable.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		updateSlider(input.Position.X)
	end
end)

--// Green Circle Button for Minimizing UI (draggable)
local circleButton = Instance.new("TextButton")
circleButton.Size = UDim2.new(0, 50, 0, 50)
circleButton.Position = UDim2.new(0.95, -55, 0, 10)
circleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
circleButton.Text = ""
circleButton.AutoButtonColor = false
circleButton.Parent = screenGui

-- Make the circle draggable
local draggingCircle = false
local function onCircleDrag(input)
	if draggingCircle then
		local delta = input.Position - circleButton.Position
		circleButton.Position = UDim2.new(0, delta.X, 0, delta.Y)
	end
end

circleButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingCircle = true
	end
end)

circleButton.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingCircle = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingCircle then
		onCircleDrag(input)
	end
end)

--// Function to show chat bubble
local function say(msg)
	TextChatService:DisplayBubble(character, msg)
end

--// Main Jump Loop
local function doJumps()
	for i = currentIndex, math.min(#messages, maxJumps) do
		if not running or stopSignal then
			currentIndex = i
			break
		end

		repeat task.wait(0.05)
		until humanoid:GetState() == Enum.HumanoidStateType.Running or humanoid:GetState() == Enum.HumanoidStateType.Landed

		say(messages[i])
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

		repeat task.wait(0.05)
		until humanoid:GetState() ~= Enum.HumanoidStateType.Freefall

		task.wait(0.1)
	end

	running = false
	toggleButton.Text = "Start"
end

--// Button Control
toggleButton.MouseButton1Click:
