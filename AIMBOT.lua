--[[
	👑 MTRIET VIP - THE FINAL BOSS 👑
	Update: Full System Integration (UI, 24H Key, Combat, Movement)
	Developed for: Bác sĩ MinT (Chị Đại)
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
-- 🔑 CẤU HÌNH GITHUB GIST (Link danh sách Key 24h - Đã gắn sẵn link chuẩn của Triết)
-- ==============================================================================
local KeyURL = "https://gist.githubusercontent.com/nguyenminhtriet961-rgb/d7926f773d015bfd58af1e0640b50350/raw" 
local SaveFileName = "MTRIET_Auth_VIP.json"
local RayfieldKeyName = "MTRIET_Key_Saved"

-- ==============================================================================
-- ⏳ XỬ LÝ LƯU TRỮ VÀ XÁC THỰC KEY 24 GIỜ
-- ==============================================================================
local ValidKeys = {"MinT_VIP_2026"} -- Key dự phòng nếu mạng lag không tải được link

-- Tự động tải danh sách key từ GitHub về
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

-- Đọc file trong máy để xem đã nhập key trong vòng 24h qua chưa
if isfile(SaveFileName) then
    local success, saved = pcall(function()
        return HttpService:JSONDecode(readfile(SaveFileName))
    end)
    
    if success and saved and saved.StartTime then
        if os.time() - saved.StartTime < 86400 then -- 86400 giây = 24 giờ
            IsAuthenticated = true
            StartTime = saved.StartTime
        else
            -- Hết hạn 24h thì xóa file đi bắt nhập lại
            delfile(SaveFileName)
            if isfile(RayfieldKeyName..".txt") then
                delfile(RayfieldKeyName..".txt")
            end
        end
    end
end

-- ==============================================================================
-- 🎨 KHỞI TẠO RAYFIELD UI (MENU ĐẸP)
-- ==============================================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "👑 MTRIET VIP",
    LoadingTitle = "Đang tải hệ thống MTRIET VIP...",
    LoadingSubtitle = "Dành riêng cho Bác sĩ MinT",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MTRIET_VIP",
        FileName = "Config_MinT"
    },
    Discord = { Enabled = false },
    KeySystem = not IsAuthenticated, -- Nếu còn hạn 24h thì không hiện bảng bắt nhập key
    KeySettings = {
        Title = "XÁC THỰC MTRIET VIP",
        Subtitle = "Nhập Key để kích hoạt",
        Note = "Key có hiệu lực trong 24 giờ. Vui lòng không chia sẻ.",
        FileName = RayfieldKeyName, 
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = ValidKeys
    }
})

-- Lưu lại mốc thời gian ngay khi người dùng nhập đúng key
if not IsAuthenticated then
    StartTime = os.time()
    local data = { StartTime = StartTime }
    writefile(SaveFileName, HttpService:JSONEncode(data))
end

-- ==============================================================================
-- 📊 TAB 1: TRẠNG THÁI (ĐẾM NGƯỢC THỜI GIAN KEY)
-- ==============================================================================
local TabInfo = Window:CreateTab("📊 Trạng Thái", 4483362458)
local LabelTime = TabInfo:CreateLabel("Đang tính thời gian...")

task.spawn(function()
    while true do
        local remaining = 86400 - (os.time() - StartTime)
        if remaining <= 0 then
            LabelTime:Set("Key đã hết hạn! Vui lòng khởi động lại Script.")
            break
        end
        local hours = math.floor(remaining / 3600)
        local mins = math.floor((remaining % 3600) / 60)
        local secs = remaining % 60
        LabelTime:Set(string.format("Thời gian VIP còn lại: %02d Giờ %02d Phút %02d Giây", hours, mins, secs))
        task.wait(1)
    end
end)

-- ==============================================================================
-- ⏳ TAB 2: TIME MACHINE (CỖ MÁY THỜI GIAN)
-- ==============================================================================
local TabTime = Window:CreateTab("⏳ Time Machine", 4483362458)
local RecData = {}
local isRec, isPlaying = false, false
local playSpeed, loopCount = 1, 1

