-- TDS-Engine/Loader.lua
local PlaceId = game.PlaceId
local BASE_URL = "https://raw.githubusercontent.com/statatenew-art/TDS-Engine/main/"

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

print("[Loader] TDS-Engine başlatılıyor...")

-- 1. Ayarlar, Logger, Ağ ve Veri Katmanları
local Config = LoadModule("Config.lua")
local Logger = LoadModule("Logger.lua")
Logger:Init(Config)

local Network = LoadModule("Network.lua")
local Data = LoadModule("Data.lua")
Data:Init()

-- 2. Lobi Kontrolü
local isLobby = (PlaceId == 3260590327 or PlaceId == 5591597781)
if isLobby then
    print("[Loader] Lobi modu devrede.")
    local Lobby = LoadModule("Lobby.lua")
    Lobby:Init(Config, Network)
    shared.TDSTable = {}
    return shared.TDSTable
end

-- 3. Maç İçi: Motor ve UI Entegrasyonu
local Engine = LoadModule("Engine.lua")
local UI = LoadModule("UI.lua")

-- UI ve Engine'i çapraz bağla
Engine:Init(Config, Network, Data, UI)
UI:Init(Config, Engine)

local Features = LoadModule("Features.lua")
Features:Init(Config, Network, Data)

shared.TDSTable = Engine
return shared.TDSTable
