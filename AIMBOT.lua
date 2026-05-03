--[[
    👑 MTRIET VIP - ULTIMATE MASTER EDITION (BẢN HOÀN THIỆN NHẤT) 👑
    - Full Module: Hitbox mờ tàng hình, ESP, Ghost, Máy Lượm 4 Mode.
    - Skill Aura Tối Thượng: Đổi target gần nhất, bật/tắt Max Y, Chế độ 2 Yo-Yo Drop.
    - Full Tiện ích: Fly GUI, Jump, TP Tọa độ, Xuất hồn, Lướt nhanh, Bám đuôi.
    - Quick GUI nổi 4 nút cực xịn.
]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ==================== BIẾN TOÀN CỤC ====================
local NoclipConnection, HuntConnection, AimbotConnection, AuraConnection
local invisOn, ghostOn, ghostSpeed, noclipOn = false, false, 50, false
local espLoop = false 
local AutoGomMode = "Tắt"
local AFK_SkyPos = nil

-- Biến Aura
local AuraOn = false
local AuraMode = "Chế độ 1: Đứng đỉnh đầu xả Skill"
local AuraMaxTools = 3
local AuraAutoClick = true
local AuraAutoSkills = false
local AuraRange = 1000
local AuraDistance = 5
local AuraHeight = 10
local AuraSpeed = 0.5
local FilterYOn = true
local MaxTargetHeight = 500  
local MinTargetHeight = -50  
local OrbitAngle = 0
local currentTarget = nil
local isYoYoAttacking = false -- Dành riêng cho Chế độ 2

-- Biến Boss King
local TOA_DO_1 = CFrame.new(732.4, 22.5, -113.8)
local TOA_DO_2 = CFrame.new(1379.3, -115.2, 64.4)
local TOA_DO_3 = CFrame.new(1334.2, -115.2, 70.1)
local TOA_DO_KHONG_GIAN = CFrame.new(391.8, 1285.3, 180.6)
local BOSS_NAME = "King"

-- Biến Dịch Chuyển & Săn Kẻ Địch
local RecData, isRec, InfJump = {}, false, false
local Waypoints = {}
local CurrentWPName = "Chưa Đặt Tên"
local SelectedWP = ""
local RealBodyCFrame = nil 

local TargetPlayerTP = ""
local HuntOn = false
local HuntDistance = 3
local HuntDirection = "Sau Lưng"

-- ==================== CÁC HÀM HỖ TRỢ ====================
local function DungVatPham(myTool, mode)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Humanoid") or not myTool then return end
    char.Humanoid:UnequipTools()
    task.wait(0.2)
    char.Humanoid:EquipTool(myTool)
    task.wait(0.3)
    if mode == "SkillE" then
        pcall(function()
            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end)
        task.wait(3) 
    elseif mode == "SpamAtk" then
        pcall(function() myTool:Activate() end)
    end
end

local function BayMuotXuyenTuong(targetCFrame, speed)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local timeToFly = distance / speed
    local tweenInfo = TweenInfo.new(timeToFly, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    local noclip
    noclip = RunService.Stepped:Connect(function()
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end)
    tween:Play()
    tween.Completed:Wait()
    noclip:Disconnect() 
end

local function SuperTouch(targetPart)
    local char = LocalPlayer.Character
    if not char then return end
    if firetouchinterest then
        for _, limb in ipairs(char:GetChildren()) do
            if limb:IsA("BasePart") then
                pcall(function()
                    firetouchinterest(limb, targetPart, 0)
                    task.wait(0.01)
                    firetouchinterest(limb, targetPart, 1)
                end)
            end
        end
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Velocity = Vector3.new(0, -10, 0) end
end

local function SpamSkillKeys()
    local keys = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V}
    for _, key in ipairs(keys) do
        pcall(function()
            VIM:SendKeyEvent(true, key, false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, key, false, game)
        end)
    end
end

-- ==============================================================================
-- 👑 GIAO DIỆN CHÍNH (RAYFIELD)
-- ==============================================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "👑 MTRIET VIP - ULTIMATE",
    LoadingTitle = "Đang kiểm tra bảo mật...",
    LoadingSubtitle = "Hệ thống yêu cầu nhập Key",
    ConfigurationSaving = { Enabled = true, FolderName = "MTRIET_VIP", FileName = "Config" },
    KeySystem = true,
    KeySettings = {
        Title = "🔑 Xác Thực Người Dùng",
        Subtitle = "Vui lòng nhập Key để mở Hub",
        Note = "BUY KEY TẠI MTRIET",
        FileName = "MinTHub_Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"suculu197834"} 
    }
})

-- ==========================================
-- 👻 TAB: GHOST MODE
-- ==========================================
local TabGhost = Window:CreateTab("👻 Ghost")

TabGhost:CreateToggle({Name = "Tàng Hình Ghost", CurrentValue = false, Callback = function(v) 
    invisOn = v
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    if invisOn then
        for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0.5 end end
        local savedpos = char.HumanoidRootPart.CFrame
        task.wait()
        char:MoveTo(Vector3.new(-25.95, 84, 3537.55))
        task.wait(0.15)
        local Seat = Instance.new("Seat")
        Seat.Anchored, Seat.CanCollide, Seat.Name, Seat.Transparency = false, false, "invischair", 1
        Seat.Position = Vector3.new(-25.95, 84, 3537.55)
        Seat.Parent = workspace
        local Weld = Instance.new("Weld", Seat)
        Weld.Part0, Weld.Part1 = Seat, char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        Seat.CFrame = savedpos
    else
        for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0 end end
        if workspace:FindFirstChild("invischair") then workspace.invischair:Destroy() end
        if char:FindFirstChild("Humanoid") then char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end
    end
end})
TabGhost:CreateSlider({Name = "Tốc độ Ghost", Range = {16, 200}, Increment = 1, CurrentValue = 50, Callback = function(v) ghostSpeed = v end})
TabGhost:CreateToggle({Name = "Chạy Nhanh", CurrentValue = false, Callback = function(v) 
    ghostOn = v
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = ghostOn and ghostSpeed or 16 end 
end})
TabGhost:CreateToggle({Name = "Xuyên Tường", CurrentValue = false, Callback = function(v) 
    noclipOn = v
    if noclipOn then
        NoclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if NoclipConnection then NoclipConnection:Disconnect() NoclipConnection = nil end
    end
end})

