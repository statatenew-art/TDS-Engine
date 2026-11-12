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

-- 3. Ortam Kontrolü (Lobi / Maç)
local isLobby = (PlaceId == 3260590327 or PlaceId == 5591597781)

if isLobby then
    print("[Loader] Lobi modu devrede. Asansör yöneticisi başlatılıyor...")
    local Lobby = LoadModule("Lobby.lua")
    Lobby:Init(Config, Network)
    
    -- Strat dosyası lobide erken çağrılsa bile metotlar nil vermesin diye Engine dönülür
    shared.TDSTable = Engine
    return shared.TDSTable
end

print("[Loader] Maç modu devrede. Strateji motoru hazır.")
shared.TDSTable = Engine
return shared.TDSTable
