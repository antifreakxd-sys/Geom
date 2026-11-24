-- Geom UI v1.0
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts.
-- Self-contained client UI; no external modules or HTTP requests.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local existing = playerGui:FindFirstChild("GeomMenu")
if existing then existing:Destroy() end

local C = {
    bg = Color3.fromRGB(18, 20, 31),
    surface = Color3.fromRGB(30, 33, 49),
    hover = Color3.fromRGB(43, 47, 68),
    text = Color3.fromRGB(245, 247, 255),
    muted = Color3.fromRGB(155, 165, 190),
    purple = Color3.fromRGB(139, 92, 246),
    blue = Color3.fromRGB(56, 189, 248),
}

local function make(class, parent, props)
    local obj = Instance.new(class)
    for key, value in pairs(props or {}) do
        obj[key] = value
    end
    obj.Parent = parent
    return obj
end

local function round(parent, radius)
    return make("UICorner", parent, {CornerRadius = UDim.new(0, radius)})
end

local function stroke(parent, color, transparency, thickness)
    return make("UIStroke", parent, {
        Color = color, Transparency = transparency, Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function label(parent, text, size, pos, dimensions, color, bold)
    return make("TextLabel", parent, {
        BackgroundTransparency = 1, Text = text,
        TextColor3 = color or C.text, TextSize = size,
        Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = pos, Size = dimensions,
    })
end

local function button(parent, text, pos, size, color)
    local b = make("TextButton", parent, {
        Text = text, Position = pos, Size = size,
        BackgroundColor3 = color or C.surface, BorderSizePixel = 0,
        AutoButtonColor = false, Font = Enum.Font.GothamMedium,
        TextSize = 14, TextColor3 = C.text,
    })
    round(b, 11)
    return b
end

local gui = make("ScreenGui", playerGui, {
    Name = "GeomMenu", ResetOnSpawn = false,
    IgnoreGuiInset = false, DisplayOrder = 50,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
local root = make("Frame", gui, {
    Name = "Root", Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
})
local overlay = make("TextButton", root, {
    Name = "Backdrop", Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Text = "", AutoButtonColor = false, Visible = false, ZIndex = 2,
    Selectable = false, Modal = false,
})

-- Floating circular launcher
local launcher = make("TextButton", root, {
    Name = "Launcher", AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -18, 0.42, 0),
    Size = UDim2.fromOffset(58, 58),
    BackgroundColor3 = C.purple, BorderSizePixel = 0,
    Text = "", AutoButtonColor = false, ZIndex = 10,
})
make("UICorner", launcher, {CornerRadius = UDim.new(1, 0)})
stroke(launcher, C.text, 0.55, 1.5)
local launcherGradient = make("UIGradient", launcher, {
    Color = ColorSequence.new(C.purple, C.blue), Rotation = 45,
})
local launcherScale = make("UIScale", launcher, {Scale = 1})
local glyph = make("Frame", launcher, {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(24, 24),
    BackgroundTransparency = 1,
})
for _, rotation in ipairs({0, 90}) do
    local bar = make("Frame", glyph, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(22, 3), Rotation = rotation,
        BackgroundColor3 = C.text, BorderSizePixel = 0,
    })
    round(bar, 2)
end

-- Menu container. CanvasGroup provides smooth whole-window fades.
local panel = make("CanvasGroup", root, {
    Name = "Menu", AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.52),
    Size = UDim2.fromOffset(340, 324),
    BackgroundColor3 = C.bg, BorderSizePixel = 0,
    GroupTransparency = 1, Visible = false, ZIndex = 3,
    ClipsDescendants = true,
})
round(panel, 22)
stroke(panel, C.purple, 0.5, 1.5)
local panelScale = make("UIScale", panel, {Scale = 1})
local accent = make("Frame", panel, {
    Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 0, 4),
    BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
})
make("UIGradient", accent, {Color = ColorSequence.new(C.purple, C.blue)})

