-- KRNL対応シンプルUIテスト
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KRNLTestUI"
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 150)
Frame.Position = UDim2.new(0.5, -125, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.Parent = ScreenGui

local TextLabel = Instance.new("TextLabel")
TextLabel.Size = UDim2.new(1, 0, 0, 50)
TextLabel.BackgroundTransparency = 1
TextLabel.Text = "KRNL UI TEST"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextScaled = true
TextLabel.Parent = Frame

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(1, -20, 0, 40)
Button.Position = UDim2.new(0, 10, 0, 70)
Button.Text = "Click Me"
Button.Parent = Frame

Button.MouseButton1Click:Connect(function()
    TextLabel.Text = "ボタンが押されました！"
end)
