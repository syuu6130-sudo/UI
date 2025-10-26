-- KRNL対応 AI Control Hub (上タブ式Rayfield風)
-- 完全版 Lua

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- 既存UI削除
local oldUI = CoreGui:FindFirstChild("AIControlHub")
if oldUI then oldUI:Destroy() end

-- ScreenGui
local UI = Instance.new("ScreenGui")
UI.Name = "AIControlHub"
UI.Parent = CoreGui
UI.ResetOnSpawn = false

-- メインフレーム
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0,500,0,350)
MainFrame.Position = UDim2.new(0.5,-250,0.5,-175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = UI

-- タイトルバー
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,40)
Title.BackgroundColor3 = Color3.fromRGB(40,40,40)
Title.BackgroundTransparency = 0.1
Title.Text = "🚀 AI Control Hub"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = MainFrame

-- 閉じるボタン
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0,40,0,40)
Close.Position = UDim2.new(1,-40,0,0)
Close.BackgroundColor3 = Color3.fromRGB(50,50,50)
Close.TextColor3 = Color3.fromRGB(255,80,80)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 18
Close.Text = "X"
Close.Parent = MainFrame
Close.MouseButton1Click:Connect(function() UI:Destroy() end)

-- タブバー
local Tabs = {"🏠 ホーム","⚔️ 戦闘","🏃 移動","👁️ 視界","🤖 自動化","⚙️ 設定"}
local TabFrames = {}
local TabButtons = {}
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1,0,0,40)
TabBar.Position = UDim2.new(0,0,0,40)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local function selectTab(name)
	for t, frame in pairs(TabFrames) do
		frame.Visible = (t==name)
	end
	for t, btn in pairs(TabButtons) do
		btn.BackgroundColor3 = (t==name) and Color3.fromRGB(60,60,60) or Color3.fromRGB(30,30,30)
	end
end

for i, tab in pairs(Tabs) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0,80,0,40)
	btn.Position = UDim2.new(0,(i-1)*80,0,0)
	btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 16
	btn.Text = tab
	btn.Parent = TabBar
	TabButtons[tab] = btn

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,-20,1,-80)
	frame.Position = UDim2.new(0,10,0,80)
	frame.BackgroundTransparency = 1
	frame.Parent = MainFrame
	TabFrames[tab] = frame

	btn.MouseButton1Click:Connect(function() selectTab(tab) end)
end

selectTab("🏠 ホーム") -- 初期表示

-- ==================== AIモジュール ====================

local AIModules = {}

-- 1. 自動回復
AIModules.AutoHeal={enabled=false,threshold=50,healAmount=5,interval=1,
start=function(self)
	self.enabled=true
	spawn(function()
		while self.enabled do
			wait(self.interval)
			local char=player.Character
			if char then
				local hum=char:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health<self.threshold and hum.Health>0 then
					hum.Health=math.min(hum.Health+self.healAmount,hum.MaxHealth)
				end
			end
		end
	end)
end,stop=function(self) self.enabled=false end}

-- 2. 敵検出
AIModules.EnemyDetector={enabled=false,range=100,detectedEnemies={},
start=function(self)
	self.enabled=true
	spawn(function()
		while self.enabled do
			wait(0.5)
			self.detectedEnemies={}
			local char=player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local pos=char.HumanoidRootPart.Position
				for _,p in pairs(Players:GetPlayers()) do
					if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
						local d=(pos-p.Character.HumanoidRootPart.Position).Magnitude
						if d<=self.range then table.insert(self.detectedEnemies,{player=p,distance=math.floor(d)}) end
					end
				end
			end
		end
	end)
end,stop=function(self) self.enabled=false; self.detectedEnemies={} end}

-- 3. 自動ジャンプ
AIModules.AutoJump={enabled=false,interval=3,
start=function(self)
	self.enabled=true
	spawn(function()
		while self.enabled do
			wait(self.interval)
			local char=player.Character
			if char then local hum=char:FindFirstChildOfClass("Humanoid") if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end
		end
	end)
end,stop=function(self) self.enabled=false end}

-- 4. スピードブースト
AIModules.SpeedBoost={enabled=false,multiplier=1.5,originalSpeed=16,
start=function(self)
	self.enabled=true
	local char=player.Character
	if char then local hum=char:FindFirstChildOfClass("Humanoid") if hum then self.originalSpeed=hum.WalkSpeed hum.WalkSpeed=self.originalSpeed*self.multiplier end end
end,
stop=function(self)
	self.enabled=false
	local char=player.Character
	if char then local hum=char:FindFirstChildOfClass("Humanoid") if hum then hum.WalkSpeed=self.originalSpeed end end
end}

-- 5. 無限ジャンプ
AIModules.InfiniteJump={enabled=false,connection=nil,
start=function(self)
	self.enabled=true
	self.connection=UserInputService.JumpRequest:Connect(function()
		if self.enabled then local char=player.Character if char then local hum=char:FindFirstChildOfClass("Humanoid") if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end end
	end)
end,stop=function(self) self.enabled=false if self.connection then self.connection:Disconnect() self.connection=nil end end}

