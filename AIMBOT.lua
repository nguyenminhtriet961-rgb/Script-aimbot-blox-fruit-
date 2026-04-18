--[[
	👑 MTRIET VIP - GIST AUTH & AUTO TP EDITION 👑
	Tích hợp: Aimbot, Hitbox, ESP, Time Machine, Ghost Xịn, Auto TP (Bám đuôi)
	Hệ thống bảo mật: GitHub Gist + Khóa 24h tại máy (Local Lock)
]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Link Gist chứa 50 Key của chị
local KeyURL = "https://gist.githubusercontent.com/nguyenminhtriet961-rgb/d7926f773d015bfd58af1e0640b50350/raw/5493ed5b76c9a83aa2e12f2961f353d5c95c0fa9/keys.txt"

-- ==============================================================================
-- 🔐 HỆ THỐNG ĐĂNG NHẬP
-- ==============================================================================
local LoginGui = Instance.new("ScreenGui", CoreGui)
LoginGui.Name = "MTRIET_LoginAuth"

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
    -- 🚀 TAB: SĂN NGƯỜI (CHỨC NĂNG MỚI CHỊ YÊU CẦU)
    -- ==========================================
    local TabHunt = Window:CreateTab("🚀 Săn Người")
    local SelectedPlayer = nil
    local LoopTP_On = false

    -- Hàm lấy danh sách tên người chơi
    local function GetPlayerNames()
        local names = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(names, p.Name) end
        end
        return names
    end

    local PlayerDropdown = TabHunt:CreateDropdown({
        Name = "Chọn Người Chơi Đang Có Trong Máy Chủ",
        Options = GetPlayerNames(),
        CurrentOption = {""},
        MultipleOptions = false,
        Flag = "Dropdown_Players",
        Callback = function(Option) SelectedPlayer = Option[1] end,
    })

    TabHunt:CreateButton({
        Name = "🔄 Làm Mới Danh Sách Người Chơi",
        Callback = function() PlayerDropdown:Refresh(GetPlayerNames(), true) end,
    })

    TabHunt:CreateToggle({
        Name = "Bật Auto TP Liên Tục (Bám Đuôi)",
        CurrentValue = false,
        Callback = function(Value) LoopTP_On = Value end,
    })

    -- Vòng lặp bám đuôi siêu mượt
    RunService.Heartbeat:Connect(function()
        if LoopTP_On and SelectedPlayer then
            local target = Players:FindFirstChild(SelectedPlayer)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    -- TP ra ngay phía sau lưng mục tiêu 3 stud để không bị kẹt vào người họ
                    char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                end
            end
        end
    end)

    -- ==========================================
    -- 👻 TAB: GHOST MODE
    -- ==========================================
    local TabGhost = Window:CreateTab("👻 Ghost & Invis")
    local invisOn, noclipOn, ghostOn, ghostSpeed = false, false, false, 50

    local function toggleInvis()
        invisOn = not invisOn
        local char = LocalPlayer.Character
        if char then
            if invisOn then
                for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0.5 end end
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
                for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0 end end
                if workspace:FindFirstChild("invischair") then workspace.invischair:Destroy() end
                char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                Rayfield:Notify({Title = "Tàng Hình", Content = "Đã hiện hình", Duration = 2})
            end
        end
    end

    TabGhost:CreateToggle({Name = "Tàng Hình Ghost (Phím Z)", CurrentValue = false, Callback = function(v) if v ~= invisOn then toggleInvis() end end})
    TabGhost:CreateSlider({Name = "Tốc độ Ghost", Range = {16, 200}, Increment = 1, CurrentValue = 50, Callback = function(v) ghostSpeed = v end})
    TabGhost:CreateToggle({Name = "Chạy Nhanh Ghost (Phím B)", CurrentValue = false, Callback = function(v) ghostOn = v; local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = ghostOn and ghostSpeed or 16 end end})
    TabGhost:CreateToggle({Name = "Đi Xuyên Tường (Phím N)", CurrentValue = false, Callback = function(v) noclipOn = v; RunService.Stepped:Connect(function() if noclipOn and LocalPlayer.Character then for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end end) end})

    -- ==========================================
    -- 🎯 TAB: COMBAT & 👁️ TAB: ESP & ⏳ TAB: TIỆN ÍCH
    -- ==========================================
    local TabCombat = Window:CreateTab("🎯 Chiến Đấu")
    local AimOn = false
    TabCombat:CreateToggle({Name = "Aimbot (Auto Lock)", CurrentValue = false, Callback = function(v) AimOn = v end})
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
    TabCombat:CreateSlider({Name = "Size Hitbox", Range = {5, 50}, Increment = 1, CurrentValue = 15, Callback = function(v) SizeHB = v end})
    TabCombat:CreateToggle({Name = "Bật Hitbox Expander", CurrentValue = false, Callback = function(v) _G.HB = v; task.spawn(function() while _G.HB do for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then p.Character.HumanoidRootPart.Size = Vector3.new(SizeHB, SizeHB, SizeHB); p.Character.HumanoidRootPart.Transparency = 0.7; p.Character.HumanoidRootPart.CanCollide = false end end task.wait(1) end end) end})

    local TabESP = Window:CreateTab("👁️ ESP")
    local ESP_On = false
    TabESP:CreateToggle({Name = "Bật ESP Highlight", CurrentValue = false, Callback = function(v) ESP_On = v end})
    task.spawn(function() while true do if ESP_On then for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then local hl = p.Character:FindFirstChild("MTRIET_ESP") or Instance.new("Highlight", p.Character); hl.Name = "MTRIET_ESP"; hl.FillColor = p.TeamColor.Color; hl.FillTransparency = 0.5 end end else for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("MTRIET_ESP") then p.Character.MTRIET_ESP:Destroy() end end end task.wait(1) end end)

    local TabOther = Window:CreateTab("⏳ Tiện Ích")
    local InfJump = false
    TabOther:CreateToggle({Name = "Nhảy Vô Tận", CurrentValue = false, Callback = function(v) InfJump = v end})
    UserInputService.JumpRequest:Connect(function() if InfJump then LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)

    TabOther:CreateButton({Name = "Lấy Gậy Dịch Chuyển (TP Tool)", Callback = function() local Tool = Instance.new("Tool"); Tool.Name = "Gậy TP VIP"; Tool.RequiresHandle = false; Tool.Parent = LocalPlayer.Backpack; Tool.Activated:Connect(function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0,3,0)) end) end})

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.Z then toggleInvis()
        elseif input.KeyCode == Enum.KeyCode.B then ghostOn = not ghostOn; local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = ghostOn and ghostSpeed or 16 end
        elseif input.KeyCode == Enum.KeyCode.N then noclipOn = not noclipOn; RunService.Stepped:Connect(function() if noclipOn and LocalPlayer.Character then for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end end)
        end
    end)
    Rayfield:LoadConfiguration()
