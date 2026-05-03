--[[
    👑 MTRIET ULTIMATE - V22 ALL-IN-ONE MASTER EDITION 👑
    - Fix Hitbox: Màu trắng, trong suốt, phát sáng Neon.
    - Fix Máy Lượm: Dùng TweenService để "bay" mượt mà tới Linh hồn & Kim cương.
    - Gộp toàn bộ tính năng VIP và Combo Modular Boss vào chung 1 bảng.
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

-- Biến toàn cục
local NoclipConnection, HuntConnection, AimbotConnection, AuraConnection
local invisOn, ghostOn, ghostSpeed, noclipOn = false, false, 50, false
local espLoop = false 
local AutoGomMode = 0
local AFK_SkyPos = nil

-- Tọa độ Boss & Triệu Hồi
local TOA_DO_1 = CFrame.new(732.4, 22.5, -113.8)
local TOA_DO_2 = CFrame.new(1379.3, -115.2, 64.4)
local TOA_DO_3 = CFrame.new(1334.2, -115.2, 70.1)
local TOA_DO_KHONG_GIAN = CFrame.new(391.8, 1285.3, 180.6)
local BOSS_NAME = "King"
local orbitAngle = 0

-- ==============================================================================
-- 🛠️ CÁC HÀM HỖ TRỢ DÙNG CHUNG
-- ==============================================================================
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

-- Hàm bay mượt (Tween) cho Máy Lượm Đồ
local function BayToi(targetCFrame, speed)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local timeToFly = distance / speed
    
    local tweenInfo = TweenInfo.new(timeToFly, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    
    tween:Play()
    tween.Completed:Wait() -- Đợi bay tới nơi mới làm tiếp
end

-- ==============================================================================
-- 👑 GIAO DIỆN CHÍNH (MAIN HUB)
-- ==============================================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "👑 MTRIET V22 - ALL IN ONE",
    LoadingTitle = "Đã tải V22",
    LoadingSubtitle = "Hitbox Trắng & Tween Lượm Đồ",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false 
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
-- 🎯 TAB: COMBAT (HITBOX TRẮNG & AIMBOT)
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
TabCombat:CreateToggle({Name = "Tăng Hitbox Trắng Trong Suốt", CurrentValue = false, Callback = function(v) 
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
                if v.HumanoidRootPart.Transparency == 0.5 then
                    v.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                    v.HumanoidRootPart.Transparency = 1
                end
            end
        end
        return
    end
    
    task.spawn(function() 
        while _G.HB do 
            -- Bơm Mobs và Players
            for _, p in pairs(workspace:GetDescendants()) do 
                if p:IsA("Model") and p:FindFirstChild("Humanoid") and p.Name ~= LocalPlayer.Name then 
                    local hrp = p:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(SizeHB, SizeHB, SizeHB)
                        hrp.Color = Color3.new(1, 1, 1) -- Đổi thành MÀU TRẮNG
                        hrp.Material = Enum.Material.Neon -- Phát sáng nhẹ
                        hrp.Transparency = 0.5 -- Trong suốt
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
-- 💎 TAB: MÁY LƯỢM K.CƯƠNG & LINH HỒN (BAY MƯỢT)
-- ==========================================
local TabDrop = Window:CreateTab("💎 Máy Lượm")

TabDrop:CreateDropdown({
    Name = "Chọn Chế Độ Nhặt",
    Options = {"Tắt", "Chế độ 1: Lướt bay tới nhặt (An toàn)", "Chế độ 2: Teleport nhặt", "Chế độ 3: AFK Trên Trời"},
    CurrentOption = {"Tắt"},
    Callback = function(Option)
        if Option[1] == "Tắt" then 
            AutoGomMode = 0
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.Anchored = false end
        elseif Option[1] == "Chế độ 1: Lướt bay tới nhặt (An toàn)" then 
            AutoGomMode = 1
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.Anchored = false end
        elseif Option[1] == "Chế độ 2: Teleport nhặt" then 
            AutoGomMode = 2
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.Anchored = false end
        elseif Option[1] == "Chế độ 3: AFK Trên Trời" then 
            AutoGomMode = 3
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                AFK_SkyPos = LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 500, 0)
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(AFK_SkyPos)
                LocalPlayer.Character.HumanoidRootPart.Anchored = true
            end
        end
    end,
})

task.spawn(function()
    while true do
        task.wait(0.1)
        if AutoGomMode == 0 then continue end
        
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        for _, item in ipairs(workspace:GetDescendants()) do
            local itemName = item.Name:lower()
            -- Quét kim cương, drop, linh hồn
            if (itemName == "diamond" or itemName == "drop" or itemName:match("soul")) and item:IsA("BasePart") then
                local prompt = item:FindFirstChildWhichIsA("ProximityPrompt")
                local touch = item:FindFirstChild("TouchInterest")

                if prompt or touch then
                    -- Bay tới mượt mà bằng TweenService
                    if AutoGomMode == 1 then
                        hrp.Anchored = true -- Giữ thăng bằng lúc bay
                        BayToi(item.CFrame * CFrame.new(0, 2, 0), 100) -- Bay tốc độ 100
                        hrp.Anchored = false
                        task.wait(0.2)
                    -- Teleport giật cục
                    elseif AutoGomMode == 2 then
                        hrp.CFrame = item.CFrame
                        task.wait(0.1)
                    -- Teleport từ trên trời xuống
                    elseif AutoGomMode == 3 then
                        hrp.Anchored = false
                        hrp.CFrame = item.CFrame
                        task.wait(0.1)
                    end

                    -- Kích hoạt nhặt đồ
                    if prompt then fireproximityprompt(prompt) end
                    if touch and firetouchinterest then
                        firetouchinterest(hrp, item, 0)
                        task.wait(0.1)
                        firetouchinterest(hrp, item, 1)
                    end

                    if AutoGomMode == 3 then
                        hrp.CFrame = CFrame.new(AFK_SkyPos)
                        hrp.Anchored = true
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- 🔮 TAB: MODULAR BOSS (TRIỆU HỒI & ĐÁNH KING)
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
-- ⏳ TAB: TIỆN ÍCH
-- ==========================================
local TabOther = Window:CreateTab("⏳ Tiện Ích")

TabOther:CreateButton({
    Name = "📋 COPY JOB ID SERVER NÀY", 
    Callback = function() 
        if setclipboard then setclipboard(game.JobId) end
        Rayfield:Notify({Title = "Đã Copy!", Content = "Job ID đã lưu vào bộ nhớ.", Duration = 3})
    end
})

TabOther:CreateButton({
    Name = "📍 COPY TỌA ĐỘ CỦA CHỊ ĐANG ĐỨNG", 
    Callback = function() 
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local str = string.format("CFrame.new(%.1f, %.1f, %.1f)", char.HumanoidRootPart.Position.X, char.HumanoidRootPart.Position.Y, char.HumanoidRootPart.Position.Z)
            if setclipboard then setclipboard(str) end
            Rayfield:Notify({Title = "Đã Copy!", Content = str, Duration = 5})
        end
    end
})

local InfJump = false
TabOther:CreateToggle({Name = "Nhảy Vô Tận", CurrentValue = false, Callback = function(v) InfJump = v end})
UserInputService.JumpRequest:Connect(function() 
    if InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then 
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) 
    end 
end)
