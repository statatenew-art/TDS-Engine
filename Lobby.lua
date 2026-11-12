-- TDS-Engine/Lobby.lua
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Lobby = {}

function Lobby:Init(Config, Network)
    print("[Lobby] Asansör yöneticisi başlatıldı.")
    task.spawn(function()
        task.wait(2)
        local elevators = Workspace:WaitForChild("Elevators", 15)
        if not elevators then 
            warn("[Lobby] Elevators klasörü bulunamadı.")
            return 
        end
        
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart", 10)
        if not root then return end
        
        for _, elev in ipairs(elevators:GetChildren()) do
            local zone = elev:FindFirstChild("Enter") or elev:FindFirstChild("Zone") or elev.PrimaryPart
            if zone then
                root.CFrame = zone.CFrame + Vector3.new(0, 2, 0)
                print("[Lobby] Hedef asansör kabinine giriş yapıldı.")
                break
            end
        end
    end)
end

return Lobby
