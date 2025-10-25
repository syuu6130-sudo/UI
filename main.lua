-- AI搭載 高度カスタムUIシステム - Rayfield風 Part 1/4
-- LocalScript (StarterPlayer > StarterPlayerScripts に配置)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ========================
-- AI機能モジュール (12個以上搭載)
-- ========================

local AIModules = {}

-- 1. AI自動体力回復システム
AIModules.AutoHeal = {
    enabled = false,
    threshold = 50,
    healAmount = 5,
    interval = 1,
    
    start = function(self)
        self.enabled = true
        spawn(function()
            while self.enabled do
                wait(self.interval)
                local char = player.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health < self.threshold and hum.Health > 0 then
                        hum.Health = math.min(hum.Health + self.healAmount, hum.MaxHealth)
                    end
                end
            end
        end)
    end,
    
    stop = function(self)
        self.enabled = false
    end
}

-- 2. AI敵検出システム
AIModules.EnemyDetector = {
    enabled = false,
    range = 100,
    detectedEnemies = {},
    
    start = function(self)
        self.enabled = true
        spawn(function()
            while self.enabled do
                wait(0.5)
                self.detectedEnemies = {}
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local pos = char.HumanoidRootPart.Position
                    for _, otherPlayer in pairs(Players:GetPlayers()) do
                        if otherPlayer ~= player and otherPlayer.Character then
                            local otherChar = otherPlayer.Character
                            if otherChar:FindFirstChild("HumanoidRootPart") then
                                local distance = (pos - otherChar.HumanoidRootPart.Position).Magnitude
                                if distance <= self.range then
                                    table.insert(self.detectedEnemies, {
                                        player = otherPlayer,
                                        distance = math.floor(distance)
                                    })
                                end
                            end
                        end
                    end
                end
            end
        end)
    end,
    
    stop = function(self)
        self.enabled = false
        self.detectedEnemies = {}
    end
}

-- 3. AI自動ジャンプシステム
AIModules.AutoJump = {
    enabled = false,
    interval = 3,
    
    start = function(self)
        self.enabled = true
        spawn(function()
            while self.enabled do
                wait(self.interval)
                local char = player.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
        end)
    end,
    
    stop = function(self)
        self.enabled = false
    end
}

-- 4. AIスピードブーストシステム
AIModules.SpeedBoost = {
    enabled = false,
    multiplier = 1.5,
    originalSpeed = 16,
    
    start = function(self)
        self.enabled = true
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                self.originalSpeed = hum.WalkSpeed
                hum.WalkSpeed = self.originalSpeed * self.multiplier
            end
        end
    end,
    
    stop = function(self)
        self.enabled = false
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = self.originalSpeed
            end
        end
    end
}

-- 5. AI無限ジャンプシステム
AIModules.InfiniteJump = {
    enabled = false,
    connection = nil,
    
    start = function(self)
        self.enabled = true
        self.connection = UserInputService.JumpRequest:Connect(function()
            if self.enabled then
                local char = player.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
        end)
    end,
    
    stop = function(self)
        self.enabled = false
        if self.connection then
            self.connection:Disconnect()
            self.connection = nil
        end
    end
}

-- 6. AI視界強化システム
AIModules.VisionEnhancer = {
    enabled = false,
    originalFog = 0,
    originalBrightness = 1,
    
    start = function(self)
        self.enabled = true
        self.originalFog = Lighting.FogEnd
        self.originalBrightness = Lighting.Brightness
        Lighting.FogEnd = 100000
        Lighting.Brightness = 2
    end,
    
    stop = function(self)
        self.enabled = false
        Lighting.FogEnd = self.originalFog
        Lighting.Brightness = self.originalBrightness
    end
}

-- Part 1 終了
-- 次に Part 2 を要求してください
-- AI搭載 高度カスタムUIシステム Part 2/4
-- Part 1 の続きです