label(panel, "GEOM", 23, UDim2.fromOffset(20, 15), UDim2.fromOffset(230, 31), C.text, true)
label(panel, "Игровое меню  /  v1.0", 12, UDim2.fromOffset(21, 47), UDim2.fromOffset(240, 19), C.muted)
local close = button(panel, "×", UDim2.fromOffset(285, 19), UDim2.fromOffset(36, 36))
close.TextSize = 24

local homeTab = button(panel, "Главная", UDim2.fromOffset(19, 83), UDim2.fromOffset(147, 38))
local settingsTab = button(panel, "Настройки", UDim2.fromOffset(174, 83), UDim2.fromOffset(147, 38))

local body = make("Frame", panel, {
    Position = UDim2.fromOffset(19, 136), Size = UDim2.fromOffset(302, 142),
    BackgroundTransparency = 1,
})

local pages = {}
for _, key in ipairs({"Home", "Settings"}) do
    pages[key] = make("CanvasGroup", body, {
        Name = key, Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1, Visible = false,
    })
end
local home = pages.Home
local welcome = make("Frame", home, {
    Size = UDim2.new(1, 0, 0, 86), BackgroundColor3 = C.surface, BorderSizePixel = 0,
})
round(welcome, 12)
label(welcome, "Добро пожаловать!", 17, UDim2.fromOffset(14, 12), UDim2.fromOffset(270, 23), C.text, true)
local username = label(welcome, player.DisplayName, 14, UDim2.fromOffset(14, 39), UDim2.fromOffset(270, 28), C.muted)
username.TextTruncate = Enum.TextTruncate.AtEnd
local play = button(home, "Продолжить игру", UDim2.fromOffset(0, 98), UDim2.fromOffset(302, 44), C.purple)

local settings = pages.Settings
local motionToggle = button(settings, "", UDim2.fromOffset(0, 0), UDim2.fromOffset(302, 46))
local accentToggle = button(settings, "", UDim2.fromOffset(0, 55), UDim2.fromOffset(302, 46))
local hint = label(settings, "Настройки действуют в текущей сессии.", 11, UDim2.fromOffset(1, 110), UDim2.fromOffset(300, 26), C.muted)
hint.TextWrapped = true
label(panel, "GEOM UI   •   CLIENT", 10, UDim2.fromOffset(20, 293), UDim2.fromOffset(300, 16), C.muted, true)

local opened = false
local motion = true
local blueTheme = false
local activePage = "Home"
local baseScale = 1
local tweens = {}
local transition = 0

local function animate(obj, duration, goals, easing)
    if tweens[obj] then
        tweens[obj]:Cancel()
        tweens[obj] = nil
    end
    if not motion or duration <= 0 then
        for key, value in pairs(goals) do obj[key] = value end
        return nil
    end
    local tween = TweenService:Create(obj, TweenInfo.new(duration, easing or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), goals)
    tweens[obj] = tween
    tween.Completed:Once(function()
        if tweens[obj] == tween then tweens[obj] = nil end
    end)
    tween:Play()
    return tween
end

local function themeColor()
    return blueTheme and C.blue or C.purple
end

local function refresh()
    motionToggle.Text = "Анимации: " .. (motion and "ВКЛ" or "ВЫКЛ")
    accentToggle.Text = "Цвет: " .. (blueTheme and "Голубой" or "Фиолетовый")
    play.BackgroundColor3 = themeColor()
    launcherGradient.Color = blueTheme and ColorSequence.new(C.blue, C.purple) or ColorSequence.new(C.purple, C.blue)
    homeTab.BackgroundColor3 = activePage == "Home" and themeColor() or C.surface
    settingsTab.BackgroundColor3 = activePage == "Settings" and themeColor() or C.surface
end

local function selectPage(key)
    activePage = key
    for name, page in pairs(pages) do
        if tweens[page] then tweens[page]:Cancel(); tweens[page] = nil end
        page.Visible = name == key
        if page.Visible then
            page.GroupTransparency = motion and 0.65 or 0
            page.Position = UDim2.fromOffset(motion and 8 or 0, 0)
            animate(page, 0.2, {GroupTransparency = 0, Position = UDim2.fromOffset(0, 0)})
        end
    end
    refresh()
end

