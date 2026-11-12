-- TDS-Engine/Engine.lua
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Engine = {
    Towers = {},
    TotalTowerCount = 0,
    Network = nil,
    Config = nil,
    Data = nil,
    UI = nil,
    IsPaused = false,
    LoadoutMap = {} -- Kulelerin slot indeksleri
}

function Engine:Init(Config, Network, Data, UI)
    self.Network = Network
    self.Config = Config
    self.Data = Data
    self.UI = UI

    -- Maç Sonu Takibi
    task.spawn(function()
        local gui = LocalPlayer:WaitForChild("PlayerGui", 15)
        while true do
            task.wait(1.5)
            local over = gui and (gui:FindFirstChild("GameOver") or gui:FindFirstChild("Victory"))
            local health = Workspace:FindFirstChild("Health")
            if (over and over.Visible) or (health and health.Value <= 0) then
                if self.UI then self.UI:SetStatus("Oyun bitti, lobiye dönülüyor...") end
                task.wait(3)
                self.Network:BackToLobby()
                break
            end
        end
    end)
    print("[Engine] Motor hazır.")
end

function Engine:TogglePause()
    self.IsPaused = not self.IsPaused
    return self.IsPaused
end

function Engine:CheckPause()
    while self.IsPaused do task.wait(0.5) end
end

function Engine:ApplyConfig(customConfig)
    if type(customConfig) ~= "table" then return end
    for k, v in pairs(customConfig) do
        self.Config[k] = v
    end
    if self.UI then self.UI:SetStatus("Özel strat ayarları yüklendi.") end
end

-- Loadout tanımlandığında kulelerin slot indekslerini eşler
function Engine:Loadout(...)
    local towers = { ... }
    for index, towerName in ipairs(towers) do
        self.LoadoutMap[towerName] = index
    end
    print("[Engine] Loadout eşlendi:", table.concat(towers, ", "))
end

function Engine:Mode(m) print("[Engine] Mod:", m) end
function Engine:GameInfo(...) end

function Engine:WaitForWave(targetWave)
    if self.UI then 
        self.UI:SetStatus(string.format("Dalga %d bekleniyor...", targetWave))
        self.UI:SetWave(targetWave)
    end
    while true do
        self:CheckPause()
        local cur = self.Data and self.Data:GetWave() or 0
        if cur >= targetWave then break end
        task.wait(0.4)
    end
end

function Engine:WaitForCash(targetCash)
    while true do
        self:CheckPause()
        local cur = self.Data and self.Data:GetCash() or 0
        if cur >= targetCash then break end
        task.wait(0.3)
    end
end

function Engine:VoteSkip()
    self:CheckPause()
    self.Network:SkipWave()
    if self.UI then self.UI:SetStatus("Skip oyu verildi.") end
end

function Engine:Place(towerName, x, y, z)
    self:CheckPause()
    local position = Vector3.new(x, y, z)
    self.TotalTowerCount = self.TotalTowerCount + 1
    local id = self.TotalTowerCount

    -- Gerekirse hotbar'da ilgili kule slotuna tıkla
    local slot = self.LoadoutMap[towerName]
    if slot then
        self.Network:SelectHotbar(slot)
        task.wait(0.1)
    end

    local towersFolder = Workspace:FindFirstChild("Towers") or Workspace:FindFirstChild("Troops")
    local existing = {}
    if towersFolder then
        for _, t in ipairs(towersFolder:GetChildren()) do existing[t] = true end
    end

    local spawnedTower = nil
    local retries = 0

    repeat
        self:CheckPause()
        retries = retries + 1
        self.Network:PlaceTower(towerName, position)
        task.wait(0.3)

        if towersFolder then
            for _, t in ipairs(towersFolder:GetChildren()) do
                if not existing[t] and t:IsA("Model") then
                    local owner = t:FindFirstChild("Owner")
                    if not owner or owner.Value == LocalPlayer.UserId then
                        spawnedTower = t
                        break
                    end
                end
            end
        end
    until spawnedTower or retries >= 15

    if spawnedTower then
        self.Towers[id] = spawnedTower
        if self.UI then
            self.UI:SetStatus(string.format("Kule [%d] (%s) konuldu.", id, towerName))
            self.UI:SetTowerCount(self.TotalTowerCount)
        end
    else
        warn(string.format("[Engine] Kule [#%d] (%s) yerleştirilemedi!", id, towerName))
    end

    return id
end

function Engine:Upgrade(towerIndex)
    self:CheckPause()
    local waitCount = 0
    while not self.Towers[towerIndex] and waitCount < 30 do
        self:CheckPause()
        task.wait(0.1)
        waitCount = waitCount + 1
    end

    local tower = self.Towers[towerIndex]
    if not tower or not tower.Parent then return end

    local levelVal = tower:FindFirstChild("Upgrade") or tower:FindFirstChild("Level")
    local startLvl = levelVal and levelVal.Value or 0
    local upgraded = false
    local attempts = 0

    repeat
        self:CheckPause()
        attempts = attempts + 1
        self.Network:UpgradeTower(tower)
        task.wait(0.35)

        if levelVal and levelVal.Value > startLvl then
            upgraded = true
        end
    until upgraded or attempts >= 10

    if upgraded and self.UI then
        self.UI:SetStatus(string.format("Kule [%d] yükseltildi.", towerIndex))
    end
end

function Engine:Sell(towerIndex)
    self:CheckPause()
    local tower = self.Towers[towerIndex]
    if tower and tower.Parent then
        self.Network:SellTower(tower)
        self.Towers[towerIndex] = nil
        if self.UI then self.UI:SetStatus(string.format("Kule [%d] satıldı.", towerIndex)) end
    end
end

function Engine:SetTarget(towerIndex, targetType)
    self:CheckPause()
    local tower = self.Towers[towerIndex]
    if tower and tower.Parent then
        self.Network:SetTarget(tower, targetType)
    end
end

function Engine:Ability(towerIndex, abilityName)
    self:CheckPause()
    local tower = self.Towers[towerIndex]
    if tower and tower.Parent then
        self.Network:UseAbility(tower, abilityName)
    end
end

return Engine