-- 7. AI自動収集システム
AIModules.AutoCollect = {
    enabled = false,
    range = 50,
    
    start = function(self)
        self.enabled = true
        spawn(function()
            while self.enabled do
                wait(0.5)
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local pos = char.HumanoidRootPart.Position
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("Part") and (obj.Name == "Coin" or obj.Name == "Gem" or obj.Name:find("Coin")) then
                            if obj.CanCollide then
                                local distance = (pos - obj.Position).Magnitude
                                if distance <= self.range then
                                    obj.CFrame = char.HumanoidRootPart.CFrame
                                end
                            end
                        end
                    end
                end
            end
        end)
    end,
    
    stop = function(self)
        self.enabled = false
    end
}

-- 8. AIフライシステム
AIModules.Fly = {
    enabled = false,
    speed = 50,
    connection = nil,
    bodyVelocity = nil,
    bodyGyro = nil,
    
    start = function(self)
        self.enabled = true
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            
            self.bodyVelocity = Instance.new("BodyVelocity")
            self.bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            self.bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            self.bodyVelocity.Parent = root
            
            self.bodyGyro = Instance.new("BodyGyro")
            self.bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            self.bodyGyro.P = 9e4
            self.bodyGyro.Parent = root
            
            self.connection = RunService.RenderStepped:Connect(function()
                if self.enabled then
                    local camera = workspace.CurrentCamera
                    local moveDir = Vector3.new(0, 0, 0)
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        moveDir = moveDir + camera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        moveDir = moveDir - camera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        moveDir = moveDir - camera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        moveDir = moveDir + camera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        moveDir = moveDir + Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        moveDir = moveDir - Vector3.new(0, 1, 0)
                    end
                    
                    if self.bodyVelocity then
                        self.bodyVelocity.Velocity = moveDir * self.speed
                    end
                    if self.bodyGyro then
                        self.bodyGyro.CFrame = camera.CFrame
                    end
                end
            end)
        end
    end,
    
    stop = function(self)
        self.enabled = false
        if self.connection then
            self.connection:Disconnect()
            self.connection = nil
        end
        if self.bodyVelocity then
            self.bodyVelocity:Destroy()
            self.bodyVelocity = nil
        end
        if self.bodyGyro then
            self.bodyGyro:Destroy()
            self.bodyGyro = nil
        end
    end
}

-- 9. AI自動回避システム
AIModules.AutoDodge = {
    enabled = false,
    dodgeDistance = 10,
    
    start = function(self)
        self.enabled = true
        spawn(function()
            while self.enabled do
                wait(0.1)
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local root = char.HumanoidRootPart
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("Part") and (obj.Name:lower():find("danger") or obj.Name:lower():find("trap") or obj.Name:lower():find("lava")) then
                            local distance = (root.Position - obj.Position).Magnitude
                            if distance < self.dodgeDistance and hum then
                                local direction = (root.Position - obj.Position).Unit
                                hum:Move(direction)
                            end
                        end
                    end
                end
            end
        end)
    end,
    
    stop = function(self)
        self.enabled = false
    end
}

-- 10. AI自動照準システム
AIModules.AutoAim = {
    enabled = false,
    
    start = function(self)
        self.enabled = true
        spawn(function()
            while self.enabled do
                wait(0.1)
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local nearestEnemy = nil
                    local nearestDistance = math.huge
                    
                    for _, otherPlayer in pairs(Players:GetPlayers()) do
                        if otherPlayer ~= player and otherPlayer.Character then
                            local otherChar = otherPlayer.Character
                            if otherChar:FindFirstChild("HumanoidRootPart") then
                                local otherHum = otherChar:FindFirstChildOfClass("Humanoid")
                                if otherHum and otherHum.Health > 0 then
                                    local distance = (char.HumanoidRootPart.Position - otherChar.HumanoidRootPart.Position).Magnitude
                                    if distance < nearestDistance then
                                        nearestDistance = distance
                                        nearestEnemy = otherChar
                                    end
                                end
                            end
                        end
                    end
                    
                    if nearestEnemy and workspace.CurrentCamera then
                        workspace.CurrentCamera.CFrame = CFrame.new(
                            workspace.CurrentCamera.CFrame.Position,
                            nearestEnemy.HumanoidRootPart.Position
                        )
                    end
                end
            end
        end)
    end,
    
    stop = function(self)
        self.enabled = false
    end
}

