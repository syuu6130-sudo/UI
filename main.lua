-- カスタムUIシステム - LocalScript (StarterPlayer > StarterPlayerScripts に配置)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- UIシステムのメインクラス
local UISystem = {}
UISystem.__index = UISystem

function UISystem.new()
	local self = setmetatable({}, UISystem)
	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "CustomUISystem"
	self.screenGui.ResetOnSpawn = false
	self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.screenGui.Parent = playerGui
	
	self.notifications = {}
	self.isMenuOpen = false
	
	self:CreateMainUI()
	self:CreateInventoryUI()
	self:CreateSettingsUI()
	self:CreateNotificationSystem()
	self:SetupControls()
	
	return self
end

-- メインHUD作成
function UISystem:CreateMainUI()
	-- HUDコンテナ
	local hudFrame = Instance.new("Frame")
	hudFrame.Name = "HUD"
	hudFrame.Size = UDim2.new(1, 0, 1, 0)
	hudFrame.BackgroundTransparency = 1
	hudFrame.Parent = self.screenGui
	
	-- ヘルスバー
	local healthBarBg = Instance.new("Frame")
	healthBarBg.Name = "HealthBarBg"
	healthBarBg.Size = UDim2.new(0, 200, 0, 25)
	healthBarBg.Position = UDim2.new(0.5, -100, 0.9, 0)
	healthBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	healthBarBg.BorderSizePixel = 0
	healthBarBg.Parent = hudFrame
	
	local healthBarCorner = Instance.new("UICorner")
	healthBarCorner.CornerRadius = UDim.new(0, 6)
	healthBarCorner.Parent = healthBarBg
	
	local healthBar = Instance.new("Frame")
	healthBar.Name = "HealthBar"
	healthBar.Size = UDim2.new(1, -4, 1, -4)
	healthBar.Position = UDim2.new(0, 2, 0, 2)
	healthBar.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
	healthBar.BorderSizePixel = 0
	healthBar.Parent = healthBarBg
	
	local healthBarInnerCorner = Instance.new("UICorner")
	healthBarInnerCorner.CornerRadius = UDim.new(0, 4)
	healthBarInnerCorner.Parent = healthBar
	
	local healthText = Instance.new("TextLabel")
	healthText.Name = "HealthText"
	healthText.Size = UDim2.new(1, 0, 1, 0)
	healthText.BackgroundTransparency = 1
	healthText.Text = "100 / 100"
	healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
	healthText.TextSize = 14
	healthText.Font = Enum.Font.GothamBold
	healthText.Parent = healthBarBg
	
	-- プレイヤー情報パネル
	local infoPanel = Instance.new("Frame")
	infoPanel.Name = "InfoPanel"
	infoPanel.Size = UDim2.new(0, 180, 0, 80)
	infoPanel.Position = UDim2.new(0, 20, 0, 20)
	infoPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	infoPanel.BorderSizePixel = 0
	infoPanel.Parent = hudFrame
	
	local infoPanelCorner = Instance.new("UICorner")
	infoPanelCorner.CornerRadius = UDim.new(0, 8)
	infoPanelCorner.Parent = infoPanel
	
	local playerNameLabel = Instance.new("TextLabel")
	playerNameLabel.Name = "PlayerName"
	playerNameLabel.Size = UDim2.new(1, -20, 0, 25)
	playerNameLabel.Position = UDim2.new(0, 10, 0, 10)
	playerNameLabel.BackgroundTransparency = 1
	playerNameLabel.Text = player.Name
	playerNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	playerNameLabel.TextSize = 16
	playerNameLabel.Font = Enum.Font.GothamBold
	playerNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	playerNameLabel.Parent = infoPanel
	
	local coinsLabel = Instance.new("TextLabel")
	coinsLabel.Name = "CoinsLabel"
	coinsLabel.Size = UDim2.new(1, -20, 0, 20)
	coinsLabel.Position = UDim2.new(0, 10, 0, 40)
	coinsLabel.BackgroundTransparency = 1
	coinsLabel.Text = "💰 コイン: 0"
	coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	coinsLabel.TextSize = 14
	coinsLabel.Font = Enum.Font.Gotham
	coinsLabel.TextXAlignment = Enum.TextXAlignment.Left
	coinsLabel.Parent = infoPanel
	
	-- ヘルス更新
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		self:UpdateHealth(humanoid)
		humanoid.HealthChanged:Connect(function()
			self:UpdateHealth(humanoid)
		end)
	end
	
	player.CharacterAdded:Connect(function(character)
		local hum = character:WaitForChild("Humanoid")
		self:UpdateHealth(hum)
		hum.HealthChanged:Connect(function()
			self:UpdateHealth(hum)
		end)
	end)
	
	self.healthBar = healthBar
	self.healthText = healthText
	self.coinsLabel = coinsLabel
end

