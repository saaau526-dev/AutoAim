game:GetService("StarterGui"):SetCore("SendNotification", {
	Title = "Loaded",
	Text = "M = Open Menu | Q = Aim | G = Change Mode"
})

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
	BindKey = Enum.KeyCode.Q,
	MenuKey = Enum.KeyCode.M,
	ModeKey = Enum.KeyCode.G
}

local selectedPlayer = nil
local isClicking = false
local refreshing = false

local CurrentMode = "Selected"

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TargetSelector"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 430)
MainFrame.Position = UDim2.new(1, -270, 0.5, -215)
MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(60,60,60)
Stroke.Thickness = 1
Stroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,40)
Title.BackgroundTransparency = 1
Title.Text = "PLAYER LIST"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = MainFrame

local SelectedLabel = Instance.new("TextLabel")
SelectedLabel.Size = UDim2.new(1,-10,0,25)
SelectedLabel.Position = UDim2.new(0,5,0,40)
SelectedLabel.BackgroundTransparency = 1
SelectedLabel.Text = "Selected: None"
SelectedLabel.TextColor3 = Color3.fromRGB(180,180,180)
SelectedLabel.Font = Enum.Font.Gotham
SelectedLabel.TextSize = 14
SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
SelectedLabel.Parent = MainFrame

local ModeButton = Instance.new("TextButton")
ModeButton.Size = UDim2.new(1,-10,0,30)
ModeButton.Position = UDim2.new(0,5,0,70)
ModeButton.BackgroundColor3 = Color3.fromRGB(35,35,35)
ModeButton.BorderSizePixel = 0
ModeButton.Text = "Mode: Selected Player"
ModeButton.TextColor3 = Color3.fromRGB(255,255,255)
ModeButton.Font = Enum.Font.GothamBold
ModeButton.TextSize = 14
ModeButton.Parent = MainFrame

local ModeCorner = Instance.new("UICorner")
ModeCorner.CornerRadius = UDim.new(0,8)
ModeCorner.Parent = ModeButton

local ModeStroke = Instance.new("UIStroke")
ModeStroke.Color = Color3.fromRGB(55,55,55)
ModeStroke.Parent = ModeButton

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1,-10,1,-140)
ScrollingFrame.Position = UDim2.new(0,5,0,110)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.CanvasSize = UDim2.new(0,0,0,0)
ScrollingFrame.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0,6)
ListLayout.Parent = ScrollingFrame

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0,5)
Padding.PaddingLeft = UDim.new(0,2)
Padding.PaddingRight = UDim.new(0,2)
Padding.Parent = ScrollingFrame

ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	ScrollingFrame.CanvasSize =
		UDim2.new(0,0,0,ListLayout.AbsoluteContentSize.Y + 10)
end)

local CreditLabel = Instance.new("TextLabel")
CreditLabel.Size = UDim2.new(1,0,0,20)
CreditLabel.Position = UDim2.new(0,0,1,-22)
CreditLabel.BackgroundTransparency = 1
CreditLabel.Text = "Made by tamanegi3121"
CreditLabel.TextColor3 = Color3.fromRGB(120,120,120)
CreditLabel.Font = Enum.Font.Gotham
CreditLabel.TextSize = 12
CreditLabel.Parent = MainFrame

local function updateMode()

	if CurrentMode == "Selected" then
		ModeButton.Text = "Mode: Selected Player"
	else
		ModeButton.Text = "Mode: Closest Player"
	end

	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "Mode Changed",
		Text = CurrentMode
	})

end

local function switchMode()

	if CurrentMode == "Selected" then
		CurrentMode = "Closest"
	else
		CurrentMode = "Selected"
	end

	updateMode()

end

local function getClosestPlayer()

	local closestPlayer = nil
	local shortestDistance = math.huge

	if not LocalPlayer.Character
		or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		return nil
	end

	for _, player in pairs(Players:GetPlayers()) do

		if player ~= LocalPlayer
			and player.Character
			and player.Character:FindFirstChild("HumanoidRootPart") then

			local distance =
				(player.Character.HumanoidRootPart.Position
				- LocalPlayer.Character.HumanoidRootPart.Position).Magnitude

			if distance < shortestDistance then
				shortestDistance = distance
				closestPlayer = player
			end
		end
	end

	return closestPlayer
end

