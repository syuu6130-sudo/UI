-- AI搭載 Orion Library UIシステム - 修正版 (Part 1+2 統合)
-- LocalScript (StarterPlayer > StarterPlayerScripts に配置)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local workspace = workspace

local player = Players.LocalPlayer

-- **重要**: Orion を読み込んで OrionLib に格納（元のスクリプトは Fluent を読み込んでいた）
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source.lua'))()

-- ========================
-- AI機能モジュール (13個)
-- ========================

local AIModules = {}

-- 1. AutoHeal
AIModules.AutoHeal = {
    enabled = false,
    threshold = 50,
    healAmount = 5,
    interval = 1,
    start = function(self)
        if self.enabled then return end
        self.enabled = true
        spawn(function()
            while self.enabled do
                wait(self.interval)
                local char = player.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 and hum.Health < self.threshold then
                        hum.Health = math.min(hum.Health + self.healAmount, hum.MaxHealth)
                    end
                end
            end
        end)
    end,
    stop = function(self) self.enabled = false end
}

-- 2. EnemyDetector
AIModules.EnemyDetector = {
    enabled = false,
    range = 100,
    detectedEnemies = {},
    start = function(self)
        if self.enabled then return end
        self.enabled = true
        spawn(function()
            while self.enabled do
                wait(0.5)
                self.detectedEnemies = {}
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local pos = char.HumanoidRootPart.Position
                    for _, otherPlayer in pairs(Players:GetPlayers()) do
                        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local distance = (pos - otherPlayer.Character.HumanoidRootPart.Position).Magnitude
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
        end)
    end,
    stop = function(self) self.enabled = false; self.detectedEnemies = {} end
}

-- 3. AutoJump
AIModules.AutoJump = {
    enabled = false,
    interval = 3,
    start = function(self)
        if self.enabled then return end
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
    stop = function(self) self.enabled = false end
}

-- 4. SpeedBoost
AIModules.SpeedBoost = {
    enabled = false,
    multiplier = 1.5,
    originalSpeed = nil,
    start = function(self)
        if self.enabled then return end
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
            if hum and self.originalSpeed then
                hum.WalkSpeed = self.originalSpeed
            end
        end
    end
}

-- 5. InfiniteJump
AIModules.InfiniteJump = {
    enabled = false,
    connection = nil,
    start = function(self)
        if self.enabled then return end
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
        if self.connection then self.connection:Disconnect(); self.connection = nil end
    end
}

-- 6. VisionEnhancer
AIModules.VisionEnhancer = {
    enabled = false,
    originalFog = nil,
    originalBrightness = nil,
    start = function(self)
        if self.enabled then return end
        self.enabled = true
        self.originalFog = Lighting.FogEnd
        self.originalBrightness = Lighting.Brightness
        Lighting.FogEnd = 100000
        Lighting.Brightness = 2
    end,
    stop = function(self)
        self.enabled = false
        if self.originalFog then Lighting.FogEnd = self.originalFog end
        if self.originalBrightness then Lighting.Brightness = self.originalBrightness end
    end
}

