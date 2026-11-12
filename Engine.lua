-- TDS-Engine/Engine.lua
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local Engine = {
    Towers = {},
    TotalTowerCount = 0
}

function Engine:Init(Config, Network)
    self.Network = Network
    self.Config = Config

    -- Maç Sonu Takibi ve Lobiye Dönüş
    task.spawn(function()
        local gui = LocalPlayer:WaitForChild("PlayerGui", 15)
        while true do
            task.wait(1)
            local over = gui and (gui:FindFirstChild("GameOver") or gui:FindFirstChild("Victory"))
            local health = Workspace:FindFirstChild("Health")
            if (over and over.Visible) or (health and health.Value <= 0) then
                print("[Engine] Oyun sonlandı, lobiye dönülüyor...")
                task.wait(3)
                TeleportService:Teleport(3260590327, LocalPlayer)
                break
            end
        end
    end)
end

function Engine:Loadout(...) print("[Engine] Loadout:", ...) end
function Engine:Mode(m) print("[Engine] Mod:", m) end
function Engine:GameInfo(...) end

function Engine:VoteSkip(wave)
    self.Network:SkipWave()
end

function Engine:Place(towerName, x, y, z)
    local position = Vector3.new(x, y, z)
    self.TotalTowerCount = self.TotalTowerCount + 1
    local id = self.TotalTowerCount

    local towersFolder = Workspace:WaitForChild("Towers", 10)
    if not towersFolder then
        warn("[Engine] Towers klasörü bulunamadı!")
        return nil
    end

    local existing = {}
    for _, t in ipairs(towersFolder:GetChildren()) do
        existing[t] = true
    end

    local spawnedTower = nil
    local retries = 0
    local maxRetries = 15

    repeat
        retries = retries + 1
        self.Network:PlaceTower(towerName, position)
        task.wait(0.3)

        for _, t in ipairs(towersFolder:GetChildren()) do
            if not existing[t] and t:IsA("Model") then
                local owner = t:FindFirstChild("Owner")
                if not owner or owner.Value == LocalPlayer.UserId then
                    spawnedTower = t
                    break
                end
            end
        end
    until spawnedTower or retries >= maxRetries

    if spawnedTower then
        self.Towers[id] = spawnedTower
        print(string.format("[Engine] Kule [#%d] (%s) yerleştirildi.", id, towerName))
    else
        warn(string.format("[Engine] Kule [#%d] (%s) yerleştirilemedi! (Yetersiz bakiye veya geçersiz pozisyon)", id, towerName))
    end

    return id
end

function Engine:Upgrade(towerIndex)
    local waitCount = 0
    while not self.Towers[towerIndex] and waitCount < 30 do
        task.wait(0.1)
        waitCount = waitCount + 1
    end

    local tower = self.Towers[towerIndex]
    if not tower or not tower.Parent then 
        warn(string.format("[Engine] Yükseltilecek kule [#%d] bulunamadı.", towerIndex))
        return 
    end

    local levelVal = tower:FindFirstChild("Upgrade") or tower:FindFirstChild("Level")
    local startLvl = levelVal and levelVal.Value or 0
    local upgraded = false
    local attempts = 0

    repeat
        attempts = attempts + 1
        self.Network:UpgradeTower(tower)
        task.wait(0.4)

        if levelVal and levelVal.Value > startLvl then
            upgraded = true
        end
    until upgraded or attempts >= 10

    if upgraded then
        print(string.format("[Engine] Kule [#%d] yükseltildi (Yeni Seviye: %s).", towerIndex, tostring(levelVal and levelVal.Value)))
    else
        warn(string.format("[Engine] Kule [#%d] yükseltilemedi (Yetersiz para veya gecikme).", towerIndex))
    end
end

function Engine:Sell(towerIndex)
    local tower = self.Towers[towerIndex]
    if tower and tower.Parent then
        self.Network:SellTower(tower)
        self.Towers[towerIndex] = nil
        print(string.format("[Engine] Kule [#%d] satıldı.", towerIndex))
    end
end

return Engine
