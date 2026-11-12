-- TDS-Engine/Loader.lua
local PlaceId = game.PlaceId
local BASE_URL = "https://raw.githubusercontent.com/statatenew-art/TDS-Engine/main/"

-- Modülleri GitHub üzerinden dinamik ve cache'siz çeken fonksiyon
local function LoadModule(fileName)
    local url = BASE_URL .. fileName .. "?t=" .. tick()
    local success, content = pcall(game.HttpGet, game, url)

    if not success or not content then
        error(string.format("[Loader] Modül çekilemedi: %s (Hata: %s)", fileName, tostring(content)))
    end

    local func, err = loadstring(content)
    if not func then
        error(string.format("[Loader] Syntax hatası (%s): %s", fileName, tostring(err)))
    end

    return func()
end

print("[Loader] TDS-Engine modülleri yükleniyor...")

-- 1. Ayarları Yükle
local Config = LoadModule("Config.lua")

-- 2. Logger Başlat (Disk/konsol temizliği ve hata kayıtları)
local Logger = LoadModule("Logger.lua")
Logger:Init(Config)

-- 3. Ağ Katmanını Yükle (RemoteFunction / RemoteEvent paketleyici)
local Network = LoadModule("Network.lua")

-- 4. Veri ve Durum Yöneticisini Yükle (Kule, Düşman, Bakiye, Dalga)
local Data = LoadModule("Data.lua")
Data:Init()

-- 5. Ortam Tespiti: Lobi mi, Maç İçi mi?
-- 3260590327: TDS Ana Lobi, 5591597781: Özel/Eski Lobi
local isLobby = (PlaceId == 3260590327 or PlaceId == 5591597781)

if isLobby then
    print("[Loader] Lobi tespit edildi. Asansör ve kuyruk yöneticisi başlatılıyor.")
    local Lobby = LoadModule("Lobby.lua")
    Lobby:Init(Config, Network)
    
    shared.TDSTable = {}
    return shared.TDSTable
end

-- 6. Maç İçi: Yardımcı Özellikler ve Strateji Motoru
print("[Loader] Maç ortamı tespit edildi. Motor ve otomasyonlar başlatılıyor.")

local Features = LoadModule("Features.lua")
Features:Init(Config, Network, Data)

local Engine = LoadModule("Engine.lua")
Engine:Init(Config, Network, Data)

-- Strateji dosyalarının doğrudan erişebilmesi için global tabloya bağla
shared.TDSTable = Engine
return shared.TDSTable
