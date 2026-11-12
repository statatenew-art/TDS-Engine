-- TDS-Engine/Network.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = {
    RemoteFunction = nil,
    RemoteEvent = nil
}

-- TDS güncellemelerine karşı esnek Remote bulucu
function Network:Init()
    local candidates = {
        ReplicatedStorage:FindFirstChild("RemoteFunction"),
        ReplicatedStorage:FindFirstChild("Networking") and ReplicatedStorage.Networking:FindFirstChild("RemoteFunction"),
        ReplicatedStorage:FindFirstChild("Common") and ReplicatedStorage.Common:FindFirstChild("RemoteFunction")
    }

    for _, remote in ipairs(candidates) do
        if remote and remote:IsA("RemoteFunction") then
            self.RemoteFunction = remote
            break
        end
    end

    if not self.RemoteFunction then
        -- 5 saniye bekleme ile tekrar dene
        self.RemoteFunction = ReplicatedStorage:WaitForChild("RemoteFunction", 5)
    end

    if self.RemoteFunction then
        print("[Network] RemoteFunction başarıyla bağlandı:", self.RemoteFunction:GetFullName())
    else
        warn("[Network] UYARI: RemoteFunction bulunamadı! Yol değişmiş olabilir.")
    end
end

function Network:Invoke(category, action, ...)
    if not self.RemoteFunction then
        self:Init()
        if not self.RemoteFunction then
            return false, "NoRemoteFunction"
        end
    end

    local args = { ... }
    local ok, res = pcall(function()
        return self.RemoteFunction:InvokeServer(category, action, table.unpack(args))
    end)
    
    return ok, res
end

-- Temel Kule Eylemleri
function Network:PlaceTower(towerName, position)
    return self:Invoke("Towers", "Place", towerName, position, 0)
end

function Network:UpgradeTower(towerInstance)
    return self:Invoke("Towers", "Upgrade", "Upgrade", { ["Tower"] = towerInstance })
end

function Network:SellTower(towerInstance)
    return self:Invoke("Towers", "Sell", { ["Tower"] = towerInstance })
end

function Network:SetTarget(towerInstance, targetType)
    -- Target tipleri: "First", "Last", "Strongest", "Weakest", "Farthest"
    return self:Invoke("Towers", "Target", "Set", { ["Tower"] = towerInstance, ["Target"] = targetType })
end

function Network:UseAbility(towerInstance, abilityName)
    return self:Invoke("Towers", "ApplyAbility", { ["Tower"] = towerInstance, ["Ability"] = abilityName })
end

function Network:SkipWave()
    return self:Invoke("Waves", "Skip")
end

Network:Init()
return Network
