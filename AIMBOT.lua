--[[
	👑 MTRIET VIP - OMNIVERSAL EDITION (BẢN CHỐT CUỐI CÙNG) 👑
	Tích hợp: Tự động lưu Key, Xem thời gian, Auto Farm, Kill Aura, Siêu Cấp Tự Động...
]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
-- XÓA BẢNG ĐEN THUI BỊ KẸT TỪ LẦN CHẠY TRƯỚC
if game:GetService("CoreGui"):FindFirstChild("MTRIET_LoginAuth") then
    game:GetService("CoreGui").MTRIET_LoginAuth:Destroy()
end
-- Biến toàn cục để các Tab giao tiếp với nhau
_G.InvisOn = false
_G.AuraOn = false
_G.ToggleInvis = nil

-- Link Gist Key
local KeyURL = "https://gist.githubusercontent.com/nguyenminhtriet961-rgb/d7926f773d015bfd58af1e0640b50350/raw/5493ed5b76c9a83aa2e12f2961f353d5c95c0fa9/keys.txt"

-- ==========================================
-- 🛡️ CHỐNG AFK
-- ==========================================
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ==========================================
-- 🔐 HỆ THỐNG ĐĂNG NHẬP & TỰ ĐỘNG LƯU KEY
-- ==========================================
local SavedKeyFile = "MTRIET_CurrentKey.txt"

local function GetExpiryTime(key)
    local fileName = "MTRIET_Auth_" .. key .. ".txt"
    if isfile and readfile and isfile(fileName) then
        return tonumber(readfile(fileName))
    end
    return nil
end

local function LoadMainHub(expiryTime)
    -- Nếu có bảng đăng nhập thì xóa nó đi
    if CoreGui:FindFirstChild("MTRIET_LoginAuth") then
        CoreGui.MTRIET_LoginAuth:Destroy()
    end

    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
        Name = "👑 MTRIET VIP - ULTIMATE",
        LoadingTitle = "Xác thực thành công!",
        LoadingSubtitle = "Auto-Login System",
        ConfigurationSaving = { Enabled = true, FolderName = "MTRIET_VIP", FileName = "Config" },
        KeySystem = false 
    })

    -- ==========================================
    -- 🕒 TAB: THÔNG TIN (XEM THỜI GIAN)
    -- ==========================================
    local TabInfo = Window:CreateTab("🕒 Thông Tin Key")
    local timeString = "Không xác định"
    if expiryTime then
        timeString = os.date("%H:%M:%S - %d/%m/%Y", expiryTime)
    end
    TabInfo:CreateParagraph({Title = "Tình trạng Key", Content = "Key của bạn đang hoạt động tốt!"})
    TabInfo:CreateParagraph({Title = "Thời gian hết hạn", Content = "Hết hạn vào lúc: " .. timeString})

    -- ==========================================
    -- 👻 TAB: GHOST & INVIS
    -- ==========================================
    local TabGhost = Window:CreateTab("👻 Ghost & Invis")
    local noclipOn, ghostOn, ghostSpeed = false, false, 50

    _G.ToggleInvis = function()
        _G.InvisOn = not _G.InvisOn
        local char = LocalPlayer.Character
        if char then
            if _G.InvisOn then
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
            else
                for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0 end end
                if workspace:FindFirstChild("invischair") then workspace.invischair:Destroy() end
                char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end

    TabGhost:CreateToggle({Name = "Tàng Hình Ghost (Phím Z)", CurrentValue = false, Callback = function(v) if v ~= _G.InvisOn then _G.ToggleInvis() end end})
    TabGhost:CreateSlider({Name = "Tốc độ Ghost", Range = {16, 200}, Increment = 1, CurrentValue = 50, Callback = function(v) ghostSpeed = v end})
    TabGhost:CreateToggle({Name = "Chạy Nhanh Ghost (Phím B)", CurrentValue = false, Callback = function(v) ghostOn = v; local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = ghostOn and ghostSpeed or 16 end end})
    TabGhost:CreateToggle({Name = "Đi Xuyên Tường (Phím N)", CurrentValue = false, Callback = function(v) noclipOn = v; RunService.Stepped:Connect(function() if noclipOn and LocalPlayer.Character then for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end end) end})

    -- ==========================================
    -- ⚔️ TAB: KILL AURA
    -- ==========================================
    local TabAura = Window:CreateTab("⚔️ Kill Aura")
    TabAura:CreateToggle({Name = "Bật Kill Aura (Đánh Không Kẹt Chuột)", CurrentValue = false, Callback = function(v) _G.AuraOn = v end})
    task.spawn(function()
        while task.wait(0.05) do
            if _G.AuraOn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local target, shortestDistance = nil, 50 
                local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                        local dist = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
                        if dist < shortestDistance then shortestDistance = dist; target = p.Character end
                    end
                end
                if target then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    local tools = {}
                    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do if item:IsA("Tool") then table.insert(tools, item) end end
                    for _, item in ipairs(LocalPlayer.Character:GetChildren()) do if item:IsA("Tool") then table.insert(tools, item) end end
                    if #tools > 0 then
                        for _, tool in ipairs(tools) do
                            if not _G.AuraOn then break end
                            LocalPlayer.Character.Humanoid:EquipTool(tool)
                            tool:Activate() 
                            task.wait(0.05) 
                        end
                    end
                end
            end
        end
    end)

    -- ==========================================
    -- 💎 TAB: SIÊU CẤP TỰ ĐỘNG
    -- ==========================================
    local TabSuper = Window:CreateTab("💎 Siêu Cấp Tự Động")
    local AutoAll = false
    TabSuper:CreateToggle({Name = "Bật Combo (Vào Trận + Linh Hồn + Kim Cương + PK)", CurrentValue = false, Callback = function(v) AutoAll = v end})
    task.spawn(function()
        while task.wait(0.3) do
            if AutoAll and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                local foundInvite = false
                if playerGui then
                    for _, v in pairs(playerGui:GetDescendants()) do
                        if v:IsA("TextButton") and (v.Text == "Yes" or v.Text == "Accept") and v.Visible and v.Parent.Visible then
                            foundInvite = true
                            local pos, size = v.AbsolutePosition, v.AbsoluteSize
                            VirtualUser:ClickButton1(Vector2.new(pos.X + size.X/2, pos.Y + size.Y/2))
                            _G.AuraOn = true
                            break
                        end
                    end
                end

                if not foundInvite then
                    local soul = nil
                    for _, item in pairs(workspace:GetChildren()) do
                        if item.Name == "Soul" or item:FindFirstChild("Soul") then soul = item break end
                    end
                    if soul then
                        if _G.InvisOn then _G.ToggleInvis() end 
                        LocalPlayer.Character.HumanoidRootPart.CFrame = soul.CFrame
                        task.wait(0.1)
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    else
                        local diamond = nil
                        for _, item in pairs(workspace:GetDescendants()) do
                            if item.Name == "Diamond" or item.Name == "DiamondDrop" then diamond = item break end
                        end
                        if diamond then
                            if not _G.InvisOn then _G.ToggleInvis() end 
                            LocalPlayer.Character.HumanoidRootPart.CFrame = diamond.CFrame
                            task.wait(0.2)
                        else
                            _G.AuraOn = true
                            if not _G.InvisOn then _G.ToggleInvis() end 
                        end
                    end
                end
            end
        end
    end)

    -- ==========================================
    -- 🚜 TAB: AUTO FARM & CÁC TAB KHÁC
    -- ==========================================
    local TabFarm = Window:CreateTab("🚜 Auto Farm")
    local AutoFarmOn = false
    TabFarm:CreateToggle({Name = "Bật Auto Farm (Sửa tên thư mục quái trong code)", CurrentValue = false, Callback = function(v) AutoFarmOn = v end})
    task.spawn(function()
        while task.wait(0.1) do
            if AutoFarmOn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local folderQuai = Workspace:FindFirstChild("Enemies") -- TRIẾT NHỚ ĐỔI TÊN Ở ĐÂY NHÉ!
                if folderQuai then
                    for _, mob in pairs(folderQuai:GetChildren()) do
                        if mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                            for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                                if tool:IsA("Tool") and AutoFarmOn then
                                    LocalPlayer.Character.Humanoid:EquipTool(tool)
                                    tool:Activate()
                                    task.wait(0.1)
                                end
                            end
                            break 
                        end
                    end
                end
            end
        end
    end)

    local TabOther = Window:CreateTab("⏳ Tiện Ích")
    local InfJump = false
    TabOther:CreateToggle({Name = "Nhảy Vô Tận", CurrentValue = false, Callback = function(v) InfJump = v end})
    UserInputService.JumpRequest:Connect(function() if InfJump then LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)
    TabOther:CreateButton({Name = "Lấy Gậy Dịch Chuyển (TP Tool)", Callback = function() local Tool = Instance.new("Tool"); Tool.Name = "Gậy TP VIP"; Tool.RequiresHandle = false; Tool.Parent = LocalPlayer.Backpack; Tool.Activated:Connect(function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0,3,0)) end) end})

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.Z then _G.ToggleInvis()
        elseif input.KeyCode == Enum.KeyCode.B then ghostOn = not ghostOn; local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = ghostOn and ghostSpeed or 16 end
        elseif input.KeyCode == Enum.KeyCode.N then noclipOn = not noclipOn; RunService.Stepped:Connect(function() if noclipOn and LocalPlayer.Character then for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end end)
        end
    end)
    Rayfield:LoadConfiguration()
