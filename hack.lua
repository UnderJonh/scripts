-- ⚡ UnderHack v7.0 - Universal Multi-Feature Script
-- Desenvolvido por: UnderJonh (João Augusto)
-- GitHub: https://github.com/underjonh
-- Temas: DarkTheme, LightTheme, GrapeTheme, BloodTheme, Ocean, Midnight, Sentinel, Synapse
-- Compatível: Synapse X, Krnl, Fluxus, Wave, Delta, Solara

getgenv().Config = getgenv().Config or {
    ESP = false,
    WallHack = false,
    Speed = false,
    Fly = false,
    AutoCollect = false,
    SpeedValue = 50,
    FlySpeed = 50,
    CollisionSize = 10,
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
local flyConnection = nil
local flyVelocity = nil
local flyGyro = nil
local originalHitboxSizes = {}
local flyKeys = {W = false, A = false, S = false, D = false, Space = false, LeftShift = false}

-- Loadstring GUI (Kavo UI)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("⚡ UnderHack v7.0 | by UnderJonh", getgenv().Config.Theme)

-- ===== THEME TAB =====
local ThemeTab = Window:NewTab("🎨 Themes")
local ThemeSec = ThemeTab:NewSection("Seletor de Tema")

local themes = {
    "DarkTheme", "LightTheme", "GrapeTheme", "BloodTheme", 
    "Ocean", "Midnight", "Sentinel", "Synapse"
}

ThemeSec:NewDropdown("Escolha o Tema", "Troca as cores da interface", themes, function(currentTheme)
    getgenv().Config.Theme = currentTheme
    Library:ChangeTheme(currentTheme)
    warn("✅ Tema alterado para: " .. currentTheme)
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

-- ===== MOVEMENT TAB =====
local MovementTab = Window:NewTab("⚡ Movement")
local SpeedSec = MovementTab:NewSection("Speed (No Rollback)")

SpeedSec:NewToggle("Velocity Speed", "Usa BodyVelocity (SEM ROLLBACK)", function(state)
    getgenv().Config.Speed = state
    getgenv().Config.SpeedMode = "velocity"
    if state then
        if getgenv().Config.Fly then
            getgenv().Config.Fly = false
            disableFly()
        end
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

local FlySec = MovementTab:NewSection("Fly Mode (Camera-Based)")

FlySec:NewToggle("Enable Fly", "Voa com controles WASD + Space/Shift", function(state)
    getgenv().Config.Fly = state
    if state then
        if getgenv().Config.Speed then
            getgenv().Config.Speed = false
            disableSpeed()
        end
        enableFly()
    else
        disableFly()
    end
end)

FlySec:NewSlider("Velocidade de Voo", "Ajuste 10-200", 200, 10, function(s)
    getgenv().Config.FlySpeed = s
end)

FlySec:NewLabel("Controles: WASD = movimento")
FlySec:NewLabel("Space = subir | Shift = descer")

-- ===== AUTO FARM TAB =====
local FarmTab = Window:NewTab("💰 Farm")
local CollectSec = FarmTab:NewSection("Auto Coleta por Hitbox")

CollectSec:NewToggle("Aumentar Hitbox", "Expande sua área de colisão", function(state)
    getgenv().Config.AutoCollect = state
    if state then
        enableHitboxExpansion()
    else
        disableHitboxExpansion()
    end
end)

CollectSec:NewSlider("Tamanho da Hitbox", "Ajuste 5-50", 50, 5, function(s)
    getgenv().Config.CollisionSize = s
    if getgenv().Config.AutoCollect then
        updateHitboxSize()
    end
end)

CollectSec:NewLabel("Coleta moedas automaticamente")
CollectSec:NewLabel("ao aumentar sua área de toque!")

local MoneySec = FarmTab:NewSection("Editor de Dinheiro")

MoneySec:NewLabel("Modifica valores de moeda (client-side)")
MoneySec:NewTextBox("Valor de Dinheiro", "Digite o valor", function(txt)
    local amount = tonumber(txt)
    if amount then
        setPlayerMoney(amount)
    else
        warn("❌ Digite um número válido!")
    end
end)

MoneySec:NewButton("Setar 1 Milhão", "Adiciona 1M de dinheiro", function()
    setPlayerMoney(1000000)
end)

MoneySec:NewButton("Setar 10 Milhões", "Adiciona 10M de dinheiro", function()
    setPlayerMoney(10000000)
end)

MoneySec:NewButton("Setar 100 Milhões", "Adiciona 100M de dinheiro", function()
    setPlayerMoney(100000000)
end)

MoneySec:NewLabel("⚠️ Funciona apenas no cliente!")
MoneySec:NewLabel("Pode não salvar no servidor")

-- ===== CREDITS TAB =====
local CreditsTab = Window:NewTab("📌 Credits")
local CreditsSec = CreditsTab:NewSection("Desenvolvedor")

CreditsSec:NewLabel("⚡ UnderHack v7.0")
CreditsSec:NewLabel("Desenvolvido por: UnderJonh")
CreditsSec:NewLabel("⭐ Se gostou, deixe uma estrela!")
CreditsSec:NewLabel("GitHub: github.com/underjonh")

CreditsSec:NewButton("📋 Copiar GitHub Link", "Copia para área de transferência", function()
    setclipboard("https://github.com/underjonh")
    warn("✅ Link copiado: https://github.com/underjonh")
end)

local InfoSec = CreditsTab:NewSection("Informações")
InfoSec:NewLabel("Versão: 7.0")
InfoSec:NewLabel("NEW: Hitbox Farm + Money Editor")
InfoSec:NewLabel("Features: ESP, WallHack, Speed, Fly")

-- ===== MISC TAB =====
local MiscTab = Window:NewTab("⚙️ Misc")
local MiscSec = MiscTab:NewSection("Configurações")

MiscSec:NewButton("Destroy GUI", "Remove o menu", function()
    disableSpeed()
    disableFly()
    disableHitboxExpansion()
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

-- ===== FUNÇÕES CORE =====

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

function enableFly()
    disableFly()
    
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = char.HumanoidRootPart
    local humanoid = char:FindFirstChild("Humanoid")
    
    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.Name = "FlyVelocity"
    flyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    flyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyVelocity.Parent = hrp
    
    flyGyro = Instance.new("BodyGyro")
    flyGyro.Name = "FlyGyro"
    flyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    flyGyro.P = 10000
    flyGyro.CFrame = hrp.CFrame
    flyGyro.Parent = hrp
    
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
        humanoid:ChangeState(Enum.HumanoidStateType.Flying)
    end
    
    local inputBegin = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.W then flyKeys.W = true
        elseif input.KeyCode == Enum.KeyCode.A then flyKeys.A = true
        elseif input.KeyCode == Enum.KeyCode.S then flyKeys.S = true
        elseif input.KeyCode == Enum.KeyCode.D then flyKeys.D = true
        elseif input.KeyCode == Enum.KeyCode.Space then flyKeys.Space = true
        elseif input.KeyCode == Enum.KeyCode.LeftShift then flyKeys.LeftShift = true
        end
    end)
    
    local inputEnd = UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.W then flyKeys.W = false
        elseif input.KeyCode == Enum.KeyCode.A then flyKeys.A = false
        elseif input.KeyCode == Enum.KeyCode.S then flyKeys.S = false
        elseif input.KeyCode == Enum.KeyCode.D then flyKeys.D = false
        elseif input.KeyCode == Enum.KeyCode.Space then flyKeys.Space = false
        elseif input.KeyCode == Enum.KeyCode.LeftShift then flyKeys.LeftShift = false
        end
    end)
    
    flyConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
            if not flyVelocity or not flyGyro then return end
            
            local cam = workspace.CurrentCamera
            local hrp = player.Character.HumanoidRootPart
            local speed = getgenv().Config.FlySpeed
            
            local moveVector = Vector3.new(0, 0, 0)
            
            if flyKeys.W then
                moveVector = moveVector + cam.CFrame.LookVector
            end
            if flyKeys.S then
                moveVector = moveVector - cam.CFrame.LookVector
            end
            if flyKeys.A then
                moveVector = moveVector - cam.CFrame.RightVector
            end
            if flyKeys.D then
                moveVector = moveVector + cam.CFrame.RightVector
            end
            if flyKeys.Space then
                moveVector = moveVector + Vector3.new(0, 1, 0)
            end
            if flyKeys.LeftShift then
                moveVector = moveVector - Vector3.new(0, 1, 0)
            end
            
            if moveVector.Magnitude > 0 then
                moveVector = moveVector.Unit
            end
            
            flyVelocity.Velocity = moveVector * speed
            flyGyro.CFrame = cam.CFrame
        end)
    end)
    
    getgenv()._flyConnections = {inputBegin, inputEnd}
    
    warn("✅ Fly ativado! Use WASD + Space/Shift para voar")
