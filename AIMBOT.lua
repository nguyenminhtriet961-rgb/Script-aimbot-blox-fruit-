--[[
    👑 MTRIET VIP - FULL GIST & LOCAL LOCK EDITION 👑
    Đã được tối ưu hóa: Sửa lỗi thiếu End, Fix Memory Leaks, Tối ưu ESP.
]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local KeyURL = "https://gist.githubusercontent.com/nguyenminhtriet961-rgb/d7926f773d015bfd58af1e0640b50350/raw/5493ed5b76c9a83aa2e12f2961f353d5c95c0fa9/keys.txt"

-- ==============================================================================
-- 🔐 HỆ THỐNG ĐĂNG NHẬP
-- ==============================================================================
local LoginGui = Instance.new("ScreenGui")
LoginGui.Name = "MTRIET_LoginAuth"
pcall(function() LoginGui.Parent = CoreGui end)

local MainFrame = Instance.new("Frame", LoginGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
MainFrame.Size = UDim2.new(0, 300, 0, 160)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", MainFrame)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "👑 MTRIET VIP - GIST AUTH"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16

local KeyInput = Instance.new("TextBox", MainFrame)
KeyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KeyInput.Position = UDim2.new(0.05, 0, 0.35, 0)
KeyInput.Size = UDim2.new(0.9, 0, 0, 40)
KeyInput.Font = Enum.Font.Gotham
KeyInput.PlaceholderText = "Nhập mã Key vào đây..."
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.TextSize = 14
KeyInput.ClearTextOnFocus = false
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)

local LoginBtn = Instance.new("TextButton", MainFrame)
LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
LoginBtn.Position = UDim2.new(0.25, 0, 0.7, 0)
LoginBtn.Size = UDim2.new(0.5, 0, 0, 35)
LoginBtn.Font = Enum.Font.GothamBold
LoginBtn.Text = "KÍCH HOẠT VIP"
LoginBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoginBtn.TextSize = 14
Instance.new("UICorner", LoginBtn).CornerRadius = UDim.new(0, 6)

local NoclipConnection, HuntConnection, AimbotConnection
local invisOn, ghostOn, ghostSpeed, noclipOn = false, false, 50, false
local espLoop = false -- Dùng cho vòng lặp ESP tối ưu

-- ==============================================================================
-- 👑 GIAO DIỆN CHÍNH (MAIN HUB)
-- ==============================================================================
local function LoadMainHub()
    LoginGui:Destroy()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
        Name = "👑 MTRIET VIP - ULTIMATE",
        LoadingTitle = "Xác thực thành công!",
        LoadingSubtitle = "Hệ thống Gist 24h",
        ConfigurationSaving = { Enabled = true, FolderName = "MTRIET_VIP", FileName = "Config" },
        KeySystem = false 
    })

    -- ==========================================
    -- 👻 TAB: GHOST MODE
    -- ==========================================
    local TabGhost = Window:CreateTab("👻 Ghost & Invis")

    local function toggleInvis()
        invisOn = not invisOn
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end

        if invisOn then
            for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0.5 end end
            local savedpos = char.HumanoidRootPart.CFrame
            task.wait()
            char:MoveTo(Vector3.new(-25.95, 84, 3537.55)) -- Lưu ý: Tọa độ chết
            task.wait(0.15)
            
            local Seat = Instance.new("Seat")
            Seat.Anchored, Seat.CanCollide, Seat.Name, Seat.Transparency = false, false, "invischair", 1
            Seat.Position = Vector3.new(-25.95, 84, 3537.55)
            Seat.Parent = workspace
            
            local Weld = Instance.new("Weld", Seat)
            Weld.Part0, Weld.Part1 = Seat, char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            Seat.CFrame = savedpos
            Rayfield:Notify({Title = "Tàng Hình", Content = "Đã vào chế độ Ma (Phím Z)", Duration = 2})
        else
            for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0 end end
            if workspace:FindFirstChild("invischair") then workspace.invischair:Destroy() end
            if char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
            Rayfield:Notify({Title = "Tàng Hình", Content = "Đã hiện hình", Duration = 2})
        end
    end

    local function toggleNoclip(state)
        noclipOn = state
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
    end

    TabGhost:CreateToggle({Name = "Tàng Hình Ghost (Phím Z)", CurrentValue = false, Callback = function(v) if v ~= invisOn then toggleInvis() end end})
    TabGhost:CreateSlider({Name = "Tốc độ Ghost", Range = {16, 200}, Increment = 1, CurrentValue = 50, Callback = function(v) ghostSpeed = v end})
    TabGhost:CreateToggle({Name = "Chạy Nhanh Ghost (Phím B)", CurrentValue = false, Callback = function(v) 
        ghostOn = v
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = ghostOn and ghostSpeed or 16 end 
    end})
    TabGhost:CreateToggle({Name = "Đi Xuyên Tường (Phím N)", CurrentValue = false, Callback = function(v) toggleNoclip(v) end})

    -- ==========================================
    -- 🎯 TAB: COMBAT (AIMBOT & HITBOX)
    -- ==========================================
    local TabCombat = Window:CreateTab("🎯 Chiến Đấu")
    local AimOn, SizeHB = false, 15

    TabCombat:CreateToggle({Name = "Aimbot (Auto Lock)", CurrentValue = false, Callback = function(v) 
        AimOn = v 
        if AimOn then
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

    TabCombat:CreateSlider({Name = "Size Hitbox", Range = {5, 50}, Increment = 1, CurrentValue = 15, Callback = function(v) SizeHB = v end})
    TabCombat:CreateToggle({Name = "Bật Hitbox Expander", CurrentValue = false, Callback = function(v) 
        _G.HB = v
        if not v then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                    p.Character.HumanoidRootPart.Transparency = 1
                    p.Character.HumanoidRootPart.CanCollide = true
                end
            end
            return
        end
        
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
    end})

    -- ==========================================
    -- 👁️ TAB: HIỂN THỊ (ESP HIGHLIGHT) - ĐÃ TỐI ƯU
    -- ==========================================
    local TabESP = Window:CreateTab("👁️ ESP")
    TabESP:CreateToggle({Name = "Bật ESP Highlight", CurrentValue = false, Callback = function(v) 
        espLoop = v
        if v then
            task.spawn(function()
                while espLoop do
                    for _, p in pairs(Players:GetPlayers()) do 
                        if p ~= LocalPlayer and p.Character then 
                            if not p.Character:FindFirstChild("MTRIET_ESP") then
                                local hl = Instance.new("Highlight")
                                hl.Name = "MTRIET_ESP"
                                hl.FillColor = p.TeamColor and p.TeamColor.Color or Color3.new(1,0,0)
                                hl.FillTransparency = 0.5 
                                hl.Parent = p.Character
                            end
                        end 
                    end
                    task.wait(1) -- Cập nhật 1 giây/lần thay vì 60 lần/giây để chống lag
                end
            end)
        else
            for _, p in pairs(Players:GetPlayers()) do 
                if p.Character and p.Character:FindFirstChild("MTRIET_ESP") then 
                    p.Character.MTRIET_ESP:Destroy() 
                end 
            end
        end
    end})

    -- ==========================================
    -- ⏳ TAB: TIỆN ÍCH
    -- ==========================================
    local TabOther = Window:CreateTab("⏳ Tiện Ích")
    local RecData, isRec, InfJump = {}, false, false

    TabOther:CreateToggle({Name = "Ghi Hình Hành Động", CurrentValue = false, Callback = function(v) 
        isRec = v
        if v then 
            RecData = {} 
            task.spawn(function() 
                while isRec do 
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
                        table.insert(RecData, LocalPlayer.Character.HumanoidRootPart.CFrame) 
                    end 
                    task.wait(0.05) 
                end 
            end) 
        end 
    end})
    
    TabOther:CreateButton({Name = "Phát Lại (Replay)", Callback = function() 
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        for i = 1, #RecData do 
            LocalPlayer.Character.HumanoidRootPart.CFrame = RecData[i] 
            task.wait(0.05) 
        end 
    end})
    
    TabOther:CreateToggle({Name = "Nhảy Vô Tận", CurrentValue = false, Callback = function(v) InfJump = v end})
    UserInputService.JumpRequest:Connect(function() 
        if InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then 
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) 
        end 
    end)

    TabOther:CreateButton({Name = "Lấy Gậy Dịch Chuyển (TP Tool)", Callback = function() 
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

    -- ==========================================
    -- 🚀 TAB: SĂN NGƯỜI (AUTO TP BÁM ĐUÔI)
    -- ==========================================
    local TabHunt = Window:CreateTab("🚀 Săn Người")
    local SelectedPlayer = nil

    local function GetPlayerNames()
        local names = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(names, p.Name) end
        end
        return names
    end

    local PlayerDropdown = TabHunt:CreateDropdown({
        Name = "Chọn Người Chơi",
        Options = GetPlayerNames(),
        CurrentOption = {""},
        MultipleOptions = false,
        Flag = "Dropdown_Players",
        Callback = function(Option) SelectedPlayer = Option[1] end,
    })

    TabHunt:CreateButton({Name = "🔄 Làm Mới Danh Sách", Callback = function() PlayerDropdown:Refresh(GetPlayerNames(), true) end})

    TabHunt:CreateToggle({Name = "Bật Auto TP (Bám Đuôi)", CurrentValue = false, Callback = function(Value) 
        if Value then
            HuntConnection = RunService.Heartbeat:Connect(function()
                if SelectedPlayer then
                    local target = Players:FindFirstChild(SelectedPlayer)
                    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                        end
                    end
                end
            end)
        else
            if HuntConnection then HuntConnection:Disconnect() HuntConnection = nil end
        end
    end})

    -- ==========================================
    -- ⚔️ TAB: KILL AURA
    -- ==========================================
    local TabAura = Window:CreateTab("⚔️ Kill Aura")
    
    local AuraOn = false
    local AuraRange = 1000
    local AuraAttackSpeed = 0.5
    local AuraConnection
    local currentTarget = nil

    TabAura:CreateSlider({Name = "Tầm Quét Mục Tiêu (Range)", Range = {50, 5000}, Increment = 50, CurrentValue = 1000, Callback = function(v) AuraRange = v end})
    TabAura:CreateSlider({Name = "Tốc độ chém (Giây/Nhát)", Range = {0.1, 2}, Increment = 0.1, CurrentValue = 0.5, Callback = function(v) AuraAttackSpeed = v end})

    TabAura:CreateToggle({Name = "Bật Kill Aura (Tàng Hình + Chống Rơi + Hitbox)", CurrentValue = false, Callback = function(Value)
        AuraOn = Value
        
        if AuraOn then
            if LocalPlayer.Character then
                for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do 
                    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 1 end 
                end
            end

            AuraConnection = RunService.Heartbeat:Connect(function()
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
                
                local myPos = LocalPlayer.Character.HumanoidRootPart.Position

                if not currentTarget or not currentTarget:FindFirstChild("Humanoid") or currentTarget.Humanoid.Health <= 0 then
                    local shortest = AuraRange
                    local newTarget = nil
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                            local dist = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
                            if dist < shortest then
                                shortest = dist
                                newTarget = p.Character
                            end
                        end
                    end
                    currentTarget = newTarget
                end

                if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    hrp.CFrame = currentTarget.HumanoidRootPart.CFrame * CFrame.new(0, 2, 4)
                    hrp.Velocity = Vector3.zero 
                    currentTarget.HumanoidRootPart.Size = Vector3.new(20, 20, 20)
                    currentTarget.HumanoidRootPart.Transparency = 0.8
                    currentTarget.HumanoidRootPart.CanCollide = false
                end
            end)

            task.spawn(function()
                while AuraOn do
                    if currentTarget and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        local tools = {}
                        for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do if item:IsA("Tool") then table.insert(tools, item) end end
                        for _, item in ipairs(LocalPlayer.Character:GetChildren()) do if item:IsA("Tool") then table.insert(tools, item) end end

                        if #tools > 0 then
                            for _, tool in ipairs(tools) do
                                if not AuraOn or not currentTarget then break end
                                LocalPlayer.Character.Humanoid:EquipTool(tool)
                                tool:Activate()
                                task.wait(AuraAttackSpeed) 
                            end
                        else
                            task.wait(0.1)
                        end
                    else
                        task.wait(0.1)
                    end
                end
            end)

        else
            if AuraConnection then AuraConnection:Disconnect() AuraConnection = nil end
            currentTarget = nil
            
            if LocalPlayer.Character then
                for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do 
                    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0 end 
                end
            end

            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                    p.Character.HumanoidRootPart.Transparency = 1
                    p.Character.HumanoidRootPart.CanCollide = true
                end
            end
        end
    end})
end -- [ĐÃ FIX LỖI THIẾU END TẠI ĐÂY]

-- ==========================================
-- 🔐 LOGIC ĐĂNG NHẬP
-- ==========================================
LoginBtn.MouseButton1Click:Connect(function()
    local key = KeyInput.Text
    if key == "" or key:match("^%s*$") then 
        LoginBtn.Text = "CHƯA NHẬP KEY!"
        LoginBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        task.wait(1.5)
        LoginBtn.Text = "KÍCH HOẠT VIP"
        LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        return 
    end
    
    LoginBtn.Text = "ĐANG CHECK GIST..."
    LoginBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)

    local success, rawText = pcall(function() return game:HttpGet(KeyURL) end)
    
    if success and rawText then
        local isValid = false
        for validKey in string.gmatch(rawText, "[^\r\n]+") do
            if key == validKey then isValid = true break end
        end

        if isValid then
            local fileName = "MTRIET_Auth_" .. key .. ".txt"
            local currentTime = os.time()
            local expiryTime = currentTime + (24 * 60 * 60)

            if type(isfile) == "function" and type(readfile) == "function" and isfile(fileName) then
                local savedTime = tonumber(readfile(fileName))
                if savedTime and currentTime > savedTime then
                    LoginBtn.Text = "KEY ĐÃ HẾT HẠN!"
                    LoginBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                    task.wait(2)
                    LoginBtn.Text = "KÍCH HOẠT VIP"
                    LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
                    return
                end
            elseif type(writefile) == "function" then
                writefile(fileName, tostring(expiryTime))
            end

            LoadMainHub()
        else
            LoginBtn.Text = "SAI KEY HOẶC BỊ XÓA!"
            LoginBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            task.wait(2)
            LoginBtn.Text = "KÍCH HOẠT VIP"
            LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        end
    else
        LoginBtn.Text = "LỖI TẢI GITHUB!"
        LoginBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        task.wait(2)
        LoginBtn.Text = "KÍCH HOẠT VIP"
        LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    end
end)