-- ヘルス更新関数
function UISystem:UpdateHealth(humanoid)
	if not self.healthBar or not self.healthText then return end
	
	local healthPercent = humanoid.Health / humanoid.MaxHealth
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local goal = {Size = UDim2.new(healthPercent, -4, 1, -4)}
	local tween = TweenService:Create(self.healthBar, tweenInfo, goal)
	tween:Play()
	
	self.healthText.Text = math.floor(humanoid.Health) .. " / " .. humanoid.MaxHealth
	
	-- 色変更
	if healthPercent > 0.5 then
		self.healthBar.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
	elseif healthPercent > 0.25 then
		self.healthBar.BackgroundColor3 = Color3.fromRGB(255, 152, 0)
	else
		self.healthBar.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
	end
end

-- インベントリUI作成
function UISystem:CreateInventoryUI()
	local inventoryFrame = Instance.new("Frame")
	inventoryFrame.Name = "Inventory"
	inventoryFrame.Size = UDim2.new(0, 400, 0, 350)
	inventoryFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
	inventoryFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	inventoryFrame.BorderSizePixel = 0
	inventoryFrame.Visible = false
	inventoryFrame.Parent = self.screenGui
	
	local invCorner = Instance.new("UICorner")
	invCorner.CornerRadius = UDim.new(0, 10)
	invCorner.Parent = inventoryFrame
	
	-- タイトル
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	title.BorderSizePixel = 0
	title.Text = "📦 インベントリ"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 18
	title.Font = Enum.Font.GothamBold
	title.Parent = inventoryFrame
	
	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 10)
	titleCorner.Parent = title
	
	-- 閉じるボタン
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -35, 0, 5)
	closeBtn.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
	closeBtn.Text = "✕"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.TextSize = 16
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.BorderSizePixel = 0
	closeBtn.Parent = title
	
	local closeBtnCorner = Instance.new("UICorner")
	closeBtnCorner.CornerRadius = UDim.new(0, 6)
	closeBtnCorner.Parent = closeBtn
	
	closeBtn.MouseButton1Click:Connect(function()
		self:ToggleInventory()
	end)
	
	-- アイテムグリッド
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, -20, 1, -60)
	scrollFrame.Position = UDim2.new(0, 10, 0, 50)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.Parent = inventoryFrame
	
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 80, 0, 80)
	gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = scrollFrame
	
	-- サンプルアイテム
	for i = 1, 12 do
		local itemFrame = Instance.new("Frame")
		itemFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		itemFrame.BorderSizePixel = 0
		itemFrame.Parent = scrollFrame
		
		local itemCorner = Instance.new("UICorner")
		itemCorner.CornerRadius = UDim.new(0, 8)
		itemCorner.Parent = itemFrame
		
		local itemLabel = Instance.new("TextLabel")
		itemLabel.Size = UDim2.new(1, 0, 1, 0)
		itemLabel.BackgroundTransparency = 1
		itemLabel.Text = "🎁\nアイテム " .. i
		itemLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		itemLabel.TextSize = 12
		itemLabel.Font = Enum.Font.Gotham
		itemLabel.Parent = itemFrame
	end
	
	self.inventoryFrame = inventoryFrame
end

