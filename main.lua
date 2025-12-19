local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- KONFIGURASI GITHUB (GANTI LINK INI)
local jsonUrl = "https://raw.githubusercontent.com/mdjazarqy-dot/POKAYHUB-/main/data.json"
local fileName = "PokayHub_Storage.json"

-- FUNGSI AMBIL DATA & SIMPAN LOKAL
local function getRemoteData()
    local data
    local success, result = pcall(function()
        return game:HttpGet(jsonUrl .. "?t=" .. tick())
    end)
    
    if success then
        data = result
        writefile(fileName, data)
    elseif isfile(fileName) then
        data = readfile(fileName)
    else
        return nil
    end
    return HttpService:JSONDecode(data)
end

local configData = getRemoteData()

-- =========================================================
-- SISTEM WHITELIST
-- =========================================================
local isWhitelisted = false
if configData and configData.Whitelist then
    for _, val in pairs(configData.Whitelist) do
        if val == LocalPlayer.UserId or val == LocalPlayer.Name then
            isWhitelisted = true
            break
        end
    end
end

if not isWhitelisted then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "ACCESS DENIED",
        Text = "Maaf, Anda tidak terdaftar dalam Whitelist PokayHub.",
        Duration = 10
    })
    return -- Script berhenti jika tidak di-whitelist
end

-- =========================================================
-- JIKA LOLOS, LANJUT LOAD UI
-- =========================================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

WindUI:AddTheme({
    Name = "My Theme",
    Accent = Color3.fromHex("#18181b"),
    Background = Color3.fromHex("#101010"),
    Outline = Color3.fromHex("#FFFFFF"),
    Text = Color3.fromHex("#FFFFFF"),
    Placeholder = Color3.fromHex("#7a7a7a"),
    Button = Color3.fromHex("#52525b"),
    Icon = Color3.fromHex("#a1a1aa"),
})
WindUI:SetTheme("My Theme")

local Window = WindUI:CreateWindow({
    Title = "PokayHub",
    Icon = "door-open",
    Author = "by jepin",
})

Window:Tag({
    Title = "VIP ACCESS",
    Icon = "badge-check",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 0,
})

-- TAB 1: MOUNT
local Tab = Window:Tab({ Title = "Mount", Icon = "mountain" })

local Keybind = Tab:Keybind({
    Title = "POKAYHUB COMMUNITY",
    Desc = "Keybind to open ui", 
    Value = "G", 
    Callback = function(v) Window:SetToggleKey(Enum.KeyCode[v]) end
})

local Section = Tab:Section({ Title = "Script para pokay", Icon = "globe", Opened = true })

-- OTOMATIS LOAD BUTTON MOUNT DARI JSON
if configData.MountScripts then
    for _, btn in pairs(configData.MountScripts) do
        Section:Button({
            Title = btn.Title,
            Desc = btn.Desc,
            Callback = function() loadstring(game:HttpGet(btn.Url))() end
        })
    end
end

-- TAB 2: UTILITY
local UtilityTab = Window:Tab({ Title = "More Script", Icon = "cpu" })
local MovementSection = UtilityTab:Section({ Title = "Script Selain Gunung", Icon = "biceps-flexed", Opened = true })

-- OTOMATIS LOAD BUTTON UTILITY DARI JSON
if configData.UtilityScripts then
    for _, btn in pairs(configData.UtilityScripts) do
        MovementSection:Button({
            Title = btn.Title,
            Desc = btn.Desc,
            Callback = function() loadstring(game:HttpGet(btn.Url))() end
        })
    end
end

-- DIALOG & SETTINGS
local Dialog = Window:Dialog({
    Icon = "badge-alert",
    Title = "PEMBERITAHUAN",
    Content = "jangan lupa join dc pokay community ya",
    Buttons = {
        { Title = "Confirm", Callback = function() Dialog:Close() end },
        { Title = "Cancel", Callback = function() Dialog:Close() end },
    },
})

Window:EditOpenButton({
    Title = "PokayHub",
    Icon = "monitor",
    Enabled = true,
    Draggable = true,
})

-- EKSEKUSI AKHIR
Tab:Select()
Window:Open()

WindUI:Notify({
    Title = "Welcome " .. LocalPlayer.DisplayName,
    Content = "Whitelist Berhasil! Data dimuat dari " .. (isfile(fileName) and "Lokal" or "Cloud"),
    Duration = 5,
    Icon = "badge-check",
})
