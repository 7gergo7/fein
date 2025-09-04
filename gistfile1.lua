local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceID = game.PlaceId
 
--  hook
getgenv().webhookurl = "https://discord.com/api/webhooks/1413192984853479493/HiMXnV43Qw-KfJmFGJi6W9sLJ2DIgZOJk0HASFMOeoyc2g5_SV7PmjwjL32EWYqh76zQ"
 
-- Target pets
getgenv().TargetPetNames = {
    "Torrtuginni Dragonfrutini",
    "Los Tralaleritos",
    "Guerriro Digitale",
    "Las Tralaleritas",
    "Las Vaquitas Saturnitas",
    "Job Job Job Sahur",
    "Graipuss Medussi",
    "Los Spyderinis",
    "Nooo My Hotspot",
    "Pot Hotspot",
    "Chicleteira Bicicleteira",
    "Spaghetti Tualetti",
    "Esok Sekolah",
    "Los Nooo My Hotspotsitos",
    "La Grande Combinassion",
    "Los Combinasionas",
    "Nuclearo Dinosauro",
    "Los Hotspositos",
    "Ketupat Kepat",
    "La Supreme Combinasion",
    "Garama and Madundung",
    "Dragon Cannelloni",
}
 
--  GUI
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild("TwizzyServerhop") then
    PlayerGui.TwizzyServerhop:Destroy()
end
 
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TwizzyServerhop"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui
 
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 220)
Frame.Position = UDim2.new(0.5, -110, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
 
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 22)
Title.Text = "Twizzy Hop"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Parent = Frame
 
local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0.9, 0, 0, 35)
StartBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
StartBtn.Text = "▶️ Start"
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextScaled = true
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
StartBtn.Parent = Frame
Instance.new("UICorner", StartBtn).CornerRadius = UDim.new(0, 6)
 
--  State
local Running = false
 
--  Webhook again
local function SendWebhook(petName, moneyPerSecond)
    local joinLink = string.format("https://www.roblox.com/games/%d?privateServerId=%s", PlaceID, game.JobId)
 
    local data = {
        username = "Brainrot Scanner",
        embeds = {{
            title = "🧠 New Pet Found!",
            color = 0,
            fields = {
                {name="Name", value=petName, inline=true},
                {name="Money/sec", value=moneyPerSecond or "Unknown", inline=true},
                {name="🔗 Join", value=joinLink, inline=false}
            }
        }}
    }
 
    local requestfunc = request or http_request or (syn and syn.request)
    if requestfunc then
        requestfunc({
            Url = getgenv().webhookurl,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(data)
        })
    end
end
 
-- scanning
local function ScanServer()
    local foundMatch = false
    for _, obj in pairs(Workspace:GetDescendants()) do
    if obj:IsA("Model") then
            for _, petName in ipairs(getgenv().TargetPetNames) do
                if petName ~= "" and string.find(obj.Name, petName) then
 
                    -- Try to detect money/sec (string like "2m/s")
                    local moneyPerSecond = "Unknown"
                    local moneyVal = obj:FindFirstChild("MoneyPerSecond") or obj:FindFirstChild("Earnings")
                    if moneyVal and moneyVal:IsA("StringValue") then
                        moneyPerSecond = moneyVal.Value
                    elseif obj:GetAttribute("MoneyPerSecond") then
                        moneyPerSecond = obj:GetAttribute("MoneyPerSecond")
                    end
 
                    -- Red outline
                    if obj:FindFirstChild("HumanoidRootPart") then
                        local highlight = Instance.new("Highlight")
                        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                        highlight.FillTransparency = 1
                        highlight.Parent = obj
                    end
 
                    SendWebhook(obj.Name, moneyPerSecond)
                    foundMatch = true
                end
            end
        end
    end
    return foundMatch
end
 
-- // Serverhop loop
local function StartServerhopLoop()
    task.spawn(function()
        while Running do
            local found = ScanServer()
            if found then
                -- Found a target pet, stop scanning
                Running = false
                StartBtn.Text = "▶️ Start"
                StartBtn.BackgroundColor3 = Color3.fromRGB(50,150,200)
                break
            end

            -- Get list of public servers
            local success, Servers = pcall(function()
                return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100"))
            end)

            if success and Servers.data then
                for _, s in ipairs(Servers.data) do
                    if s.playing < s.maxPlayers and not s.hidden and s.id ~= game.JobId then
                        -- Queue script to run automatically in the new server
                        if syn and syn.queue_on_teleport then
                            syn.queue_on_teleport([[
                                loadstring(game:HttpGet("https://gist.githubusercontent.com/7gergo7/bc0dd591b64facb088517ef999e4aa31"))()
                            ]])
                        end

                        -- Teleport to new server
                        TeleportService:TeleportToPlaceInstance(PlaceID, s.id, LocalPlayer)
                        task.wait(2)
                        break
                    end
                end
            end

            task.wait(5)
        end
    end)
end