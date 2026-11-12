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

-- 1. Ayarları Yükle
local Config = LoadModule("Config.lua")

-- 2. Logger Başlat
local Logger = LoadModule("Logger.lua")
Logger:Init(Config)

-- 3. Ağ Katmanını Yükle
local Network = LoadModule("Network.lua")

-- 4. Ortam Tespiti: Lobi mi, Maç içi mi?
local isLobby = (PlaceId == 3260590327 or PlaceId == 5591597781)

if isLobby then
    local Lobby = LoadModule("Lobby.lua")
    Lobby:Init(Config, Network)
    shared.TDSTable = {}
    return shared.TDSTable
end

-- 5. Maç İçi: Otomasyonlar ve Çekirdek Motor
local Features = LoadModule("Features.lua")
Features:Init(Config, Network)

local Engine = LoadModule("Engine.lua")
Engine:Init(Config, Network)

shared.TDSTable = Engine
return shared.TDSTable
