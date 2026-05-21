--[[
    UNIVERSAL OBJECT CLONER - V4 (MOBILE OPTIMIZED)
    ✅ نسخ جذري للكائنات (100% Replica)
    ✅ نظام فحص المسارات والأسماء
    ✅ واجهة متحركة تدعم اللمس
]]--

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- متغيرات الحالة
local scanning = false
local selectedTarget = nil
local savedObject = nil

-- إنشاء الواجهة
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ClonerGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 220)
mainFrame.Position = UDim2.new(0.5, -125, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- يعمل على معظم المنفذات
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner", mainFrame)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "📦 مستنسخ الأشياء الاحترافي"
title.TextColor3 = Color3.fromRGB(255, 255, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = mainFrame

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0.9, 0, 0, 40)
infoLabel.Position = UDim2.new(0.05, 0, 0.15, 0)
infoLabel.Text = "الحالة: في انتظار التشغيل..."
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.BackgroundTransparency = 1
infoLabel.TextWrapped = true
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 10
infoLabel.Parent = mainFrame

-- ============ وظيفة الحصول على المسار الكامل ============
local function getFullPath(obj)
    local path = obj.Name
    local parent = obj.Parent
    while parent and parent ~= game do
        path = parent.Name .. "." .. path
        parent = parent.Parent
    end
    return "game." .. path
end

-- ============ أزرار التحكم ============

-- 1. زر التشغيل/الإيقاف (Scan Toggle)
local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(0.9, 0, 0, 35)
scanBtn.Position = UDim2.new(0.05, 0, 0.35, 0)
scanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
scanBtn.Text = "تشغيل وضع الفحص"
scanBtn.TextColor3 = Color3.new(1,1,1)
scanBtn.Font = Enum.Font.GothamBold
scanBtn.Parent = mainFrame
Instance.new("UICorner", scanBtn)

-- 2. زر التأكيد (Confirm)
local confirmBtn = Instance.new("TextButton")
confirmBtn.Size = UDim2.new(0.9, 0, 0, 35)
confirmBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
confirmBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
confirmBtn.Text = "تأكيد النسخ (OK)"
confirmBtn.TextColor3 = Color3.new(1,1,1)
confirmBtn.Visible = false
confirmBtn.Font = Enum.Font.GothamBold
confirmBtn.Parent = mainFrame
Instance.new("UICorner", confirmBtn)

-- 3. زر الرسبنة (Spawn)
local spawnBtn = Instance.new("TextButton")
spawnBtn.Size = UDim2.new(0.9, 0, 0, 35)
spawnBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
spawnBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
spawnBtn.Text = "إرساء النسخة (Select)"
spawnBtn.TextColor3 = Color3.new(1,1,1)
spawnBtn.Font = Enum.Font.GothamBold
spawnBtn.Parent = mainFrame
Instance.new("UICorner", spawnBtn)

-- ============ منطق البرمجة ============

-- تفعيل وتعطيل الفحص
scanBtn.MouseButton1Click:Connect(function()
    scanning = not scanning
    if scanning then
        scanBtn.Text = "إيقاف الفحص"
        scanBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        infoLabel.Text = "المس أي شيء في الماب لاختياره..."
    else
        scanBtn.Text = "تشغيل وضع الفحص"
        scanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    end
end)

-- التقاط الشيء عند الضغط
UserInputService.InputBegan:Connect(function(input)
    if scanning and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        local target = mouse.Target
        if target then
            -- نحاول أخذ الموديل الكامل إذا كان جزءاً من موديل
            selectedTarget = target:FindFirstAncestorOfClass("Model") or target
            infoLabel.Text = "تم اختيار: " .. selectedTarget.Name .. "\nالمسار: " .. getFullPath(selectedTarget)
            confirmBtn.Visible = true
        end
    end
end)

-- تأكيد حفظ الكائن في الذاكرة
confirmBtn.MouseButton1Click:Connect(function()
    if selectedTarget then
        savedObject = selectedTarget
        infoLabel.Text = "✅ تم حفظ النسخة الأصلية بنجاح: " .. savedObject.Name
        confirmBtn.Visible = false
        scanning = false
        scanBtn.Text = "تشغيل وضع الفحص"
        scanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    end
end)

-- رسبنة الكائن المنسوخ
spawnBtn.MouseButton1Click:Connect(function()
    if savedObject then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            -- عمل النسخة الجذرية
            local success, clone = pcall(function()
                return savedObject:Clone()
            end)

            if success and clone then
                -- التأكد من أن الكائن قابل للرسبنة (Archivable)
                clone.Parent = workspace
                
                -- تحديد الموقع (فوق اللاعب قليلاً)
                local pos = char.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
                if clone:IsA("Model") then
                    clone:MoveTo(pos)
                elseif clone:IsA("BasePart") then
                    clone.Position = pos
                end
                
                print("✅ تم رسبنة نسخة طبق الأصل من " .. savedObject.Name)
            else
                infoLabel.Text = "❌ خطأ: هذا الشيء محمي من النسخ المباشر"
            end
        end
    else
        infoLabel.Text = "⚠️ اختر شيئاً أولاً ثم اضغط OK"
    end
end)

-- نظام سحب الواجهة للجوال
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