-- 6. 視界強化
AIModules.VisionEnhancer={enabled=false,originalFog=0,originalBrightness=1,
start=function(self) self.enabled=true self.originalFog=Lighting.FogEnd self.originalBrightness=Lighting.Brightness Lighting.FogEnd=100000 Lighting.Brightness=2 end,
stop=function(self) self.enabled=false Lighting.FogEnd=self.originalFog Lighting.Brightness=self.originalBrightness end}

-- 7. 自動収集
AIModules.AutoCollect={enabled=false,range=50,
start=function(self)
	self.enabled=true
	spawn(function()
		while self.enabled do
			wait(0.5)
			local char=player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local pos=char.HumanoidRootPart.Position
				for _,obj in pairs(workspace:GetDescendants()) do
					if obj:IsA("Part") and (obj.Name=="Coin" or obj.Name=="Gem" or obj.Name:find("Coin")) and obj.CanCollide then
						local d=(pos-obj.Position).Magnitude
						if d<=self.range then obj.CFrame=char.HumanoidRootPart.CFrame end
					end
				end
			end
		end
	end)
end,stop=function(self) self.enabled=false end}

-- 8. フライ
AIModules.Fly={enabled=false,speed=50,connection=nil,bodyVelocity=nil,bodyGyro=nil,
start=function(self)
	self.enabled=true
	local char=player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		local root=char.HumanoidRootPart
		self.bodyVelocity=Instance.new("BodyVelocity")
		self.bodyVelocity.MaxForce=Vector3.new(9e9,9e9,9e9)
		self.bodyVelocity.Velocity=Vector3.new(0,0,0)
		self.bodyVelocity.Parent=root
		self.bodyGyro=Instance.new("BodyGyro")
		self.bodyGyro.MaxTorque=Vector3.new(9e9,9e9,9e9)
		self.bodyGyro.P=9e4
		self.bodyGyro.Parent=root
		self.connection=RunService.RenderStepped:Connect(function()
			if self.enabled then
				local cam=workspace.CurrentCamera
				local moveDir=Vector3.new(0,0,0)
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir+=cam.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir-=cam.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir-=cam.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir+=cam.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir+=Vector3.new(0,1,0) end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir-=Vector3.new(0,1,0) end
				self.bodyVelocity.Velocity=moveDir*self.speed
				self.bodyGyro.CFrame=cam.CFrame
			end
		end)
	end
end,
stop=function(self)
	self.enabled=false
	if self.connection then self.connection:Disconnect() self.connection=nil end
	if self.bodyVelocity then self.bodyVelocity:Destroy() self.bodyVelocity=nil end
	if self.bodyGyro then self.bodyGyro:Destroy() self.bodyGyro=nil end
end}

-- 9. 自動回避
AIModules.AutoDodge={enabled=false,dodgeDistance=10,
start=function(self)
	self.enabled=true
	spawn(function()
		while self.enabled do
			wait(0.1)
			local char=player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local root=char.HumanoidRootPart
				local hum=char:FindFirstChildOfClass("Humanoid")
				for _,obj in pairs(workspace:GetDescendants()) do
					if obj:IsA("Part") and (obj.Name:lower():find("danger") or obj.Name:lower():find("trap") or obj.Name:lower():find("lava")) then
						local distance=(root.Position-obj.Position).Magnitude
						if distance<self.dodgeDistance and hum then hum:Move((root.Position-obj.Position).Unit) end
					end
				end
			end
		end
	end)
end,
stop=function(self) self.enabled=false end}

-- 10. 自動照準
AIModules.AutoAim={enabled=false,
start=function(self)
	self.enabled=true
	spawn(function()
		while self.enabled do
			wait(0.1)
			local char=player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local nearest=nil
				local nearestDist=math.huge
				for _,p in pairs(Players:GetPlayers()) do
					if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
						local h=p.Character:FindFirstChildOfClass("Humanoid")
						if h and h.Health>0 then
							local d=(char.HumanoidRootPart.Position-p.Character.HumanoidRootPart.Position).Magnitude
							if d<nearestDist then nearestDist=d nearest=p.Character end
						end
					end
				end
				if nearest and workspace.CurrentCamera then
					workspace.CurrentCamera.CFrame=CFrame.new(workspace.CurrentCamera.CFrame.Position,nearest.HumanoidRootPart.Position)
				end
			end
		end
	end)
end,stop=function(self) self.enabled=false end}

-- 11. リソース監視
AIModules.ResourceMonitor={enabled=false,stats={fps=0,ping=0,memory=0},
start=function(self)
	self.enabled=true
	spawn(function()
		while self.enabled do
			wait(1)
			local last=tick()
			RunService.RenderStepped:Wait()
			self.stats.fps=math.floor(1/(tick()-last))
			self.stats.ping=math.floor(player:GetNetworkPing()*1000)
			self.stats.memory=math.floor(collectgarbage("count")/1024)
		end
	end)
end,
stop=function(self) self.enabled=false end}

