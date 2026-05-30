-- =====================================================
-- 👁️ MOZER - CODE INVOKER (مستدعي الأكواد)
-- ⚡ يعرض كل Remotes + الأكواد المخفية بداخلها
-- 📋 نسخ الكود | تشغيل الكود | استدعاء الـ Remote
-- =====================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local plr = Players.LocalPlayer

-- =====================================================
-- المتغيرات
-- =====================================================
local allRemotes = {}
local mainFrame = nil
local scrollFrame = nil
local miniBtn = nil

-- =====================================================
-- 1. جلب جميع الـ Remotes
-- =====================================================
local function fetchAllRemotes()
    allRemotes = {}
    local function scan(container)
        for _, obj in pairs(container:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                -- البحث عن سكريبتات داخل الـ Remote
                local scripts = {}
                for _, child in pairs(obj:GetChildren()) do
                    if child:IsA("LocalScript") or child:IsA("Script") then
                        table.insert(scripts, {
                            name = child.Name,
                            source = child.Source or "❌ No source available",
                            class = child.ClassName
                        })
                    end
                end
                
                table.insert(allRemotes, {
                    name = obj.Name,
                    path = obj:GetFullName(),
                    className = obj.ClassName,
                    ref = obj,
                    scripts = scripts
                })
            end
        end
    end
    
    scan(ReplicatedStorage)
    scan(game:GetService("Workspace"))
    scan(game:GetService("Players"))
    
    return allRemotes
end

-- =====================================================
-- 2. وظيفة السحب
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
-- 3. استدعاء الـ Remote (تشغيله)
-- =====================================================
local function executeRemote(remoteRef, remoteName)
    if not remoteRef then return end
    
    if remoteRef:IsA("RemoteEvent") then
        pcall(function() remoteRef:FireServer() end)
        print("✅ [Remote] Executed: " .. remoteName)
    elseif remoteRef:IsA("RemoteFunction") then
        pcall(function() remoteRef:InvokeServer() end)
        print("✅ [Remote] Invoked: " .. remoteName)
    end
end

-- =====================================================
-- 4. نسخ الكود (Source Code)
-- =====================================================
local function copyScriptSource(scriptObj)
    if scriptObj and scriptObj.Source then
        setclipboard(scriptObj.Source)
        print("📋 Script source copied: " .. scriptObj.Name)
        return true
    end
    return false
end

-- =====================================================
-- 5. بناء الواجهة
-- =====================================================
local function buildUI()
    local oldGui = plr.PlayerGui:FindFirstChild("CodeInvoker")
    if oldGui then oldGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CodeInvoker"
    screenGui.Parent = plr.PlayerGui
    screenGui.ResetOnSpawn = false
    
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 450, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -225, 0.15, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
    
    -- شريط العنوان
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 38)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    titleBar.Parent = mainFrame
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)
    
    local dragIcon = Instance.new("TextLabel")
    dragIcon.Size = UDim2.new(0, 35, 1, 0)
    dragIcon.Position = UDim2.new(0, 5, 0, 0)
    dragIcon.BackgroundTransparency = 1
    dragIcon.Text = "☰"
    dragIcon.TextColor3 = Color3.fromRGB(150, 150, 150)
    dragIcon.Font = Enum.Font.Gotham
    dragIcon.TextSize = 20
    dragIcon.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0, 45, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "👁️ CODE INVOKER"
    title.TextColor3 = Color3.fromRGB(200, 0, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
    minimizeBtn.Position = UDim2.new(1, -38, 0, 3)
    minimizeBtn.Text = "✕"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    minimizeBtn.BackgroundTransparency = 1
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 16
    minimizeBtn.Parent = titleBar
    
    scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -55)
    scrollFrame.Position = UDim2.new(0, 5, 0, 45)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.Parent = mainFrame
    Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 10)
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = scrollFrame
    
    -- إضافة كل Remote
    for i, remote in ipairs(allRemotes) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -10, 0, 120 + (#remote.scripts * 30))
        card.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
        card.Parent = scrollFrame
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
        
        -- اسم الـ Remote
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -120, 0, 22)
        nameLabel.Position = UDim2.new(0, 8, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "📡 " .. remote.name .. " (" .. remote.className .. ")"
        nameLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 12
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = card
        
        -- المسار
        local pathLabel = Instance.new("TextLabel")
        pathLabel.Size = UDim2.new(1, -120, 0, 30)
        pathLabel.Position = UDim2.new(0, 8, 0, 28)
        pathLabel.BackgroundTransparency = 1
        pathLabel.Text = remote.path
        pathLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
        pathLabel.Font = Enum.Font.Gotham
        pathLabel.TextSize = 9
        pathLabel.TextWrapped = true
        pathLabel.TextXAlignment = Enum.TextXAlignment.Left
        pathLabel.Parent = card
        
        -- زر INVOKE (تشغيل الـ Remote)
        local invokeBtn = Instance.new("TextButton")
        invokeBtn.Size = UDim2.new(0, 60, 0, 30)
        invokeBtn.Position = UDim2.new(1, -70, 0, 5)
        invokeBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        invokeBtn.Text = "INVOKE"
        invokeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        invokeBtn.Font = Enum.Font.GothamBold
        invokeBtn.TextSize = 10
        invokeBtn.Parent = card
        Instance.new("UICorner", invokeBtn).CornerRadius = UDim.new(0, 6)
        
        invokeBtn.MouseButton1Click:Connect(function()
            executeRemote(remote.ref, remote.name)
            invokeBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            task.delay(0.5, function()
                if invokeBtn and invokeBtn.Parent then
                    invokeBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
                end
            end)
        end)
        
        -- عرض الأكواد (الـ Scripts) داخل الـ Remote
        local yOffset = 65
        for j, script in ipairs(remote.scripts) do
            local scriptFrame = Instance.new("Frame")
            scriptFrame.Size = UDim2.new(1, -20, 0, 28)
            scriptFrame.Position = UDim2.new(0, 10, 0, yOffset)
            scriptFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            scriptFrame.Parent = card
            Instance.new("UICorner", scriptFrame).CornerRadius = UDim.new(0, 6)
            
            local scriptLabel = Instance.new("TextLabel")
            scriptLabel.Size = UDim2.new(1, -80, 1, 0)
            scriptLabel.Position = UDim2.new(0, 8, 0, 0)
            scriptLabel.BackgroundTransparency = 1
            scriptLabel.Text = "📜 " .. script.name .. " (" .. script.class .. ")"
            scriptLabel.TextColor3 = Color3.fromRGB(200, 200, 100)
            scriptLabel.Font = Enum.Font.Gotham
            scriptLabel.TextSize = 9
            scriptLabel.TextXAlignment = Enum.TextXAlignment.Left
            scriptLabel.Parent = scriptFrame
            
            -- زر COPY CODE
            local copyCodeBtn = Instance.new("TextButton")
            copyCodeBtn.Size = UDim2.new(0, 55, 0, 24)
            copyCodeBtn.Position = UDim2.new(1, -62, 0, 2)
            copyCodeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            copyCodeBtn.Text = "COPY"
            copyCodeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            copyCodeBtn.Font = Enum.Font.GothamBold
            copyCodeBtn.TextSize = 8
            copyCodeBtn.Parent = scriptFrame
            Instance.new("UICorner", copyCodeBtn).CornerRadius = UDim.new(0, 6)
            
            copyCodeBtn.MouseButton1Click:Connect(function()
                if script.source then
                    setclipboard(script.source)
                    copyCodeBtn.Text = "✓"
                    copyCodeBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                    task.delay(1, function()
                        if copyCodeBtn and copyCodeBtn.Parent then
                            copyCodeBtn.Text = "COPY"
                            copyCodeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
                        end
                    end)
                    print("📋 Code copied from: " .. script.name)
                else
                    copyCodeBtn.Text = "❌"
                    task.delay(1, function()
                        if copyCodeBtn and copyCodeBtn.Parent then
                            copyCodeBtn.Text = "COPY"
                        end
                    end)
                end
            end)
            
            yOffset = yOffset + 32
        end
        
        -- إذا لم يكن هناك أكواد
        if #remote.scripts == 0 then
            local noScriptLabel = Instance.new("TextLabel")
            noScriptLabel.Size = UDim2.new(1, -20, 0, 20)
            noScriptLabel.Position = UDim2.new(0, 10, 0, 65)
            noScriptLabel.BackgroundTransparency = 1
            noScriptLabel.Text = "⚠️ No scripts found inside this Remote"
            noScriptLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
            noScriptLabel.Font = Enum.Font.Gotham
            noScriptLabel.TextSize = 9
            noScriptLabel.TextXAlignment = Enum.TextXAlignment.Left
            noScriptLabel.Parent = card
        end
        
        -- زر Copy Path
        local copyPathBtn = Instance.new("TextButton")
        copyPathBtn.Size = UDim2.new(0, 50, 0, 24)
        copyPathBtn.Position = UDim2.new(1, -62, 0, 90 + (#remote.scripts * 30))
        copyPathBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
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
                    copyPathBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                end
            end)
        end)
    end
    
    local function updateCanvas()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    task.wait(0.1)
    updateCanvas()
    
    makeDraggable(mainFrame)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        if miniBtn then miniBtn.Visible = true end
    end)
