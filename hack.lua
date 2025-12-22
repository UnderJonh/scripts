-- 🍌 BANANA EATS v1.3 - Multi-Theme Hack Menu
-- Desenvolvido por: UnderJonh (João Augusto)
-- GitHub: https://github.com/underjonh
-- Temas: DarkTheme, LightTheme, GrapeTheme, BloodTheme, Ocean, Midnight, Sentinel, Synapse
-- Compatível: Synapse X, Krnl, Fluxus, Wave, Delta, Solara

getgenv().Config = getgenv().Config or {
    ESP = false,
    WallHack = false,
    Speed = false,
    SpeedValue = 50,
    SpeedMode = "velocity",
    Theme = "DarkTheme"
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local espConnections = {}
local highlightObjects = {}
local speedConnection = nil
local velocityInstance = nil

-- Loadstring GUI (Kavo UI)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("🍌 BANANA EATS v1.3 | by UnderJonh", getgenv().Config.Theme)

-- ===== THEME TAB =====
local ThemeTab = Window:NewTab("🎨 Themes")
local ThemeSec = ThemeTab:NewSection("Seletor de Tema")

local themes = {
    "DarkTheme", "LightTheme", "GrapeTheme", "BloodTheme", 
    "Ocean", "Midnight", "Sentinel", "Synapse"
}

ThemeSec:NewDropdown("Escolha o Tema", "Troca apenas as cores da GUI", themes, function(currentTheme)
    getgenv().Config.Theme = currentTheme
    Library:ChangeTheme(currentTheme)
    warn("✅ Tema alterado para: " .. currentTheme)
end)

ThemeSec:NewLabel("Tema Atual: " .. getgenv().Config.Theme)

-- ===== ESP TAB =====
local ESPTab = Window:NewTab("👁️ Visuals")
local ESPSec = ESPTab:NewSection("ESP & WallHack")

ESPSec:NewToggle("ESP Boxes", "Caixas vermelhas nos players", function(state)
    getgenv().Config.ESP = state
    if state then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                createESP(p)
            end
        end
    else
        for _, data in pairs(espConnections) do
            if data and data.box then 
                pcall(function() data.box:Remove() end)
            end
            if data and data.nameTag then 
                pcall(function() data.nameTag:Remove() end)
            end
            if data and data.connection then 
                pcall(function() data.connection:Disconnect() end)
            end
        end
        espConnections = {}
    end
end)

ESPSec:NewToggle("WallHack", "Highlight através de paredes", function(state)
    getgenv().Config.WallHack = state
    if state then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                createWallHack(p)
            end
        end
    else
        for _, hl in pairs(highlightObjects) do
            if hl then 
                pcall(function() hl:Destroy() end)
            end
        end
        highlightObjects = {}
    end
end)

-- ===== SPEED TAB =====
local SpeedTab = Window:NewTab("⚡ Movement")
local SpeedSec = SpeedTab:NewSection("Speed (No Rollback)")

SpeedSec:NewToggle("Velocity Speed", "Usa BodyVelocity (SEM ROLLBACK)", function(state)
    getgenv().Config.Speed = state
    getgenv().Config.SpeedMode = "velocity"
    if state then
        enableVelocitySpeed()
    else
        disableSpeed()
    end
end)

SpeedSec:NewSlider("Velocidade", "Ajuste 10-200", 200, 10, function(s)
    getgenv().Config.SpeedValue = s
end)

SpeedSec:NewButton("Speed Normal (WalkSpeed)", "Pode causar rollback", function()
    if getgenv().Config.Speed then
        getgenv().Config.SpeedMode = "walkspeed"
        disableSpeed()
        enableWalkSpeed()
    end
end)

-- ===== CREDITS TAB =====
local CreditsTab = Window:NewTab("📌 Credits")
local CreditsSec = CreditsTab:NewSection("Desenvolvedor")

CreditsSec:NewLabel("🍌 BANANA EATS v1.3")
CreditsSec:NewLabel("Desenvolvido por: UnderJonh")
CreditsSec:NewLabel("Nome: João Augusto")
CreditsSec:NewLabel("GitHub: github.com/underjonh")
CreditsSec:NewLabel("")
CreditsSec:NewLabel("⭐ Se gostou, deixe uma estrela!")

CreditsSec:NewButton("📋 Copiar GitHub Link", "Copia para área de transferência", function()
    setclipboard("https://github.com/underjonh")
    warn("✅ Link copiado: https://github.com/underjonh")
end)

local InfoSec = CreditsTab:NewSection("Informações do Script")
InfoSec:NewLabel("Versão: 1.3")
InfoSec:NewLabel("Data: 22/12/2025")
InfoSec:NewLabel("Tema Atual: " .. getgenv().Config.Theme)
InfoSec:NewLabel("Features: ESP, WallHack, Speed")
InfoSec:NewLabel("")
InfoSec:NewLabel("Changelog v1.3:")
InfoSec:NewLabel("- Dropdown de temas")
InfoSec:NewLabel("- Interface mais limpa")
InfoSec:NewLabel("- Estabilidade melhorada")

-- ===== MISC TAB =====
local MiscTab = Window:NewTab("⚙️ Misc")
local MiscSec = MiscTab:NewSection("Configurações")

MiscSec:NewButton("Destroy GUI", "Remove o menu", function()
    disableSpeed()
    for _, data in pairs(espConnections) do
        if data and data.box then pcall(function() data.box:Remove() end) end
        if data and data.nameTag then pcall(function() data.nameTag:Remove() end) end
        if data and data.connection then pcall(function() data.connection:Disconnect() end) end
    end
    for _, hl in pairs(highlightObjects) do
        if hl then pcall(function() hl:Destroy() end) end
    end
    pcall(function() game.CoreGui:FindFirstChild("Kavo"):Destroy() end)
end)

MiscSec:NewKeybind("Toggle Menu", "Tecla para abrir/fechar", Enum.KeyCode.RightShift, function()
    Library:ToggleUI()
end)

MiscSec:NewLabel("Tip: Use RightShift para abrir/fechar")

-- ===== FUNÇÕES CORE (CORRIGIDAS) =====

-- ESP Corrigido com Drawing API
function createESP(target)
    if target == player or not target.Character then return end
    if espConnections[target] then return end
    
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Transparency = 1
    box.Filled = false
    box.Visible = false
    box.ZIndex = 2
    
    local nameTag = Drawing.new("Text")
    nameTag.Text = target.Name
    nameTag.Size = 16
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.fromRGB(0, 0, 0)
    nameTag.Color = Color3.fromRGB(255, 255, 255)
    nameTag.Visible = false
    
    local connection = RunService.RenderStepped:Connect(function()
        pcall(function()
            if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") or not target.Character:FindFirstChild("Humanoid") or target.Character.Humanoid.Health <= 0 then
                box.Visible = false
                nameTag.Visible = false
                return
            end
            
            local hrp = target.Character.HumanoidRootPart
            local head = target.Character:FindFirstChild("Head")
            
            if hrp and head then
                local rootPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
                
                if onScreen then
                    local headPos = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local legPos = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height * 0.6
                    
                    box.Size = Vector2.new(width, height)
                    box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
                    box.Visible = true
                    
                    nameTag.Position = Vector2.new(rootPos.X, rootPos.Y - height/2 - 15)
                    nameTag.Visible = true
                else
                    box.Visible = false
                    nameTag.Visible = false
                end
            end
        end)
    end)
    
    espConnections[target] = {box = box, nameTag = nameTag, connection = connection}
end

-- WallHack Corrigido
function createWallHack(target)
    if target == player or not target.Character then return end
    if highlightObjects[target] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "WH_" .. target.Name
    highlight.FillColor = Color3.fromRGB(255, 0, 255)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = target.Character
    highlight.Parent = target.Character
    
    highlightObjects[target] = highlight
    
    local humanoid = target.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Died:Connect(function()
            if highlightObjects[target] then
                pcall(function() highlightObjects[target]:Destroy() end)
                highlightObjects[target] = nil
            end
        end)
    end
end

-- Velocity Speed (Sem Rollback)
function enableVelocitySpeed()
    disableSpeed()
    
    speedConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
            
            local hrp = player.Character.HumanoidRootPart
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            if humanoid and humanoid.MoveDirection.Magnitude > 0 then
                if not velocityInstance or velocityInstance.Parent ~= hrp then
                    velocityInstance = Instance.new("BodyVelocity")
                    velocityInstance.Name = "SpeedBoost"
                    velocityInstance.MaxForce = Vector3.new(100000, 0, 100000)
                    velocityInstance.Parent = hrp
                end
                
                local moveDir = humanoid.MoveDirection
                velocityInstance.Velocity = moveDir * getgenv().Config.SpeedValue
            else
                if velocityInstance and velocityInstance.Parent then
                    velocityInstance:Destroy()
                    velocityInstance = nil
                end
            end
        end)
    end)
