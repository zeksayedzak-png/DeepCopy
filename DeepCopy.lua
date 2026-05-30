-- =====================================================
-- 💀 MOZER - THE NIGHTMARE (الكابوس)
-- ⚡ يفضح كل شيء في اللعبة | Gamepasses | Remotes | Scripts
-- 🔪 يستخرج الأكواد المخفية وينسخها وينفذها
-- 😈 واجهة مرعبة | أسود + أحمر
-- =====================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local plr = Players.LocalPlayer

-- =====================================================
-- المتغيرات
-- =====================================================
local allGamepasses = {}
local allRemotes = {}
local allScripts = {}
local mainFrame = nil
local scrollFrame = nil
local miniBtn = nil
local currentTab = "Gamepasses"

-- =====================================================
-- 1. جلب Gamepasses الحقيقية
-- =====================================================
local function fetchGamepasses()
    allGamepasses = {}
    local gameId = game.PlaceId
    local url = "https://economy.roblox.com/v1/games/" .. gameId .. "/gamepasses?limit=100"
    
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    
    if success and response and response.data then
        for _, gp in ipairs(response.data) do
            table.insert(allGamepasses, {
                id = gp.id,
                name = gp.name,
                price = gp.price or 0
            })
        end
    end
    
    return allGamepasses
end

-- =====================================================
-- 2. جلب جميع الـ Remotes والأكواد المخفية
-- =====================================================
local function fetchRemotesAndScripts()
    allRemotes = {}
    allScripts = {}
    
    local function scanForScripts(container, sourcePath)
        for _, obj in pairs(container:GetChildren()) do
            if obj:IsA("LocalScript") or obj:IsA("Script") or obj:IsA("ModuleScript") then
                table.insert(allScripts, {
                    name = obj.Name,
                    source = obj.Source or "❌ No source",
                    class = obj.ClassName,
                    path = obj:GetFullName(),
                    ref = obj
                })
            end
            
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local scriptsInside = {}
                for _, child in pairs(obj:GetChildren()) do
                    if child:IsA("LocalScript") or child:IsA("Script") then
                        table.insert(scriptsInside, {
                            name = child.Name,
                            source = child.Source or "❌ No source",
                            class = child.ClassName
                        })
                        table.insert(allScripts, {
                            name = child.Name,
                            source = child.Source or "❌ No source",
                            class = child.ClassName,
                            path = child:GetFullName(),
                            ref = child
                        })
                    end
                end
                
                table.insert(allRemotes, {
                    name = obj.Name,
                    path = obj:GetFullName(),
                    className = obj.ClassName,
                    ref = obj,
                    scripts = scriptsInside
                })
            end
            
            scanForScripts(obj, sourcePath .. "/" .. obj.Name)
        end
    end
    
    scanForScripts(ReplicatedStorage, "ReplicatedStorage")
    scanForScripts(ServerScriptService, "ServerScriptService")
    scanForScripts(plr.PlayerGui, "PlayerGui")
    scanForScripts(plr.Character, "Character")
    scanForScripts(workspace, "Workspace")
    
    return allRemotes, allScripts
end

-- =====================================================
-- 3. تنفيذ Remote
-- =====================================================
local function executeRemote(remoteRef, remoteName)
    if not remoteRef then return end
    
    if remoteRef:IsA("RemoteEvent") then
        pcall(function() remoteRef:FireServer() end)
        print("💀 [Remote] Executed: " .. remoteName)
    elseif remoteRef:IsA("RemoteFunction") then
        pcall(function() remoteRef:InvokeServer() end)
        print("💀 [Remote] Invoked: " .. remoteName)
    end
end

-- =====================================================
-- 4. تنفيذ Script (تشغيل الكود)
-- =====================================================
local function executeScript(scriptRef)
    if not scriptRef then return end
    
    pcall(function()
        local cloned = scriptRef:Clone()
        cloned.Parent = plr.Character or plr
        print("💀 [Script] Executed: " .. scriptRef.Name)
        task.wait(1)
        cloned:Destroy()
    end)
end

-- =====================================================
-- 5. Method 1 (Client Bypass) على Gamepass
-- =====================================================
local function method1OnGamepass(id, name)
    local payload = {
        gamepassId = id,
        playerId = plr.UserId,
        timestamp = os.time(),
        signature = HttpService:GenerateGUID(false)
    }
    
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            pcall(function() remote:FireServer(payload) end)
        end
    end
    pcall(function() MarketplaceService:PromptProductPurchase(plr, id) end)
    print("💀 [Method 1] On: " .. name)