end

function disableFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    
    if flyVelocity and flyVelocity.Parent then
        flyVelocity:Destroy()
        flyVelocity = nil
    end
    
    if flyGyro and flyGyro.Parent then
        flyGyro:Destroy()
        flyGyro = nil
    end
    
    if getgenv()._flyConnections then
        for _, conn in pairs(getgenv()._flyConnections) do
            pcall(function() conn:Disconnect() end)
        end
        getgenv()._flyConnections = nil
    end
    
    for k, _ in pairs(flyKeys) do
        flyKeys[k] = false
    end
    
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
        humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
    end
end

-- ===== HITBOX EXPANSION =====
function enableHitboxExpansion()
    if not player.Character then return end
    
    -- Salva tamanhos originais
    for _, part in pairs(player.Character:GetChildren()) do
        if part:IsA("BasePart") then
            originalHitboxSizes[part] = part.Size
        end
    end
    
    updateHitboxSize()
    warn("✅ Hitbox expandida! Colete moedas facilmente")
end

function updateHitboxSize()
    if not player.Character then return end
    
    local size = getgenv().Config.CollisionSize
    
    pcall(function()
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Size = Vector3.new(size, size, size)
            hrp.Transparency = 0.7
            hrp.CanCollide = false
        end
    end)
end

