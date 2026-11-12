-- TDS-Engine/Config.lua
local Config = {
    AutoReady = (getgenv().AutoReady ~= nil and getgenv().AutoReady) or true,
    AutoSkipCutscenes = (getgenv().AutoSkipCutscenes ~= nil and getgenv().AutoSkipCutscenes) or true,
    AutoChain = (getgenv().AutoChain ~= nil and getgenv().AutoChain) or true,
    AutoMedic = (getgenv().AutoMedic ~= nil and getgenv().AutoMedic) or false,
    AutoDJ = (getgenv().AutoDJ ~= nil and getgenv().AutoDJ) or true,
    AutoPickups = (getgenv().AutoPickups ~= nil and getgenv().AutoPickups) or true,
    ElevatorTarget = getgenv().ElevatorTarget or "Survival",
    AutoCleanLogs = (getgenv().AutoCleanLogs ~= nil and getgenv().AutoCleanLogs) or true,
    LogCleanInterval = getgenv().LogCleanInterval or 300
}

return Config
