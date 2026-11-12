-- TDS-Engine/UI.lua
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local UI = {
    ScreenGui = nil,
    MainFrame = nil,
    StatusLabel = nil,
    WaveLabel = nil,
    TowerCountLabel = nil,
    PauseButton = nil,
    Config = nil,
    Engine = nil
}

function UI:Init(Config, Engine)
    self.Config = Config
    self.Engine = Engine

    local oldUI = CoreGui:FindFirstChild("TDS_Engine_UI")
    if oldUI then oldUI:Destroy() end

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "TDS_Engine_UI"
    self.ScreenGui.ResetOnSpawn = false
    
    local parentTarget = (type(gethui) == "function" and gethui()) or CoreGui
    self.ScreenGui.Parent = parentTarget

    -- Ana Pencere
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 260, 0, 240)
    self.MainFrame.Position = UDim2.new(0.02, 0, 0.30, 0)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(20, 21, 27)
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = self.MainFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(45, 48, 62)
    stroke.Thickness = 1.5
    stroke.Parent = self.MainFrame

    -- Başlık
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 26)
    title.Position = UDim2.new(0, 10, 0, 6)
    title.BackgroundTransparency = 1
    title.Text = "⚡ TDS ENGINE"
    title.TextColor3 = Color3.fromRGB(115, 128, 236)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = self.MainFrame

    -- Bilgi Etiketleri
    self.WaveLabel = self:CreateLabel("Dalga: 0", 32)
    self.TowerCountLabel = self:CreateLabel("Kule Sayısı: 0", 52)

    -- Durum Kutusu
    self.StatusLabel = Instance.new("TextLabel")
    self.StatusLabel.Size = UDim2.new(1, -20, 0, 32)
    self.StatusLabel.Position = UDim2.new(0, 10, 0, 76)
    self.StatusLabel.BackgroundColor3 = Color3.fromRGB(14, 15, 20)
    self.StatusLabel.TextColor3 = Color3.fromRGB(70, 215, 145)
    self.StatusLabel.Font = Enum.Font.Gotham
    self.StatusLabel.TextSize = 10
    self.StatusLabel.Text = " Hazır"
    self.StatusLabel.TextWrapped = true
    self.StatusLabel.Parent = self.MainFrame

    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 6)
    statusCorner.Parent = self.StatusLabel

    -- 1. Pause / Resume Butonu
    self.PauseButton = Instance.new("TextButton")
    self.PauseButton.Size = UDim2.new(1, -20, 0, 28)
    self.PauseButton.Position = UDim2.new(0, 10, 0, 116)
    self.PauseButton.BackgroundColor3 = Color3.fromRGB(235, 87, 87)
    self.PauseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.PauseButton.Font = Enum.Font.GothamBold
    self.PauseButton.TextSize = 11
    self.PauseButton.Text = "BOTU DURAKLAT"
    self.PauseButton.Parent = self.MainFrame

    local pauseCorner = Instance.new("UICorner")
    pauseCorner.CornerRadius = UDim.new(0, 6)
    pauseCorner.Parent = self.PauseButton

    self.PauseButton.MouseButton1Click:Connect(function()
        if self.Engine then
            local isPaused = self.Engine:TogglePause()
            if isPaused then
                self.PauseButton.Text = "DEVAM ETTİR"
                self.PauseButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
                self:SetStatus("Bot duraklatıldı.")
            else
                self.PauseButton.Text = "BOTU DURAKLAT"
                self.PauseButton.BackgroundColor3 = Color3.fromRGB(235, 87, 87)
                self:SetStatus("Bot devam ediyor...")
            end
        end
    end)

    -- 2. Canlı Özellik Toggle Butonları (AutoSkip & AutoChain)
    self:CreateToggleButton("AutoSkip", 152, Config.AutoSkipCutscenes, function(state)
        Config.AutoSkipCutscenes = state
        self:SetStatus("AutoSkip: " .. (state and "Açık" or "Kapalı"))
    end)

    self:CreateToggleButton("AutoChain", 188, Config.AutoChain, function(state)
        Config.AutoChain = state
        self:SetStatus("AutoChain: " .. (state and "Açık" or "Kapalı"))
    end)

    self:MakeDraggable(self.MainFrame)
    print("[UI] Kontrol paneli yüklendi.")
end

function UI:CreateLabel(text, yPos)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 18)
    lbl.Position = UDim2.new(0, 10, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(180, 185, 200)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = self.MainFrame
    return lbl
end

function UI:CreateToggleButton(name, yPos, initialValue, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 26)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 10
    btn.Parent = self.MainFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local state = initialValue
    local function updateVisual()
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(40, 60, 100)
            btn.TextColor3 = Color3.fromRGB(130, 180, 255)
            btn.Text = name .. ": AKTİF"
        else
            btn.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
            btn.TextColor3 = Color3.fromRGB(120, 125, 140)
            btn.Text = name .. ": DEVRE DIŞI"
        end
    end

    updateVisual()

    btn.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
        callback(state)
    end)
end

function UI:SetStatus(text)
    if self.StatusLabel then self.StatusLabel.Text = " " .. tostring(text) end
end

function UI:SetWave(wave)
    if self.WaveLabel then self.WaveLabel.Text = string.format("Dalga: %s", tostring(wave)) end
end

function UI:SetTowerCount(count)
    if self.TowerCountLabel then self.TowerCountLabel.Text = string.format("Kule Sayısı: %s", tostring(count)) end
end

function UI:MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

return UI