end

-- ==========================================
-- LOGIC TỰ ĐỘNG ĐĂNG NHẬP (AUTO-LOGIN)
-- ==========================================
local AutoLoginSuccess = false
if isfile and readfile and isfile(SavedKeyFile) then
    local currentKey = readfile(SavedKeyFile)
    local expiryTime = GetExpiryTime(currentKey)
    local currentTime = os.time()
    
    if expiryTime and currentTime < expiryTime then
        AutoLoginSuccess = true
        LoadMainHub(expiryTime) -- Bỏ qua màn hình đăng nhập luôn!
    end
end

-- Nếu chưa lưu Key hoặc Key hết hạn thì hiện bảng Login
if not AutoLoginSuccess then
    local LoginGui = Instance.new("ScreenGui", CoreGui)
    LoginGui.Name = "MTRIET_LoginAuth"

    local MainFrame = Instance.new("Frame", LoginGui)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
    -- ĐÃ FIX LỖI THIẾU SỐ 0 Ở ĐÂY NÈ CHỊ ĐẠI:
    MainFrame.Size = UDim2.new(0, 300, 0, 160) 
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

    local Title = Instance.new("TextLabel", MainFrame)
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "👑 MTRIET VIP - ĐĂNG NHẬP"
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

    LoginBtn.MouseButton1Click:Connect(function()
        local key = KeyInput.Text
        if key == "" or key:match("^%s*$") then return end
        
        LoginBtn.Text = "ĐANG CHECK GIST..."
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
                        return
                    else
                        expiryTime = savedTime 
                    end
                elseif writefile then
                    writefile(fileName, tostring(expiryTime))
                end

                if writefile then writefile(SavedKeyFile, key) end

                LoadMainHub(expiryTime)
            else
                LoginBtn.Text = "SAI KEY/BỊ XÓA!"
                LoginBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            end
        end
    end)
end