-- ==========================================
-- 🎯 TAB: COMBAT (HITBOX TRẮNG MỜ & AIMBOT)
-- ==========================================
local TabCombat = Window:CreateTab("🎯 Chiến Đấu")
local SizeHB = 25

TabCombat:CreateToggle({Name = "Aimbot (Auto Lock)", CurrentValue = false, Callback = function(v) 
    if v then
        AimbotConnection = RunService.RenderStepped:Connect(function()
            local target, dist = nil, 1000
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                    if onScreen then
                        local d = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                        if d < dist then dist = d; target = p.Character.HumanoidRootPart end
                    end
                end
            end
            if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
        end)
    else
        if AimbotConnection then AimbotConnection:Disconnect() AimbotConnection = nil end
    end
end})

TabCombat:CreateSlider({Name = "Size Hitbox", Range = {5, 100}, Increment = 1, CurrentValue = 25, Callback = function(v) SizeHB = v end})
TabCombat:CreateToggle({Name = "Tăng Hitbox (Trắng Mờ Chống Mù)", CurrentValue = false, Callback = function(v) 
    _G.HB = v
    if not v then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                p.Character.HumanoidRootPart.Transparency = 1
                p.Character.HumanoidRootPart.CanCollide = true
            end
        end
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Name ~= LocalPlayer.Name and v:FindFirstChild("HumanoidRootPart") then
                if v.HumanoidRootPart.Transparency == 0.85 then
                    v.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                    v.HumanoidRootPart.Transparency = 1
                end
            end
        end
        return
    end
    
    task.spawn(function() 
        while _G.HB do 
            for _, p in pairs(workspace:GetDescendants()) do 
                if p:IsA("Model") and p:FindFirstChild("Humanoid") and p.Name ~= LocalPlayer.Name then 
                    local hrp = p:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(SizeHB, SizeHB, SizeHB)
                        hrp.Color = Color3.new(1, 1, 1) 
                        hrp.Material = Enum.Material.SmoothPlastic -- Không dùng Neon nữa để dễ nhìn
                        hrp.Transparency = 0.85 -- Mờ 85% tàng hình
                        hrp.CanCollide = false 
                    end
                end 
            end 
            task.wait(1) 
        end 
    end) 
end})

TabCombat:CreateToggle({Name = "Bật ESP Highlight", CurrentValue = false, Callback = function(v) 
    espLoop = v
    if v then
        task.spawn(function()
            while espLoop do
                for _, p in pairs(Players:GetPlayers()) do 
                    if p ~= LocalPlayer and p.Character then 
                        if not p.Character:FindFirstChild("MTRIET_ESP") then
                            local hl = Instance.new("Highlight")
                            hl.Name = "MTRIET_ESP"
                            hl.FillColor = p.TeamColor and p.TeamColor.Color or Color3.new(1,1,1)
                            hl.FillTransparency = 0.5 
                            hl.Parent = p.Character
                        end
                    end 
                end
                task.wait(1)
            end
        end)
    else
        for _, p in pairs(Players:GetPlayers()) do 
            if p.Character and p.Character:FindFirstChild("MTRIET_ESP") then p.Character.MTRIET_ESP:Destroy() end 
        end
    end
end})

-- ==========================================
-- 💎 TAB: MÁY LƯỢM ĐỒ
-- ==========================================
local TabDrop = Window:CreateTab("💎 Máy Lượm Đồ")

TabDrop:CreateDropdown({
    Name = "Cài Đặt Chế Độ Nhặt",
    Options = {
        "Tắt", 
        "Chế độ 1: Bay xuyên tường (Tween + Noclip)", 
        "Chế độ 2: Dịch chuyển nhanh (Teleport)", 
        "Chế độ 3: AFK Trên Trời (Thả rớt)",
        "Chế độ 4: Nam Châm (Hút đồ về người)"
    },
    CurrentOption = {"Tắt"},
    Callback = function(Option)
        AutoGomMode = Option[1]
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Anchored = false
        end
        if AutoGomMode == "Chế độ 3: AFK Trên Trời (Thả rớt)" then
            if char and char:FindFirstChild("HumanoidRootPart") then
                AFK_SkyPos = char.HumanoidRootPart.Position + Vector3.new(0, 500, 0)
                char.HumanoidRootPart.CFrame = CFrame.new(AFK_SkyPos)
                char.HumanoidRootPart.Anchored = true
            end
        end
    end,
})

