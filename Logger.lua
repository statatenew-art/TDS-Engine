-- TDS-Engine/Logger.lua
local LogService = game:GetService("LogService")

local Logger = {
    LogHistory = {},
    MaxInMemoryLogs = 100,
    LogDirectory = "TDS-Logs"
}

local hasFileSystem = (type(writefile) == "function") and (type(listfiles) == "function") and (type(delfile) == "function")

function Logger:InitStorage()
    if not hasFileSystem then return end
    if type(isfolder) == "function" and type(makefolder) == "function" then
        if not isfolder(self.LogDirectory) then
            makefolder(self.LogDirectory)
        end
    end
end

function Logger:PurgeLogFiles(maxSizeKB)
    if not hasFileSystem then return end
    maxSizeKB = maxSizeKB or 512

    local ok, files = pcall(listfiles, self.LogDirectory)
    if not ok or not files then return end

    local deletedCount = 0
    for _, filePath in ipairs(files) do
        if filePath:match("%.log$") or filePath:match("%.txt$") then
            local shouldDelete = false
            if type(readfile) == "function" then
                local contentOk, content = pcall(readfile, filePath)
                if contentOk and content and (#content / 1024) > maxSizeKB then
                    shouldDelete = true
                end
            end

            if shouldDelete then
                pcall(delfile, filePath)
                deletedCount = deletedCount + 1
            end
        end
    end

    if deletedCount > 0 then
        print(string.format("[Logger] %d adet eski/şişmiş dosya temizlendi.", deletedCount))
    end
end

function Logger:ClearConsole()
    local rconsoleclear = rconsoleclear or consoleclear
    if type(rconsoleclear) == "function" then
        pcall(rconsoleclear)
    end
    table.clear(self.LogHistory)
end

function Logger:HookLogs()
    LogService.MessageOut:Connect(function(message, messageType)
        local isEngineMsg = message:find("%[Engine%]") or message:find("%[Network%]") or message:find("%[Features%]") or message:find("%[Lobby%]")
        if isEngineMsg then
            table.insert(self.LogHistory, {
                Time = os.time(),
                Type = messageType,
                Text = message
            })
            if #self.LogHistory > self.MaxInMemoryLogs then
                table.remove(self.LogHistory, 1)
            end
        end
    end)
end

function Logger:StartAutoCleaner(intervalSeconds)
    task.spawn(function()
        while true do
            task.wait(intervalSeconds)
            self:PurgeLogFiles(512)
            self:ClearConsole()
        end
    end)
end

function Logger:Init(Config)
    self:InitStorage()
    self:HookLogs()
    self:PurgeLogFiles(512)
    
    if Config.AutoCleanLogs then
        self:StartAutoCleaner(Config.LogCleanInterval or 300)
    end
    print("[Logger] Log ve dosya temizleyici başlatıldı.")
end

return Logger
