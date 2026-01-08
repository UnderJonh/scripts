-- ⚡ UnderHack v6.0 - Universal Multi-Feature Script
-- Desenvolvido por: UnderJonh (João Augusto)
-- GitHub: https://github.com/underjonh
-- Temas: DarkTheme, LightTheme, GrapeTheme, BloodTheme, Ocean, Midnight, Sentinel, Synapse
-- Compatível: Synapse X, Krnl, Fluxus, Wave, Delta, Solara

getgenv().Config = getgenv().Config or {
    ESP = false,
    WallHack = false,
    Speed = false,
    Fly = false,
    AutoCollectCoins = false,
    FreePurchase = false,
    SpeedValue = 50,
    FlySpeed = 50,
    CoinFarmRadius = 100,
    SpeedMode = "velocity",
    Theme = "DarkTheme"
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local espConnections = {}
local highlightObjects = {}
local speedConnection = nil
local velocityInstance = nil
local flyConnection = nil
local flyVelocity = nil
local flyGyro = nil
local coinFarmConnection = nil
local flyKeys = {W = false, A = false, S = false, D = false, Space = false, LeftShift = false}

-- Loadstring GUI (Kavo UI)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("⚡ UnderHack v6.0 | by UnderJonh", getgenv().Config.Theme)

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
local FarmTab = Window:NewTab("💰 Auto Farm")
local CoinSec = FarmTab:NewSection("Auto Coleta de Moedas")

CoinSec:NewToggle("Auto Coletar Moedas", "Coleta moedas automaticamente", function(state)
    getgenv().Config.AutoCollectCoins = state
    if state then
        enableCoinFarm()
    else
        disableCoinFarm()
    end
end)

CoinSec:NewSlider("Raio de Coleta", "Distância para coletar (10-200)", 200, 10, function(s)
    getgenv().Config.CoinFarmRadius = s
end)

CoinSec:NewLabel("Coleta: Coins, Orbs, Collectibles")
CoinSec:NewLabel("Funciona em qualquer jogo!")

local PurchaseSec = FarmTab:NewSection("Compra Gratuita")

PurchaseSec:NewToggle("Comprar Sem Dinheiro", "Bypass de verificação de moedas", function(state)
    getgenv().Config.FreePurchase = state
    if state then
        enableFreePurchase()
        warn("✅ Compra gratuita ativada! Tente comprar qualquer item")
    else
        disableFreePurchase()
        warn("⚠️ Compra gratuita desativada")
    end
end)

PurchaseSec:NewLabel("Atenção: Use com cuidado!")
PurchaseSec:NewLabel("Pode não funcionar em todos os jogos")
PurchaseSec:NewButton("Testar Compra", "Abre menu de compra se disponível", function()
    findAndOpenShop()
end)

-- ===== CREDITS TAB =====
local CreditsTab = Window:NewTab("📌 Credits")
local CreditsSec = CreditsTab:NewSection("Desenvolvedor")

CreditsSec:NewLabel("⚡ UnderHack v6.0")
CreditsSec:NewLabel("Desenvolvido por: UnderJonh")
CreditsSec:NewLabel("⭐ Se gostou, deixe uma estrela!")
CreditsSec:NewLabel("GitHub: github.com/underjonh")

CreditsSec:NewButton("📋 Copiar GitHub Link", "Copia para área de transferência", function()
    setclipboard("https://github.com/underjonh")
    warn("✅ Link copiado: https://github.com/underjonh")
end)

local InfoSec = CreditsTab:NewSection("Informações")
InfoSec:NewLabel("Versão: 6.0")
InfoSec:NewLabel("NEW: Auto Farm + Free Purchase")
InfoSec:NewLabel("Features: ESP, WallHack, Speed, Fly")

-- ===== MISC TAB =====
local MiscTab = Window:NewTab("⚙️ Misc")
local MiscSec = MiscTab:NewSection("Configurações")

MiscSec:NewButton("Destroy GUI", "Remove o menu", function()
    disableSpeed()
    disableFly()
    disableCoinFarm()
    disableFreePurchase()
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

-- ===== AUTO COIN FARM =====
function enableCoinFarm()
    disableCoinFarm()
    
    warn("✅ Auto coleta de moedas ativada!")
    
    coinFarmConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
            
            local hrp = player.Character.HumanoidRootPart
            local radius = getgenv().Config.CoinFarmRadius
            
            -- Procura por moedas/orbs no workspace
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                    local name = obj.Name:lower()
                    
                    -- Detecta moedas comuns em jogos
                    if name:find("coin") or name:find("orb") or name:find("collect") or 
                       name:find("money") or name:find("cash") or name:find("gem") or
                       name:find("currency") or name:find("pickup") then
                        
                        local distance = (obj.Position - hrp.Position).Magnitude
                        
                        if distance <= radius and obj:CanSetNetworkOwnership() then
                            -- Teleporta a moeda para o player
                            pcall(function()
                                obj.CFrame = hrp.CFrame
                                obj.CanCollide = false
                                
                                -- Força o toque se houver Touched event
                                if obj:FindFirstChild("Touched") or obj.Touched then
                                    firetouchinterest(hrp, obj, 0)
                                    task.wait(0.05)
                                    firetouchinterest(hrp, obj, 1)
                                end
                            end)
                        end
                    end
                end
            end
        end)
    end)
