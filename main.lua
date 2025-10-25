-- AI搭載 Orion Library UIシステム - Part 1/2
-- LocalScript (StarterPlayer > StarterPlayerScripts に配置)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer

-- Fluent UI の読み込み
loadstring(game:HttpGet("https://github.com/devforfun/fluent-ui/raw/main/source.lua"))()

-- ========================
-- AI機能モジュール (13個搭載)
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

-- Part 1 終了
-- 次に「パート2」と入力してください
-- AI搭載 Orion Library UIシステム - Part 2/2 (最終)
-- Part 1 の続きです

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

-- ========================
-- Orion Library UI構築
-- ========================

local Window = OrionLib:MakeWindow({
    Name = "🚀 AI Control Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "AIHubConfig",
    IntroEnabled = true,
    IntroText = "AI Hub Loading..."
})

-- ホームタブ
local HomeTab = Window:MakeTab({
    Name = "🏠 ホーム",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

HomeTab:AddParagraph("ようこそ!", "AI Control Hubへようこそ!\n13個以上のAI機能を搭載しています。")
HomeTab:AddParagraph("使い方", "各タブから機能を選択してトグルをONにしてください。")
HomeTab:AddLabel("プレイヤー: " .. player.Name)

-- コンバットタブ
local CombatTab = Window:MakeTab({
    Name = "⚔️ 戦闘",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

CombatTab:AddToggle({
    Name = "🎯 自動照準",
    Default = false,
    Callback = function(Value)
        if Value then
            AIModules.AutoAim:start()
            OrionLib:MakeNotification({
                Name = "✅ 自動照準",
                Content = "自動照準が有効になりました",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            AIModules.AutoAim:stop()
        end
    end    
})

CombatTab:AddToggle({
    Name = "👥 敵検出",
    Default = false,
    Callback = function(Value)
        if Value then
            AIModules.EnemyDetector:start()
            OrionLib:MakeNotification({
                Name = "✅ 敵検出",
                Content = "敵検出システムが有効になりました",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            AIModules.EnemyDetector:stop()
        end
    end    
})

CombatTab:AddToggle({
    Name = "🛡️ 自動回避",
    Default = false,
    Callback = function(Value)
        if Value then
            AIModules.AutoDodge:start()
            OrionLib:MakeNotification({
                Name = "✅ 自動回避",
                Content = "自動回避が有効になりました",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            AIModules.AutoDodge:stop()
        end
    end    
})

CombatTab:AddToggle({
    Name = "🔍 ウォールハック",
    Default = false,
    Callback = function(Value)
        if Value then
            AIModules.Wallhack:start()
            OrionLib:MakeNotification({
                Name = "✅ ウォールハック",
                Content = "ウォールハックが有効になりました",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            AIModules.Wallhack:stop()
        end
    end    
})

CombatTab:AddToggle({
    Name = "⭐ 無敵モード",
    Default = false,
    Callback = function(Value)
        if Value then
            AIModules.GodMode:start()
            OrionLib:MakeNotification({
                Name = "✅ 無敵モード",
                Content = "無敵モードが有効になりました",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            AIModules.GodMode:stop()
        end
    end    
})

-- 移動タブ
local MovementTab = Window:MakeTab({
    Name = "🏃 移動",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MovementTab:AddToggle({
    Name = "⚡ スピードブースト",
    Default = false,
    Callback = function(Value)
        if Value then
            AIModules.SpeedBoost:start()
            OrionLib:MakeNotification({
                Name = "✅ スピードブースト",
                Content = "スピードブーストが有効になりました",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            AIModules.SpeedBoost:stop()
        end
    end    
})

MovementTab:AddToggle({
    Name = "🦘 無限ジャンプ",
    Default = false,
    Callback = function(Value)
        if Value then
            AIModules.InfiniteJump:start()
            OrionLib:MakeNotification({
                Name = "✅ 無限ジャンプ",
                Content = "無限ジャンプが有効になりました",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            AIModules.InfiniteJump:stop()
        end
    end    
})

MovementTab:AddToggle({
    Name = "🕊️ フライモード",
    Default = false,
    Callback = function(Value)
        if Value then
            AIModules.Fly:start()
            OrionLib:MakeNotification({
                Name = "✅ フライモード",
                Content = "フライモードが有効になりました (WASD + Space/Shift)",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            AIModules.Fly:stop()
        end
    end    
})

MovementTab:AddToggle({
    Name = "🎪 自動ジャンプ",
    Default = false,
    Callback = function(Value)
        if Value then
            AIModules.AutoJump:start()
            OrionLib:MakeNotification({
                Name = "✅ 自動ジャンプ",
                Content = "自動ジャンプが有効になりました",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            AIModules.AutoJump:stop()
        end
    end    
})

-- 視界タブ
local VisionTab = Window:MakeTab({
    Name = "👁️ 視界",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

VisionTab:AddToggle({
    Name = "👁️ 視界強化",
    Default = false,
    Callback = function(Value)
        if Value then
            AIModules.VisionEnhancer:start()
            OrionLib:MakeNotification({
                Name = "✅ 視界強化",
                Content = "視界強化が有効になりました",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            AIModules.VisionEnhancer:stop()
        end
    end    
})

-- 自動化タブ
local AutoTab = Window:MakeTab({
    Name = "🤖 自動化",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

AutoTab:AddToggle({
    Name = "❤️ 自動回復",
    Default = false,
    Callback = function(Value)
        if Value then
            AIModules.AutoHeal:start()
            OrionLib:MakeNotification({
                Name = "✅ 自動回復",
                Content = "自動回復が有効になりました",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            AIModules.AutoHeal:stop()
        end
    end    
})

AutoTab:AddToggle({
    Name = "💰 自動収集",
    Default = false,
    Callback = function(Value)
        if Value then
            AIModules.AutoCollect:start()
            OrionLib:MakeNotification({
                Name = "✅ 自動収集",
                Content = "自動収集が有効になりました",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            AIModules.AutoCollect:stop()
        end
    end    
})

-- 統計タブ
local StatsTab = Window:MakeTab({
    Name = "📊 統計",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

AIModules.ResourceMonitor:start()

local fpsLabel = StatsTab:AddLabel("FPS: 計測中...")
local pingLabel = StatsTab:AddLabel("Ping: 計測中...")
local memoryLabel = StatsTab:AddLabel("メモリ: 計測中...")

spawn(function()
    while wait(1) do
        if AIModules.ResourceMonitor.enabled then
            fpsLabel:Set("FPS: " .. AIModules.ResourceMonitor.stats.fps)
            pingLabel:Set("Ping: " .. AIModules.ResourceMonitor.stats.ping .. "ms")
            memoryLabel:Set("メモリ: " .. AIModules.ResourceMonitor.stats.memory .. " MB")
        end
    end
end)

StatsTab:AddParagraph("システム情報", "リアルタイムでパフォーマンスを監視します")

-- 設定タブ
local SettingsTab = Window:MakeTab({
    Name = "⚙️ 設定",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

SettingsTab:AddButton({
    Name = "🔄 UIを再読み込み",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "🔄 再読み込み",
            Content = "UIを再読み込みしています...",
            Image = "rbxassetid://4483345998",
            Time = 2
        })
        wait(1)
        OrionLib:Destroy()
        wait(0.5)
        loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
    end    
})

SettingsTab:AddButton({
    Name = "❌ UIを閉じる",
    Callback = function()
        OrionLib:Destroy()
    end    
})

-- 初期化完了通知
OrionLib:MakeNotification({
    Name = "✨ AI Control Hub",
    Content = "起動完了! 13個のAI機能が利用可能です",
    Image = "rbxassetid://4483345998",
    Time = 5
})

OrionLib:Init()

print("=================================")
print("AI Control Hub (Orion Library版)")
print("ロード完了!")
print("AI機能数: 13個")
print("=================================")

-- Part 2 完成! 全コード終了!