task.spawn(function()
    while true do
        task.wait(0.05)
        if AutoGomMode == "Tắt" then continue end
        
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        for _, item in ipairs(Workspace:GetDescendants()) do
            local itemName = item.Name:lower()
            if itemName == "diamond" or itemName == "drop" or itemName:match("soul") or itemName:match("gem") then
                local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                local touch = item:FindFirstChild("TouchInterest", true)

                if prompt or touch then
                    local targetPart = item
                    if item:IsA("Model") then targetPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart", true) end

                    if targetPart and targetPart:IsA("BasePart") then
                        if AutoGomMode == "Chế độ 1: Bay xuyên tường (Tween + Noclip)" then
                            hrp.Anchored = true 
                            BayMuotXuyenTuong(targetPart.CFrame * CFrame.new(0, 2, 0), 150)
                            hrp.Anchored = false
                            task.wait(0.1)
                        elseif AutoGomMode == "Chế độ 2: Dịch chuyển nhanh (Teleport)" then
                            hrp.CFrame = targetPart.CFrame
                            task.wait(0.1)
                        elseif AutoGomMode == "Chế độ 3: AFK Trên Trời (Thả rớt)" then
                            hrp.Anchored = false
                            hrp.CFrame = targetPart.CFrame
                            task.wait(0.1)
                        elseif AutoGomMode == "Chế độ 4: Nam Châm (Hút đồ về người)" then
                            local oldPos = hrp.CFrame
                            hrp.CFrame = targetPart.CFrame
                            task.wait(0.05)
                            if prompt then pcall(function() fireproximityprompt(prompt) end) end
                            SuperTouch(targetPart)
                            hrp.CFrame = oldPos
                        end

                        if AutoGomMode ~= "Chế độ 4: Nam Châm (Hút đồ về người)" then
                            if prompt then pcall(function() fireproximityprompt(prompt) end) end
                            SuperTouch(targetPart)
                        end

                        if AutoGomMode == "Chế độ 3: AFK Trên Trời (Thả rớt)" then
                            hrp.CFrame = CFrame.new(AFK_SkyPos)
                            hrp.Anchored = true
                            task.wait(0.1)
                        end
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- ⚔️ TAB: KILL AURA TỐI THƯỢNG
-- ==========================================
local TabAura = Window:CreateTab("⚔️ Kill Aura")

TabAura:CreateDropdown({
    Name = "Vị Trí Bay Quanh Địch (Aura Mode)",
    Options = {
        "Chế độ 1: Đứng đỉnh đầu xả Skill", 
        "Chế độ 2: Rơi từ trời chém rồi giật lên (Yo-Yo)", 
        "Chế độ 3: Xoay vòng tròn đánh thường"
    },
    CurrentOption = {"Chế độ 1: Đứng đỉnh đầu xả Skill"},
    Callback = function(Option) AuraMode = Option[1] end,
})

TabAura:CreateSlider({Name = "Khoảng Cách (Xa/Gần)", Range = {0, 50}, Increment = 1, CurrentValue = 5, Callback = function(v) AuraDistance = v end})
TabAura:CreateSlider({Name = "Chiều Cao (Trên đầu)", Range = {0, 50}, Increment = 1, CurrentValue = 10, Callback = function(v) AuraHeight = v end})
TabAura:CreateSlider({Name = "Tốc Độ Đánh (Delay)", Range = {0.1, 3}, Increment = 0.1, CurrentValue = 0.5, Callback = function(v) AuraSpeed = v end})
TabAura:CreateSlider({Name = "Tầm Quét Kẻ Địch (Range)", Range = {50, 5000}, Increment = 50, CurrentValue = 1000, Callback = function(v) AuraRange = v end})

TabAura:CreateLabel("--- TÙY CHỈNH KỸ NĂNG & VŨ KHÍ ---")
TabAura:CreateSlider({Name = "Số Lượng Vật Phẩm Dùng", Range = {1, 10}, Increment = 1, CurrentValue = 3, Callback = function(v) AuraMaxTools = v end})
TabAura:CreateToggle({Name = "Tự Động Đánh Thường (Click)", CurrentValue = true, Callback = function(v) AuraAutoClick = v end})
TabAura:CreateToggle({Name = "Tự Động Xả Phím Kỹ Năng (Z,X,C,V)", CurrentValue = false, Callback = function(v) AuraAutoSkills = v end})

TabAura:CreateLabel("--- BỘ LỌC ĐỘ CAO MỤC TIÊU ---")
TabAura:CreateToggle({Name = "Bật/Tắt Lọc Độ Cao (Max/Min Y)", CurrentValue = true, Callback = function(v) FilterYOn = v end})
TabAura:CreateSlider({Name = "Giới Hạn Cao Tối Đa (Max Y)", Range = {100, 2000}, Increment = 50, CurrentValue = 500, Callback = function(v) MaxTargetHeight = v end})
TabAura:CreateSlider({Name = "Giới Hạn Thấp Tối Thiểu (Min Y)", Range = {-500, 100}, Increment = 10, CurrentValue = -50, Callback = function(v) MinTargetHeight = v end})

TabAura:CreateToggle({Name = "🚀 Bật Kill Aura", CurrentValue = false, Callback = function(Value)
    AuraOn = Value
    if AuraOn then
        AuraConnection = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local hrp = char.HumanoidRootPart
            local myPos = hrp.Position

            -- Luôn quét lại mục tiêu GẦN NHẤT
            local shortest = AuraRange
            local newTarget = nil
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    local tPos = p.Character.HumanoidRootPart.Position
                    local validY = true
                    if FilterYOn then
                        if tPos.Y > MaxTargetHeight or tPos.Y < MinTargetHeight then validY = false end
                    end
                    if validY then
                        local dist = (tPos - myPos).Magnitude
                        if dist < shortest then
                            shortest = dist
                            newTarget = p.Character
                        end
                    end
                end
            end
            currentTarget = newTarget -- Luôn Update thằng gần nhất

            if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
                local tCFrame = currentTarget.HumanoidRootPart.CFrame
                local tPos = currentTarget.HumanoidRootPart.Position
                hrp.Velocity = Vector3.zero 
                
                if AuraMode == "Chế độ 1: Đứng đỉnh đầu xả Skill" then
                    hrp.CFrame = CFrame.new(tPos + Vector3.new(0, AuraHeight, 0), tPos)
                elseif AuraMode == "Chế độ 2: Rơi từ trời chém rồi giật lên (Yo-Yo)" then
                    if not isYoYoAttacking then
                        -- Treo lơ lửng chờ chém (AuraHeight + 30m)
                        hrp.CFrame = CFrame.new(tPos + Vector3.new(0, AuraHeight + 30, 0), tPos)
                    end
                elseif AuraMode == "Chế độ 3: Xoay vòng tròn đánh thường" then
                    OrbitAngle = OrbitAngle + math.rad(5)
                    local offset = Vector3.new(math.cos(OrbitAngle) * AuraDistance, AuraHeight, math.sin(OrbitAngle) * AuraDistance)
                    hrp.CFrame = CFrame.new(tPos + offset, tPos)
                end
            end
        end)

        task.spawn(function()
            while AuraOn do
                local char = LocalPlayer.Character
                if currentTarget and char and char:FindFirstChild("Humanoid") then
                    local tools = {}
                    for _, t in ipairs(LocalPlayer:WaitForChild("Backpack"):GetChildren()) do if t:IsA("Tool") then table.insert(tools, t) end end
                    for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") then table.insert(tools, t) end end

                    if AuraMode == "Chế độ 2: Rơi từ trời chém rồi giật lên (Yo-Yo)" then
                        local myTool = tools[2] or tools[1]
                        if myTool then
                            char.Humanoid:EquipTool(myTool)
                            isYoYoAttacking = true
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if hrp and currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
                                hrp.CFrame = currentTarget.HumanoidRootPart.CFrame * CFrame.new(0, 0, AuraDistance)
                                task.wait(0.1)
                                if AuraAutoClick then pcall(function() myTool:Activate() end) end
                                task.wait(0.15)
                            end
                            isYoYoAttacking = false
                        end
                        task.wait(AuraSpeed)
                    else
                        local maxT = math.min(AuraMaxTools, #tools)
                        if maxT > 0 then
                            for i = 1, maxT do
                                if not AuraOn or not currentTarget then break end
                                local myTool = tools[i]
                                char.Humanoid:EquipTool(myTool)
                                task.wait(0.1)
                                
                                if AuraAutoClick then pcall(function() myTool:Activate() end) end
                                if AuraAutoSkills then SpamSkillKeys() end
                                
                                task.wait(AuraSpeed)
                            end
                        else
                            task.wait(0.5)
                        end
                    end
                else
                    task.wait(0.2)
                end
            end
        end)
    else
        if AuraConnection then AuraConnection:Disconnect() AuraConnection = nil end
        currentTarget = nil
    end
end})

-- ==========================================
-- 🔮 TAB: COMBO BOSS KING
-- ==========================================
local TabBoss = Window:CreateTab("🔮 Combo Boss")
local TrieuHoiToggle 

TrieuHoiToggle = TabBoss:CreateToggle({
    Name = "🚀 Chạy Chuỗi Triệu Hồi (Nhặt -> Xả E)", 
    CurrentValue = false, 
    Callback = function(v)
        _G.AutoTrieuHoi = v
        if v then
            task.spawn(function()
                while _G.AutoTrieuHoi do
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp then break end

                    hrp.Anchored = false
                    hrp.CFrame = TOA_DO_1
                    task.wait(3) 

                    local allTools = {}
                    for _, t in ipairs(LocalPlayer:WaitForChild("Backpack"):GetChildren()) do if t:IsA("Tool") then table.insert(allTools, t) end end
                    for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") then table.insert(allTools, t) end end
                    local ToolSo2 = allTools[2]; local ToolSo3 = allTools[3]

                    if not ToolSo2 or not ToolSo3 then
                        Rayfield:Notify({Title = "Lỗi", Content = "Thiếu đồ!", Duration = 5})
                        _G.AutoTrieuHoi = false; TrieuHoiToggle:Set(false); break
                    end

                    hrp.CFrame = TOA_DO_2; task.wait(0.1); hrp.Anchored = true 
                    DungVatPham(ToolSo2, "SkillE")

                    hrp.Anchored = false; hrp.CFrame = TOA_DO_3; task.wait(0.1); hrp.Anchored = true 
                    DungVatPham(ToolSo3, "SkillE")

                    hrp.Anchored = false
                    _G.AutoTrieuHoi = false
                    TrieuHoiToggle:Set(false)
                    break 
                end
            end)
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.Anchored = false end
        end
    end
})

TabBoss:CreateToggle({
    Name = "⚔️ Đánh King & Hồi Máu (10s/10s)", 
    CurrentValue = false, 
    Callback = function(v)
        _G.AutoBoss = v
        if v then
            task.spawn(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                hrp.Anchored = false
                hrp.CFrame = TOA_DO_KHONG_GIAN
                task.wait(2)

                while _G.AutoBoss do
                    local currentTools = {}
                    for _, t in ipairs(LocalPlayer:WaitForChild("Backpack"):GetChildren()) do if t:IsA("Tool") then table.insert(currentTools, t) end end
                    for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") then table.insert(currentTools, t) end end
                    local ToolSo2 = currentTools[2]

                    local boss = workspace:FindFirstChild(BOSS_NAME, true)
                    
                    if boss and boss:FindFirstChild("HumanoidRootPart") and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
                        local bossHRP = boss.HumanoidRootPart
                        bossHRP.Size = Vector3.new(100, 100, 100) 
                        bossHRP.CanCollide = false
                        
                        local attackStart = tick()
                        hrp.Anchored = false 
                        while _G.AutoBoss and boss.Parent and (tick() - attackStart < 10) do
                            RunService.Heartbeat:Wait()
                            orbitAngle = orbitAngle + math.rad(7)
                            local offset = Vector3.new(math.cos(orbitAngle) * 12, 6, math.sin(orbitAngle) * 12)
                            hrp.CFrame = CFrame.new(bossHRP.Position + offset, bossHRP.Position)
                            hrp.Velocity = Vector3.zero 
                            if ToolSo2 then DungVatPham(ToolSo2, "SpamAtk") end
                        end
                        if not _G.AutoBoss then break end

                        local skyPos = hrp.Position + Vector3.new(0, 180, 0)
                        hrp.CFrame = CFrame.new(skyPos)
                        task.wait(0.1); hrp.Anchored = true 
                        task.wait(10)
                    else
                        task.wait(2)
                    end
                end
            end)
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.Anchored = false end
        end
    end
})

-- ==========================================
-- ⏳ TAB: TIỆN ÍCH VIP 
-- ==========================================
local TabOther = Window:CreateTab("⏳ Tiện Ích VIP")

TabOther:CreateSection("⭐ CÁC TIỆN ÍCH CƠ BẢN")

TabOther:CreateButton({Name = "🚀 Mở Bảng Fly Mobile (VIP)", Callback = function() 
    if LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("MTRIET_FlyGUI") then return end

    local main = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local up = Instance.new("TextButton")
    local down = Instance.new("TextButton")
    local onof = Instance.new("TextButton")
    local TextLabel = Instance.new("TextLabel")
    local plus = Instance.new("TextButton")
    local speed = Instance.new("TextLabel")
    local mine = Instance.new("TextButton")
    local closebutton = Instance.new("TextButton")
    local mini = Instance.new("TextButton")
    local mini2 = Instance.new("TextButton")

    main.Name = "MTRIET_FlyGUI"
    main.Parent = LocalPlayer:WaitForChild("PlayerGui")
    main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    main.ResetOnSpawn = false

    Frame.Parent = main
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Frame.BorderSizePixel = 0
    Frame.Position = UDim2.new(0.1, 0, 0.4, 0)
    Frame.Size = UDim2.new(0, 200, 0, 90)
    Frame.Active = true 
    Frame.Draggable = true
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", Frame).Color = Color3.fromRGB(0, 120, 215)
    Instance.new("UIStroke", Frame).Thickness = 2

    TextLabel.Parent = Frame
    TextLabel.BackgroundTransparency = 1
    TextLabel.Position = UDim2.new(0, 0, 0, 0)
    TextLabel.Size = UDim2.new(1, 0, 0, 30)
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.Text = "FLY GUI V3 VIP"
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextSize = 16

    up.Parent = Frame; up.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    up.Position = UDim2.new(0.05, 0, 0.35, 0); up.Size = UDim2.new(0, 55, 0, 25)
    up.Font = Enum.Font.GothamBold; up.Text = "UP"; up.TextColor3 = Color3.fromRGB(255, 255, 255); up.TextSize = 12
    Instance.new("UICorner", up).CornerRadius = UDim.new(0, 4)

    down.Parent = Frame; down.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    down.Position = UDim2.new(0.05, 0, 0.65, 0); down.Size = UDim2.new(0, 55, 0, 25)
    down.Font = Enum.Font.GothamBold; down.Text = "DOWN"; down.TextColor3 = Color3.fromRGB(255, 255, 255); down.TextSize = 12
    Instance.new("UICorner", down).CornerRadius = UDim.new(0, 4)

    onof.Parent = Frame; onof.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    onof.Position = UDim2.new(0.65, 0, 0.65, 0); onof.Size = UDim2.new(0, 60, 0, 25)
    onof.Font = Enum.Font.GothamBold; onof.Text = "FLY"; onof.TextColor3 = Color3.fromRGB(255, 255, 255); onof.TextSize = 12
    Instance.new("UICorner", onof).CornerRadius = UDim.new(0, 4)

    plus.Parent = Frame; plus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    plus.Position = UDim2.new(0.8, 0, 0.35, 0); plus.Size = UDim2.new(0, 30, 0, 25)
    plus.Font = Enum.Font.GothamBold; plus.Text = "+"; plus.TextColor3 = Color3.fromRGB(0, 255, 0); plus.TextSize = 16
    Instance.new("UICorner", plus).CornerRadius = UDim.new(0, 4)

    speed.Parent = Frame; speed.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    speed.Position = UDim2.new(0.55, 0, 0.35, 0); speed.Size = UDim2.new(0, 40, 0, 25)
    speed.Font = Enum.Font.GothamBold; speed.Text = "1"; speed.TextColor3 = Color3.fromRGB(255, 170, 0); speed.TextSize = 14
    Instance.new("UICorner", speed).CornerRadius = UDim.new(0, 4)

    mine.Parent = Frame; mine.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mine.Position = UDim2.new(0.35, 0, 0.35, 0); mine.Size = UDim2.new(0, 30, 0, 25)
    mine.Font = Enum.Font.GothamBold; mine.Text = "-"; mine.TextColor3 = Color3.fromRGB(255, 0, 0); mine.TextSize = 16
    Instance.new("UICorner", mine).CornerRadius = UDim.new(0, 4)

    closebutton.Parent = Frame; closebutton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closebutton.Position = UDim2.new(0.85, -5, -0.3, 0); closebutton.Size = UDim2.new(0, 25, 0, 25)
    closebutton.Font = Enum.Font.GothamBold; closebutton.Text = "X"; closebutton.TextColor3 = Color3.fromRGB(255, 255, 255); closebutton.TextSize = 14
    Instance.new("UICorner", closebutton).CornerRadius = UDim.new(0, 100)

    mini.Parent = Frame; mini.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    mini.Position = UDim2.new(0.7, -5, -0.3, 0); mini.Size = UDim2.new(0, 25, 0, 25)
    mini.Font = Enum.Font.GothamBold; mini.Text = "-"; mini.TextColor3 = Color3.fromRGB(255, 255, 255); mini.TextSize = 18
    Instance.new("UICorner", mini).CornerRadius = UDim.new(0, 100)

    mini2.Parent = Frame; mini2.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    mini2.Position = UDim2.new(0.7, -5, -0.3, 0); mini2.Size = UDim2.new(0, 25, 0, 25)
    mini2.Font = Enum.Font.GothamBold; mini2.Text = "+"; mini2.TextColor3 = Color3.fromRGB(255, 255, 255); mini2.TextSize = 18
    mini2.Visible = false
    Instance.new("UICorner", mini2).CornerRadius = UDim.new(0, 100)

    local speeds = 1
    local speaker = game:GetService("Players").LocalPlayer
    local nowe = false
    local tpwalking = false

    onof.MouseButton1Down:connect(function()
        if nowe == true then
            nowe = false
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,true)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,true)
            speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        else 
            nowe = true
            for i = 1, speeds do
                spawn(function()
                    local hb = game:GetService("RunService").Heartbeat  
                    tpwalking = true
                    local chr = game.Players.LocalPlayer.Character
                    local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                    while tpwalking and hb:Wait() and chr and hum and hum.Parent do
                        if hum.MoveDirection.Magnitude > 0 then
                            chr:TranslateBy(hum.MoveDirection)
                        end
                    end
                end)
            end
            speaker.Character.Animate.Disabled = true
            local Hum = speaker.Character:FindFirstChildOfClass("Humanoid") or speaker.Character:FindFirstChildOfClass("AnimationController")
            for i,v in next, Hum:GetPlayingAnimationTracks() do v:AdjustSpeed(0) end
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,false)
            speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)
            speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
        end

        local torso = speaker.Character:FindFirstChild("Torso") or speaker.Character:FindFirstChild("UpperTorso")
        if torso then
            local ctrl = {f = 0, b = 0, l = 0, r = 0}
            local lastctrl = {f = 0, b = 0, l = 0, r = 0}
            local maxspeed = 50
            local p_speed = 0
            local bg = Instance.new("BodyGyro", torso)
            bg.P = 9e4; bg.maxTorque = Vector3.new(9e9, 9e9, 9e9); bg.cframe = torso.CFrame
            local bv = Instance.new("BodyVelocity", torso)
            bv.velocity = Vector3.new(0,0.1,0); bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
            if nowe == true then speaker.Character.Humanoid.PlatformStand = true end
            while nowe == true or speaker.Character.Humanoid.Health == 0 do
                game:GetService("RunService").RenderStepped:Wait()
                if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                    p_speed = p_speed+.5+(p_speed/maxspeed)
                    if p_speed > maxspeed then p_speed = maxspeed end
                elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and p_speed ~= 0 then
                    p_speed = p_speed-1
                    if p_speed < 0 then p_speed = 0 end
                end
                if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                    bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*p_speed
                    lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
                elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and p_speed ~= 0 then
                    bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*p_speed
                else
                    bv.velocity = Vector3.new(0,0,0)
                end
                bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*p_speed/maxspeed),0,0)
            end
            bg:Destroy(); bv:Destroy()
            speaker.Character.Humanoid.PlatformStand = false
            speaker.Character.Animate.Disabled = false
            tpwalking = false
        end
    end)

    local tis
    up.MouseButton1Down:connect(function()
        tis = up.MouseEnter:connect(function()
            while tis do task.wait() speaker.Character.HumanoidRootPart.CFrame *= CFrame.new(0,1,0) end
        end)
    end)
    up.MouseLeave:connect(function() if tis then tis:Disconnect() tis = nil end end)

    local dis
    down.MouseButton1Down:connect(function()
        dis = down.MouseEnter:connect(function()
            while dis do task.wait() speaker.Character.HumanoidRootPart.CFrame *= CFrame.new(0,-1,0) end
        end)
    end)
    down.MouseLeave:connect(function() if dis then dis:Disconnect() dis = nil end end)

    plus.MouseButton1Down:connect(function()
        speeds = speeds + 1
        speed.Text = tostring(speeds)
    end)

    mine.MouseButton1Down:connect(function()
        if speeds > 1 then speeds = speeds - 1 end
        speed.Text = tostring(speeds)
    end)

    closebutton.MouseButton1Click:Connect(function() main:Destroy() end)
    mini.MouseButton1Click:Connect(function()
        up.Visible = false; down.Visible = false; onof.Visible = false; plus.Visible = false; speed.Visible = false; mine.Visible = false
        mini.Visible = false; mini2.Visible = true; Frame.BackgroundTransparency = 1; TextLabel.Visible = false
    end)
    mini2.MouseButton1Click:Connect(function()
        up.Visible = true; down.Visible = true; onof.Visible = true; plus.Visible = true; speed.Visible = true; mine.Visible = true
        mini.Visible = true; mini2.Visible = false; Frame.BackgroundTransparency = 0; TextLabel.Visible = true
    end)
    Rayfield:Notify({Title = "Thành Công", Content = "Đã mở giao diện Fly!", Duration = 2})