end

-- =====================================================
-- 6. زر التصغير العالمي
-- =====================================================
local function createMinimizeButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MinimizeButton"
    screenGui.Parent = plr.PlayerGui
    screenGui.ResetOnSpawn = false
    
    miniBtn = Instance.new("TextButton")
    miniBtn.Size = UDim2.new(0, 55, 0, 55)
    miniBtn.Position = UDim2.new(0.03, 0, 0.75, 0)
    miniBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    miniBtn.Text = "M"
    miniBtn.TextColor3 = Color3.fromRGB(255, 150, 0)
    miniBtn.Font = Enum.Font.FredokaOne
    miniBtn.TextSize = 32
    miniBtn.Visible = false
    miniBtn.Parent = screenGui
    Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 14)
    
    task.spawn(function()
        while true do
            local hue = tick() % 5 / 5
            miniBtn.TextColor3 = Color3.fromHSV(hue, 1, 1)
            task.wait(0.15)
        end
    end)
    
    miniBtn.MouseButton1Click:Connect(function()
        local labGui = plr.PlayerGui:FindFirstChild("CodeInvoker")
        if labGui and labGui:FindFirstChildWhichIsA("Frame") then
            labGui:FindFirstChildWhichIsA("Frame").Visible = true
            miniBtn.Visible = false
        else
            buildUI()
            miniBtn.Visible = false
        end
    end)
    
    makeDraggable(miniBtn)
end

-- =====================================================
-- 7. التشغيل الرئيسي
-- =====================================================
fetchAllRemotes()
if #allRemotes > 0 then
    createMinimizeButton()
    buildUI()
    print("\n👁️ MOZER - CODE INVOKER")
    print("📡 " .. #allRemotes .. " Remotes detected")
    print("📜 Each Remote shows scripts inside it")
    print("📋 Press COPY to copy script source code")
    print("⚡ Press INVOKE to trigger the Remote")
else
    print("❌ No Remotes found in this game")
end