end

-- =====================================================
-- 6. Method 6 (Remote Replay) على Gamepass
-- =====================================================
local function method6OnGamepass(id, name)
    local payload = { gamepassId = id, playerId = plr.UserId, timestamp = os.time() }
    
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            pcall(function()
                remote:FireServer(payload)
                remote:FireServer({payload})
                remote:FireServer(id)
            end)
        end
    end
    print("💀 [Method 6] On: " .. name)
end

-- =====================================================
-- 7. وظيفة السحب
-- =====================================================
local function makeDraggable(frame)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- =====================================================
-- 8. بناء الواجهة المرعبة
-- =====================================================
local screenGui = nil
local rightContent = nil

local function showGamepassesPage()
    for _, child in pairs(rightContent:GetChildren()) do
        if child.Name ~= "UICorner" then child:Destroy() end
    end
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -10)
    scroll.Position = UDim2.new(0, 5, 0, 5)
    scroll.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
    scroll.ScrollBarThickness = 4
    scroll.Parent = rightContent
    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 10)
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scroll
    
    for i, gp in ipairs(allGamepasses) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -10, 0, 80)
        card.BackgroundColor3 = Color3.fromRGB(20, 10, 10)
        card.Parent = scroll
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -140, 0, 22)
        nameLabel.Position = UDim2.new(0, 8, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "🎮 " .. gp.name
        nameLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 11
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = card
        
        local priceLabel = Instance.new("TextLabel")
        priceLabel.Size = UDim2.new(1, -140, 0, 16)
        priceLabel.Position = UDim2.new(0, 8, 0, 28)
        priceLabel.BackgroundTransparency = 1
        priceLabel.Text = "💰 " .. gp.price .. " Robux"
        priceLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        priceLabel.Font = Enum.Font.Gotham
        priceLabel.TextSize = 10
        priceLabel.TextXAlignment = Enum.TextXAlignment.Left
        priceLabel.Parent = card
        
        local idLabel = Instance.new("TextLabel")
        idLabel.Size = UDim2.new(1, -140, 0, 16)
        idLabel.Position = UDim2.new(0, 8, 0, 46)
        idLabel.BackgroundTransparency = 1
        idLabel.Text = "🆔 ID: " .. gp.id
        idLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
        idLabel.Font = Enum.Font.Gotham
        idLabel.TextSize = 9
        idLabel.TextXAlignment = Enum.TextXAlignment.Left
        idLabel.Parent = card
        
        local copyBtn = Instance.new("TextButton")
        copyBtn.Size = UDim2.new(0, 40, 0, 28)
        copyBtn.Position = UDim2.new(1, -130, 0, 8)
        copyBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
        copyBtn.Text = "📋"
        copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        copyBtn.Font = Enum.Font.GothamBold
        copyBtn.TextSize = 14
        copyBtn.Parent = card
        Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)
        
        copyBtn.MouseButton1Click:Connect(function()
            setclipboard(tostring(gp.id))
            copyBtn.Text = "✓"
            copyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            task.delay(1, function()
                if copyBtn and copyBtn.Parent then
                    copyBtn.Text = "📋"
                    copyBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
                end
            end)
        end)
        
        local m1Btn = Instance.new("TextButton")
        m1Btn.Size = UDim2.new(0, 40, 0, 28)
        m1Btn.Position = UDim2.new(1, -85, 0, 8)
        m1Btn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
        m1Btn.Text = "1"
        m1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        m1Btn.Font = Enum.Font.GothamBold
        m1Btn.TextSize = 14
        m1Btn.Parent = card
        Instance.new("UICorner", m1Btn).CornerRadius = UDim.new(0, 6)
        
        m1Btn.MouseButton1Click:Connect(function()
            method1OnGamepass(gp.id, gp.name)
            m1Btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            task.delay(0.5, function()
                if m1Btn and m1Btn.Parent then m1Btn.BackgroundColor3 = Color3.fromRGB(80, 20, 20) end
            end)
        end)
        
        local m6Btn = Instance.new("TextButton")
        m6Btn.Size = UDim2.new(0, 40, 0, 28)
        m6Btn.Position = UDim2.new(1, -40, 0, 8)
        m6Btn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
        m6Btn.Text = "6"
        m6Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        m6Btn.Font = Enum.Font.GothamBold
        m6Btn.TextSize = 14
        m6Btn.Parent = card
        Instance.new("UICorner", m6Btn).CornerRadius = UDim.new(0, 6)
        
        m6Btn.MouseButton1Click:Connect(function()
            method6OnGamepass(gp.id, gp.name)
            m6Btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            task.delay(0.5, function()
                if m6Btn and m6Btn.Parent then m6Btn.BackgroundColor3 = Color3.fromRGB(80, 20, 20) end
            end)
        end)
    end
    
    local countLabel = Instance.new("TextLabel")
    countLabel.Size = UDim2.new(1, -10, 0, 25)
    countLabel.Position = UDim2.new(0, 5, 0, 5)
    countLabel.BackgroundTransparency = 1
    countLabel.Text = "💀 GAMEPASSES: " .. #allGamepasses
    countLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    countLabel.Font = Enum.Font.GothamBold
    countLabel.TextSize = 12
    countLabel.Parent = scroll
    
    local function updateCanvas()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 50)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    task.wait(0.05)
    updateCanvas()