-- 12. ウォールハック
AIModules.Wallhack={enabled=false,highlights={},
start=function(self)
	self.enabled=true
	spawn(function()
		while self.enabled do
			wait(0.5)
			for _,p in pairs(Players:GetPlayers()) do
				if p~=player and p.Character then
					if not self.highlights[p.UserId] then
						local hl=Instance.new("Highlight")
						hl.FillColor=Color3.fromRGB(255,0,0)
						hl.OutlineColor=Color3.fromRGB(255,255,0)
						hl.FillTransparency=0.5
						hl.OutlineTransparency=0
						hl.Parent=p.Character
						self.highlights[p.UserId]=hl
					end
				end
			end
		end
	end)
end,
stop=function(self)
	self.enabled=false
	for _,hl in pairs(self.highlights) do if hl then hl:Destroy() end end
	self.highlights={}
end}

-- 13. 無敵モード
AIModules.GodMode={enabled=false,connection=nil,
start=function(self)
	self.enabled=true
	local char=player.Character
	if char then
		local hum=char:FindFirstChildOfClass("Humanoid")
		if hum then
			self.connection=hum.HealthChanged:Connect(function()
				if self.enabled then hum.Health=hum.MaxHealth end
			end)
		end
	end
end,
stop=function(self)
	self.enabled=false
	if self.connection then self.connection:Disconnect() self.connection=nil end
end}

-- ==================== タブにUI追加 ====================

local function addToggle(tabFrame,name,module,posY)
	local btn=Instance.new("TextButton")
	btn.Size=UDim2.new(0,200,0,30)
	btn.Position=UDim2.new(0,10,0,posY)
	btn.BackgroundColor3=Color3.fromRGB(50,50,50)
	btn.TextColor3=Color3.fromRGB(255,255,255)
	btn.Font=Enum.Font.GothamBold
	btn.TextSize=16
	btn.Text=name..": OFF"
	btn.Parent=tabFrame
	local enabled=false
	btn.MouseButton1Click:Connect(function()
		enabled=not enabled
		btn.Text=name..": "..(enabled and "ON" or "OFF")
		if enabled then module:start() else module:stop() end
	end)
end

-- ホームタブ
do
	local frame=TabFrames["🏠 ホーム"]
	local label=Instance.new("TextLabel")
	label.Size=UDim2.new(1,0,1,0)
	label.Text="ようこそ! AI Control Hub へ\n13個のAI機能を搭載しています。"
	label.TextColor3=Color3.fromRGB(255,255,255)
	label.Font=Enum.Font.GothamBold
	label.TextScaled=true
	label.BackgroundTransparency=1
	label.Parent=frame
end

-- 戦闘
do
	local frame=TabFrames["⚔️ 戦闘"]
	addToggle(frame,"自動照準",AIModules.AutoAim,10)
	addToggle(frame,"敵検出",AIModules.EnemyDetector,50)
	addToggle(frame,"自動回避",AIModules.AutoDodge,90)
	addToggle(frame,"ウォールハック",AIModules.Wallhack,130)
	addToggle(frame,"無敵モード",AIModules.GodMode,170)
end

-- 移動
do
	local frame=TabFrames["🏃 移動"]
	addToggle(frame,"スピードブースト",AIModules.SpeedBoost,10)
	addToggle(frame,"無限ジャンプ",AIModules.InfiniteJump,50)
	addToggle(frame,"フライモード",AIModules.Fly,90)
	addToggle(frame,"自動ジャンプ",AIModules.AutoJump,130)
end

-- 視界
do
	local frame=TabFrames["👁️ 視界"]
	addToggle(frame,"視界強化",AIModules.VisionEnhancer,10)
end

-- 自動化
do
	local frame=TabFrames["🤖 自動化"]
	addToggle(frame,"自動回復",AIModules.AutoHeal,10)
	addToggle(frame,"自動収集",AIModules.AutoCollect,50)
end

-- 設定
do
	local frame=TabFrames["⚙️ 設定"]
	local reloadBtn=Instance.new("TextButton")
	reloadBtn.Size=UDim2.new(0,200,0,30)
	reloadBtn.Position=UDim2.new(0,10,0,10)
	reloadBtn.BackgroundColor3=Color3.fromRGB(50,50,50)
	reloadBtn.TextColor3=Color3.fromRGB(255,255,255)
	reloadBtn.Font=Enum.Font.GothamBold
	reloadBtn.TextSize=16
	reloadBtn.Text="UIを再読み込み"
	reloadBtn.Parent=frame
	reloadBtn.MouseButton1Click:Connect(function()
		UI:Destroy()
		wait(0.5)
		loadstring(game:HttpGet('https://pastebin.com/raw/xxxxxx'))() -- ここは自身の再ロードURL
	end)
end

print("✨ AI Control Hub 起動完了 (KRNL / Rayfield風)")
