-- TDS-Engine/Network.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteFunction = ReplicatedStorage:WaitForChild("RemoteFunction", 15)

local Network = {}

function Network:Invoke(category, action, ...)
    if not RemoteFunction then
        warn("[Network] RemoteFunction bulunamadı!")
        return false, nil
    end

    local args = { ... }
    local ok, res = pcall(function()
        return RemoteFunction:InvokeServer(category, action, table.unpack(args))
    end)
    
    return ok, res
end

function Network:PlaceTower(towerName, position)
    return self:Invoke("Towers", "Place", towerName, position, 0)
end

function Network:UpgradeTower(towerInstance)
    return self:Invoke("Towers", "Upgrade", "Upgrade", { ["Tower"] = towerInstance })
end

function Network:SellTower(towerInstance)
    return self:Invoke("Towers", "Sell", { ["Tower"] = towerInstance })
end

function Network:SkipWave()
    return self:Invoke("Waves", "Skip")
end

return Network