end

local function showRemotesPage()
    for _, child in pairs(rightContent:GetChildren()) do
        if child.Name ~= "UICorner" then child:Destroy() end
    end
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -10)
    scroll.Position = UDim2.new(0, 5, 0, 5)
    scroll.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
    scroll.ScrollBarThickness = 4
    scroll.Parent = rightContent
    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 10)
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scroll
    
    for i, remote in ipairs(allRemotes) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -10, 0, 85 + (#remote.scripts * 28))
        card.BackgroundColor3 = Color3.fromRGB(20, 10, 10)
        card.Parent = scroll
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -120, 0, 22)
        nameLabel.Position = UDim2.new(0, 8, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "📡 " .. remote.name .. " (" .. remote.className .. ")"
        nameLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 11
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = card
        
        local pathLabel = Instance.new("TextLabel")
        pathLabel.Size = UDim2.new(1, -120, 0, 30)
        pathLabel.Position = UDim2.new(0, 8, 0, 28)
        pathLabel.BackgroundTransparency = 1
        pathLabel.Text = remote.path
        pathLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
        pathLabel.Font = Enum.Font.Gotham
        pathLabel.TextSize = 8
        pathLabel.TextWrapped = true
        pathLabel.TextXAlignment = Enum.TextXAlignment.Left
        pathLabel.Parent = card
        
        local invokeBtn = Instance.new("TextButton")
        invokeBtn.Size = UDim2.new(0, 55, 0, 28)
        invokeBtn.Position = UDim2.new(1, -62, 0, 5)
        invokeBtn.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
        invokeBtn.Text = "INVOKE"
        invokeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        invokeBtn.Font = Enum.Font.GothamBold
        invokeBtn.TextSize = 9
        invokeBtn.Parent = card
        Instance.new("UICorner", invokeBtn).CornerRadius = UDim.new(0, 6)
        
        invokeBtn.MouseButton1Click:Connect(function()
            executeRemote(remote.ref, remote.name)
            invokeBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            task.delay(0.5, function()
                if invokeBtn and invokeBtn.Parent then
                    invokeBtn.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
                end
            end)
        end)
        
        local yOffset = 60
        for j, script in ipairs(remote.scripts) do
            local scriptFrame = Instance.new("Frame")
            scriptFrame.Size = UDim2.new(1, -20, 0, 26)
            scriptFrame.Position = UDim2.new(0, 10, 0, yOffset)
            scriptFrame.BackgroundColor3 = Color3.fromRGB(25, 15, 15)
            scriptFrame.Parent = card
            Instance.new("UICorner", scriptFrame).CornerRadius = UDim.new(0, 6)
            
            local scriptLabel = Instance.new("TextLabel")
            scriptLabel.Size = UDim2.new(1, -80, 1, 0)
            scriptLabel.Position = UDim2.new(0, 8, 0, 0)
            scriptLabel.BackgroundTransparency = 1
            scriptLabel.Text = "📜 " .. script.name
            scriptLabel.TextColor3 = Color3.fromRGB(200, 200, 100)
            scriptLabel.Font = Enum.Font.Gotham
            scriptLabel.TextSize = 9
            scriptLabel.TextXAlignment = Enum.TextXAlignment.Left
            scriptLabel.Parent = scriptFrame
            
            local copyScriptBtn = Instance.new("TextButton")
            copyScriptBtn.Size = UDim2.new(0, 45, 0, 22)
            copyScriptBtn.Position = UDim2.new(1, -52, 0, 2)
            copyScriptBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
            copyScriptBtn.Text = "COPY"
            copyScriptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            copyScriptBtn.Font = Enum.Font.GothamBold
            copyScriptBtn.TextSize = 8
            copyScriptBtn.Parent = scriptFrame
            Instance.new("UICorner", copyScriptBtn).CornerRadius = UDim.new(0, 6)
            
            copyScriptBtn.MouseButton1Click:Connect(function()
                setclipboard(script.source)
                copyScriptBtn.Text = "✓"
                copyScriptBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                task.delay(1, function()
                    if copyScriptBtn and copyScriptBtn.Parent then
                        copyScriptBtn.Text = "COPY"
                        copyScriptBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
                    end
                end)
            end)
            
            yOffset = yOffset + 28
        end
        
        local copyPathBtn = Instance.new("TextButton")
        copyPathBtn.Size = UDim2.new(0, 50, 0, 24)
        copyPathBtn.Position = UDim2.new(1, -62, 0, yOffset + 5)
        copyPathBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
        copyPathBtn.Text = "📋"
        copyPathBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        copyPathBtn.Font = Enum.Font.GothamBold
        copyPathBtn.TextSize = 12
        copyPathBtn.Parent = card
        Instance.new("UICorner", copyPathBtn).CornerRadius = UDim.new(0, 6)
        
        copyPathBtn.MouseButton1Click:Connect(function()
            setclipboard(remote.path)
            copyPathBtn.Text = "✓"
            copyPathBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            task.delay(1, function()
                if copyPathBtn and copyPathBtn.Parent then
                    copyPathBtn.Text = "📋"
                    copyPathBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
                end
            end)
        end)
    end
    
    local countLabel = Instance.new("TextLabel")
    countLabel.Size = UDim2.new(1, -10, 0, 25)
    countLabel.Position = UDim2.new(0, 5, 0, 5)
    countLabel.BackgroundTransparency = 1
    countLabel.Text = "💀 REMOTES: " .. #allRemotes
    countLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    countLabel.Font = Enum.Font.GothamBold
    countLabel.TextSize = 12
    countLabel.Parent = scroll
    
    local function updateCanvas()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 50)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    task.wait(0.05)
    updateCanvas()