end

-- Logic kiểm tra Key trên Gist và lưu sổ đen
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

            if isfile and readfile and isfile(fileName) then
                local savedTime = tonumber(readfile(fileName))
                if savedTime and currentTime > savedTime then
                    LoginBtn.Text = "KEY ĐÃ HẾT HẠN!"
                    LoginBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                    task.wait(2)
                    LoginBtn.Text = "KÍCH HOẠT VIP"
                    LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
                    return
                end
            elseif writefile then
                writefile(fileName, tostring(expiryTime))
            end

            LoadMainHub()
        else
            LoginBtn.Text = "SAI KEY HOẶC KEY BỊ XÓA!"
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
-- ==========================================
    -- 🚀 TAB: SĂN NGƯỜI (AUTO TP BÁM ĐUÔI)
    -- ==========================================
    local TabHunt = Window:CreateTab("🚀 Săn Người")
    local SelectedPlayer = nil
    local LoopTP_On = false

    -- Hàm lấy danh sách tên người chơi
    local function GetPlayerNames()
        local names = {}
        for _, p in pairs(game:GetService("Players"):GetPlayers()) do
            if p ~= game:GetService("Players").LocalPlayer then 
                table.insert(names, p.Name) 
            end
        end
        return names
    end

    -- Khung thả xuống để chọn người
    local PlayerDropdown = TabHunt:CreateDropdown({
        Name = "Chọn Người Chơi Đang Có Trong Máy Chủ",
        Options = GetPlayerNames(),
        CurrentOption = {""},
        MultipleOptions = false,
        Flag = "Dropdown_Players",
        Callback = function(Option) 
            SelectedPlayer = Option[1] 
        end,
    })

    -- Nút làm mới lỡ có người mới vào server
    TabHunt:CreateButton({
        Name = "🔄 Làm Mới Danh Sách Người",
        Callback = function() 
            PlayerDropdown:Refresh(GetPlayerNames(), true) 
        end,
    })

    -- Công tắc bật tắt TP liên tục
    TabHunt:CreateToggle({
        Name = "Bật Auto TP Liên Tục (Bám Đuôi)",
        CurrentValue = false,
        Callback = function(Value) 
            LoopTP_On = Value 
        end,
    })

    -- Vòng lặp bám đuôi siêu mượt bám sát lưng 3 stud
    game:GetService("RunService").Heartbeat:Connect(function()
        if LoopTP_On and SelectedPlayer then
            local target = game:GetService("Players"):FindFirstChild(SelectedPlayer)
            local LocalPlayer = game:GetService("Players").LocalPlayer
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    -- TP ra ngay phía sau lưng mục tiêu 3 stud để không bị kẹt vào người họ
                    char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                end
            end
        end
    end)
