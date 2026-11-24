-- GEOM UI 2.0 | monochrome, responsive, touch-first
-- LocalScript: StarterPlayer > StarterPlayerScripts
-- All UI is created locally. Gameplay controls can be added to the category builders.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local old = playerGui:FindFirstChild("GeomMenu")
if old then old:Destroy() end

local C = {
    black = Color3.fromRGB(10, 10, 10),
    panel = Color3.fromRGB(15, 15, 15),
    card = Color3.fromRGB(22, 22, 22),
    line = Color3.fromRGB(43, 43, 43),
    selected = Color3.fromRGB(38, 38, 38),
    white = Color3.fromRGB(245, 245, 245),
    muted = Color3.fromRGB(146, 146, 146),
    darkText = Color3.fromRGB(15, 15, 15),
}
local function new(class, parent, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end
local function corner(obj, r)
    new("UICorner", obj, {CornerRadius = UDim.new(0, r)})
end
local function outline(obj, color)
    return new("UIStroke", obj, {
        Color = color or C.line, Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end
local function text(parent, value, size, pos, dimensions, color, bold)
    return new("TextLabel", parent, {
        BackgroundTransparency = 1, Text = value,
        TextColor3 = color or C.white, TextSize = size,
        Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Position = pos, Size = dimensions,
    })
end
local function button(parent, value, color, textColor)
    local b = new("TextButton", parent, {
        BackgroundColor3 = color or C.card, BorderSizePixel = 0,
        Text = value, TextColor3 = textColor or C.white,
        Font = Enum.Font.GothamMedium, TextSize = 12,
        AutoButtonColor = false,
    })
    corner(b, 8)
    return b
end

local gui = new("ScreenGui", playerGui, {
    Name = "GeomMenu", ResetOnSpawn = false, DisplayOrder = 50,
    IgnoreGuiInset = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
local root = new("Frame", gui, {
    Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
})
local backdrop = new("TextButton", root, {
    Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.black,
    BackgroundTransparency = 1, BorderSizePixel = 0, Text = "",
    AutoButtonColor = false, Visible = false, ZIndex = 2, Selectable = false,
})
local panel = new("CanvasGroup", root, {
    Name = "Menu", AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(580, 320),
    BackgroundColor3 = C.panel, BorderSizePixel = 0,
    GroupTransparency = 1, Visible = false, ZIndex = 3, ClipsDescendants = true,
})
corner(panel, 15)
outline(panel)
local panelScale = new("UIScale", panel, {Scale = 1})
local header = new("Frame", panel, {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0),
    Size = UDim2.new(1, -24, 0, 47),
})
text(header, "GEOM", 16, UDim2.fromOffset(2, 5), UDim2.fromOffset(110, 23), C.white, true)
text(header, "CONTROL PANEL  /  2.0", 9, UDim2.fromOffset(2, 27), UDim2.fromOffset(185, 12), C.muted)
local close = button(header, "", C.card)
close.AnchorPoint = Vector2.new(1, 0.5)
close.Position = UDim2.new(1, 0, 0.5, 0)
close.Size = UDim2.fromOffset(34, 34)
local function cross(parent, size, color)
    local icon = new("Frame", parent, {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1,
    })
    for _, angle in ipairs({45, -45}) do
        local bar = new("Frame", icon, {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(size, 1.5), Rotation = angle,
            BackgroundColor3 = color, BorderSizePixel = 0,
        })
        corner(bar, 2)
    end
    return icon
end
cross(close, 14, C.white)
new("Frame", panel, {
    Position = UDim2.fromOffset(0, 47), Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = C.line, BorderSizePixel = 0,
})

local nav = new("Frame", panel, {
    Name = "Categories", BackgroundTransparency = 1,
    Position = UDim2.fromOffset(9, 57), Size = UDim2.new(0, 108, 1, -67),
})
local navLayout = new("UIListLayout", nav, {
    SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3),
})
local separator = new("Frame", panel, {
    Position = UDim2.fromOffset(126, 56), Size = UDim2.new(0, 1, 1, -65),
    BackgroundColor3 = C.line, BorderSizePixel = 0,
})
local content = new("Frame", panel, {
    BackgroundTransparency = 1, ClipsDescendants = true,
    Position = UDim2.fromOffset(139, 57), Size = UDim2.new(1, -151, 1, -68),
})

local launcher = new("TextButton", root, {
    Name = "Launcher", AnchorPoint = Vector2.new(0.5, 0.5),
    Size = UDim2.fromOffset(46, 46), BackgroundColor3 = C.black,
    BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 10,
})
new("UICorner", launcher, {CornerRadius = UDim.new(1, 0)})
local ring = outline(launcher, Color3.fromRGB(95, 95, 95))
local launchScale = new("UIScale", launcher, {Scale = 1})
local glyph = cross(launcher, 18, C.white)
glyph.Rotation = -45

local motion, dimBackground = true, true
local opened, generation = false, 0
local active = "Player"
local tweens, connections, pages, tabs, marks = {}, {}, {}, {}, {}
local function connect(signal, callback)
    local c = signal:Connect(callback)
    table.insert(connections, c)
    return c
end
local function cancel(obj)
    local t = tweens[obj]
    if t then tweens[obj] = nil; t:Cancel() end
end
local function animate(obj, seconds, goals, style)
    cancel(obj)
    if not motion or seconds <= 0 then
        for k, v in pairs(goals) do obj[k] = v end
        return nil
    end
    local t = TweenService:Create(obj, TweenInfo.new(seconds, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), goals)
    tweens[obj] = t
    t.Completed:Once(function()
        if tweens[obj] == t then tweens[obj] = nil end
    end)
    t:Play()
    return t
end

local categories = {
    {"Player", "Игрок", "01"},
    {"Combat", "Бой", "02"},
    {"Other", "Остальное", "03"},
    {"Settings", "Настройки", "04"},
    {"Games", "Игры", "05"},
}
for i, item in ipairs(categories) do
    local key, title, index = item[1], item[2], item[3]
    local tab = button(nav, "", C.panel)
    tab.Name = key
    tab.LayoutOrder = i
    tab.Size = UDim2.new(1, 0, 0, 34)
    local marker = new("Frame", tab, {
        Position = UDim2.fromOffset(0, 8), Size = UDim2.new(0, 2, 1, -16),
        BackgroundColor3 = C.white, BackgroundTransparency = 1, BorderSizePixel = 0,
    })
    corner(marker, 2)
    text(tab, index, 9, UDim2.fromOffset(7, 0), UDim2.fromOffset(16, 34), C.muted)
    text(tab, title, 11, UDim2.fromOffset(24, 0), UDim2.new(1, -25, 1, 0), C.white)
    tabs[key], marks[key] = tab, marker

    local page = new("ScrollingFrame", content, {
        Name = key, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = C.muted,
        CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y, Visible = false,
    })
    new("UIPadding", page, {PaddingRight = UDim.new(0, 5), PaddingBottom = UDim.new(0, 3)})
    new("UIListLayout", page, {Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder})
    local titleLabel = text(page, title, 15, UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 24), C.white, true)
    titleLabel.LayoutOrder = 0
    pages[key] = page
end

local function info(page, order, title, subtitle)
    local card = new("Frame", page, {
        LayoutOrder = order, Size = UDim2.new(1, 0, 0, 57),
        BackgroundColor3 = C.card, BorderSizePixel = 0,
    })
    corner(card, 8)
    outline(card)
    text(card, title, 12, UDim2.fromOffset(10, 6), UDim2.new(1, -20, 0, 20), C.white, true)
    local desc = text(card, subtitle, 10, UDim2.fromOffset(10, 27), UDim2.new(1, -20, 0, 24), C.muted)
    desc.TextWrapped = true
    desc.TextTruncate = Enum.TextTruncate.None
    return card, desc
end
local function action(page, order, title, callback)
    local b = button(page, title, C.card)
    b.LayoutOrder = order
    b.Size = UDim2.new(1, 0, 0, 39)
    outline(b)
    connect(b.Activated, callback)
    return b
end
local function toggle(page, order, title, getter, setter)
    local b = button(page, "", C.card)
    b.LayoutOrder = order
    b.Size = UDim2.new(1, 0, 0, 42)
    outline(b)
    text(b, title, 12, UDim2.fromOffset(9, 0), UDim2.new(1, -58, 1, 0), C.white)
    local track = new("Frame", b, {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -9, 0.5, 0),
        Size = UDim2.fromOffset(36, 20), BackgroundColor3 = C.selected, BorderSizePixel = 0,
    })
    corner(track, 10)
    local knob = new("Frame", track, {
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = C.white, BorderSizePixel = 0,
    })
    corner(knob, 7)
    local function refresh(instant)
        local on = getter()
        animate(track, instant and 0 or 0.18, {BackgroundColor3 = on and C.white or C.selected})
        animate(knob, instant and 0 or 0.22, {
            Position = UDim2.new(0, on and 25 or 11, 0.5, 0),
            BackgroundColor3 = on and C.darkText or C.white,
        })
    end
    connect(b.Activated, function() setter(not getter()); refresh(false) end)
    refresh(true)
    return b
end

-- Category builders: only real UI functions and game information for now.
info(pages.Player, 1, player.DisplayName, "@" .. player.Name)
info(pages.Player, 2, "Профиль", "ID: " .. tostring(player.UserId))
info(pages.Combat, 1, "Боевые функции", "Пока не добавлены. Раздел готов к расширению.")
info(pages.Other, 1, "Дополнительные функции", "Здесь будут новые возможности игры.")

local function selectPage(key, instant)
    if not pages[key] then return end
    local previous = active
    active = key
    for name, page in pairs(pages) do
        local selected = name == key
        cancel(page)
        page.Visible = selected
        if selected then
            page.Position = UDim2.fromOffset(not instant and motion and previous ~= key and 12 or 0, 0)
            animate(page, instant and 0 or 0.25, {Position = UDim2.fromOffset(0, 0)})
        end
        animate(tabs[name], instant and 0 or 0.18, {BackgroundColor3 = selected and C.selected or C.panel})
        animate(marks[name], instant and 0 or 0.18, {BackgroundTransparency = selected and 0 or 1})
    end
end
for key, tab in pairs(tabs) do
    local category = key
    connect(tab.Activated, function() selectPage(category, false) end)
end

local function setOpen(value)
    if value == opened then return end
    opened = value
    generation += 1
    local ticket = generation
    if opened then
        if not panel.Visible then
            panelScale.Scale = motion and 0.94 or 1
            panel.GroupTransparency = 1
            panel.Position = UDim2.new(0.5, 0, 0.5, 10)
        end
        panel.Visible = true
        backdrop.Visible = true
    end
    animate(backdrop, 0.24, {BackgroundTransparency = opened and dimBackground and 0.47 or 1})
    animate(glyph, 0.28, {Rotation = opened and 0 or -45})
    animate(ring, 0.24, {Color = opened and C.white or Color3.fromRGB(95, 95, 95)})
    animate(panelScale, opened and 0.36 or 0.20, {Scale = opened and 1 or 0.94}, opened and Enum.EasingStyle.Back or Enum.EasingStyle.Quint)
    local t = animate(panel, opened and 0.27 or 0.19, {
        GroupTransparency = opened and 0 or 1,
        Position = UDim2.new(0.5, 0, 0.5, opened and 0 or 10),
    })
    if not opened then
        local function hide()
            if ticket == generation and not opened then
                panel.Visible = false
                backdrop.Visible = false
            end
        end
        if t then t.Completed:Once(hide) else hide() end
    end
end

toggle(pages.Settings, 1, "Анимации", function() return motion end, function(v)
    motion = v
    if not v then
        -- Finish active transitions immediately rather than leaving intermediate states.
        animate(panel, 0, {GroupTransparency = 0, Position = UDim2.fromScale(0.5, 0.5)})
        animate(panelScale, 0, {Scale = 1})
        animate(backdrop, 0, {BackgroundTransparency = dimBackground and 0.47 or 1})
        animate(glyph, 0, {Rotation = 0})
        animate(launchScale, 0, {Scale = 1})
        animate(ring, 0, {Color = C.white})
        selectPage(active, true)
    end
end)
toggle(pages.Settings, 2, "Затемнение", function() return dimBackground end, function(v)
    dimBackground = v
    animate(backdrop, 0.22, {BackgroundTransparency = opened and v and 0.47 or 1})
end)
info(pages.Games, 1, "Текущая игра", "Place ID: " .. tostring(game.PlaceId))
action(pages.Games, 2, "Продолжить игру", function() setOpen(false) end)
connect(close.Activated, function() setOpen(false) end)
connect(backdrop.Activated, function() setOpen(false) end)

-- Responsive sizing uses actual safe-area dimensions; no per-frame loops.
-- On short landscape screens the category rail and content can scroll.
local rail = new("ScrollingFrame", panel, {
    Name = "CategoryScroll", BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = nav.Position, Size = nav.Size, ScrollBarThickness = 0,
    CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollingDirection = Enum.ScrollingDirection.Y,
})
nav.Parent = rail
nav.Position = UDim2.fromOffset(0, 0)
nav.Size = UDim2.new(1, 0, 0, 182)

local center = nil
local lastSize = nil
local drag = nil
local function clampCenter(p)
    local s = root.AbsoluteSize
    local pad = 27
    return Vector2.new(
        math.clamp(p.X, math.min(pad, s.X / 2), math.max(s.X - pad, s.X / 2)),
        math.clamp(p.Y, math.min(pad, s.Y / 2), math.max(s.Y - pad, s.Y / 2))
    )
end
local function moveLauncher(p)
    center = clampCenter(p)
    launcher.Position = UDim2.fromOffset(center.X, center.Y)
end
local function resize()
    local s = root.AbsoluteSize
    if s.X < 1 or s.Y < 1 then return end
    local w = math.min(600, math.max(1, s.X - 20))
    local h = math.min(326, math.max(1, s.Y - 20))
    local narrow = w < 410
    local side = narrow and 95 or 120
    panel.Size = UDim2.fromOffset(w, h)
    rail.Size = UDim2.new(0, side, 1, -67)
    separator.Position = UDim2.fromOffset(side + 17, 56)
    content.Position = UDim2.fromOffset(side + 26, 57)
    content.Size = UDim2.new(1, -(side + 36), 1, -68)
    if not center then
        moveLauncher(Vector2.new(s.X - 32, s.Y * 0.30))
    elseif lastSize and lastSize.X > 0 and lastSize.Y > 0 and not drag then
        moveLauncher(Vector2.new(center.X * s.X / lastSize.X, center.Y * s.Y / lastSize.Y))
    else
        moveLauncher(center)
    end
    lastSize = s
end
connect(root:GetPropertyChangedSignal("AbsoluteSize"), resize)

-- Capture a single pointer. A move past 8 px is a drag, never a menu tap.
local function point(input)
    return Vector2.new(input.Position.X, input.Position.Y)
end
connect(launcher.InputBegan, function(input)
    local kind = input.UserInputType
    if drag or (kind ~= Enum.UserInputType.Touch and kind ~= Enum.UserInputType.MouseButton1) then return end
    if not center then resize() end
    if not center then return end
    drag = {input = input, kind = kind, start = point(input), origin = center, moved = false}
    animate(launchScale, 0.11, {Scale = 0.90})
end)
connect(UIS.InputChanged, function(input)
    local d = drag
    if not d then return end
    if d.kind == Enum.UserInputType.Touch then
        if input ~= d.input then return end
    elseif input.UserInputType ~= Enum.UserInputType.MouseMovement then
        return
    end
    local delta = point(input) - d.start
    if not d.moved and delta.Magnitude >= 8 then
        d.moved = true
        animate(launchScale, 0.18, {Scale = 1.05})
    end
    if d.moved then moveLauncher(d.origin + delta) end
end)
connect(UIS.InputEnded, function(input)
    local d = drag
    if not d then return end
    if d.kind == Enum.UserInputType.Touch then
        if input ~= d.input then return end
    elseif input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end
    drag = nil
    animate(launchScale, 0.28, {Scale = 1}, Enum.EasingStyle.Back)
    if not d.moved and input.UserInputState == Enum.UserInputState.End then
        setOpen(not opened)
    end
end)
connect(UIS.WindowFocusReleased, function()
    if drag then drag = nil; animate(launchScale, 0, {Scale = 1}) end
end)
connect(UIS.InputBegan, function(input, processed)
    if processed or UIS:GetFocusedTextBox() then return end
    if input.KeyCode == Enum.KeyCode.M then setOpen(not opened) end
end)
gui.Destroying:Connect(function()
    for _, c in ipairs(connections) do c:Disconnect() end
    local objects = {}
    for obj in pairs(tweens) do table.insert(objects, obj) end
    for _, obj in ipairs(objects) do cancel(obj) end
end)

resize()
selectPage("Player", true)