TabTime:CreateToggle({
    Name = "🔴 Ghi Hình Hành Động",
    CurrentValue = false,
    Flag = "TimeRec",
    Callback = function(Value)
        isRec = Value
        if Value then
            RecData = {}
            task.spawn(function()
                while isRec do
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        table.insert(RecData, LocalPlayer.Character.HumanoidRootPart.CFrame)
                    end
                    task.wait(0.03)
                end
            end)
        else
            Rayfield:Notify({Title = "Time Machine", Content = "Đã lưu " .. #RecData .. " khung hình.", Duration = 2})
        end
    end,
})

TabTime:CreateSlider({
    Name = "Tốc Độ Phát", Range = {1, 5}, Increment = 1, CurrentValue = 1, Flag = "TimeSpeed",
    Callback = function(Value) playSpeed = Value end,
})

TabTime:CreateSlider({
    Name = "Số Vòng Lặp", Range = {1, 20}, Increment = 1, CurrentValue = 1, Flag = "TimeLoop",
    Callback = function(Value) loopCount = Value end,
})

TabTime:CreateButton({
    Name = "▶️ PLAY (Chiếu Lại)",
    Callback = function()
        if isPlaying or #RecData == 0 then return end
        isPlaying = true
        LocalPlayer.Character.Humanoid.PlatformStand = true
        LocalPlayer.Character.HumanoidRootPart.Anchored = true
        for l = 1, loopCount do
            for i = 1, #RecData do
                if not isPlaying then break end
                LocalPlayer.Character.HumanoidRootPart.CFrame = RecData[i]
                task.wait(0.03 / playSpeed)
            end
        end
        LocalPlayer.Character.HumanoidRootPart.Anchored = false
        LocalPlayer.Character.Humanoid.PlatformStand = false
        isPlaying = false
    end,
})

TabTime:CreateButton({
    Name = "🛑 DỪNG (STOP)",
    Callback = function() isPlaying = false; isRec = false end,
})

-- ==============================================================================
-- 🏃 TAB 3: VẬN ĐỘNG (MOVEMENT)
-- ==============================================================================
local TabMove = Window:CreateTab("🏃 Vận Động", 4483362458)
local flySpd = 50
local isFlying = false

TabMove:CreateToggle({
    Name = "✈️ Fly V3",
    CurrentValue = false,
    Flag = "FlyV3",
    Callback = function(Value)
        isFlying = Value
        if Value then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local lv = Instance.new("LinearVelocity", hrp)
            lv.Name = "FlyV"; lv.MaxForce = math.huge; lv.VectorVelocity = Vector3.zero
            lv.Attachment0 = hrp:FindFirstChild("RootAttachment") or Instance.new("Attachment", hrp)
            local ao = Instance.new("AlignOrientation", hrp)
            ao.Name = "FlyO"; ao.MaxTorque = math.huge; ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
            ao.Attachment0 = lv.Attachment0
            LocalPlayer.Character.Humanoid.PlatformStand = true

            RunService:BindToRenderStep("Fly", Enum.RenderPriority.Camera.Value, function()
                if not isFlying then return end
                ao.CFrame = CFrame.new(hrp.Position, hrp.Position + Camera.CFrame.LookVector)
                local move = LocalPlayer.Character.Humanoid.MoveDirection
                local vel = (move * flySpd)
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, flySpd, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel - Vector3.new(0, flySpd, 0) end
                lv.VectorVelocity = vel
            end)
        else
            pcall(function() LocalPlayer.Character.HumanoidRootPart.FlyV:Destroy() end)
            pcall(function() LocalPlayer.Character.HumanoidRootPart.FlyO:Destroy() end)
            LocalPlayer.Character.Humanoid.PlatformStand = false
            RunService:UnbindFromRenderStep("Fly")
        end
    end,
})

TabMove:CreateSlider({
    Name = "Tốc Độ Bay (Fly Speed)", Range = {20, 200}, Increment = 5, CurrentValue = 50, Flag = "FlySpeed",
    Callback = function(Value) flySpd = Value end,
})

TabMove:CreateToggle({
    Name = "🌊 Đi Trên Nước",
    CurrentValue = false,
    Flag = "WaterWalk",
    Callback = function(Value)
        for _, x in pairs(Workspace:GetDescendants()) do
            if x:IsA("Terrain") or x.Name == "Water" then x.CanCollide = Value end
        end
        if Value then 
            local p = Instance.new("Part", Workspace)
            p.Name = "JPart"; p.Size = Vector3.new(9e4, 1, 9e4)
            p.Position = Vector3.new(0, -3.5, 0); p.Transparency = 1; p.Anchored = true 
        else 
            if Workspace:FindFirstChild("JPart") then Workspace.JPart:Destroy() end 
        end
    end,
})

TabMove:CreateSlider({
    Name = "Tốc Độ Chạy (WalkSpeed)", Range = {16, 200}, Increment = 1, CurrentValue = 16, Flag = "WalkSpeed",
    Callback = function(Value) LocalPlayer.Character.Humanoid.WalkSpeed = Value end,
})

TabMove:CreateToggle({
    Name = "👻 Xuyên Tường (Noclip)",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(Value)
        getgenv().noclip = Value
        RunService.Stepped:Connect(function() 
            if getgenv().noclip and LocalPlayer.Character then 
                for _,x in pairs(LocalPlayer.Character:GetDescendants()) do 
                    if x:IsA("BasePart") then x.CanCollide = false end 
                end 
            end 
        end)
    end,
})

-- ==============================================================================
-- ⚔️ TAB 4: CHIẾN ĐẤU (COMBAT)
-- ==============================================================================
local TabCombat = Window:CreateTab("⚔️ Chiến Đấu", 4483362458)

local aimlock = false
TabCombat:CreateToggle({
    Name = "Khóa Mục Tiêu (Aimlock Head)", CurrentValue = false, Flag = "Aimlock",
    Callback = function(Value) aimlock = Value end,
})

RunService.RenderStepped:Connect(function()
    if aimlock then
        local c, d = nil, 500
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.Head.Position).Magnitude
                if dist < d then d = dist; c = p.Character.Head end
            end
        end
        if c then Camera.CFrame = CFrame.new(Camera.CFrame.Position, c.Position) end
    end
end)

local hitboxSize = 10
TabCombat:CreateSlider({
    Name = "Kích Thước Hitbox", Range = {2, 50}, Increment = 1, CurrentValue = 10, Flag = "HitboxSize",
    Callback = function(Value) hitboxSize = Value end,
})

TabCombat:CreateToggle({
    Name = "Mở Rộng Hitbox (Hitbox Expander)",
    CurrentValue = false,
    Flag = "HitboxToggle",
    Callback = function(Value)
        getgenv().hitbox = Value
        task.spawn(function()
            while getgenv().hitbox do
                for _,p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = p.Character.HumanoidRootPart
                        hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                        hrp.Transparency = 0.6
                        hrp.BrickColor = BrickColor.new("Really blue")
                        hrp.Material = Enum.Material.Neon
                        hrp.CanCollide = false
                    end
                end
                task.wait(1)
            end
        end)
    end,
})

-- Load cài đặt tự động (Của Rayfield)
Rayfield:LoadConfiguration()