end})

TabOther:CreateToggle({Name = "Nhảy Vô Tận (Infinity Jump)", CurrentValue = false, Callback = function(v) InfJump = v end})
UserInputService.JumpRequest:Connect(function() 
    if InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then 
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) 
    end 
end)

TabOther:CreateToggle({Name = "Ghi Hình Hành Động", CurrentValue = false, Callback = function(v) 
    isRec = v
    if v then 
        RecData = {} 
        task.spawn(function() 
            while isRec do 
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then table.insert(RecData, LocalPlayer.Character.HumanoidRootPart.CFrame) end 
                task.wait(0.05) 
            end 
        end) 
    end 
end})

TabOther:CreateButton({Name = "▶️ Phát Lại (Replay)", Callback = function() 
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    for i = 1, #RecData do LocalPlayer.Character.HumanoidRootPart.CFrame = RecData[i]; task.wait(0.05) end 
end})

TabOther:CreateButton({Name = "🪄 Lấy Gậy Dịch Chuyển (TP Tool)", Callback = function() 
    local Tool = Instance.new("Tool")
    Tool.Name = "Gậy TP VIP"
    Tool.RequiresHandle = false
    Tool.Parent = LocalPlayer.Backpack
    Tool.Activated:Connect(function() 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0,3,0)) 
        end
    end) 