-- 11. AIリソース監視システム
AIModules.ResourceMonitor = {
    enabled = false,
    stats = {fps = 0, ping = 0, memory = 0},
    
    start = function(self)
        self.enabled = true
        spawn(function()
            while self.enabled do
                wait(1)
                local lastTime = tick()
                RunService.RenderStepped:Wait()
                self.stats.fps = math.floor(1 / (tick() - lastTime))
                self.stats.ping = math.floor(player:GetNetworkPing() * 1000)
                self.stats.memory = math.floor(collectgarbage("count") / 1024)
            end
        end)
    end,
    
    stop = function(self)
        self.enabled = false
    end
}

-- 12. AIウォールハックシステム
AIModules.Wallhack = {
    enabled = false,
    highlights = {},
    
    start = function(self)
        self.enabled = true
        spawn(function()
            while self.enabled do
                wait(0.5)
                for _, otherPlayer in pairs(Players:GetPlayers()) do
                    if otherPlayer ~= player and otherPlayer.Character then
                        if not self.highlights[otherPlayer.UserId] then
                            local highlight = Instance.new("Highlight")
                            highlight.FillColor = Color3.fromRGB(255, 0, 0)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                            highlight.FillTransparency = 0.5
                            highlight.OutlineTransparency = 0
                            highlight.Parent = otherPlayer.Character
                            self.highlights[otherPlayer.UserId] = highlight
                        end
                    end
                end
            end
        end)
    end,
    
    stop = function(self)
        self.enabled = false
        for _, highlight in pairs(self.highlights) do
            if highlight then
                highlight:Destroy()
            end
        end
        self.highlights = {}
    end
}

-- 13. AI無敵モードシステム
AIModules.GodMode = {
    enabled = false,
    connection = nil,
    
    start = function(self)
        self.enabled = true
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                self.connection = hum.HealthChanged:Connect(function()
                    if self.enabled then
                        hum.Health = hum.MaxHealth
                    end
                end)
            end
        end
    end,
    
    stop = function(self)
        self.enabled = false
        if self.connection then
            self.connection:Disconnect()
            self.connection = nil
        end
    end
}

-- Part 2 終了
-- 次に Part 3 を要求してください
-- AI搭載 高度カスタムUIシステム Part 3/4
-- Part 2 の続きです

-- ========================
-- UIシステム
-- ========================

local UISystem = {}
UISystem.__index = UISystem

function UISystem.new()
    local self = setmetatable({}, UISystem)
    
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "RayfieldUI"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screenGui.Parent = playerGui
    
    self.currentTab = "Home"
    self.isOpen = false
    
    self:CreateMainWindow()
    self:CreateTabs()
    self:CreateNotificationSystem()
    self:SetupToggle()
    
    return self
end

function UISystem:CreateMainWindow()
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainWindow"
    self.mainFrame.Size = UDim2.new(0, 550, 0, 400)
    self.mainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    self.mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.Visible = false
    self.mainFrame.Parent = self.screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = self.mainFrame
    
    local border = Instance.new("UIStroke")
    border.Color = Color3.fromRGB(100, 100, 255)
    border.Thickness = 2
    border.Transparency = 0.5
    border.Parent = self.mainFrame
    
    -- ヘッダー
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    header.BorderSizePixel = 0
    header.Parent = self.mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 200, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🚀 AI Control Hub"
    title.TextColor3 = Color3.fromRGB(150, 150, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0, 7.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = header
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 8)
    closeBtnCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- サイドバー
    self.sidebar = Instance.new("Frame")
    self.sidebar.Name = "Sidebar"
    self.sidebar.Size = UDim2.new(0, 140, 1, -50)
    self.sidebar.Position = UDim2.new(0, 0, 0, 50)
    self.sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    self.sidebar.BorderSizePixel = 0
    self.sidebar.Parent = self.mainFrame
    
    local sidebarList = Instance.new("UIListLayout")
    sidebarList.Padding = UDim.new(0, 5)
    sidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarList.Parent = self.sidebar
    
    -- コンテンツエリア
    self.contentArea = Instance.new("Frame")
    self.contentArea.Name = "ContentArea"
    self.contentArea.Size = UDim2.new(1, -140, 1, -50)
    self.contentArea.Position = UDim2.new(0, 140, 0, 50)
    self.contentArea.BackgroundTransparency = 1
    self.contentArea.BorderSizePixel = 0
    self.contentArea.Parent = self.mainFrame
