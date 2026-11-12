-- TDS-Engine/Lobby.lua
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local Lobby = {
    TargetMode = "Survival",
    TargetDifficulty = "Easy"
}

-- Executor uyumlu güvenli GUI tıklama fonksiyonu
local function ClickButton(btn)
    if not btn then return false end
    
    -- 1. firesignal ile UI eventlerini ateşle
    if type(firesignal) == "function" then
        pcall(function()
            if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                firesignal(btn.MouseButton1Down)
                firesignal(btn.MouseButton1Click)
                firesignal(btn.MouseButton1Up)
                firesignal(btn.Activated)
            end
        end)
        return true
    end

    -- 2. VirtualUser ile koordinat tıklaması
    if VirtualUser and btn.AbsolutePosition and btn.AbsoluteSize then
        local center = btn.AbsolutePosition + (btn.AbsoluteSize / 2)
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(center.X, center.Y))
        return true
    end

    return false
end

-- Belirli bir metni veya ismi taşıyan görünür butonu bulur
local function FindAndClickButton(keyword)
    local pGui = LocalPlayer:WaitForChild("PlayerGui", 10)
    if not pGui then return false end

    keyword = keyword:lower()
    for _, desc in ipairs(pGui:GetDescendants()) do
        if (desc:IsA("TextButton") or desc:IsA("ImageButton")) and desc.Visible then
            local textMatch = (desc:IsA("TextButton") and desc.Text:lower():find(keyword))
            local nameMatch = desc.Name:lower():find(keyword)

            if textMatch or nameMatch then
                print(string.format("[Lobby] '%s' butonu bulundu ve tıklandı.", keyword))
                ClickButton(desc)
                return true
            end
        end
    end
    return false
end

function Lobby:Init(Config, Network)
    print("[Lobby] Yeni Matchmaking & Solo Oda Yöneticisi başlatıldı.")
    
    self.TargetMode = Config.TargetMode or "Survival"
    self.TargetDifficulty = Config.TargetDifficulty or "Easy"

    task.spawn(function()
        task.wait(2.5)

        -- 1. ADIM: Yeşil PLAY Butonuna Bas
        print("[Lobby] 1. Adım: PLAY butonuna basılıyor...")
        local playClicked = FindAndClickButton("play")
        task.wait(1.5)

        -- 2. ADIM: Mod Seçimi (Survival)
        print(string.format("[Lobby] 2. Adım: '%s' modu aranıyor...", self.TargetMode))
        FindAndClickButton(self.TargetMode)
        task.wait(1.2)

        -- 3. ADIM: Zorluk Seçimi (Easy / Molten / Fallen)
        print(string.format("[Lobby] 3. Adım: '%s' zorluğu aranıyor...", self.TargetDifficulty))
        FindAndClickButton(self.TargetDifficulty)
        task.wait(1.2)

        -- 4. ADIM: Solo / Create Butonuna Bas
        print("[Lobby] 4. Adım: 'Solo' veya 'Create' aranıyor...")
        local soloClicked = FindAndClickButton("solo") or FindAndClickButton("create")
        task.wait(1)

        -- 5. ADIM (GÜVENCE): Apex Loglarındaki Resmi Solo Oluşturma Remote'u
        -- UI tıklaması bir gecikme yaşarsa doğrudan sunucuya solo maçı başlatma emri gönderir
        print("[Lobby] 5. Adım: Ağ katmanından 'single_create' çağrısı ile maça aktarılıyor...")
        Network:Invoke("Multiplayer", "single_create")
    end)
end

return Lobby