-- 設定UI作成
function UISystem:CreateSettingsUI()
	local settingsFrame = Instance.new("Frame")
	settingsFrame.Name = "Settings"
	settingsFrame.Size = UDim2.new(0, 350, 0, 300)
	settingsFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
	settingsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	settingsFrame.BorderSizePixel = 0
	settingsFrame.Visible = false
	settingsFrame.Parent = self.screenGui
	
	local settingsCorner = Instance.new("UICorner")
	settingsCorner.CornerRadius = UDim.new(0, 10)
	settingsCorner.Parent = settingsFrame
	
	-- タイトル
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	title.BorderSizePixel = 0
	title.Text = "⚙️ 設定"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 18
	title.Font = Enum.Font.GothamBold
	title.Parent = settingsFrame
	
	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 10)
	titleCorner.Parent = title
	
	-- 閉じるボタン
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -35, 0, 5)
	closeBtn.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
	closeBtn.Text = "✕"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.TextSize = 16
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.BorderSizePixel = 0
	closeBtn.Parent = title
	
	local closeBtnCorner = Instance.new("UICorner")
	closeBtnCorner.CornerRadius = UDim.new(0, 6)
	closeBtnCorner.Parent = closeBtn
	
	closeBtn.MouseButton1Click:Connect(function()
		self:ToggleSettings()
	end)
	
	-- 設定オプション
	local optionsFrame = Instance.new("Frame")
	optionsFrame.Size = UDim2.new(1, -20, 1, -60)
	optionsFrame.Position = UDim2.new(0, 10, 0, 50)
	optionsFrame.BackgroundTransparency = 1
	optionsFrame.Parent = settingsFrame
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 10)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = optionsFrame
	
	-- サンプル設定
	local settings = {
		{name = "🔊 サウンド", default = true},
		{name = "🎵 音楽", default = true},
		{name = "💬 チャット", default = true},
		{name = "📱 通知", default = true}
	}
	
	for _, setting in ipairs(settings) do
		local optionFrame = Instance.new("Frame")
		optionFrame.Size = UDim2.new(1, 0, 0, 40)
		optionFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		optionFrame.BorderSizePixel = 0
		optionFrame.Parent = optionsFrame
		
		local optionCorner = Instance.new("UICorner")
		optionCorner.CornerRadius = UDim.new(0, 6)
		optionCorner.Parent = optionFrame
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -60, 1, 0)
		label.Position = UDim2.new(0, 10, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = setting.name
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextSize = 14
		label.Font = Enum.Font.Gotham
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = optionFrame
		
		local toggle = Instance.new("TextButton")
		toggle.Size = UDim2.new(0, 50, 0, 25)
		toggle.Position = UDim2.new(1, -60, 0.5, -12.5)
		toggle.BackgroundColor3 = setting.default and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(120, 120, 120)
		toggle.Text = setting.default and "ON" or "OFF"
		toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
		toggle.TextSize = 12
		toggle.Font = Enum.Font.GothamBold
		toggle.BorderSizePixel = 0
		toggle.Parent = optionFrame
		
		local toggleCorner = Instance.new("UICorner")
		toggleCorner.CornerRadius = UDim.new(0, 4)
		toggleCorner.Parent = toggle
		
		toggle.MouseButton1Click:Connect(function()
			local isOn = toggle.Text == "ON"
			toggle.Text = isOn and "OFF" or "ON"
			toggle.BackgroundColor3 = isOn and Color3.fromRGB(120, 120, 120) or Color3.fromRGB(76, 175, 80)
		end)
	end
	
	self.settingsFrame = settingsFrame
end

-- 通知システム作成
function UISystem:CreateNotificationSystem()
	self.notificationContainer = Instance.new("Frame")
	self.notificationContainer.Name = "Notifications"
	self.notificationContainer.Size = UDim2.new(0, 300, 1, -20)
	self.notificationContainer.Position = UDim2.new(1, -310, 0, 10)
	self.notificationContainer.BackgroundTransparency = 1
	self.notificationContainer.Parent = self.screenGui
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 10)
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = self.notificationContainer
end

-- 通知表示
function UISystem:ShowNotification(message, type)
	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(1, 0, 0, 60)
	notif.BackgroundColor3 = type == "success" and Color3.fromRGB(76, 175, 80) or 
	                         type == "error" and Color3.fromRGB(244, 67, 54) or 
	                         Color3.fromRGB(33, 150, 243)
	notif.BorderSizePixel = 0
	notif.Parent = self.notificationContainer
	
	local notifCorner = Instance.new("UICorner")
	notifCorner.CornerRadius = UDim.new(0, 8)
	notifCorner.Parent = notif
	
	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, -20, 1, 0)
	text.Position = UDim2.new(0, 10, 0, 0)
	text.BackgroundTransparency = 1
	text.Text = message
	text.TextColor3 = Color3.fromRGB(255, 255, 255)
	text.TextSize = 14
	text.Font = Enum.Font.Gotham
	text.TextWrapped = true
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.Parent = notif
	
	-- アニメーション
	notif.Position = UDim2.new(1, 20, 0, 0)
	local tweenIn = TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(0, 0, 0, 0)})
	tweenIn:Play()
	
	-- 3秒後に削除
	task.wait(3)
	local tweenOut = TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(1, 20, 0, 0)})
	tweenOut:Play()
	tweenOut.Completed:Wait()
	notif:Destroy()
end

-- UIトグル
function UISystem:ToggleInventory()
	self.inventoryFrame.Visible = not self.inventoryFrame.Visible
	if self.inventoryFrame.Visible then
		self.settingsFrame.Visible = false
	end
end

function UISystem:ToggleSettings()
	self.settingsFrame.Visible = not self.settingsFrame.Visible
	if self.settingsFrame.Visible then
		self.inventoryFrame.Visible = false
	end
end

-- キーバインド設定
function UISystem:SetupControls()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.KeyCode == Enum.KeyCode.I then
			self:ToggleInventory()
		elseif input.KeyCode == Enum.KeyCode.Escape then
			self:ToggleSettings()
		end
	end)
end

-- システム初期化
local uiSystem = UISystem.new()

-- テスト通知
task.wait(1)
uiSystem:ShowNotification("✨ UIシステムが起動しました！", "success")

task.wait(2)
uiSystem:ShowNotification("ℹ️ [I]キーでインベントリを開く\n[ESC]キーで設定を開く", "info")

-- コイン更新のサンプル（実際のゲームロジックに合わせて変更）
task.spawn(function()
	local coins = 0
	while task.wait(5) do
		coins = coins + 10
		uiSystem.coinsLabel.Text = "💰 コイン: " .. coins
		uiSystem:ShowNotification("💰 +10コインを獲得！", "success")
	end
end)