end

function UISystem:CreateTabButton(name, icon, order)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Tab"
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.Text = icon .. " " .. name
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order
    btn.Parent = self.sidebar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    local btnPadding = Instance.new("UIPadding")
    btnPadding.PaddingLeft = UDim.new(0, 10)
    btnPadding.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        self:SwitchTab(name)
    end)
    
    return btn
end

function UISystem:CreateScrollingContent(tabName)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = tabName .. "Content"
    scroll.Size = UDim2.new(1, -20, 1, -20)
    scroll.Position = UDim2.new(0, 10, 0, 10)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.Visible = false
    scroll.Parent = self.contentArea
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 10)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scroll
    
    return scroll
end

function UISystem:CreateToggleOption(parent, name, icon, aiModule)
    local option = Instance.new("Frame")
    option.Size = UDim2.new(1, 0, 0, 50)
    option.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    option.BorderSizePixel = 0
    option.Parent = parent
    
    local optionCorner = Instance.new("UICorner")
    optionCorner.CornerRadius = UDim.new(0, 8)
    optionCorner.Parent = option
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = icon .. " " .. name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = option
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 60, 0, 30)
    toggle.Position = UDim2.new(1, -70, 0.5, -15)
    toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    toggle.Text = "OFF"
    toggle.TextColor3 = Color3.fromRGB(180, 180, 180)
    toggle.TextSize = 12
    toggle.Font = Enum.Font.GothamBold
    toggle.BorderSizePixel = 0
    toggle.Parent = option
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggle
    
    toggle.MouseButton1Click:Connect(function()
        if aiModule then
            if toggle.Text == "OFF" then
                aiModule:start()
                toggle.Text = "ON"
                toggle.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
                self:ShowNotification("✅ " .. name .. " 有効化", "success")
            else
                aiModule:stop()
                toggle.Text = "OFF"
                toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
                self:ShowNotification("❌ " .. name .. " 無効化", "info")
            end
        end
    end)
end

function UISystem:CreateTabs()
    self:CreateTabButton("Home", "🏠", 1)
    self:CreateTabButton("Combat", "⚔️", 2)
    self:CreateTabButton("Movement", "🏃", 3)
    self:CreateTabButton("Vision", "👁️", 4)
    self:CreateTabButton("Auto", "🤖", 5)
    self:CreateTabButton("Stats", "📊", 6)
    
    self:CreateHomeTab()
    self:CreateCombatTab()
    self:CreateMovementTab()
    self:CreateVisionTab()
    self:CreateAutoTab()
    self:CreateStatsTab()
end

