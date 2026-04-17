--[[
	👑 MTRIET VIP - THE FINAL BOSS (ULTIMATE VERSION) 👑
	Update: Full Integration (UI, 24H Key, ESP, Invis, Inf Jump, TP Tool)
	Developed for: Bác sĩ MinT (Chị Đại)
	Code by: Gemini (Em trai AI của chị)
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
-- 🔑 CẤU HÌNH KEY (Lấy từ Gist của nhóc Triết)
-- ==============================================================================
local KeyURL = "https://gist.githubusercontent.com/nguyenminhtriet961-rgb/d7926f773d015bfd58af1e0640b50350/raw" 
local SaveFileName = "MTRIET_Auth_VIP.json"
local RayfieldKeyName = "MTRIET_Key_Saved"

local ValidKeys = {"MinT_VIP_2026"} 
pcall(function()
    local rawText = game:HttpGet(KeyURL)
    if rawText then
        ValidKeys = {}
        for key in string.gmatch(rawText, "[^\r\n]+") do
            table.insert(ValidKeys, key)
        end
    end
end)

local IsAuthenticated = false
local StartTime = 0

if isfile(SaveFileName) then
    local success, saved = pcall(function()
        return HttpService:JSONDecode(readfile(SaveFileName))
    end)
    if success and saved and saved.StartTime then
        if os.time() - saved.StartTime < 86400 then
            IsAuthenticated = true
            StartTime = saved.StartTime
        else
            delfile(SaveFileName)
        end
    end
end

-- ==============================================================================
-- 🎨 KHỞI TẠO RAYFIELD UI
-- ==============================================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "👑 MTRIET VIP",
    LoadingTitle = "Đang khởi động MTRIET VIP...",
    LoadingSubtitle = "Dành riêng cho Chị Đại MinT",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MTRIET_VIP",
        FileName = "Config"
    },
    KeySystem = not IsAuthenticated,
    KeySettings = {
        Title = "XÁC THỰC MTRIET VIP",
        Subtitle = "Hệ thống bảo mật 24 Giờ",
        Note = "Key được quản lý bởi MinT. Vui lòng không chia sẻ.",
        FileName = RayfieldKeyName, 
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = ValidKeys
    }
})

if not IsAuthenticated then
    StartTime = os.time()
    writefile(SaveFileName, HttpService:JSONEncode({StartTime = StartTime}))
end

-- ==============================================================================
-- 📊 TAB: TRẠNG THÁI (STATUS)
-- ==============================================================================
local TabInfo = Window:CreateTab("📊 Trạng Thái")
local LabelTime = TabInfo:CreateLabel("Đang tính thời gian...")

task.spawn(function()
    while true do
        local remaining = 86400 - (os.time() - StartTime)
        if remaining <= 0 then
            LabelTime:Set("Key đã hết hạn! Vui lòng reset script.")
            break
        end
        local hours = math.floor(remaining / 3600)
        local mins = math.floor((remaining % 3600) / 60)
        local secs = remaining % 60
        LabelTime:Set(string.format("VIP còn lại: %02d Giờ %02d Phút %02d Giây", hours, mins, secs))
        task.wait(1)
    end
end)

-- ==============================================================================
-- 🏃 TAB: VẬN ĐỘNG (MOVEMENT)
-- ==============================================================================
local TabMove = Window:CreateTab("🏃 Vận Động")

-- Infinity Jump
local InfJumpEnabled = false
TabMove:CreateToggle({
    Name = "Nhảy Vô Tận (Infinity Jump)",
    CurrentValue = false,
    Callback = function(Value) InfJumpEnabled = Value end,
})

UserInputService.JumpRequest:Connect(function()
    if InfJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- TP Tool
TabMove:CreateButton({
    Name = "Lấy Gậy Dịch Chuyển (TP Tool)",
    Callback = function()
        local TPTool = Instance.new("Tool")
        TPTool.Name = "Gậy Dịch Chuyển VIP"
        TPTool.RequiresHandle = false
        TPTool.Parent = LocalPlayer.Backpack
        TPTool.Activated:Connect(function()
            local pos = Mouse.Hit.Position + Vector3.new(0, 3, 0)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
            end
        end)
        Rayfield:Notify({Title = "MTRIET VIP", Content = "Đã thêm gậy TP vào túi đồ!", Duration = 2})
    end,
})

TabMove:CreateSlider({
    Name = "Tốc Độ Chạy", Range = {16, 250}, Increment = 1, CurrentValue = 16,
    Callback = function(v) if LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = v end end,
})

TabMove:CreateToggle({
    Name = "Đi Trên Nước (Jesus)",
    CurrentValue = false,
    Callback = function(Value)
        for _, x in pairs(Workspace:GetDescendants()) do
            if x:IsA("Terrain") or x.Name == "Water" then x.CanCollide = Value end
        end
    end,
})

-- ==============================================================================
-- 👁️ TAB: HIỂN THỊ (ESP)
-- ==============================================================================
local TabESP = Window:CreateTab("👁️ Hiển Thị")
local ESPEnabled = false

TabESP:CreateToggle({
    Name = "Bật ESP Highlight (Nhìn xuyên tường)",
    CurrentValue = false,
    Callback = function(Value) ESPEnabled = Value end,
})

task.spawn(function()
    while true do
        if ESPEnabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hl = p.Character:FindFirstChild("MTRIET_ESP") or Instance.new("Highlight", p.Character)
                    hl.Name = "MTRIET_ESP"
                    hl.FillColor = p.TeamColor.Color
                    hl.FillTransparency = 0.5
                    hl.OutlineColor = Color3.new(1,1,1)
                end
            end
        else
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("MTRIET_ESP") then 
                    p.Character.MTRIET_ESP:Destroy() 
                end
            end
        end
        task.wait(1)
    end
end)

-- ==============================================================================
-- 🤡 TAB: TÀNG HÌNH & TROLL
-- ==============================================================================
local TabTroll = Window:CreateTab("🤡 Troll")

TabTroll:CreateToggle({
    Name = "Tàng Hình (Ghost Mode)",
    CurrentValue = false,
    Callback = function(Value)
        local char = LocalPlayer.Character
        if char then
            if Value then
                local savedpos = char.HumanoidRootPart.CFrame
                local Seat = Instance.new("Seat", workspace)
                Seat.Name = "MTRIET_InvisChair"; Seat.Transparency = 1; Seat.Position = Vector3.new(0, 5000, 0)
                local Weld = Instance.new("Weld", Seat)
                Weld.Part0 = Seat; Weld.Part1 = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                Seat.CFrame = savedpos
            else
                if workspace:FindFirstChild("MTRIET_InvisChair") then 
                    workspace.MTRIET_InvisChair:Destroy() 
                end
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end,
})

Rayfield:LoadConfiguration()
