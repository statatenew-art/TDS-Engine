-- TDS-Engine/Features.lua
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local Features = {}

function Features:Init(Config, Network)
    -- 1. Anti-AFK ve Idled Engelleme
    task.spawn(function()
        LocalPlayer.Idled:Connect(function()
            if VirtualUser then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end
        end)
    end)

    -- 2. Ara Sahne Atlama (AutoSkipCutscenes)
    if Config.AutoSkipCutscenes then
        task.spawn(function()
            local camera = Workspace.CurrentCamera
            if camera then
                camera:GetPropertyChangedSignal("CameraType"):Connect(function()
                    if camera.CameraType == Enum.CameraType.Scriptable then
                        camera.CameraType = Enum.CameraType.Custom
                    end
                end)
            end
        end)
    end

    -- 3. Commander Otomatik Zincirleme (AutoChain)
    if Config.AutoChain then
        task.spawn(function()
            while true do
                task.wait(1)
                local towers = Workspace:FindFirstChild("Towers")
                if towers then
                    local commanders = {}
                    for _, t in ipairs(towers:GetChildren()) do
                        if t.Name == "Commander" and t:FindFirstChild("Owner") and t.Owner.Value == LocalPlayer.UserId then
                            local lvl = t:FindFirstChild("Upgrade") or t:FindFirstChild("Level")
                            if lvl and lvl.Value >= 2 then
                                table.insert(commanders, t)
                            end
                        end
                    end

                    for _, cmdr in ipairs(commanders) do
                        Network:Invoke("Towers", "ApplyAbility", { ["Tower"] = cmdr, ["Ability"] = "Call to Arms" })
                        task.wait(10.05)
                    end
                end
            end
        end)
    end

    -- 4. Haritadaki Eşyaları Toplama (AutoPickups)
    if Config.AutoPickups then
        task.spawn(function()
            local pickups = Workspace:WaitForChild("Pickups", 10)
            if pickups then
                pickups.ChildAdded:Connect(function(drop)
                    task.wait(0.1)
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") and drop:IsA("BasePart") then
                        Network:Invoke("Pickups", "Collect", drop)
                    end
                end)
            end
        end)
    end
end

return Features
