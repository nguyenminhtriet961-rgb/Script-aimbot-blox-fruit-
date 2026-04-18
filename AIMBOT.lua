--[[
	👑 MTRIET VIP - THE FINAL VERSION 👑
	Tích hợp: Aimbot, Hitbox, ESP, Time Machine, Ghost Xịn, Inf Jump, TP Tool
	Yêu cầu: Chị Đại MinT (Dược 4) - Đã fix link Key!
]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ==============================================================================
-- 🔑 KEY SYSTEM (Link cập nhật mới nhất)
-- ==============================================================================
local KeyURL = "https://gist.githubusercontent.com/nguyenminhtriet961-rgb/d7926f773d015bfd58af1e0640b50350/raw/5493ed5b76c9a83aa2e12f2961f353d5c95c0fa9/keys.txt"
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "👑 MTRIET VIP - ULTIMATE",
    LoadingTitle = "Đang nạp hệ thống cho Chị MinT...",
    LoadingSubtitle = "Vui lòng kiểm tra lỗi chính tả trước khi chơi!",
    KeySystem = true,
    KeySettings = {
        Title = "XÁC THỰC MTRIET VIP",
        FileName = "MTRIET_Key_Final",
        SaveKey = true,
        Key = {"MinT_VIP_2026"} -- Vẫn giữ dự phòng, nhưng giờ link chính đã chạy
    }
})

-- Tự động lấy list 50 Key từ link mới
pcall(function()
    local rawText = game:HttpGet(KeyURL)
    if rawText then
        local newKeys = {"MinT_VIP_2026"}
        for key in string.gmatch(rawText, "[^\r\n]+") do
            table.insert(newKeys, key)
        end
        -- Ghi đè danh sách key của Rayfield
        Window.KeySettings.Key = newKeys
    end
end)

-- ==========================================
-- 👻 TAB: GHOST MODE & VẬN ĐỘNG
-- ==========================================
local TabGhost = Window:CreateTab("👻 Ghost & Invis")
local invisOn = false
local noclipOn = false
local ghostOn = false
local ghostSpeed = 50

local function setTransparency(char, val)
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = val end
    end
end

local function toggleInvis()
    invisOn = not invisOn
    local char = LocalPlayer.Character
    if char then
        if invisOn then
            setTransparency(char, 0.5)
            local savedpos = char.HumanoidRootPart.CFrame
            task.wait()
            char:MoveTo(Vector3.new(-25.95, 84, 3537.55))
            task.wait(0.15)
            local Seat = Instance.new("Seat", workspace)
            Seat.Anchored, Seat.CanCollide, Seat.Name, Seat.Transparency = false, false, "invischair", 1
            Seat.Position = Vector3.new(-25.95, 84, 3537.55)
            local Weld = Instance.new("Weld", Seat)
            Weld.Part0, Weld.Part1 = Seat, char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            Seat.CFrame = savedpos
            Rayfield:Notify({Title = "Tàng Hình", Content = "Đã vào chế độ Ma (Phím Z)", Duration = 2})
        else
            setTransparency(char, 0)
            if workspace:FindFirstChild("invischair") then workspace.invischair:Destroy() end
            Rayfield:Notify({Title = "Tàng Hình", Content = "Đã hiện hình", Duration = 2})
        end
    end
end

TabGhost:CreateToggle({
    Name = "Tàng Hình Ghost (Phím Z)",
    CurrentValue = false,
    Callback = function(v) if v ~= invisOn then toggleInvis() end end,
})

TabGhost:CreateSlider({
    Name = "Tốc độ Ghost", Range = {16, 200}, Increment = 1, CurrentValue = 50,
    Callback = function(v) ghostSpeed = v end,
})

TabGhost:CreateToggle({
    Name = "Chạy Nhanh Ghost (Phím B)",
    CurrentValue = false,
    Callback = function(v)
        ghostOn = v
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = ghostOn and ghostSpeed or 16 end
    end,
})