end

function disableCoinFarm()
    if coinFarmConnection then
        coinFarmConnection:Disconnect()
        coinFarmConnection = nil
        warn("⚠️ Auto coleta de moedas desativada")
    end
end

-- ===== FREE PURCHASE BYPASS =====
local originalNamecall
local originalIndex

function enableFreePurchase()
    -- Hook no Namecall para interceptar verificações de dinheiro
    originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Intercepta chamadas de verificação de moedas
        if method == "InvokeServer" or method == "FireServer" then
            local name = tostring(self)
            
            -- Comum em sistemas de compra
            if name:find("Purchase") or name:find("Buy") or name:find("Shop") then
                -- Tenta modificar argumentos de preço
                for i, arg in pairs(args) do
                    if type(arg) == "number" and arg > 0 then
                        args[i] = 0  -- Seta preço para 0
                    end
                end
                
                warn("💰 Tentando compra gratuita...")
            end
        end
        
        return originalNamecall(self, unpack(args))
    end)
    
    -- Hook no Index para valores de moeda
    originalIndex = hookmetamethod(game, "__index", function(self, key)
        -- Intercepta leitura de valores de moeda
        if type(key) == "string" then
            local keyLower = key:lower()
            
            -- Comum em leaderstats ou valores de UI
            if keyLower:find("money") or keyLower:find("cash") or 
               keyLower:find("coin") or keyLower:find("currency") or
               keyLower:find("balance") or keyLower:find("gem") then
                
                -- Retorna valor alto para passar verificações
                if type(originalIndex(self, key)) == "number" then
                    return 999999999
                end
            end
        end
        
        return originalIndex(self, key)
    end)
    
    warn("✅ Free Purchase ativado! Hooks instalados")
end

function disableFreePurchase()
    if originalNamecall then
        hookmetamethod(game, "__namecall", originalNamecall)
        originalNamecall = nil
    end
    
    if originalIndex then
        hookmetamethod(game, "__index", originalIndex)
        originalIndex = nil
    end
    
    warn("⚠️ Free Purchase desativado! Hooks removidos")
end

function findAndOpenShop()
    pcall(function()
        -- Procura por GUIs de loja
        for _, gui in pairs(player.PlayerGui:GetDescendants()) do
            if gui:IsA("Frame") or gui:IsA("ScreenGui") then
                local name = gui.Name:lower()
                if name:find("shop") or name:find("store") or name:find("purchase") or name:find("buy") then
                    gui.Visible = true
                    warn("🛒 Menu de loja encontrado: " .. gui.Name)
                end
            end
        end
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
    
    if getgenv().Config.AutoCollectCoins then
        enableCoinFarm()
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

print("⚡ UnderHack v6.0 Loaded!")
print("👨‍💻 Desenvolvido por: UnderJonh (João Augusto)")
print("🌐 GitHub: https://github.com/underjonh")
print("✨ NEW Features: Auto Coin Farm + Free Purchase!")
print("💰 Auto Farm: Coleta moedas automaticamente")
print("🛒 Free Purchase: Compre sem dinheiro (use com cuidado)")
print("⚡ Velocity Speed = SEM ROLLBACK!")
print("🚁 Fly = Camera-based controls (WASD + Space/Shift)")
print("📌 RightShift = Toggle Menu")