end

function enableWalkSpeed()
    disableSpeed()
    
    speedConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = getgenv().Config.SpeedValue
            end
        end)
    end)
end

function disableSpeed()
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    
    if velocityInstance and velocityInstance.Parent then
        velocityInstance:Destroy()
        velocityInstance = nil
    end
    
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 16
    end
end

-- ===== EVENTOS (CORRIGIDOS) =====

player.CharacterAdded:Connect(function(char)
    task.wait(1)
    
    if getgenv().Config.Speed then
        if getgenv().Config.SpeedMode == "velocity" then
            enableVelocitySpeed()
        else
            enableWalkSpeed()
        end
    end
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        task.wait(1)
        if getgenv().Config.ESP then createESP(p) end
        if getgenv().Config.WallHack then createWallHack(p) end
    end)
end)

Players.PlayerRemoving:Connect(function(p)
    if espConnections[p] then
        local data = espConnections[p]
        if data.box then pcall(function() data.box:Remove() end) end
        if data.nameTag then pcall(function() data.nameTag:Remove() end) end
        if data.connection then pcall(function() data.connection:Disconnect() end) end
        espConnections[p] = nil
    end
    
    if highlightObjects[p] then
        pcall(function() highlightObjects[p]:Destroy() end)
        highlightObjects[p] = nil
    end
end)

for _, p in pairs(Players:GetPlayers()) do
    if p ~= player and p.Character then
        if getgenv().Config.ESP then createESP(p) end
        if getgenv().Config.WallHack then createWallHack(p) end
    end
    
    p.CharacterAdded:Connect(function(char)
        task.wait(1)
        if getgenv().Config.ESP then createESP(p) end
        if getgenv().Config.WallHack then createWallHack(p) end
    end)
end

print("🍌 BANANA EATS v1.3 Loaded!")
print("👨‍💻 Desenvolvido por: UnderJonh (João Augusto)")
print("🌐 GitHub: https://github.com/underjonh")
print("🎨 Tema Atual: " .. getgenv().Config.Theme)
print("⚡ Velocity Speed = SEM ROLLBACK!")
print("📌 RightShift = Toggle Menu")
print("✨ Changelog v1.3: Dropdown de temas + interface limpa!")