end})

TabOther:CreateButton({Name = "📋 COPY JOB ID SERVER NÀY", Callback = function() 
    if setclipboard then setclipboard(game.JobId) end
    Rayfield:Notify({Title = "Đã Copy!", Content = "Job ID đã lưu vào bộ nhớ.", Duration = 3})
end})

TabOther:CreateButton({Name = "📍 COPY TỌA ĐỘ CỦA BẠN ĐANG ĐỨNG", Callback = function() 
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local p = char.HumanoidRootPart.Position
        local str = string.format("CFrame.new(%.1f, %.1f, %.1f)", p.X, p.Y, p.Z)
        if setclipboard then setclipboard(str) end
        Rayfield:Notify({Title = "Đã Copy!", Content = str, Duration = 5})
    end
end})

TabOther:CreateSection("⏩ LƯỚT TỚI TRƯỚC")

TabOther:CreateInput({
    Name = "Nhập Số Mét Lướt (Xuyên tường)",
    PlaceholderText = "Nhập số (VD: 50)...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local dist = tonumber(Text)
        local char = LocalPlayer.Character
        if dist and char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -dist)
            Rayfield:Notify({Title = "Thành Công", Content = "Đã lướt tới trước " .. dist .. " mét!", Duration = 2})
        else
            Rayfield:Notify({Title = "Lỗi", Content = "Vui lòng nhập một con số hợp lệ!", Duration = 2})
        end
    end,
})