end

local function showScriptsPage()
    for _, child in pairs(rightContent:GetChildren()) do
        if child.Name ~= "UICorner" then child:Destroy() end
    end
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -10)
    scroll.Position = UDim2.new(0, 5, 0, 5)
    scroll.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
    scroll.ScrollBarThickness = 4
    scroll.Parent = rightContent
    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 10)
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scroll
    
    for i, script in ipairs(allScripts) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -10, 0, 75)
        card.BackgroundColor3 = Color3.fromRGB(20, 10, 10)
        card.Parent = scroll
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -120, 0, 22)
        nameLabel.Position = UDim2.new(0, 8, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "📜 " .. script.name .. " (" .. script.class .. ")"
        nameLabel.TextColor3 = Color3.fromRGB(255, 150, 100)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 11
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = card
        
        local pathLabel = Instance.new("TextLabel")
        pathLabel.Size = UDim2.new(1, -120, 0, 30)
        pathLabel.Position = UDim2.new(0, 8, 0, 28)
        pathLabel.BackgroundTransparency = 1
        pathLabel.Text = script.path
        pathLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
        pathLabel.Font = Enum.Font.Gotham
        pathLabel.TextSize = 8
        pathLabel.TextWrapped = true
        pathLabel.TextXAlignment = Enum.TextXAlignment.Left
        pathLabel.Parent = card
        
        local copyBtn = Instance.new("TextButton")
        copyBtn.Size = UDim2.new(0, 50, 0, 28)
        copyBtn.Position = UDim2.new(1, -110, 0, 5)
        copyBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
        copyBtn.Text = "COPY"
        copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        copyBtn.Font = Enum.Font.GothamBold
        copyBtn.TextSize = 9
        copyBtn.Parent = card
        Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)
        
        copyBtn.MouseButton1Click:Connect(function()
            setclipboard(script.source)
            copyBtn.Text = "✓"
            copyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            task.delay(1, function()
                if copyBtn and copyBtn.Parent then
                    copyBtn.Text = "COPY"
                    copyBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
                end
            end)
        end)
        
        local execBtn = Instance.new("TextButton")
        execBtn.Size = UDim2.new(0, 55, 0, 28)
        execBtn.Position = UDim2.new(1, -52, 0, 5)
        execBtn.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
        execBtn.Text = "EXEC"
        execBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        execBtn.Font = Enum.Font.GothamBold
        execBtn.TextSize = 9
        execBtn.Parent = card
        Instance.new("UICorner", execBtn).CornerRadius = UDim.new(0, 6)
        
        execBtn.MouseButton1Click:Connect(function()
            executeScript(script.ref)
            execBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            task.delay(0.5, function()
                if execBtn and execBtn.Parent then
                    execBtn.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
                end
            end)
        end)
    end
    
    local countLabel = Instance.new("TextLabel")
    countLabel.Size = UDim2.new(1, -10, 0, 25)
    countLabel.Position = UDim2.new(0, 5, 0, 5)
    countLabel.BackgroundTransparency = 1
    countLabel.Text = "💀 SCRIPTS: " .. #allScripts
    countLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    countLabel.Font = Enum.Font.GothamBold
    countLabel.TextSize = 12
    countLabel.Parent = scroll
    
    local function updateCanvas()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 50)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    task.wait(0.05)
    updateCanvas()
