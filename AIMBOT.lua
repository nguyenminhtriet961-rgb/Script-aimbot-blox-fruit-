--[[
	👑 MTRIET VIP - FULL GIST & LOCAL LOCK EDITION 👑
	Tích hợp: Aimbot, Hitbox, ESP, Time Machine, Ghost Xịn, Inf Jump, TP Tool
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

-- Link Gist chứa 50 Key của chị (Đã gắn sẵn link chuẩn lúc nãy)
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
    -- 🎯 TAB: COMBAT (AIMBOT & HITBOX)
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

    -- ==========================================
    -- 👁️ TAB: HIỂN THỊ (ESP HIGHLIGHT)
    -- ==========================================
    local TabESP = Window:CreateTab("👁️ ESP")
    local ESP_On = false
    TabESP:CreateToggle({Name = "Bật ESP Highlight", CurrentValue = false, Callback = function(v) ESP_On = v end})
    task.spawn(function() while true do if ESP_On then for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then local hl = p.Character:FindFirstChild("MTRIET_ESP") or Instance.new("Highlight", p.Character); hl.Name = "MTRIET_ESP"; hl.FillColor = p.TeamColor.Color; hl.FillTransparency = 0.5 end end else for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("MTRIET_ESP") then p.Character.MTRIET_ESP:Destroy() end end end task.wait(1) end end)

    -- ==========================================
    -- ⏳ TAB: TIỆN ÍCH (TIME MACHINE & TP)
    -- ==========================================
    local TabOther = Window:CreateTab("⏳ Tiện Ích")
    local RecData, isRec = {}, false

    TabOther:CreateToggle({Name = "Ghi Hình Hành Động", CurrentValue = false, Callback = function(v) isRec = v; if v then RecData = {} task.spawn(function() while isRec do if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then table.insert(RecData, LocalPlayer.Character.HumanoidRootPart.CFrame) end task.wait(0.05) end end) end end})
    TabOther:CreateButton({Name = "Phát Lại (Replay)", Callback = function() for i = 1, #RecData do LocalPlayer.Character.HumanoidRootPart.CFrame = RecData[i] task.wait(0.05) end end})
    
    local InfJump = false
    TabOther:CreateToggle({Name = "Nhảy Vô Tận", CurrentValue = false, Callback = function(v) InfJump = v end})
    UserInputService.JumpRequest:Connect(function() if InfJump then LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)

    TabOther:CreateButton({Name = "Lấy Gậy Dịch Chuyển (TP Tool)", Callback = function() local Tool = Instance.new("Tool"); Tool.Name = "Gậy TP VIP"; Tool.RequiresHandle = false; Tool.Parent = LocalPlayer.Backpack; Tool.Activated:Connect(function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0,3,0)) end) end})

    -- ==========================================
    -- PHÍM TẮT HỖ TRỢ Z B N
    -- ==========================================
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