TabOther:CreateSection("📍 THÊM TỌA ĐỘ DỊCH CHUYỂN MỚI")

TabOther:CreateInput({
    Name = "1. Nhập Tên Địa Điểm",
    PlaceholderText = "Nhập tên rồi bấm Enter...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text) CurrentWPName = Text end,
})

local WPDropdown 
local function RefreshWPDropdown()
    local list = {}
    for name, _ in pairs(Waypoints) do table.insert(list, name) end
    if #list == 0 then table.insert(list, "(Trống)") end
    WPDropdown:Refresh(list, true)
end

TabOther:CreateButton({
    Name = "🎯 Chế Độ 1: Lưu Vị Trí Đang Đứng",
    Callback = function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and CurrentWPName ~= "" then
            Waypoints[CurrentWPName] = hrp.CFrame
            Rayfield:Notify({Title = "Thành Công", Content = "Đã lưu: " .. CurrentWPName, Duration = 3})
            RefreshWPDropdown()
        else
            Rayfield:Notify({Title = "Lỗi", Content = "Chưa nhập tên hoặc chưa có nhân vật!", Duration = 3})
        end
    end,
})

TabOther:CreateInput({
    Name = "🎯 Chế Độ 2: Nhập Tọa Độ (X, Y, Z)",
    PlaceholderText = "VD: 100, 50, -200",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local coords = string.split(Text, ",")
        if #coords == 3 and CurrentWPName ~= "" then
            local x, y, z = tonumber(coords[1]), tonumber(coords[2]), tonumber(coords[3])
            if x and y and z then
                Waypoints[CurrentWPName] = CFrame.new(x, y, z)
                Rayfield:Notify({Title = "Thành Công", Content = "Đã lưu tọa độ tay: " .. CurrentWPName, Duration = 3})
                RefreshWPDropdown()
            else
                Rayfield:Notify({Title = "Lỗi", Content = "Tọa độ không hợp lệ!", Duration = 3})
            end
        else
            Rayfield:Notify({Title = "Lỗi", Content = "Nhập đủ X, Y, Z cách nhau bằng dấu phẩy!", Duration = 3})
        end
    end,
})