end

-- =====================================================
-- 9. بناء الواجهة الرئيسية
-- =====================================================
local function buildUI()
    local oldGui = plr.PlayerGui:FindFirstChild("Nightmare")
    if oldGui then oldGui:Destroy() end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Nightmare"
    screenGui.Parent = plr.PlayerGui
    screenGui.ResetOnSpawn = false
    
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 480, 0, 520)
    mainFrame.Position = UDim2.new(0.5, -240, 0.15, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(8, 0, 0)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
    
    -- شريط العنوان
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
    titleBar.Parent = mainFrame
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)
    
    local dragIcon = Instance.new("TextLabel")
    dragIcon.Size = UDim2.new(0, 40, 1, 0)
    dragIcon.Position = UDim2.new(0, 5, 0, 0)
    dragIcon.BackgroundTransparency = 1
    dragIcon.Text = "☰"
    dragIcon.TextColor3 = Color3.fromRGB(200, 0, 0)
    dragIcon.Font = Enum.Font.Gotham
    dragIcon.TextSize = 24
    dragIcon.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.Position = UDim2.new(0, 50, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "💀 THE NIGHTMARE 💀"
    title.TextColor3 = Color3.fromRGB(255, 0, 0)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 38, 0, 38)
    minimizeBtn.Position = UDim2.new(1, -45, 0, 3)
    minimizeBtn.Text = "✕"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
    minimizeBtn.BackgroundTransparency = 1
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 22
    minimizeBtn.Parent = titleBar
    
    -- تبويبات
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, 0, 0, 40)
    tabBar.Position = UDim2.new(0, 0, 0, 45)
    tabBar.BackgroundTransparency = 1
    tabBar.Parent = mainFrame
    
    local gamepassTab = Instance.new("TextButton")
    gamepassTab.Size = UDim2.new(0.33, -5, 1, 0)
    gamepassTab.Position = UDim2.new(0, 10, 0, 0)
    gamepassTab.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
    gamepassTab.Text = "💀 GAMEPASSES"
    gamepassTab.TextColor3 = Color3.fromRGB(255, 100, 100)
    gamepassTab.Font = Enum.Font.GothamBold
    gamepassTab.TextSize = 12
    gamepassTab.Parent = tabBar
    Instance.new("UICorner", gamepassTab).CornerRadius = UDim.new(0, 8)
    
    local remoteTab = Instance.new("TextButton")
    remoteTab.Size = UDim2.new(0.33, -5, 1, 0)
    remoteTab.Position = UDim2.new(0.34, 0, 0, 0)
    remoteTab.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
    remoteTab.Text = "📡 REMOTES"
    remoteTab.TextColor3 = Color3.fromRGB(200, 100, 100)
    remoteTab.Font = Enum.Font.GothamBold
    remoteTab.TextSize = 12
    remoteTab.Parent = tabBar
    Instance.new("UICorner", remoteTab).CornerRadius = UDim.new(0, 8)
    
    local scriptTab = Instance.new("TextButton")
    scriptTab.Size = UDim2.new(0.33, -5, 1, 0)
    scriptTab.Position = UDim2.new(0.67, 5, 0, 0)
    scriptTab.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
    scriptTab.Text = "📜 SCRIPTS"
    scriptTab.TextColor3 = Color3.fromRGB(200, 100, 100)
    scriptTab.Font = Enum.Font.GothamBold
    scriptTab.TextSize = 12
    scriptTab.Parent = tabBar
    Instance.new("UICorner", scriptTab).CornerRadius = UDim.new(0, 8)
    
    rightContent = Instance.new("Frame")
    rightContent.Size = UDim2.new(1, -20, 1, -105)
    rightContent.Position = UDim2.new(0, 10, 0, 95)
    rightContent.BackgroundColor3 = Color3.fromRGB(10, 0, 0)
    rightContent.Parent = mainFrame
    Instance.new("UICorner", rightContent).CornerRadius = UDim.new(0, 12)
    
    gamepassTab.MouseButton1Click:Connect(function()
        gamepassTab.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
        remoteTab.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
        scriptTab.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
        showGamepassesPage()
    end)
    
    remoteTab.MouseButton1Click:Connect(function()
        gamepassTab.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
        remoteTab.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
        scriptTab.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
        showRemotesPage()
    end)
    
    scriptTab.MouseButton1Click:Connect(function()
        gamepassTab.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
        remoteTab.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
        scriptTab.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
        showScriptsPage()
    end)
    
    makeDraggable(mainFrame)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        if miniBtn then miniBtn.Visible = true end
    end)
    
    showGamepassesPage()
