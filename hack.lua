-- 🍌 BANANA EATS v1.1 - Multi-Theme Hack Menu
-- Desenvolvido por: UnderJonh
-- GitHub: https://github.com/underjonh
-- Temas: DarkTheme, LightTheme, GrapeTheme, BloodTheme, Ocean, Midnight, Sentinel, Synapse, LiquidGlass
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

-- Tema LiquidGlass Customizado
local LiquidGlassTheme = {
    SchemeColor = Color3.fromRGB(100, 200, 255),
    Background = Color3.fromRGB(20, 25, 35),
    Header = Color3.fromRGB(30, 40, 55),
    TextColor = Color3.fromRGB(255, 255, 255),
    ElementColor = Color3.fromRGB(25, 35, 50)
}

-- Loadstring GUI (Kavo UI)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("🍌 BANANA EATS v1.1 | by UnderJonh", getgenv().Config.Theme)

-- ===== THEME TAB =====
local ThemeTab = Window:NewTab("🎨 Themes")
local ThemeSec = ThemeTab:NewSection("Escolha seu tema")

local themes = {
    "DarkTheme", "LightTheme", "GrapeTheme", "BloodTheme", 
    "Ocean", "Midnight", "Sentinel", "Synapse"
}

for _, themeName in pairs(themes) do
    ThemeSec:NewButton(themeName, "Aplicar tema " .. themeName, function()
        getgenv().Config.Theme = themeName
        pcall(function()
            game.CoreGui:FindFirstChild("Kavo"):Destroy()
        end)
        
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
        Window = Library.CreateLib("🍌 BANANA EATS v1.1 | by UnderJonh", themeName)
        
        warn("⚠️ GUI recriada! Tema aplicado: " .. themeName)
        warn("🔄 Execute o script novamente para aplicar completamente")
    end)
end

ThemeSec:NewButton("LiquidGlass (Custom)", "Tema translúcido estilo iOS 26", function()
    pcall(function()
        game.CoreGui:FindFirstChild("Kavo"):Destroy()
    end)
    
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
    Window = Library.CreateLib("🍌 BANANA EATS v1.1 | by UnderJonh", LiquidGlassTheme)
    
    warn("✨ LiquidGlass Theme Aplicado!")
    warn("🔄 Execute o script novamente para recriar todas as funcionalidades")
end)

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
            if data and data.box then data.box:Remove() end
            if data and data.connection then data.connection:Disconnect() end
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
            if hl then hl:Destroy() end
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

CreditsSec:NewLabel("🍌 BANANA EATS v1.1")
CreditsSec:NewLabel("Desenvolvido por: UnderJonh")
CreditsSec:NewLabel("GitHub: github.com/underjonh")
CreditsSec:NewLabel("")
CreditsSec:NewLabel("⭐ Se gostou, deixe uma estrela!")

CreditsSec:NewButton("📋 Copiar GitHub Link", "Copia para área de transferência", function()
    setclipboard("https://github.com/underjonh")
    warn("✅ Link copiado: https://github.com/underjonh")
end)

CreditsSec:NewButton("🌐 Abrir GitHub", "Abre perfil no navegador", function()
    warn("🌐 Abrindo: https://github.com/underjonh")
end)

local InfoSec = CreditsTab:NewSection("Informações do Script")
InfoSec:NewLabel("Versão: 1.1")
InfoSec:NewLabel("Data: 22/12/2025")
InfoSec:NewLabel("Tema Atual: " .. getgenv().Config.Theme)
InfoSec:NewLabel("Features: ESP, WallHack, Speed")

-- ===== MISC TAB =====
local MiscTab = Window:NewTab("⚙️ Misc")
local MiscSec = MiscTab:NewSection("Configurações")

MiscSec:NewButton("Destroy GUI", "Remove o menu", function()
    Library:ToggleUI()
    disableSpeed()
end)

MiscSec:NewKeybind("Toggle Menu", "Tecla para abrir/fechar", Enum.KeyCode.RightShift, function()
    Library:ToggleUI()
end)

-- ===== FUNÇÕES CORE =====

function createESP(target)
    if target == player or not target.Character then return end
    
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Transparency = 1
    box.Filled = false
    box.Visible = true
    box.ZIndex = 2
    
    local connection = RunService.RenderStepped:Connect(function()
        pcall(function()
            if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
                box:Remove()
                connection:Disconnect()
                espConnections[target] = nil
                return
            end
            
            local hrp = target.Character.HumanoidRootPart
            local head = target.Character:FindFirstChild("Head")
            
            if hrp and head then
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
                local headPos = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                
                local height = math.abs(headPos.Y - legPos.Y)
                local width = height * 0.6
                
                box.Size = Vector2.new(width, height)
                box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                box.Visible = onScreen
            end
        end)
    end)
    
    espConnections[target] = {box = box, connection = connection}
end

function createWallHack(target)
    if target == player or not target.Character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "WH_" .. target.Name
    highlight.FillColor = Color3.fromRGB(255, 0, 255)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Adornee = target.Character
    highlight.Parent = target.Character
    
    highlightObjects[target] = highlight
end

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

-- ===== EVENTOS =====
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
    p.CharacterAdded:Connect(function()
        task.wait(1)
        if getgenv().Config.ESP then createESP(p) end
        if getgenv().Config.WallHack then createWallHack(p) end
    end)
end)

for _, p in pairs(Players:GetPlayers()) do
    if p ~= player and p.Character then
        if getgenv().Config.ESP then createESP(p) end
        if getgenv().Config.WallHack then createWallHack(p) end
    end
end

print("🍌 BANANA EATS v1.1 Loaded!")
print("👨‍💻 Desenvolvido por: UnderJonh")
print("🌐 GitHub: https://github.com/underjonh")
print("🎨 Tema Atual: " .. getgenv().Config.Theme)
print("⚡ Velocity Speed = SEM ROLLBACK!")
print("📌 RightShift = Toggle Menu")