TabOther:CreateToggle({
    Name = "👻 Chế Độ 3: Bật/Tắt Xuất Hồn", 
    CurrentValue = false, 
    Callback = function(Value)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if Value then
            RealBodyCFrame = hrp.CFrame
            Rayfield:Notify({Title = "Xuất Hồn", Content = "Đã để lại thể xác. Bạn đang bay ở dạng Hồn!", Duration = 3})
            for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0.5 end end
            if char:FindFirstChild("Humanoid") then char.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming) end
        else
            if RealBodyCFrame then hrp.CFrame = RealBodyCFrame end
            Rayfield:Notify({Title = "Nhập Hồn", Content = "Đã quay trở về thể xác cũ!", Duration = 3})
            for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0 end end
            if char:FindFirstChild("Humanoid") then char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end
        end
    end
})

TabOther:CreateButton({
    Name = "💾 LƯU TỌA ĐỘ CỦA HỒN ĐANG BAY",
    Callback = function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and CurrentWPName ~= "" then
            Waypoints[CurrentWPName] = hrp.CFrame
            Rayfield:Notify({Title = "Đã Lưu Điểm Xuất Hồn", Content = "Lưu thành công: " .. CurrentWPName, Duration = 3})
            RefreshWPDropdown()
        else
            Rayfield:Notify({Title = "Lỗi", Content = "Chưa nhập tên địa điểm!", Duration = 3})
        end
    end,
})

TabOther:CreateSection("🚀 QUẢN LÝ DỊCH CHUYỂN")

WPDropdown = TabOther:CreateDropdown({
    Name = "Danh Sách Địa Điểm Đã Lưu",
    Options = {"(Trống)"},
    CurrentOption = {"(Trống)"},
    MultipleOptions = false,
    Callback = function(Option) SelectedWP = Option[1] end,
})

TabOther:CreateButton({
    Name = "⚡ DỊCH CHUYỂN TỚI ĐIỂM ĐÃ CHỌN",
    Callback = function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and SelectedWP and Waypoints[SelectedWP] then
            hrp.CFrame = Waypoints[SelectedWP]
            Rayfield:Notify({Title = "Dịch Chuyển", Content = "Đã tới: " .. SelectedWP, Duration = 2})
        end
    end,
})

local ConfirmDelete = false
local DelBtn
DelBtn = TabOther:CreateButton({
    Name = "🗑️ XÓA ĐỊA ĐIỂM (Bấm để chọn)",
    Callback = function()
        if not SelectedWP or SelectedWP == "(Trống)" or not Waypoints[SelectedWP] then 
            Rayfield:Notify({Title = "Lỗi", Content = "Chưa chọn địa điểm hợp lệ để xóa!", Duration = 2})
            return 
        end

        if ConfirmDelete then
            Waypoints[SelectedWP] = nil
            RefreshWPDropdown()
            ConfirmDelete = false
            DelBtn:Set("🗑️ XÓA ĐỊA ĐIỂM (Bấm để chọn)")
            Rayfield:Notify({Title = "Thành Công", Content = "Đã xóa tọa độ!", Duration = 2})
        else
            ConfirmDelete = true
            DelBtn:Set("⚠️ BẠN CÓ CHẮC CHẮN XÓA? (BẤM LẠI ĐỂ XÁC NHẬN)")
            task.delay(3, function()
                if ConfirmDelete then
                    ConfirmDelete = false
                    DelBtn:Set("🗑️ XÓA ĐỊA ĐIỂM (Bấm để chọn)")
                end
            end)
        end
    end,
})

TabOther:CreateSection("⚔️ SĂN NGƯỜI CHƠI (BÁM ĐUÔI)")

TabOther:CreateDropdown({
    Name = "Chọn Người Để Bám Theo",
    Options = {"Cập nhật danh sách..."},
    CurrentOption = {""},
    Flag = "Dropdown_TPPlayer",
    Callback = function(Option) TargetPlayerTP = Option[1] end,
})

TabOther:CreateButton({
    Name = "🔄 Làm Mới Danh Sách",
    Callback = function()
        local list = {}
        for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(list, p.Name) end end
        if #list == 0 then table.insert(list, "Không có ai") end
        Rayfield.Flags["Dropdown_TPPlayer"]:Refresh(list, true)
    end,
})

TabOther:CreateSlider({Name = "Khoảng Cách Bám (Mét)", Range = {1, 50}, Increment = 1, CurrentValue = 3, Callback = function(v) HuntDistance = v end})

TabOther:CreateDropdown({
    Name = "Hướng Bám Theo",
    Options = {"Sau Lưng", "Trước Mặt", "Bên Trái", "Bên Phải", "Trên Đầu"},
    CurrentOption = {"Sau Lưng"},
    Callback = function(Option) HuntDirection = Option[1] end,
})