end

-- =====================================================
-- 10. زر التصغير العالمي
-- =====================================================
local function createMinimizeButton()
    local gui = Instance.new("ScreenGui")
    gui.Name = "MinimizeBtn"
    gui.Parent = plr.PlayerGui
    gui.ResetOnSpawn = false
    
    miniBtn = Instance.new("TextButton")
    miniBtn.Size = UDim2.new(0, 65, 0, 65)
    miniBtn.Position = UDim2.new(0.03, 0, 0.75, 0)
    miniBtn.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
    miniBtn.Text = "M"
    miniBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
    miniBtn.Font = Enum.Font.FredokaOne
    miniBtn.TextSize = 34
    miniBtn.Visible = false
    miniBtn.Parent = gui
    Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 14)
    
    task.spawn(function()
        while true do
            local hue = tick() % 5 / 5
            miniBtn.TextColor3 = Color3.fromHSV(hue, 1, 1)
            task.wait(0.15)
        end
    end)
    
    miniBtn.MouseButton1Click:Connect(function()
        local nightmare = plr.PlayerGui:FindFirstChild("Nightmare")
        if nightmare and nightmare:FindFirstChildWhichIsA("Frame") then
            nightmare:FindFirstChildWhichIsA("Frame").Visible = true
            miniBtn.Visible = false
        else
            buildUI()
            miniBtn.Visible = false
        end
    end)
    
    makeDraggable(miniBtn)
end

-- =====================================================
-- 11. التشغيل الرئيسي
-- =====================================================
print("💀 MOZER - THE NIGHTMARE IS LOADING...")
fetchGamepasses()
fetchRemotesAndScripts()
createMinimizeButton()
buildUI()

print("\n💀 =====================================================")
print("💀 MOZER - THE NIGHTMARE")
print("💀 Gamepasses: " .. #allGamepasses)
print("💀 Remotes: " .. #allRemotes)
print("💀 Scripts Found: " .. #allScripts)
print("💀 =====================================================")
print("💀 3 TABS: GAMEPASSES | REMOTES | SCRIPTS")
print("💀 Each Remote shows scripts INSIDE it")
print("💀 COPY = Copy source code | INVOKE = Execute Remote")
print("💀 EXEC = Run any script")
print("💀 =====================================================")