-- 7. AutoCollect (改善: BasePart 判定、Anchored 判定)
AIModules.AutoCollect = {
    enabled = false,
    range = 50,
    start = function(self)
        if self.enabled then return end
        self.enabled = true
        spawn(function()
            while self.enabled do
                wait(0.5)
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local root = char.HumanoidRootPart
                    local pos = root.Position
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            local name = tostring(obj.Name):lower()
                            if name:find("coin") or name:find("gem") then
                                local distance = (pos - obj.Position).Magnitude
                                if distance <= self.range then
                                    -- Anchored でないものだけ移動（物理的に拾う動作が必要な場合は別実装）
                                    if not obj.Anchored then
                                        pcall(function()
                                            obj.CFrame = root.CFrame
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end,
    stop = function(self) self.enabled = false end
}

-- 8. Fly (安全対策: 既存の BodyInstance があればクリア)
AIModules.Fly = {
    enabled = false,
    speed = 50,
    connection = nil,
    bodyVelocity = nil,
    bodyGyro = nil,
    start = function(self)
        if self.enabled then return end
        self.enabled = true
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            -- 既存のがあれば消す
            if root:FindFirstChild("AI_Fly_BV") then root.AI_Fly_BV:Destroy() end
            if root:FindFirstChild("AI_Fly_BG") then root.AI_Fly_BG:Destroy() end

            self.bodyVelocity = Instance.new("BodyVelocity")
            self.bodyVelocity.Name = "AI_Fly_BV"
            self.bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            self.bodyVelocity.Velocity = Vector3.new(0,0,0)
            self.bodyVelocity.Parent = root

            self.bodyGyro = Instance.new("BodyGyro")
            self.bodyGyro.Name = "AI_Fly_BG"
            self.bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            self.bodyGyro.P = 9e4
            self.bodyGyro.Parent = root

            self.connection = RunService.RenderStepped:Connect(function()
                if not self.enabled then return end
                local camera = workspace.CurrentCamera
                if not camera then return end
                local moveDir = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0,1,0) end

                if self.bodyVelocity then
                    self.bodyVelocity.Velocity = moveDir.Unit ~= moveDir.Unit and Vector3.new(0,0,0) or (moveDir * self.speed)
                end
                if self.bodyGyro then
                    self.bodyGyro.CFrame = camera.CFrame
                end
            end)
        end
    end,
    stop = function(self)
        self.enabled = false
        if self.connection then self.connection:Disconnect(); self.connection = nil end
        if self.bodyVelocity then self.bodyVelocity:Destroy(); self.bodyVelocity = nil end
        if self.bodyGyro then self.bodyGyro:Destroy(); self.bodyGyro = nil end
    end
}

-- 9. AutoDodge (改善: Humanoid:Move の第二引数を追加)
AIModules.AutoDodge = {
    enabled = false,
    dodgeDistance = 10,
    start = function(self)
        if self.enabled then return end
        self.enabled = true
        spawn(function()
            while self.enabled do
                wait(0.1)
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local root = char.HumanoidRootPart
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            local lname = tostring(obj.Name):lower()
                            if lname:find("danger") or lname:find("trap") or lname:find("lava") then
                                local distance = (root.Position - obj.Position).Magnitude
                                if distance < self.dodgeDistance and hum then
                                    local direction = (root.Position - obj.Position)
                                    if direction.Magnitude > 0 then
                                        direction = direction.Unit
                                        -- 第二引数 true を付けてカメラ相対ではなくワールド方向で移動させる
                                        pcall(function()
                                            hum:Move(direction, true)
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end,
    stop = function(self) self.enabled = false end
}

-- 10. AutoAim
AIModules.AutoAim = {
    enabled = false,
    start = function(self)
        if self.enabled then return end
        self.enabled = true
        spawn(function()
            while self.enabled do
                wait(0.1)
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local nearestEnemy, nearestDistance = nil, math.huge
                    for _, otherPlayer in pairs(Players:GetPlayers()) do
                        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local otherHum = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
                            if otherHum and otherHum.Health > 0 then
                                local dist = (char.HumanoidRootPart.Position - otherPlayer.Character.HumanoidRootPart.Position).Magnitude
                                if dist < nearestDistance then
                                    nearestDistance = dist
                                    nearestEnemy = otherPlayer.Character
                                end
                            end
                        end
                    end
                    if nearestEnemy and workspace.CurrentCamera and nearestEnemy:FindFirstChild("HumanoidRootPart") then
                        -- カメラを直接設定するのは一部の環境で干渉する可能性あり
                        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, nearestEnemy.HumanoidRootPart.Position)
                    end
                end
            end
        end)
    end,
    stop = function(self) self.enabled = false end
}

-- 11. ResourceMonitor
AIModules.ResourceMonitor = {
    enabled = false,
    stats = {fps = 0, ping = 0, memory = 0},
    start = function(self)
        if self.enabled then return end
        self.enabled = true
        spawn(function()
            while self.enabled do
                local last = tick()
                RunService.RenderStepped:Wait()
                local dt = tick() - last
                if dt > 0 then
                    self.stats.fps = math.floor(1 / dt)
                end
                self.stats.ping = math.floor(player:GetNetworkPing() * 1000)
                self.stats.memory = math.floor(collectgarbage("count") / 1024)
                wait(0.2)
            end
        end)
    end,
    stop = function(self) self.enabled = false end
}

-- 12. Wallhack (Highlight の生成を pcall で安全に)
AIModules.Wallhack = {
    enabled = false,
    highlights = {},
    start = function(self)
        if self.enabled then return end
        self.enabled = true
        spawn(function()
            while self.enabled do
                wait(0.5)
                for _, otherPlayer in pairs(Players:GetPlayers()) do
                    if otherPlayer ~= player and otherPlayer.Character and not self.highlights[otherPlayer.UserId] then
                        pcall(function()
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "AI_WallHack_HL"
                            highlight.FillColor = Color3.fromRGB(255, 0, 0)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                            highlight.FillTransparency = 0.5
                            highlight.OutlineTransparency = 0
                            highlight.Parent = otherPlayer.Character
                            self.highlights[otherPlayer.UserId] = highlight
                        end)
                    end
                end
            end
        end)
    end,
    stop = function(self)
        self.enabled = false
        for _, highlight in pairs(self.highlights) do
            if highlight and highlight.Destroy then
                pcall(function() highlight:Destroy() end)
            end
        end
        self.highlights = {}
    end
}

-- 13. GodMode
AIModules.GodMode = {
    enabled = false,
    connection = nil,
    start = function(self)
        if self.enabled then return end
        self.enabled = true
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                -- 既存のコネクションがあれば切断
                if self.connection then
                    self.connection:Disconnect()
                    self.connection = nil
                end
                self.connection = hum.HealthChanged:Connect(function()
                    if self.enabled and hum and hum.Health < hum.MaxHealth then
                        hum.Health = hum.MaxHealth
                    end
                end)
            end
        end
    end,
    stop = function(self)
        self.enabled = false
        if self.connection then self.connection:Disconnect(); self.connection = nil end
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
HomeTab:AddLabel("プレイヤー: " .. (player and player.Name or "Unknown"))

-- 戦闘タブ
local CombatTab = Window:MakeTab({ Name = "⚔️ 戦闘", Icon = "rbxassetid://4483345998", PremiumOnly = false })

CombatTab:AddToggle({
    Name = "🎯 自動照準",
    Default = false,
    Callback = function(Value)
        if Value then AIModules.AutoAim:start() else AIModules.AutoAim:stop() end
    end
})

CombatTab:AddToggle({
    Name = "👥 敵検出",
    Default = false,
    Callback = function(Value)
        if Value then AIModules.EnemyDetector:start() else AIModules.EnemyDetector:stop() end
    end
})

CombatTab:AddToggle({
    Name = "🛡️ 自動回避",
    Default = false,
    Callback = function(Value)
        if Value then AIModules.AutoDodge:start() else AIModules.AutoDodge:stop() end
    end
})

CombatTab:AddToggle({
    Name = "🔍 ウォールハック",
    Default = false,
    Callback = function(Value)
        if Value then AIModules.Wallhack:start() else AIModules.Wallhack:stop() end
    end
})

CombatTab:AddToggle({
    Name = "⭐ 無敵モード",
    Default = false,
    Callback = function(Value)
        if Value then AIModules.GodMode:start() else AIModules.GodMode:stop() end
    end
})

-- 移動タブ
local MovementTab = Window:MakeTab({ Name = "🏃 移動", Icon = "rbxassetid://4483345998", PremiumOnly = false })

MovementTab:AddToggle({ Name = "⚡ スピードブースト", Default = false, Callback = function(Value) if Value then AIModules.SpeedBoost:start() else AIModules.SpeedBoost:stop() end end })
MovementTab:AddToggle({ Name = "🦘 無限ジャンプ", Default = false, Callback = function(Value) if Value then AIModules.InfiniteJump:start() else AIModules.InfiniteJump:stop() end end })
MovementTab:AddToggle({ Name = "🕊️ フライモード", Default = false, Callback = function(Value) if Value then AIModules.Fly:start() else AIModules.Fly:stop() end end })
MovementTab:AddToggle({ Name = "🎪 自動ジャンプ", Default = false, Callback = function(Value) if Value then AIModules.AutoJump:start() else AIModules.AutoJump:stop() end end })

-- 視界タブ
local VisionTab = Window:MakeTab({ Name = "👁️ 視界", Icon = "rbxassetid://4483345998", PremiumOnly = false })
VisionTab:AddToggle({ Name = "👁️ 視界強化", Default = false, Callback = function(Value) if Value then AIModules.VisionEnhancer:start() else AIModules.VisionEnhancer:stop() end end })

-- 自動化タブ
local AutoTab = Window:MakeTab({ Name = "🤖 自動化", Icon = "rbxassetid://4483345998", PremiumOnly = false })
AutoTab:AddToggle({ Name = "❤️ 自動回復", Default = false, Callback = function(Value) if Value then AIModules.AutoHeal:start() else AIModules.AutoHeal:stop() end end })
AutoTab:AddToggle({ Name = "💰 自動収集", Default = false, Callback = function(Value) if Value then AIModules.AutoCollect:start() else AIModules.AutoCollect:stop() end end })

-- 統計タブ
local StatsTab = Window:MakeTab({ Name = "📊 統計", Icon = "rbxassetid://4483345998", PremiumOnly = false })

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
local SettingsTab = Window:MakeTab({ Name = "⚙️ 設定", Icon = "rbxassetid://4483345998", PremiumOnly = false })

SettingsTab:AddButton({
    Name = "🔄 UIを再読み込み",
    Callback = function()
        OrionLib:MakeNotification({ Name = "🔄 再読み込み", Content = "UIを再読み込みしています...", Image = "rbxassetid://4483345998", Time = 2 })
        wait(1)
        OrionLib:Destroy()
        wait(0.5)
        -- 再読み込みは Orion を再取得
        OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source.lua'))()
    end
})

SettingsTab:AddButton({
    Name = "❌ UIを閉じる",
    Callback = function() OrionLib:Destroy() end
})

-- 初期化完了通知
OrionLib:MakeNotification({ Name = "✨ AI Control Hub", Content = "起動完了! 13個のAI機能が利用可能です", Image = "rbxassetid://4483345998", Time = 5 })
OrionLib:Init()

print("AI Control Hub (Orion Library版) - ロード完了!")
