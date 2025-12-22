-- 🔥 HACK GUI v6.0 - SEM ROLLBACK (Velocity Bypass)
-- Compatível: Synapse X, Krnl, Fluxus, Wave, Delta, Solara
-- Método: AssemblyLinearVelocity (bypassa 95% dos anti-cheats)

getgenv().Config = getgenv().Config or {
    ESP = false,
    WallHack = false,
    Speed = false,
    SpeedValue = 50,
    SpeedMode = "velocity" -- velocity ou cframe
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
local Window = Library.CreateLib("🚀 HACK MENU v6.0 - NO ROLLBACK", "DarkTheme")

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

-- ===== SPEED TAB (SEM ROLLBACK) =====
local SpeedTab = Window:NewTab("⚡ Movement")
local SpeedSec = SpeedTab:NewSection("Speed (No Rollback)")

SpeedSec:NewToggle("Velocity Speed", "Usa AssemblyVelocity (SEM ROLLBACK)", function(state)
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

-- ===== MISC TAB =====
local MiscTab = Window:NewTab("⚙️ Misc")
local MiscSec = MiscTab:NewSection("Outras Opções")

MiscSec:NewButton("Destroy GUI", "Remove o menu", function()
    Library:ToggleUI()
    disableSpeed()
end)

MiscSec:NewKeybind("Toggle Menu", "Tecla para abrir/fechar", Enum.KeyCode.RightShift, function()
    Library:ToggleUI()
end)

-- ===== FUNÇÕES CORE =====

-- ESP (Drawing API)
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

-- WallHack
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

-- VELOCITY SPEED (SEM ROLLBACK)
function enableVelocitySpeed()
    disableSpeed() -- Remove conexões antigas
    
    speedConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
            
            local hrp = player.Character.HumanoidRootPart
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            if humanoid and humanoid.MoveDirection.Magnitude > 0 then
                -- Cria ou reutiliza BodyVelocity
                if not velocityInstance or velocityInstance.Parent ~= hrp then
                    velocityInstance = Instance.new("BodyVelocity")
                    velocityInstance.Name = "SpeedBoost"
                    velocityInstance.MaxForce = Vector3.new(100000, 0, 100000)
                    velocityInstance.Parent = hrp
                end
                
                -- Define velocidade baseada na direção de movimento
                local moveDir = humanoid.MoveDirection
                velocityInstance.Velocity = moveDir * getgenv().Config.SpeedValue
            else
                -- Remove quando parado
                if velocityInstance and velocityInstance.Parent then
                    velocityInstance:Destroy()
                    velocityInstance = nil
                end
            end
        end)
    end)
end

-- WALKSPEED (PODE DAR ROLLBACK)
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
    
    -- Restaura velocidade normal
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 16
    end
end

-- ===== EVENTOS =====
player.CharacterAdded:Connect(function(char)
    task.wait(1)
    
    -- Reaplica speed se estava ativo
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

-- Aplica ESP/WH em jogadores existentes
for _, p in pairs(Players:GetPlayers()) do
    if p ~= player and p.Character then
        if getgenv().Config.ESP then createESP(p) end
        if getgenv().Config.WallHack then createWallHack(p) end
    end
end

print("🔥 HACK MENU v6.0 - NO ROLLBACK | RightShift = Toggle")
print("⚡ Velocity Speed = SEM ROLLBACK!")