function UISystem:CreateHomeTab()
    local content = self:CreateScrollingContent("Home")
    content.Visible = true
    
    local welcome = Instance.new("Frame")
    welcome.Size = UDim2.new(1, 0, 0, 120)
    welcome.BackgroundColor3 = Color3.fromRGB(40, 40, 100)
    welcome.BorderSizePixel = 0
    welcome.Parent = content
    
    local welcomeCorner = Instance.new("UICorner")
    welcomeCorner.CornerRadius = UDim.new(0, 10)
    welcomeCorner.Parent = welcome
    
    local welcomeText = Instance.new("TextLabel")
    welcomeText.Size = UDim2.new(1, -20, 1, -20)
    welcomeText.Position = UDim2.new(0, 10, 0, 10)
    welcomeText.BackgroundTransparency = 1
    welcomeText.Text = "🚀 AI Control Hub へようこそ！\n\n13個以上のAI機能搭載\n左のタブから機能を選択\n\n[Right Ctrl] でUI開閉"
    welcomeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    welcomeText.TextSize = 14
    welcomeText.Font = Enum.Font.Gotham
    welcomeText.TextWrapped = true
    welcomeText.Parent = welcome
end

function UISystem:CreateCombatTab()
    local content = self:CreateScrollingContent("Combat")
    self:CreateToggleOption(content, "自動照準", "🎯", AIModules.AutoAim)
    self:CreateToggleOption(content, "敵検出システム", "👥", AIModules.EnemyDetector)
    self:CreateToggleOption(content, "自動回避", "🛡️", AIModules.AutoDodge)
    self:CreateToggleOption(content, "ウォールハック", "🔍", AIModules.Wallhack)
    self:CreateToggleOption(content, "無敵モード", "⭐", AIModules.GodMode)
end

function UISystem:CreateMovementTab()
    local content = self:CreateScrollingContent("Movement")
    self:CreateToggleOption(content, "スピードブースト", "⚡", AIModules.SpeedBoost)
    self:CreateToggleOption(content, "無限ジャンプ", "🦘", AIModules.InfiniteJump)
    self:CreateToggleOption(content, "フライモード", "🕊️", AIModules.Fly)
    self:CreateToggleOption(content, "自動ジャンプ", "🎪", AIModules.AutoJump)
end

function UISystem:CreateVisionTab()
    local content = self:CreateScrollingContent("Vision")
    self:CreateToggleOption(content, "視界強化", "👁️", AIModules.VisionEnhancer)
end

function UISystem:CreateAutoTab()
    local content = self:CreateScrollingContent("Auto")
    self:CreateToggleOption(content, "自動体力回復", "❤️", AIModules.AutoHeal)
    self:CreateToggleOption(content, "自動収集", "💰", AIModules.AutoCollect)
end

-- Part 3 終了
-- 次に Part 4 を要求してください
-- AI搭載 高度カスタムUIシステム Part 4/4 (最終)
-- Part 3 の続きです