-- ==========================================
    -- ⚔️ TAB: KILL AURA (ĐẤU TRƯỜNG PHÉP THUẬT)
    -- ==========================================
    local TabAura = Window:CreateTab("⚔️ Kill Aura (Auto Đánh)")
    local AuraOn = false
    
    -- Nút bật tắt chế độ chém liên hoàn
    TabAura:CreateToggle({
        Name = "Bật Kill Aura (Đánh Thường Không Kẹt Chuột)",
        CurrentValue = false,
        Callback = function(Value)
            AuraOn = Value
        end,
    })

    -- Vòng lặp lõi của Aura
    task.spawn(function()
        while task.wait(0.05) do -- Tốc độ quét cực nhanh
            if AuraOn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                -- 1. Tìm mục tiêu ngẫu nhiên ở gần (trong bán kính 50 stud)
                local target = nil
                local shortestDistance = 50 
                local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                        local dist = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
                        if dist < shortestDistance then
                            shortestDistance = dist
                            target = p.Character
                        end
                    end
                end

                -- 2. Dịch chuyển và xả skill
                if target then
                    -- TP ra thẳng sau lưng nó để tránh đòn
                    LocalPlayer.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    
                    -- 3. Quét toàn bộ vũ khí/skill đang có và xả liên tục
                    local tools = {}
                    -- Gom đồ trong Balo
                    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
                        if item:IsA("Tool") then table.insert(tools, item) end
                    end
                    -- Gom đồ đang cầm trên tay
                    for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
                        if item:IsA("Tool") then table.insert(tools, item) end
                    end

                    -- Cơ chế Lách Delay & Không Kẹt Chuột
                    if #tools > 0 then
                        for _, tool in ipairs(tools) do
                            if not AuraOn then break end
                            -- Tự động chuyển qua vũ khí số 1, 2, 3...
                            LocalPlayer.Character.Humanoid:EquipTool(tool)
                            
                            -- Lệnh ":Activate()" này xả chiêu thẳng vào hệ thống game
                            -- KHÔNG can thiệp vào con chuột vật lý của chị -> Chị vẫn xoay camera bình thường!
                            tool:Activate() 
                            
                            -- Đợi xíu để chiêu kịp tung ra trước khi đổi món khác
                            task.wait(0.05) 
                        end
                    end
                end
            end
        end
    end)
