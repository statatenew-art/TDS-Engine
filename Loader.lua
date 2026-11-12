-- TDS-Engine/Loader.lua
local PlaceId = game.PlaceId
local BASE_URL = "https://raw.githubusercontent.com/statatenew-art/TDS-Engine/main/"

local function LoadModule(fileName)
    local url = BASE_URL .. fileName .. "?t=" .. tick()
    local success, content = pcall(function()
        return game:HttpGet(url)
    end)

    if not success or not content or content == "" then
        error(string.format("[Loader] Modül çekilemedi: %s (Hata: %s)", fileName, tostring(content)))
    end

    local func, err = loadstring(content)
    if not func then
        error(string.format("[Loader] Syntax hatası (%s): %s", fileName, tostring(err)))
    end

    return func()
end

print("[Loader] TDS-Engine başlatılıyor...")

-- 1. Temel Katmanlar: Config, Logger, Network, Data
local Config = LoadModule("Config.lua")

local Logger = LoadModule("Logger.lua")
Logger:Init(Config)

local Network = LoadModule("Network.lua")

local Data = LoadModule("Data.lua")
Data:Init()

-- 2. Motor ve UI Katmanları
local Engine = LoadModule("Engine.lua")
local UI = LoadModule("UI.lua")

Engine:Init(Config, Network, Data, UI)
UI:Init(Config, Engine)

local Features = LoadModule("Features.lua")
Features:Init(Config, Network, Data)

-- 3. Ortam Kontrolü
-- 3260590327: Ana Lobi
-- 5591597781: Oyun / Maç Alanı
local isLobby = (PlaceId == 3260590327)

if isLobby then
    print("[Loader] Ana lobi tespit edildi (PlaceId: 3260590327). Kuyruk yöneticisi aktif.")
    local Lobby = LoadModule("Lobby.lua")
    Lobby:Init(Config, Network)
    
    shared.TDSTable = Engine
    return shared.TDSTable
end

print(string.format("[Loader] Maç alanı tespit edildi (PlaceId: %d). Strateji motoru devrede!", PlaceId))
shared.TDSTable = Engine
return shared.TDSTable
