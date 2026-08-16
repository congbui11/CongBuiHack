local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

local targetLabel = nil

-- Tìm chính xác label tiền dựa trên vị trí và màu xanh lá
for _, screenGui in pairs(gui:GetChildren()) do
    if screenGui:IsA("ScreenGui") then
        for _, frame in pairs(screenGui:GetDescendants()) do
            if frame:IsA("TextLabel") and frame.Text and string.match(frame.Text, "^%$%s*[%d,]+$") then
                -- Kiểm tra màu chữ (xanh lá cây nhạt)
                local success, color = pcall(function() return frame.TextColor3 end)
                if success and color and color.G > 0.5 and color.R < 0.5 and color.B < 0.5 then
                    targetLabel = frame
                    break
                end
            end
        end
        if targetLabel then break end
    end
end

if targetLabel then
    targetLabel.Text = "$100,000,000,000"
    
    -- Vô hiệu hóa mọi hàm cập nhật của game bằng cách ghi đè lên metatable của label
    local mt = getrawmetatable(targetLabel)
    if mt then
        local oldIndex = mt.__index
        mt.__index = function(tbl, key)
            if key == "Text" and tbl == targetLabel then
                return "$100,000,000,000"
            end
            return oldIndex(tbl, key)
        end
    end

    -- Hook vào hàm gán Text (nếu game dùng :SetText hoặc .Text = ...)
    local oldNamecall = nil
    if getnamecallmethod then
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if self == targetLabel and method == "SetText" then
                return oldNamecall(self, "$100,000,000,000")
            end
            return oldNamecall(self, ...)
        end)
    end

    print("Client GUI injected and locked to 100 billion.")
else
    warn("Không tìm thấy label tiền phù hợp (màu xanh, dạng $XXX).")
end
