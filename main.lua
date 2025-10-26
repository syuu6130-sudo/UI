-- // AI Control Hub - Executor Edition (Orion UI)
-- // Version: 1.2
-- // Author: GPT-5 Fix

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- 安全ロード関数
local function safeLoad(url)
    local s, e = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not s then
        warn("[AI Hub] Load failed:", e)
        return nil
    end
    return e
end

-- Orionライブラリ読込
local OrionLib = safeLoad("https://raw.githubusercontent.com/shlexware/Orion/main/source")
if not OrionLib then
    return warn("[AI Hub] Orion Library failed to load.")
end

-- AIModules
local AIModules = {}

-- AI 自動体力回復
AIModules.AutoHeal = {
    enabled = false,
    threshold = 50,
    healAmount = 5,
    interval = 1,
    start = function(self)
        self.enabled = true
        task.spawn(function()
            while self.enabled do
                task.wait(self.interval)
                local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health < self.threshold and hum.Health > 0 then
                    hum.Health = math.min(hum.Health + self.healAmount, hum.MaxHealth)
                end
            end
        end)
    end,
    stop = function(self) self.enabled = false end
}

-- AI 無限ジャンプ
AIModules.InfiniteJump = {
    enabled = false,
    conn = nil,
    start = function(self)
        self.enabled = true
        self.conn = UserInputService.JumpRequest:Connect(function()
            if self.enabled and player.Character then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end,
    stop = function(self)
        self.enabled = false
        if self.conn then self.conn:Disconnect() self.conn = nil end
    end
}

-- AI フライ
AIModules.Fly = {
    enabled = false,
    speed = 50,
    vel = nil,
    gyro = nil,
    conn = nil,
    start = function(self)
        self.enabled = true
        local char = player.Character or player.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart")

        self.vel = Instance.new("BodyVelocity")
        self.vel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        self.vel.Velocity = Vector3.zero
        self.vel.Parent = root

        self.gyro = Instance.new("BodyGyro")
        self.gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        self.gyro.P = 9e4
        self.gyro.Parent = root

        self.conn = RunService.RenderStepped:Connect(function()
            if not self.enabled then return end
            local cam = workspace.CurrentCamera
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end
            self.vel.Velocity = move * self.speed
            self.gyro.CFrame = cam.CFrame
        end)
    end,
    stop = function(self)
        self.enabled = false
        if self.conn then self.conn:Disconnect() end
        if self.vel then self.vel:Destroy() end
        if self.gyro then self.gyro:Destroy() end
    end
}

-- ============================
-- Orion UI 設定
-- ============================

local Window = OrionLib:MakeWindow({
    Name = "🚀 AI Control Hub (Executor Edition)",
    HidePremium = false,
    SaveConfig = false
})

local MainTab = Window:MakeTab({
    Name = "⚙️ メイン機能",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MainTab:AddToggle({
    Name = "❤️ 自動回復",
    Default = false,
    Callback = function(Value)
        if Value then
            AIModules.AutoHeal:start()
        else
            AIModules.AutoHeal:stop()
        end
    end
})

MainTab:AddToggle({
    Name = "🦘 無限ジャンプ",
    Default = false,
    Callback = function(Value)
        if Value then
            AIModules.InfiniteJump:start()
        else
            AIModules.InfiniteJump:stop()
        end
    end
})

MainTab:AddToggle({
    Name = "🕊️ フライモード",
    Default = false,
    Callback = function(Value)
        if Value then
            AIModules.Fly:start()
        else
            AIModules.Fly:stop()
        end
    end
})

OrionLib:MakeNotification({
    Name = "AI Control Hub 起動",
    Content = "Executor版が正常に起動しました。",
    Time = 5
})

OrionLib:Init()
