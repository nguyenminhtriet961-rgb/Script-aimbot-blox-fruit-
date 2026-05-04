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
        Key = {"khonlangoccu"} 
    }
})

-- Sau đoạn này chị dán cái code hack (Aimbot, BayMuot...) của chị vào bên dưới
-- Hoặc dùng loadstring để gọi file 'natural' như em đã chỉ
loadstring(game:HttpGet("https://raw.githubusercontent.com/nguyenminhtriet961-rgb/mtriet12/main/natural"))()