local function refreshPlayerList()

	if refreshing then
		return
	end

	refreshing = true

	for _, child in pairs(ScrollingFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local playerList = {}
	local added = {}

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and not added[player] then
			added[player] = true
			table.insert(playerList, player)
		end
	end

	table.sort(playerList, function(a, b)
		return a.Name:lower() < b.Name:lower()
	end)

	for _, player in ipairs(playerList) do

		local Holder = Instance.new("Frame")
		Holder.Name = player.Name
		Holder.Size = UDim2.new(1,-4,0,50)
		Holder.BackgroundColor3 = Color3.fromRGB(35,35,35)
		Holder.BorderSizePixel = 0
		Holder.Parent = ScrollingFrame

		local HolderCorner = Instance.new("UICorner")
		HolderCorner.CornerRadius = UDim.new(0,8)
		HolderCorner.Parent = Holder

		local HolderStroke = Instance.new("UIStroke")
		HolderStroke.Color = Color3.fromRGB(55,55,55)
		HolderStroke.Parent = Holder

		local ClickButton = Instance.new("TextButton")
		ClickButton.BackgroundTransparency = 1
		ClickButton.Size = UDim2.new(1,0,1,0)
		ClickButton.Text = ""
		ClickButton.Parent = Holder

		local Icon = Instance.new("ImageLabel")
		Icon.Size = UDim2.new(0,36,0,36)
		Icon.Position = UDim2.new(0,7,0.5,-18)
		Icon.BackgroundTransparency = 1
		Icon.Parent = Holder

		local IconCorner = Instance.new("UICorner")
		IconCorner.CornerRadius = UDim.new(1,0)
		IconCorner.Parent = Icon

		local thumbnail = Players:GetUserThumbnailAsync(
			player.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size100x100
		)

		Icon.Image = thumbnail

		local DisplayName = Instance.new("TextLabel")
		DisplayName.Size = UDim2.new(1,-60,0,20)
		DisplayName.Position = UDim2.new(0,50,0,5)
		DisplayName.BackgroundTransparency = 1
		DisplayName.Text = player.DisplayName
		DisplayName.TextColor3 = Color3.fromRGB(255,255,255)
		DisplayName.Font = Enum.Font.GothamBold
		DisplayName.TextSize = 15
		DisplayName.TextXAlignment = Enum.TextXAlignment.Left
		DisplayName.Parent = Holder

		local Username = Instance.new("TextLabel")
		Username.Size = UDim2.new(1,-60,0,15)
		Username.Position = UDim2.new(0,50,0,25)
		Username.BackgroundTransparency = 1
		Username.Text = "@"..player.Name
		Username.TextColor3 = Color3.fromRGB(170,170,170)
		Username.Font = Enum.Font.Gotham
		Username.TextSize = 11
		Username.TextXAlignment = Enum.TextXAlignment.Left
		Username.Parent = Holder

		Holder.MouseEnter:Connect(function()
			if selectedPlayer ~= player then
				Holder.BackgroundColor3 = Color3.fromRGB(50,50,50)
			end
		end)

		Holder.MouseLeave:Connect(function()
			if selectedPlayer ~= player then
				Holder.BackgroundColor3 = Color3.fromRGB(35,35,35)
			end
		end)

		ClickButton.MouseButton1Click:Connect(function()

			selectedPlayer = player
			SelectedLabel.Text = "Selected: "..player.DisplayName

			for _, obj in pairs(ScrollingFrame:GetChildren()) do
				if obj:IsA("Frame") then
					obj.BackgroundColor3 = Color3.fromRGB(35,35,35)
				end
			end

			Holder.BackgroundColor3 = Color3.fromRGB(70,70,70)

			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "Target Selected",
				Text = player.DisplayName
			})

		end)
	end

	refreshing = false
end

ModeButton.MouseButton1Click:Connect(function()
	switchMode()
end)

local function aimAt(target)

	if target
		and target.Character
		and target.Character:FindFirstChild("HumanoidRootPart") then

		local targetPosition =
			target.Character.HumanoidRootPart.Position

		Camera.CFrame =
			CFrame.new(Camera.CFrame.Position, targetPosition)

		if not isClicking then
			isClicking = true
			mouse1click()
			task.wait()
			isClicking = false
		end
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)

	if gameProcessed then
		return
	end

	if input.KeyCode == Settings.MenuKey then

		MainFrame.Visible = not MainFrame.Visible

		if MainFrame.Visible then
			refreshPlayerList()
		end
	end

	if input.KeyCode == Settings.ModeKey then
		switchMode()
	end

	if input.KeyCode == Settings.BindKey then

		local target = nil

		if CurrentMode == "Selected" then
			target = selectedPlayer
		elseif CurrentMode == "Closest" then
			target = getClosestPlayer()
		end

		if target then
			aimAt(target)
		else
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "No Target",
				Text = "No valid target found"
			})
		end
	end
end)

Players.PlayerAdded:Connect(function()
	task.wait(1)
	refreshPlayerList()
end)

Players.PlayerRemoving:Connect(function()
	task.wait()
	refreshPlayerList()
end)