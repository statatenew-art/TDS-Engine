-- TDS-Engine/Data.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Data = {
    TowerDefinitions = {}, -- Oyunun kendi modüllerinden çekilen statik kule bilgileri
    IsInitialized = false
}

-- 1. Statik Kule Bilgilerini Oyunun Kendi Modüllerinden Çekme
function Data:CacheGameData()
    task.spawn(function()
        -- TDS kule tanımlarının bulunduğu olası klasörler
        local towerModules = ReplicatedStorage:FindFirstChild("Towers") 
            or (ReplicatedStorage:FindFirstChild("Common") and ReplicatedStorage.Common:FindFirstChild("Towers"))
        
        if towerModules then
            for _, mod in ipairs(towerModules:GetChildren()) do
                if mod:IsA("ModuleScript") then
                    local ok, def = pcall(require, mod)
                    if ok and type(def) == "table" then
                        Data.TowerDefinitions[mod.Name] = def
                    end
                end
            end
            print(string.format("[Data] %d adet kule tanımı önbelleğe alındı.", self:GetTableLength(Data.TowerDefinitions)))
        else
            warn("[Data] Kule tanımları ReplicatedStorage içinde bulunamadı, dinamik mod devrede.")
        end
        self.IsInitialized = true
    end)
end

function Data:GetTableLength(tbl)
    local c = 0
    for _ in pairs(tbl) do c = c + 1 end
    return c
end

-- 2. Dinamik Oyuncu Verisi: Mevcut Bakiye (Cash)
function Data:GetCash()
    -- Liderlik tablosu kontrolü
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats and leaderstats:FindFirstChild("Cash") then
        return leaderstats.Cash.Value
    end

    -- State/ReplicatedStorage kontrolü
    local state = ReplicatedStorage:FindFirstChild("State")
    if state and state:FindFirstChild("Coins") then
        return state.Coins.Value
    end

    return 0
end

-- 3. Dinamik Oyun Verisi: Mevcut Dalga (Wave)
function Data:GetWave()
    local waveVal = Workspace:FindFirstChild("Wave") 
        or (ReplicatedStorage:FindFirstChild("State") and ReplicatedStorage.State:FindFirstChild("Wave"))
    
    if waveVal then
        return waveVal.Value
    end

    -- UI üzerinden okuma yedeği
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local waveGui = playerGui:FindFirstChild("WaveGui") or playerGui:FindFirstChild("TopBar")
        -- Oyun içi UI hiyerarşisine göre metin ayıklanabilir
    end

    return 0
end

-- 4. Düşman (NPC) Analitiği
function Data:GetEnemies()
    local enemies = {}
    local npcFolder = Workspace:FindFirstChild("NPCs")
    
    if npcFolder then
        for _, npc in ipairs(npcFolder:GetChildren()) do
            if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
                table.insert(enemies, {
                    Instance = npc,
                    Name = npc.Name,
                    Health = npc.Humanoid.Health,
                    MaxHealth = npc.Humanoid.MaxHealth,
                    Position = npc.HumanoidRootPart.Position
                })
            end
        end
    end
    
    return enemies
end

-- 5. Kule Yükseltme / Satın Alma Maliyeti Sorgulama
function Data:GetTowerCost(towerName, level)
    level = level or 0
    local def = self.TowerDefinitions[towerName]
    if def and def.Upgrades and def.Upgrades[level] then
        return def.Upgrades[level].Cost or 0
    end
    return nil -- Bilinmiyorsa nil döner
end

function Data:Init()
    self:CacheGameData()
    print("[Data] Veri ve durum yöneticisi yüklendi.")
end

return Data
