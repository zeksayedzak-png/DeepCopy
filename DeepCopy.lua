--[[
    MOBILE PART DELETER - V2.5 (DEEP DELETE EDITION)
    ✅ تحسين الحذف العميق (تأثير على الموبات والفيزياء)
    ✅ دعم كامل لـ Delta و Mobile
    ✅ واجهة قابلة للسحب بسلاسة
]]--

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local autoDeleteActive = false
local selectionModeActive = false
local selectedPart = nil

-- صندوق التحديد (ليظهر لك ماذا ستلحذف)
local selectionBox = Instance.new("SelectionBox")
selectionBox.Color3 = Color3.fromRGB(255, 0, 0)
selectionBox.LineThickness = 0.15
selectionBox.Parent = game.Workspace

-- ==================== بناء الواجهة (متوافقة مع الهاتف) ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeepDeleterV2"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 280)
mainFrame.Position = UDim2.new(0.5, -100, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- تفعيل السحب التلقائي لـ Delta
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Text = "🧱 Deep Deleter V2.5"
title.Size = UDim2.new(1, 0, 0, 40)
title.TextColor3 = Color3.fromRGB(0, 255, 150)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = mainFrame

-- ==================== وظيفة الحذف العميق (السر هنا) ====================
local function deepDelete(part)
    if part and part:IsA("BasePart") then
        if part.Name == "Baseplate" or part.Name == "Terrain" then return end
        
        -- 1. إبطال الفيزياء والتصادم أولاً لضمان سقوط الموبات
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.Transparency = 1
        
        -- 2. نقل الجزء لمكان سحيق لإجبار السيرفر المحلي على تحديث الموقع
        part.CFrame = CFrame.new(0, -99999, 0)
        
        -- 3. محاولة حذف الجزء نهائياً
        task.wait(0.05)
        part:Destroy()
        
        -- تنظيف التحديد
        selectionBox.Adornee = nil
        selectedPart = nil
    end
end

-- ==================== وظيفة الحصول على الهدف باللمس ====================
local function getTouchTarget(input)
    local unitRay = camera:ScreenPointToRay(input.Position.X, input.Position.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {player.Character}
    
    local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 2000, raycastParams)
    return raycastResult and raycastResult.Instance
end

-- ==================== الأزرار ====================

local function createBtn(text, pos, color)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = mainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local autoBtn = createBtn("تلقائي (لمس): OFF", UDim2.new(0.05, 0, 0.2, 0), Color3.fromRGB(180, 40, 40))
local selectModeBtn = createBtn("وضع التحديد: OFF", UDim2.new(0.05, 0, 0.42, 0), Color3.fromRGB(60, 60, 60))
local deleteBtn = createBtn("🔥 حذف نهائي", UDim2.new(0.05, 0, 0.65, 0), Color3.fromRGB(0, 120, 255))
deleteBtn.Visible = false

-- ==================== الأوامر والتحكم ====================

autoBtn.MouseButton1Click:Connect(function()
    autoDeleteActive = not autoDeleteActive
    selectionModeActive = false
    autoBtn.Text = autoDeleteActive and "تلقائي (لمس): ON" or "تلقائي (لمس): OFF"
    autoBtn.BackgroundColor3 = autoDeleteActive and Color3.fromRGB(40, 180, 40) or Color3.fromRGB(180, 40, 40)
    selectModeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    deleteBtn.Visible = false
    selectionBox.Adornee = nil
end)

selectModeBtn.MouseButton1Click:Connect(function()
    selectionModeActive = not selectionModeActive
    autoDeleteActive = false
    selectModeBtn.Text = selectionModeActive and "وضع التحديد: ON" or "وضع التحديد: OFF"
    selectModeBtn.BackgroundColor3 = selectionModeActive and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60)
    autoBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    autoBtn.Text = "تلقائي (لمس): OFF"
    deleteBtn.Visible = false
    selectionBox.Adornee = nil
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local target = getTouchTarget(input)
        if target then
            if autoDeleteActive then
                deepDelete(target)
            elseif selectionModeActive then
                if target.Name ~= "Baseplate" then
                    selectedPart = target
                    selectionBox.Adornee = target
                    deleteBtn.Visible = true
                end
            end
        end
    end
end)

deleteBtn.MouseButton1Click:Connect(function()
    if selectedPart then
        deepDelete(selectedPart)
        deleteBtn.Visible = false
    end
end)

-- زر إغلاق السكريبت
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Parent = mainFrame
Instance.new("UICorner", closeBtn)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

print("✅ Deep Part Deleter V2.5 Loaded! (Physics Optimized)")
