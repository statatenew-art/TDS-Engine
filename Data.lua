-- TDS-Engine/Data.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Data = {
    TowerDefinitions = {},
    IsInitialized = false
}

function Data:CacheGameData()
    task.spawn(function()
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
        end
        self.IsInitialized = true
    end)
end

function Data:GetTableLength(tbl)
    local c = 0
    for _ in pairs(tbl) do c = c + 1 end
    return c
end

-- Bakiye Okuyucu: Çok Katmanlı Kontrol
function Data:GetCash()
    -- 1. Liderlik Tablosu
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats and leaderstats:FindFirstChild("Cash") then
        return leaderstats.Cash.Value
    end

    -- 2. ReplicatedStorage State
    local state = ReplicatedStorage:FindFirstChild("State")
    if state and state:FindFirstChild("Coins") then
        return state.Coins.Value
    end

    -- 3. Oyuncu Değerleri
    local cashVal = LocalPlayer:FindFirstChild("Cash")
    if cashVal and cashVal:IsA("ValueBase") then
        return cashVal.Value
    end

    return 0
end

-- Dalga Okuyucu: Çok Katmanlı Kontrol
function Data:GetWave()
    -- 1. Workspace kontrolü
    local waveVal = Workspace:FindFirstChild("Wave") 
        or (ReplicatedStorage:FindFirstChild("State") and ReplicatedStorage.State:FindFirstChild("Wave"))
    
    if waveVal and waveVal:IsA("ValueBase") then
        return waveVal.Value
    end

    -- 2. Replicated ReplicatedVariables
    local replicatedVars = ReplicatedStorage:FindFirstChild("ReplicatedVariables")
    if replicatedVars and replicatedVars:FindFirstChild("Wave") then
        return replicatedVars.Wave.Value
    end

    -- 3. UI Üzerinden Okuma
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        local topBar = pGui:FindFirstChild("TopBar") or pGui:FindFirstChild("WaveGui")
        if topBar then
            local waveText = topBar:FindFirstChild("WaveText", true) or topBar:FindFirstChild("Wave", true)
            if waveText and waveText:IsA("TextLabel") then
                local w = tonumber(waveText.Text:match("%d+"))
                if w then return w end
            end
        end
    end

    return 0
end

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

function Data:Init()
    self:CacheGameData()
    print("[Data] Veri ve durum yöneticisi aktif.")
end

return Data