function UISystem:CreateStatsTab()
    local content = self:CreateScrollingContent("Stats")
    AIModules.ResourceMonitor:start()
    
    local statsPanel = Instance.new("Frame")
    statsPanel.Size = UDim2.new(1, 0, 0, 180)
    statsPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    statsPanel.BorderSizePixel = 0
    statsPanel.Parent = content
    
    local statsCorner = Instance.new("UICorner")
    statsCorner.CornerRadius = UDim.new(0, 10)
    statsCorner.Parent = statsPanel
    
    local statsTitle = Instance.new("TextLabel")
    statsTitle.Size = UDim2.new(1, -20, 0, 30)
    statsTitle.Position = UDim2.new(0, 10, 0, 10)
    statsTitle.BackgroundTransparency = 1
    statsTitle.Text = "📊 システム統計"
    statsTitle.TextColor3 = Color3.fromRGB(150, 150, 255)
    statsTitle.TextSize = 16
    statsTitle.Font = Enum.Font.GothamBold
    statsTitle.TextXAlignment = Enum.TextXAlignment.Left
    statsTitle.Parent = statsPanel
    
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(1, -20, 0, 25)
    fpsLabel.Position = UDim2.new(0, 10, 0, 45)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: 60"
    fpsLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    fpsLabel.TextSize = 14
    fpsLabel.Font = Enum.Font.Gotham
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    fpsLabel.Parent = statsPanel
    
    local pingLabel = Instance.new("TextLabel")
    pingLabel.Size = UDim2.new(1, -20, 0, 25)
    pingLabel.Position = UDim2.new(0, 10, 0, 75)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Text = "Ping: 0ms"
    pingLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    pingLabel.TextSize = 14
    pingLabel.Font = Enum.Font.Gotham
    pingLabel.TextXAlignment = Enum.TextXAlignment.Left
    pingLabel.Parent = statsPanel
    
    local memoryLabel = Instance.new("TextLabel")
    memoryLabel.Size = UDim2.new(1, -20, 0, 25)
    memoryLabel.Position = UDim2.new(0, 10, 0, 105)
    memoryLabel.BackgroundTransparency = 1
    memoryLabel.Text = "メモリ: 0 MB"
    memoryLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    memoryLabel.TextSize = 14
    memoryLabel.Font = Enum.Font.Gotham
    memoryLabel.TextXAlignment = Enum.TextXAlignment.Left
    memoryLabel.Parent = statsPanel
    
    local playerLabel = Instance.new("TextLabel")
    playerLabel.Size = UDim2.new(1, -20, 0, 25)
    playerLabel.Position = UDim2.new(0, 10, 0, 135)
    playerLabel.BackgroundTransparency = 1
    playerLabel.Text = "プレイヤー: " .. player.Name
    playerLabel.TextColor3 = Color3.fromRGB(255, 150, 255)
    playerLabel.TextSize = 14
    playerLabel.Font = Enum.Font.Gotham
    playerLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerLabel.Parent = statsPanel
    
    spawn(function()
        while wait(0.5) do
            if AIModules.ResourceMonitor.enabled then
                fpsLabel.Text = "FPS: " .. AIModules.ResourceMonitor.stats.fps
                pingLabel.Text = "Ping: " .. AIModules.ResourceMonitor.stats.ping .. "ms"
                memoryLabel.Text = "メモリ: " .. AIModules.ResourceMonitor.stats.memory .. " MB"
            end
        end
    end)
end

function UISystem:SwitchTab(tabName)
    self.currentTab = tabName
    
    for _, child in pairs(self.contentArea:GetChildren()) do
        if child:IsA("ScrollingFrame") then
            child.Visible = false
        end
    end
    
    for _, btn in pairs(self.sidebar:GetChildren()) do
        if btn:IsA("TextButton") then
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
    end
    
    local targetContent = self.contentArea:FindFirstChild(tabName .. "Content")
    if targetContent then
        targetContent.Visible = true
    end
    
    local targetBtn = self.sidebar:FindFirstChild(tabName .. "Tab")
    if targetBtn then
        targetBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 100)
        targetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

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
    
    notif.Position = UDim2.new(1, 20, 0, 0)
    local tweenIn = TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(0, 0, 0, 0)})
    tweenIn:Play()
    
    task.wait(3)
    local tweenOut = TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(1, 20, 0, 0)})
    tweenOut:Play()
    tweenOut.Completed:Wait()
    notif:Destroy()
end

function UISystem:Toggle()
    self.isOpen = not self.isOpen
    self.mainFrame.Visible = self.isOpen
    
    if self.isOpen then
        self.mainFrame.Position = UDim2.new(0.5, -275, 1, 0)
        local tween = TweenService:Create(self.mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Position = UDim2.new(0.5, -275, 0.5, -200)
        })
        tween:Play()
    end
end

function UISystem:SetupToggle()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.RightControl then
            self:Toggle()
        end
    end)
end

-- ========================
-- システム初期化
-- ========================

local uiSystem = UISystem.new()

task.wait(1)
uiSystem:ShowNotification("✨ AI Control Hub が起動しました！", "success")

task.wait(2)
uiSystem:ShowNotification("ℹ️ [Right Ctrl] でUIを開閉", "info")

task.wait(3)
uiSystem:ShowNotification("🎯 13個以上のAI機能が利用可能です！", "success")

print("AI Control Hub システムが正常にロードされました")
print("合計AI機能数: 13個以上")
print("[Right Ctrl] キーでUIを開閉できます")

-- Part 4 終了 - 全コード完成！