-- ==========================================
-- 🛡️ CHỨC NĂNG ANTI-AFK (CHỐNG VĂNG GAME)
-- ==========================================
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    print("Đã ngăn chặn AFK thành công!")
end)
-- ==========================================
    -- 💎 TAB: SIÊU CẤP TỰ ĐỘNG (FULL LOGIC)
    -- ==========================================
    local TabSuper = Window:CreateTab("💎 Siêu Cấp Tự Động")
    local AutoAll = false

    TabSuper:CreateToggle({
        Name = "Bật Chế Độ Tự Động Toàn Phần",
        CurrentValue = false,
        Callback = function(v) AutoAll = v end,
    })

    -- Vòng lặp điều khiển thông minh
    task.spawn(function()
        while task.wait(0.3) do
            if AutoAll and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                
                -- 1. ƯU TIÊN SỐ 1: KIỂM TRA BẢNG YES/NO (VÀO TRẬN ĐẤU)
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                local foundInvite = false
                if playerGui then
                    for _, v in pairs(playerGui:GetDescendants()) do
                        -- Quét tìm nút Yes hoặc Accept đang hiện trên màn hình
                        if v:IsA("TextButton") and (v.Text == "Yes" or v.Text == "Accept") and v.Visible and v.Parent.Visible then
                            foundInvite = true
                            -- Giả lập bấm nút
                            local pos = v.AbsolutePosition
                            local size = v.AbsoluteSize
                            game:GetService("VirtualUser"):ClickButton1(Vector2.new(pos.X + size.X/2, pos.Y + size.Y/2))
                            
                            -- Thông báo vào trận
                            Rayfield:Notify({Title = "Đấu Trường", Content = "Đã chấp nhận thách đấu! Bật Aura càn quét!", Duration = 3})
                            
                            -- Bật Kill Aura ngay lập tức khi vào trận
                            _G.AuraOn = true
                            break
                        end
                    end
                end

                -- 2. TRƯỜNG HỢP BÌNH THƯỜNG (KHI KHÔNG CÓ BẢNG MỜI)
                if not foundInvite then
                    
                    -- A. QUÉT LINH HỒN (SOUULS) - Ưu tiên lượm trước
                    local soul = nil
                    for _, item in pairs(workspace:GetChildren()) do
                        if item.Name == "Soul" or item:FindFirstChild("Soul") then
                            soul = item break
                        end
                    end

                    if soul then
                        -- Tắt tàng hình để nhặt đồ (theo ý chị)
                        if _G.InvisOn then _G.ToggleInvis() end 
                        LocalPlayer.Character.HumanoidRootPart.CFrame = soul.CFrame
                        task.wait(0.1)
                        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(0.1)
                        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    
                    else
                        -- B. QUÉT KIM CƯƠNG (DIAMONDS)
                        local diamond = nil
                        for _, item in pairs(workspace:GetDescendants()) do
                            if item.Name == "Diamond" or item.Name == "DiamondDrop" then
                                diamond = item break
                            end
                        end

                        if diamond then
                            -- Nhặt kim cương thì bật tàng hình cho an toàn
                            if not _G.InvisOn then _G.ToggleInvis() end 
                            LocalPlayer.Character.HumanoidRootPart.CFrame = diamond.CFrame
                            task.wait(0.2)
                        
                        else
                            -- C. QUÉT NGƯỜI CHƠI (KILL PLAYERS)
                            -- Nếu không có đồ để lượm thì đi săn người
                            _G.AuraOn = true
                            -- Luôn tàng hình khi săn người cho an toàn
                            if not _G.InvisOn then _G.ToggleInvis() end 
                        end
                    end
                end
            end
        end
    end)