local function resize()
    local size = root.AbsoluteSize
    if size.X <= 0 or size.Y <= 0 then return end
    baseScale = math.min(1, (size.X - 24) / 340, (size.Y - 30) / 324)
    baseScale = math.max(0.1, baseScale)
    if tweens[panelScale] then tweens[panelScale]:Cancel(); tweens[panelScale] = nil end
    panelScale.Scale = baseScale * (opened and 1 or 0.90)
end
root:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)

local function setOpen(value)
    if opened == value then return end
    opened = value
    transition += 1
    local current = transition
    if opened then
        if not panel.Visible then
            panel.GroupTransparency = 1
            panel.Position = UDim2.fromScale(0.5, 0.53)
            panelScale.Scale = baseScale * 0.90
        end
        panel.Visible = true
        overlay.Visible = true
    end
    animate(overlay, 0.25, {BackgroundTransparency = opened and 0.46 or 1})
    animate(glyph, 0.30, {Rotation = opened and 45 or 0})
    animate(launcherGradient, 0.35, {Rotation = opened and 140 or 45})
    animate(panelScale, 0.28, {Scale = baseScale * (opened and 1 or 0.90)}, opened and Enum.EasingStyle.Back or Enum.EasingStyle.Quint)
    local tween = animate(panel, 0.26, {
        GroupTransparency = opened and 0 or 1,
        Position = UDim2.fromScale(0.5, opened and 0.5 or 0.53),
    })
    if not opened then
        local function hide()
            if current == transition and not opened then
                panel.Visible = false
                overlay.Visible = false
            end
        end
        if tween then tween.Completed:Once(hide) else hide() end
    end
end

launcher.Activated:Connect(function() setOpen(not opened) end)
overlay.Activated:Connect(function() setOpen(false) end)
close.Activated:Connect(function() setOpen(false) end)
play.Activated:Connect(function() setOpen(false) end)
homeTab.Activated:Connect(function() selectPage("Home") end)
settingsTab.Activated:Connect(function() selectPage("Settings") end)
motionToggle.Activated:Connect(function()
    motion = not motion
    if not motion then
        animate(panel, 0, {GroupTransparency = 0, Position = UDim2.fromScale(0.5, 0.5)})
        animate(panelScale, 0, {Scale = baseScale})
        animate(overlay, 0, {BackgroundTransparency = 0.46})
        animate(glyph, 0, {Rotation = 45})
        animate(launcherGradient, 0, {Rotation = 140})
        animate(launcherScale, 0, {Scale = 1})
        animate(pages[activePage], 0, {GroupTransparency = 0, Position = UDim2.fromOffset(0, 0)})
    end
    refresh()
end)
accentToggle.Activated:Connect(function()
    blueTheme = not blueTheme
    refresh()
end)

-- Press feedback works with both mouse and touch.
launcher.MouseButton1Down:Connect(function() animate(launcherScale, 0.12, {Scale = motion and 0.88 or 1}) end)
launcher.MouseButton1Up:Connect(function() animate(launcherScale, 0.24, {Scale = 1}, Enum.EasingStyle.Back) end)
launcher.MouseLeave:Connect(function() animate(launcherScale, 0.2, {Scale = 1}) end)
for _, b in ipairs({close, play, homeTab, settingsTab, motionToggle, accentToggle}) do
    local s = make("UIScale", b, {Scale = 1})
    b.MouseButton1Down:Connect(function() animate(s, 0.1, {Scale = motion and 0.96 or 1}) end)
    b.MouseButton1Up:Connect(function() animate(s, 0.19, {Scale = 1}) end)
    b.MouseLeave:Connect(function() animate(s, 0.19, {Scale = 1}) end)
end

local keyboardConnection = UserInputService.InputBegan:Connect(function(input, processed)
    if processed or UserInputService:GetFocusedTextBox() then return end
    if input.KeyCode == Enum.KeyCode.M then setOpen(not opened) end
end)
gui.Destroying:Connect(function()
    keyboardConnection:Disconnect()
    for _, tween in pairs(tweens) do tween:Cancel() end
end)

resize()
selectPage("Home")