TabGhost:CreateToggle({
    Name = "Đi Xuyên Tường (Phím N)",
    CurrentValue = false,
    Callback = function(v)
        noclipOn = v
        RunService.Stepped:Connect(function()
            if noclipOn and LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    end,
})

-- ==========================================
-- 🎯 TAB: COMBAT (AIMBOT & HITBOX)
-- ==========================================
local TabCombat = Window:CreateTab("🎯 Chiến Đấu")
local AimOn = false

TabCombat:CreateToggle({
    Name = "Aimbot (Auto Lock)",
    CurrentValue = false,
    Callback = function(v) AimOn = v end,
})

RunService.RenderStepped:Connect(function()
    if AimOn then
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
    end
end)

local SizeHB = 15
TabCombat:CreateSlider({
    Name = "Size Hitbox", Range = {5, 50}, Increment = 1, CurrentValue = 15,
    Callback = function(v) SizeHB = v end,
})

TabCombat:CreateToggle({
    Name = "Bật Hitbox Expander",
    CurrentValue = false,
    Callback = function(v)
        _G.HB = v
        task.spawn(function()
            while _G.HB do
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        p.Character.HumanoidRootPart.Size = Vector3.new(SizeHB, SizeHB, SizeHB)
                        p.Character.HumanoidRootPart.Transparency = 0.7
                        p.Character.HumanoidRootPart.CanCollide = false
                    end
                end
                task.wait(1)
            end
        end)
    end,
})

-- ==========================================
-- 👁️ TAB: HIỂN THỊ (ESP HIGHLIGHT)
-- ==========================================
local TabESP = Window:CreateTab("👁️ ESP")
local ESP_On = false

TabESP:CreateToggle({
    Name = "Bật ESP Highlight",
    CurrentValue = false,
    Callback = function(v) ESP_On = v end,
})

task.spawn(function()
    while true do
        if ESP_On then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hl = p.Character:FindFirstChild("MTRIET_ESP") or Instance.new("Highlight", p.Character)
                    hl.Name = "MTRIET_ESP"
                    hl.FillColor = p.TeamColor.Color
                    hl.FillTransparency = 0.5
                end
            end
        else
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("MTRIET_ESP") then p.Character.MTRIET_ESP:Destroy() end
            end
        end
        task.wait(1)
    end
end)

-- ==========================================
-- ⏳ TAB: TIME MACHINE & OTHER
-- ==========================================
local TabOther = Window:CreateTab("⏳ Tiện Ích")
local RecData = {}
local isRec = false

TabOther:CreateToggle({
    Name = "Ghi Hình Hành Động",
    CurrentValue = false,
    Callback = function(v)
        isRec = v
        if v then RecData = {} task.spawn(function()
            while isRec do
                if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(RecData, LocalPlayer.Character.HumanoidRootPart.CFrame)
                end
                task.wait(0.05)
            end
        end) end
    end,
})

TabOther:CreateButton({
    Name = "Phát Lại (Replay)",
    Callback = function()
        for i = 1, #RecData do LocalPlayer.Character.HumanoidRootPart.CFrame = RecData[i] task.wait(0.05) end
    end,
})

local InfJump = false
TabOther:CreateToggle({
    Name = "Nhảy Vô Tận",
    CurrentValue = false,
    Callback = function(v) InfJump = v end,
})
UserInputService.JumpRequest:Connect(function()
    if InfJump then LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

TabOther:CreateButton({
    Name = "Lấy Gậy Dịch Chuyển (TP Tool)",
    Callback = function()
        local Tool = Instance.new("Tool")
        Tool.Name = "Gậy TP VIP"; Tool.RequiresHandle = false; Tool.Parent = LocalPlayer.Backpack
        Tool.Activated:Connect(function()
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0,3,0))
        end)
    end,
})

-- Phím tắt hỗ trợ
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Z then toggleInvis()
    end
end)

Rayfield:LoadConfiguration()