TabOther:CreateToggle({
    Name = "🚀 Bật/Tắt Bám Đuôi",
    CurrentValue = false,
    Callback = function(Value)
        HuntOn = Value
        if HuntOn then
            HuntConnection = RunService.Heartbeat:Connect(function()
                if TargetPlayerTP ~= "" and TargetPlayerTP ~= "Không có ai" then
                    local target = Players:FindFirstChild(TargetPlayerTP)
                    local char = LocalPlayer.Character
                    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and char and char:FindFirstChild("HumanoidRootPart") then
                        local hrp = char.HumanoidRootPart
                        local tCFrame = target.Character.HumanoidRootPart.CFrame
                        hrp.Velocity = Vector3.zero
                        if HuntDirection == "Sau Lưng" then
                            hrp.CFrame = tCFrame * CFrame.new(0, 0, HuntDistance)
                        elseif HuntDirection == "Trước Mặt" then
                            hrp.CFrame = tCFrame * CFrame.new(0, 0, -HuntDistance) * CFrame.Angles(0, math.rad(180), 0)
                        elseif HuntDirection == "Bên Trái" then
                            hrp.CFrame = tCFrame * CFrame.new(-HuntDistance, 0, 0) * CFrame.Angles(0, math.rad(-90), 0)
                        elseif HuntDirection == "Bên Phải" then
                            hrp.CFrame = tCFrame * CFrame.new(HuntDistance, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
                        elseif HuntDirection == "Trên Đầu" then
                            hrp.CFrame = tCFrame * CFrame.new(0, HuntDistance, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                        end
                    end
                end
            end)
        else
            if HuntConnection then HuntConnection:Disconnect() HuntConnection = nil end
        end
    end
})

-- ==============================================================================
-- 📱 MENU NÚT NỔI NGOÀI MÀN HÌNH (QUICK GUI 4 NÚT)
-- ==============================================================================
local QuickGui = Instance.new("ScreenGui")
local QuickFrame = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local BtnAura = Instance.new("TextButton")
local BtnGhost = Instance.new("TextButton")
local BtnTelePlayer = Instance.new("TextButton")
local BtnTeleWP = Instance.new("TextButton")

pcall(function() QuickGui.Parent = CoreGui end)
if QuickGui.Parent ~= CoreGui then 
    QuickGui.Parent = LocalPlayer:WaitForChild("PlayerGui") 
end
QuickGui.Name = "MTRIET_QuickGUI"
QuickGui.ResetOnSpawn = false

QuickFrame.Name = "MainFrame"
QuickFrame.Parent = QuickGui
QuickFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
QuickFrame.BackgroundTransparency = 0.5
QuickFrame.Position = UDim2.new(0, 10, 0.5, -60)
QuickFrame.Size = UDim2.new(0, 130, 0, 135) 
QuickFrame.Active = true
QuickFrame.Draggable = true

UIListLayout.Parent = QuickFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

local function TaoNut(btn, text, color)
    btn.Parent = QuickFrame
    btn.BackgroundColor3 = color
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn
end

 
TaoNut(BtnGhost, "👻 Ghost: OFF", Color3.fromRGB(100, 100, 100))
TaoNut(BtnTelePlayer, "🚀 Bám Địch: OFF", Color3.fromRGB(100, 100, 100))
TaoNut(BtnTeleWP, "📍 TP Tới Tọa Độ", Color3.fromRGB(200, 150, 0))

BtnAura.MouseButton1Click:Connect(function()
    AuraOn = not AuraOn 
    if AuraOn then
        BtnAura.Text = "⚔️ Aura: ON"
        BtnAura.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        BtnAura.Text = "⚔️ Aura: OFF"
        BtnAura.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

BtnGhost.MouseButton1Click:Connect(function()
    invisOn = not invisOn 
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    if invisOn then
        BtnGhost.Text = "👻 Ghost: ON"
        BtnGhost.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0.5 end end
        local savedpos = char.HumanoidRootPart.CFrame
        task.wait()
        char:MoveTo(Vector3.new(-25.95, 84, 3537.55))
        task.wait(0.15)
        local Seat = Instance.new("Seat")
        Seat.Anchored = false; Seat.CanCollide = false; Seat.Name = "invischair"; Seat.Transparency = 1
        Seat.Position = Vector3.new(-25.95, 84, 3537.55)
        Seat.Parent = workspace
        local Weld = Instance.new("Weld", Seat)
        Weld.Part0 = Seat; Weld.Part1 = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        Seat.CFrame = savedpos
    else
        BtnGhost.Text = "👻 Ghost: OFF"
        BtnGhost.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        
        for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0 end end
        if workspace:FindFirstChild("invischair") then workspace.invischair:Destroy() end
        if char:FindFirstChild("Humanoid") then char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end
    end
end)

BtnTelePlayer.MouseButton1Click:Connect(function()
    HuntOn = not HuntOn
    if HuntOn then
        if TargetPlayerTP == "" or TargetPlayerTP == "Không có ai" then
            HuntOn = false
            Rayfield:Notify({Title = "Lỗi", Content = "Hãy mở Hub và chọn mục tiêu trước!", Duration = 3})
            return
        end
        BtnTelePlayer.Text = "🚀 Bám Địch: ON"
        BtnTelePlayer.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        HuntConnection = RunService.Heartbeat:Connect(function()
            if TargetPlayerTP ~= "" and TargetPlayerTP ~= "Không có ai" then
                local target = Players:FindFirstChild(TargetPlayerTP)
                local char = LocalPlayer.Character
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    local tCFrame = target.Character.HumanoidRootPart.CFrame
                    hrp.Velocity = Vector3.zero
                    if HuntDirection == "Sau Lưng" then
                        hrp.CFrame = tCFrame * CFrame.new(0, 0, HuntDistance)
                    elseif HuntDirection == "Trước Mặt" then
                        hrp.CFrame = tCFrame * CFrame.new(0, 0, -HuntDistance) * CFrame.Angles(0, math.rad(180), 0)
                    elseif HuntDirection == "Bên Trái" then
                        hrp.CFrame = tCFrame * CFrame.new(-HuntDistance, 0, 0) * CFrame.Angles(0, math.rad(-90), 0)
                    elseif HuntDirection == "Bên Phải" then
                        hrp.CFrame = tCFrame * CFrame.new(HuntDistance, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
                    elseif HuntDirection == "Trên Đầu" then
                        hrp.CFrame = tCFrame * CFrame.new(0, HuntDistance, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    end
                end
            end
        end)
    else
        BtnTelePlayer.Text = "🚀 Bám Địch: OFF"
        BtnTelePlayer.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        if HuntConnection then HuntConnection:Disconnect() HuntConnection = nil end
    end
end)

BtnTeleWP.MouseButton1Click:Connect(function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp and SelectedWP and SelectedWP ~= "" and SelectedWP ~= "(Trống)" and Waypoints[SelectedWP] then
        hrp.CFrame = Waypoints[SelectedWP]
        Rayfield:Notify({Title = "Dịch Chuyển", Content = "Đã bay tới điểm: " .. SelectedWP, Duration = 2})
    else
        Rayfield:Notify({Title = "Lỗi", Content = "Hãy mở Hub và chọn 1 địa điểm trước!", Duration = 3})
    end
end)
