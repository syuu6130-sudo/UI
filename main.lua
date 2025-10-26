-- // KRNL Compatible Rayfield-like UI
-- // by GPT-5
if not game:IsLoaded() then game.Loaded:Wait() end

local CoreGui = game:GetService("CoreGui")

-- 既に存在してたら削除（再実行対策）
local old = CoreGui:FindFirstChild("KRNL_UI")
if old then old:Destroy() end

-- ScreenGui
local UI = Instance.new("ScreenGui")
UI.Name = "KRNL_UI"
UI.Parent = CoreGui
UI.ResetOnSpawn = false

-- メインウィンドウ
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 260)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = UI

-- タイトルバー
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.Text = "⚙️ KRNL Rayfield風 UI"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

-- 閉じるボタン
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 35, 0, 35)
Close.Position = UDim2.new(1, -35, 0, 0)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 80, 80)
Close.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Close.BorderSizePixel = 0
Close.Font = Enum.Font.SourceSansBold
Close.TextSize = 20
Close.Parent = MainFrame
Close.MouseButton1Click:Connect(function()
	UI:Destroy()
end)

-- セクション作成関数
local function createSection(name, order)
	local section = Instance.new("Frame")
	section.Size = UDim2.new(1, -20, 0, 60)
	section.Position = UDim2.new(0, 10, 0, 40 + (order * 70))
	section.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	section.BorderSizePixel = 0
	section.Parent = MainFrame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 25)
	title.Text = name
	title.Font = Enum.Font.SourceSansBold
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.BackgroundTransparency = 1
	title.TextSize = 16
	title.Parent = section

	return section
end

-- トグルボタン作成
local function createToggle(section, text, callback)
	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(0, 150, 0, 30)
	toggle.Position = UDim2.new(0, 10, 0, 25)
	toggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggle.Font = Enum.Font.SourceSans
	toggle.TextSize = 16
	toggle.Text = text .. ": OFF"
	toggle.Parent = section

	local enabled = false
	toggle.MouseButton1Click:Connect(function()
		enabled = not enabled
		toggle.Text = text .. ": " .. (enabled and "ON" or "OFF")
		toggle.BackgroundColor3 = enabled and Color3.fromRGB(80, 140, 80) or Color3.fromRGB(70, 70, 70)
		callback(enabled)
	end)
end

-- ========= 機能一覧 =========

-- Section 1: 無限ジャンプ
local s1 = createSection("🦘 無限ジャンプ", 0)
createToggle(s1, "Toggle", function(state)
	if state then
		_G.infjump = true
		game:GetService("UserInputService").JumpRequest:Connect(function()
			if _G.infjump and game.Players.LocalPlayer.Character then
				local h = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
			end
		end)
	else
		_G.infjump = false
	end
end)

-- Section 2: フライ
local s2 = createSection("🕊️ フライモード", 1)
createToggle(s2, "Toggle", function(state)
	local player = game.Players.LocalPlayer
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	if state then
		_G.fly = true
		local bv = Instance.new("BodyVelocity")
		local bg = Instance.new("BodyGyro")
		bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		bv.Parent = hrp
		bg.Parent = hrp

		task.spawn(function()
			while _G.fly do
				task.wait()
				local cam = workspace.CurrentCamera
				local dir = Vector3.zero
				local uis = game:GetService("UserInputService")
				if uis:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
				if uis:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
				if uis:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
				if uis:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
				if uis:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
				if uis:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
				bv.Velocity = dir * 60
				bg.CFrame = cam.CFrame
			end
			bv:Destroy()
			bg:Destroy()
		end)
	else
		_G.fly = false
	end
end)

-- Section 3: 自動回復
local s3 = createSection("❤️ 自動回復", 2)
createToggle(s3, "Toggle", function(state)
	if state then
		_G.autoheal = true
		task.spawn(function()
			while _G.autoheal do
				task.wait(1)
				local p = game.Players.LocalPlayer
				local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
				if h and h.Health < h.MaxHealth then
					h.Health = math.min(h.Health + 5, h.MaxHealth)
				end
			end
		end)
	else
		_G.autoheal = false
	end
end)