function disableHitboxExpansion()
    if not player.Character then return end
    
    -- Restaura tamanhos originais
    for part, originalSize in pairs(originalHitboxSizes) do
        if part and part.Parent then
            pcall(function()
                part.Size = originalSize
                if part.Name == "HumanoidRootPart" then
                    part.Transparency = 1
                end
            end)
        end
    end
    
    originalHitboxSizes = {}
    warn("⚠️ Hitbox restaurada ao tamanho normal")
end

-- ===== MONEY EDITOR =====
function setPlayerMoney(amount)
    pcall(function()
        -- Tenta modificar leaderstats (mais comum)
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            for _, stat in pairs(leaderstats:GetChildren()) do
                local statName = stat.Name:lower()
                if statName:find("money") or statName:find("cash") or 
                   statName:find("coin") or statName:find("gold") or 
                   statName:find("currency") or statName:find("dollar") then
                    stat.Value = amount
                    warn("✅ Dinheiro alterado: " .. stat.Name .. " = " .. amount)
                    return
                end
            end
        end
        
        -- Tenta modificar valores diretos no player
        for _, obj in pairs(player:GetChildren()) do
            if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                local objName = obj.Name:lower()
                if objName:find("money") or objName:find("cash") or 
                   objName:find("coin") or objName:find("gold") then
                    obj.Value = amount
                    warn("✅ Dinheiro alterado: " .. obj.Name .. " = " .. amount)
                    return
                end
            end
        end
        
        warn("⚠️ Não encontrei variável de dinheiro no jogo!")
        warn("💡 Isso é client-side, pode não funcionar em todos os jogos")
    end)
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
    
    if getgenv().Config.Fly then
        enableFly()
    end
    
    if getgenv().Config.AutoCollect then
        enableHitboxExpansion()
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

print("⚡ UnderHack v7.0 Loaded!")
print("👨‍💻 Desenvolvido por: UnderJonh (João Augusto)")
print("🌐 GitHub: https://github.com/underjonh")
print("✨ Features: Hitbox Farm + Money Editor!")
print("💰 Hitbox: Expande área de colisão para coletar")
print("💵 Money: Modifica valores de moeda (client-side)")
print("⚡ Velocity Speed = SEM ROLLBACK!")
print("🚁 Fly = Camera-based controls (WASD + Space/Shift)")
print("📌 RightShift = Toggle Menu")
