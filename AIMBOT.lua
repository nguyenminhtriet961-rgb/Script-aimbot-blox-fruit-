--[[
    👑 MTRIET VIP - DIRECT EXECUTE EDITION (BẢN KHÔNG CẦN KEY) 👑
    Bản cập nhật: Loại bỏ hệ thống Key, Tích hợp Fly Mobile VIP, Sửa lỗi Aura Hit & Run.
]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local NoclipConnection, HuntConnection, AimbotConnection
local invisOn, ghostOn, ghostSpeed, noclipOn = false, false, 50, false
local espLoop = false 

-- ==============================================================================
-- 👑 GIAO DIỆN CHÍNH (MAIN HUB)
-- ==============================================================================
local function LoadMainHub()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
        Name = "👑 MTRIET VIP - ULTIMATE",
        LoadingTitle = "Đã tải MTRIET VIP",
        LoadingSubtitle = "Phiên bản không cần Key",
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
            char:MoveTo(Vector3.new(-25.95, 84, 3537.55))
            task.wait(0.15)
            
            local Seat = Instance.new("Seat")
            Seat.Anchored, Seat.CanCollide, Seat.Name, Seat.Transparency = false, false, "invischair", 1
            Seat.Position = Vector3.new(-25.95, 84, 3537.55)
            Seat.Parent = workspace
            
            local Weld = Instance.new("Weld", Seat)
            Weld.Part0, Weld.Part1 = Seat, char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            Seat.CFrame = savedpos
            Rayfield:Notify({Title = "Tàng Hình", Content = "Đã vào chế độ Ma", Duration = 2})
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

    TabGhost:CreateToggle({Name = "Tàng Hình Ghost", CurrentValue = false, Callback = function(v) if v ~= invisOn then toggleInvis() end end})
    TabGhost:CreateSlider({Name = "Tốc độ Ghost", Range = {16, 200}, Increment = 1, CurrentValue = 50, Callback = function(v) ghostSpeed = v end})
    TabGhost:CreateToggle({Name = "Chạy Nhanh Ghost", CurrentValue = false, Callback = function(v) 
        ghostOn = v
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = ghostOn and ghostSpeed or 16 end 
    end})
    TabGhost:CreateToggle({Name = "Đi Xuyên Tường", CurrentValue = false, Callback = function(v) toggleNoclip(v) end})

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
    -- 👁️ TAB: HIỂN THỊ (ESP HIGHLIGHT)
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
                    task.wait(1)
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
    -- ⏳ TAB: TIỆN ÍCH (TÍCH HỢP FLY GUI TẠI ĐÂY)
    -- ==========================================
    local TabOther = Window:CreateTab("⏳ Tiện Ích")
    local RecData, isRec, InfJump = {}, false, false

    TabOther:CreateButton({Name = "🚀 Mở Bảng Fly Mobile (VIP)", Callback = function() 
        if LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("MTRIET_FlyGUI") then
            Rayfield:Notify({Title = "Lỗi", Content = "Bảng Fly đã được mở rồi!", Duration = 2})
            return
        end

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

        up.Name = "up"
        up.Parent = Frame
        up.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        up.Position = UDim2.new(0.05, 0, 0.35, 0)
        up.Size = UDim2.new(0, 55, 0, 25)
        up.Font = Enum.Font.GothamBold
        up.Text = "UP"
        up.TextColor3 = Color3.fromRGB(255, 255, 255)
        up.TextSize = 12
        Instance.new("UICorner", up).CornerRadius = UDim.new(0, 4)

        down.Name = "down"
        down.Parent = Frame
        down.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        down.Position = UDim2.new(0.05, 0, 0.65, 0)
        down.Size = UDim2.new(0, 55, 0, 25)
        down.Font = Enum.Font.GothamBold
        down.Text = "DOWN"
        down.TextColor3 = Color3.fromRGB(255, 255, 255)
        down.TextSize = 12
        Instance.new("UICorner", down).CornerRadius = UDim.new(0, 4)

        onof.Name = "onof"
        onof.Parent = Frame
        onof.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        onof.Position = UDim2.new(0.65, 0, 0.65, 0)
        onof.Size = UDim2.new(0, 60, 0, 25)
        onof.Font = Enum.Font.GothamBold
        onof.Text = "FLY"
        onof.TextColor3 = Color3.fromRGB(255, 255, 255)
        onof.TextSize = 12
        Instance.new("UICorner", onof).CornerRadius = UDim.new(0, 4)

        plus.Name = "plus"
        plus.Parent = Frame
        plus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        plus.Position = UDim2.new(0.8, 0, 0.35, 0)
        plus.Size = UDim2.new(0, 30, 0, 25)
        plus.Font = Enum.Font.GothamBold
        plus.Text = "+"
        plus.TextColor3 = Color3.fromRGB(0, 255, 0)
        plus.TextSize = 16
        Instance.new("UICorner", plus).CornerRadius = UDim.new(0, 4)

        speed.Name = "speed"
        speed.Parent = Frame
        speed.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        speed.Position = UDim2.new(0.55, 0, 0.35, 0)
        speed.Size = UDim2.new(0, 40, 0, 25)
        speed.Font = Enum.Font.GothamBold
        speed.Text = "1"
        speed.TextColor3 = Color3.fromRGB(255, 170, 0)
        speed.TextSize = 14
        Instance.new("UICorner", speed).CornerRadius = UDim.new(0, 4)

        mine.Name = "mine"
        mine.Parent = Frame
        mine.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        mine.Position = UDim2.new(0.35, 0, 0.35, 0)
        mine.Size = UDim2.new(0, 30, 0, 25)
        mine.Font = Enum.Font.GothamBold
        mine.Text = "-"
        mine.TextColor3 = Color3.fromRGB(255, 0, 0)
        mine.TextSize = 16
        Instance.new("UICorner", mine).CornerRadius = UDim.new(0, 4)

        closebutton.Name = "Close"
        closebutton.Parent = Frame
        closebutton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        closebutton.Position = UDim2.new(0.85, -5, -0.3, 0)
        closebutton.Size = UDim2.new(0, 25, 0, 25)
        closebutton.Font = Enum.Font.GothamBold
        closebutton.Text = "X"
        closebutton.TextColor3 = Color3.fromRGB(255, 255, 255)
        closebutton.TextSize = 14
        Instance.new("UICorner", closebutton).CornerRadius = UDim.new(0, 100)

        mini.Name = "minimize"
        mini.Parent = Frame
        mini.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        mini.Position = UDim2.new(0.7, -5, -0.3, 0)
        mini.Size = UDim2.new(0, 25, 0, 25)
        mini.Font = Enum.Font.GothamBold
        mini.Text = "-"
        mini.TextColor3 = Color3.fromRGB(255, 255, 255)
        mini.TextSize = 18
        Instance.new("UICorner", mini).CornerRadius = UDim.new(0, 100)

        mini2.Name = "minimize2"
        mini2.Parent = Frame
        mini2.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        mini2.Position = UDim2.new(0.7, -5, -0.3, 0)
        mini2.Size = UDim2.new(0, 25, 0, 25)
        mini2.Font = Enum.Font.GothamBold
        mini2.Text = "+"
        mini2.TextColor3 = Color3.fromRGB(255, 255, 255)
        mini2.TextSize = 18
        mini2.Visible = false
        Instance.new("UICorner", mini2).CornerRadius = UDim.new(0, 100)

        local speeds = 1
        local speaker = game:GetService("Players").LocalPlayer
        local chr = speaker.Character
        local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
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
                for i,v in next, Hum:GetPlayingAnimationTracks() do
                    v:AdjustSpeed(0)
                end
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

            if speaker.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
                local torso = speaker.Character.Torso
                local ctrl = {f = 0, b = 0, l = 0, r = 0}
                local lastctrl = {f = 0, b = 0, l = 0, r = 0}
                local maxspeed = 50
                local p_speed = 0

                local bg = Instance.new("BodyGyro", torso)
                bg.P = 9e4
                bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
                bg.cframe = torso.CFrame
                local bv = Instance.new("BodyVelocity", torso)
                bv.velocity = Vector3.new(0,0.1,0)
                bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
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
                bg:Destroy()
                bv:Destroy()
                speaker.Character.Humanoid.PlatformStand = false
                speaker.Character.Animate.Disabled = false
                tpwalking = false
            else
                local UpperTorso = speaker.Character.UpperTorso
                local ctrl = {f = 0, b = 0, l = 0, r = 0}
                local lastctrl = {f = 0, b = 0, l = 0, r = 0}
                local maxspeed = 50
                local p_speed = 0

                local bg = Instance.new("BodyGyro", UpperTorso)
                bg.P = 9e4
                bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
                bg.cframe = UpperTorso.CFrame
                local bv = Instance.new("BodyVelocity", UpperTorso)
                bv.velocity = Vector3.new(0,0.1,0)
                bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
                if nowe == true then speaker.Character.Humanoid.PlatformStand = true end
                while nowe == true or speaker.Character.Humanoid.Health == 0 do
                    task.wait()
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
                bg:Destroy()
                bv:Destroy()
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

        speaker.CharacterAdded:Connect(function(char)
            task.wait(0.7)
            speaker.Character.Humanoid.PlatformStand = false
            speaker.Character.Animate.Disabled = false
        end)

        plus.MouseButton1Down:connect(function()
            speeds = speeds + 1
            speed.Text = tostring(speeds)
            if nowe == true then
                tpwalking = false
                for i = 1, speeds do
                    spawn(function()
                        local hb = game:GetService("RunService").Heartbeat  
                        tpwalking = true
                        local chr = speaker.Character
                        local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                        while tpwalking and hb:Wait() and chr and hum and hum.Parent do
                            if hum.MoveDirection.Magnitude > 0 then chr:TranslateBy(hum.MoveDirection) end
                        end
                    end)
                end
            end
        end)

        mine.MouseButton1Down:connect(function()
            if speeds == 1 then
                speed.Text = 'Min=1'
                task.wait(1)
                speed.Text = tostring(speeds)
            else
                speeds = speeds - 1
                speed.Text = tostring(speeds)
                if nowe == true then
                    tpwalking = false
                    for i = 1, speeds do
                        spawn(function()
                            local hb = game:GetService("RunService").Heartbeat  
                            tpwalking = true
                            local chr = speaker.Character
                            local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
                            while tpwalking and hb:Wait() and chr and hum and hum.Parent do
                                if hum.MoveDirection.Magnitude > 0 then chr:TranslateBy(hum.MoveDirection) end
                            end
                        end)
                    end
                end
            end
        end)

        closebutton.MouseButton1Click:Connect(function() main:Destroy() end)

        mini.MouseButton1Click:Connect(function()
            up.Visible = false; down.Visible = false; onof.Visible = false
            plus.Visible = false; speed.Visible = false; mine.Visible = false
            mini.Visible = false; mini2.Visible = true
            Frame.BackgroundTransparency = 1; TextLabel.Visible = false
        end)

        mini2.MouseButton1Click:Connect(function()
            up.Visible = true; down.Visible = true; onof.Visible = true
            plus.Visible = true; speed.Visible = true; mine.Visible = true
            mini.Visible = true; mini2.Visible = false
            Frame.BackgroundTransparency = 0; TextLabel.Visible = true
        end)
        
        Rayfield:Notify({Title = "Thành Công", Content = "Đã mở giao diện Fly!", Duration = 2})
    end})

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
    -- 🚀 TAB: SĂN NGƯỜI
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
    local currentOffset = CFrame.new(0, 50, 0)

    TabAura:CreateSlider({Name = "Tầm Quét Mục Tiêu", Range = {50, 5000}, Increment = 50, CurrentValue = 1000, Callback = function(v) AuraRange = v end})
    TabAura:CreateSlider({Name = "Tốc độ chém (Giây/Nhát)", Range = {0.1, 2}, Increment = 0.1, CurrentValue = 0.5, Callback = function(v) AuraAttackSpeed = v end})

    TabAura:CreateToggle({Name = "Bật Kill Aura (Bổ nhào & Bám đuôi tới chết)", CurrentValue = false, Callback = function(Value)
        AuraOn = Value
        
        if AuraOn then
            if LocalPlayer.Character then
                for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do 
                    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 1 end 
                end
            end

            AuraConnection = RunService.Heartbeat:Connect(function()
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
                local hrp = LocalPlayer.Character.HumanoidRootPart
                local myPos = hrp.Position

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
                    hrp.CFrame = currentTarget.HumanoidRootPart.CFrame * currentOffset
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
                                currentOffset = CFrame.new(0, 0, 4) 
                                task.wait(0.05) 
                                tool:Activate()
                                
                                currentOffset = CFrame.new(0, 50, 0)
                                task.wait(AuraAttackSpeed) 
                            end
                        else
                            task.wait(0.1)
                        end
                    else
                        currentOffset = CFrame.new(0, 50, 0) 
                        task.wait(0.1)
                    end
                end
            end)

        else
            if AuraConnection then AuraConnection:Disconnect() AuraConnection = nil end
            currentTarget = nil
            currentOffset = CFrame.new(0, 50, 0)
            
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
end

-- ==============================================================================
-- 🚀 CHẠY TRỰC TIẾP KHÔNG CẦN KEY
-- ==============================================================================
LoadMainHub()
