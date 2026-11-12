-- TDS-Engine/Network.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = {
    RemoteFunction = nil,
    RemoteEvent = nil,
    BackToLobbyRemote = nil
}

function Network:Init()
    self.RemoteFunction = ReplicatedStorage:FindFirstChild("RemoteFunction") or ReplicatedStorage:WaitForChild("RemoteFunction", 5)
    self.RemoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvent") or ReplicatedStorage:WaitForChild("RemoteEvent", 5)

    -- Lobiye dönüş event'i
    pcall(function()
        if ReplicatedStorage:FindFirstChild("Network") and ReplicatedStorage.Network:FindFirstChild("Teleport") then
            self.BackToLobbyRemote = ReplicatedStorage.Network.Teleport:FindFirstChild("RE:backToLobby")
        end
    end)
end

function Network:Invoke(category, action, ...)
    if not self.RemoteFunction then self:Init() end
    if not self.RemoteFunction then return false, "NoRemoteFunction" end

    local args = { ... }
    local ok, res = pcall(function()
        return self.RemoteFunction:InvokeServer(category, action, table.unpack(args))
    end)
    return ok, res
end

function Network:Fire(category, action, ...)
    if not self.RemoteEvent then self:Init() end
    if not self.RemoteEvent then return false end

    local args = { ... }
    pcall(function()
        self.RemoteEvent:FireServer(category, action, table.unpack(args))
    end)
    return true
end

-- 1. Kule Eylemleri (Troops yapısı)
function Network:PlaceTower(towerName, position, rotation)
    rotation = rotation or CFrame.new()
    local transformData = {
        ["Position"] = position,
        ["Rotation"] = rotation
    }
    return self:Invoke("Troops", "Place", transformData, towerName)
end

function Network:UpgradeTower(troopInstance)
    return self:Invoke("Troops", "Upgrade", "Set", { ["Troop"] = troopInstance })
end

function Network:SellTower(troopInstance)
    return self:Invoke("Troops", "Sell", "Set", { ["Troop"] = troopInstance })
end

function Network:SetTarget(troopInstance, targetType)
    return self:Invoke("Troops", "Target", "Set", { ["Troop"] = troopInstance, ["Target"] = targetType })
end

function Network:UseAbility(troopInstance, abilityName)
    return self:Invoke("Troops", "Abilities", "Use", { ["Troop"] = troopInstance, ["Ability"] = abilityName })
end

-- 2. Dalga Atlama (Voting -> Skip)
function Network:SkipWave()
    return self:Invoke("Voting", "Skip")
end

-- 3. Hotbar Seçimi
function Network:SelectHotbar(slotIndex)
    return self:Fire("Hotbar", "Click", slotIndex)
end

-- 4. Lobi Envanter Donatımı
function Network:EquipTower(towerName)
    return self:Fire("Inventory", "Equip", "Tower", towerName)
end

function Network:UnequipTower(towerName)
    return self:Fire("Inventory", "Unequip", "Tower", towerName)
end

-- 5. Lobiye Dönüş
function Network:BackToLobby()
    if self.BackToLobbyRemote then
        pcall(function() self.BackToLobbyRemote:FireServer() end)
    else
        game:GetService("TeleportService"):Teleport(3260590327, game:GetService("Players").LocalPlayer)
    end
end

Network:Init()
return Network
