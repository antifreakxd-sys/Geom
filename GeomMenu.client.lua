-- GEOM UI 4.3 | monochrome, responsive, touch-first
-- LocalScript: StarterPlayer > StarterPlayerScripts
-- All UI is created locally. Gameplay controls can be added to the category builders.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
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
local panel = new("Frame", root, {
    Name = "Menu", AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(460, 248),
    BackgroundColor3 = C.panel, BorderSizePixel = 0,
    Active = true, Visible = false, ZIndex = 3, ClipsDescendants = true,
})
corner(panel, 15)
outline(panel)
local panelScale = new("UIScale", panel, {Scale = 1})
local header = new("Frame", panel, {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0),
    Size = UDim2.new(1, -24, 0, 47),
})
text(header, "GEOM", 16, UDim2.fromOffset(2, 5), UDim2.fromOffset(110, 23), C.white, true)
text(header, "CONTROL PANEL  /  4.3", 9, UDim2.fromOffset(2, 27), UDim2.fromOffset(185, 12), C.muted)
local close = button(header, "", C.card)
close.AnchorPoint = Vector2.new(1, 0.5)
close.Position = UDim2.new(1, 0, 0.5, 0)
close.Size = UDim2.fromOffset(44, 44)
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
local featureRefresh = {}
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
    {"Visuals", "Визуалы", "03"},
    {"Other", "Остальное", "04"},
    {"Binds", "Бинды", "05"},
    {"Settings", "Настройки", "06"},
    {"Games", "Игры", "07"},
}
for i, item in ipairs(categories) do
    local key, title, index = item[1], item[2], item[3]
    local tab = button(nav, "", C.panel)
    tab.Name = key
    tab.LayoutOrder = i
    tab.Size = UDim2.new(1, 0, 0, 42)
    local marker = new("Frame", tab, {
        Position = UDim2.fromOffset(0, 8), Size = UDim2.new(0, 2, 1, -16),
        BackgroundColor3 = C.white, BackgroundTransparency = 1, BorderSizePixel = 0,
    })
    corner(marker, 2)
    local caption = text(tab, title, 13, UDim2.fromOffset(10, 0), UDim2.new(1, -20, 1, 0), C.white)
    caption.TextXAlignment = Enum.TextXAlignment.Center
    tabs[key], marks[key] = tab, marker

    local page = new("ScrollingFrame", content, {
        Name = key, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = C.muted,
        CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y, Visible = false,
    })
    new("UIPadding", page, {PaddingRight = UDim.new(0, 5), PaddingBottom = UDim.new(0, 3)})
    new("UIListLayout", page, {Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder})
    local titleLabel = text(page, title, 13, UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 18), C.white, true)
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
local function toggle(page, order, title, getter, setter, compact)
    local b = button(page, "", C.card)
    b.LayoutOrder = order
    b.Size = UDim2.new(1, 0, 0, 44)
    if not compact then outline(b) end
    text(b, title, 13, UDim2.fromOffset(9, 0), UDim2.new(1, -58, 1, 0), C.white)
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
    return b, refresh
end

-- Reusable accordion: separate touch targets for options and the main switch.
local function featureRow(page, order, title, getter, setter, build, key)
    local row = new("Frame", page, {
        LayoutOrder = order, Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = C.card, BorderSizePixel = 0, ClipsDescendants = true,
    })
    corner(row, 9)
    outline(row)
    local arrow = button(row, "", C.card)
    arrow.Position = UDim2.fromOffset(2, 2)
    arrow.Size = UDim2.new(1, -58, 0, 40)
    local chevron = new("Frame", arrow, {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 19, 0.5, 0),
        Size = UDim2.fromOffset(12, 12), BackgroundTransparency = 1,
    })
    for _, spec in ipairs({{-2, 45}, {2, -45}}) do
        local bar = new("Frame", chevron, {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, spec[1]),
            Size = UDim2.fromOffset(7, 1.5), Rotation = spec[2],
            BackgroundColor3 = C.muted, BorderSizePixel = 0,
        })
        corner(bar, 1)
    end
    text(arrow, title, 13, UDim2.fromOffset(35, 0), UDim2.new(1, -39, 1, 0), C.white, true)
    local switch = button(row, "", C.card)
    switch.AnchorPoint = Vector2.new(1, 0)
    switch.Position = UDim2.new(1, -4, 0, 2)
    switch.Size = UDim2.fromOffset(50, 40)
    local track = new("Frame", switch, {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(36, 20), BackgroundColor3 = C.selected, BorderSizePixel = 0,
    })
    corner(track, 10)
    local knob = new("Frame", track, {
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = C.white, BorderSizePixel = 0,
    })
    corner(knob, 7)
    local function refresh(now)
        local on = getter()
        animate(track, now and 0 or 0.16, {BackgroundColor3 = on and C.white or C.selected})
        animate(knob, now and 0 or 0.20, {
            Position = UDim2.new(0, on and 25 or 11, 0.5, 0),
            BackgroundColor3 = on and C.darkText or C.white,
        })
    end
    if key then featureRefresh[key] = refresh end
    connect(switch.Activated, function() setter(not getter()); refresh(false) end)
    refresh(true)
    local inner = new("Frame", row, {
        Position = UDim2.fromOffset(7, 47), Size = UDim2.new(1, -14, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
        Visible = false,
    })
    local layout = new("UIListLayout", inner, {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3)})
    build(inner)
    local expanded, revision = false, 0
    local function fit(now)
        local h = expanded and (layout.AbsoluteContentSize.Y + 54) or 44
        animate(row, now and 0 or 0.22, {Size = UDim2.new(1, 0, 0, h)})
    end
    connect(layout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        if expanded then fit(false) end
    end)
    connect(arrow.Activated, function()
        expanded = not expanded
        revision += 1
        local current = revision
        if expanded then inner.Visible = true end
        animate(chevron, 0.20, {Rotation = expanded and 90 or 0})
        local t = animate(row, 0.22, {Size = UDim2.new(1, 0, 0, expanded and (layout.AbsoluteContentSize.Y + 54) or 44)})
        if not expanded then
            local function hide()
                if current == revision and not expanded then inner.Visible = false end
            end
            if t then t.Completed:Once(hide) else hide() end
        end
    end)
    return row
end

local function choice(parent, order, title, values, getter, setter)
    local row = new("Frame", parent, {
        LayoutOrder = order, Size = UDim2.new(1, 0, 0, 66),
        BackgroundTransparency = 1,
    })
    text(row, title, 11, UDim2.fromOffset(8, 0), UDim2.new(1, -16, 0, 19), C.muted)
    local left = button(row, "−", C.panel)
    left.Position = UDim2.fromOffset(8, 20)
    left.Size = UDim2.fromOffset(44, 44)
    local right = button(row, "+", C.panel)
    right.AnchorPoint = Vector2.new(1, 0)
    right.Position = UDim2.new(1, -8, 0, 20)
    right.Size = UDim2.fromOffset(44, 44)
    local value = text(row, "", 12, UDim2.fromOffset(53, 20), UDim2.new(1, -106, 0, 44), C.white, true)
    value.TextXAlignment = Enum.TextXAlignment.Center
    local function refresh() value.Text = tostring(getter()) end
    local function step(delta)
        local i = table.find(values, getter()) or 1
        setter(values[math.clamp(i + delta, 1, #values)])
        refresh()
    end
    connect(left.Activated, function() step(-1) end)
    connect(right.Activated, function() step(1) end)
    refresh()
end

-- Entity markers for this experience. NPCs are humanoid models without a Player;
-- non-humanoid entities can be tagged GeomEntity in Studio.
-- All markers are local, disabled by default, and limited to nearby targets.
-- A viewport-aligned HUD, independent of menu safe-area insets.
local hud = new("ScreenGui", playerGui, {
    Name = "GeomVisualHUD", ResetOnSpawn = false, IgnoreGuiInset = true,
    ScreenInsets = Enum.ScreenInsets.None, DisplayOrder = 40,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
local fovRing = new("Frame", hud, {
    Name = "AimFOV", AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(1, 1),
    BackgroundTransparency = 1, Visible = false,
})
new("UICorner", fovRing, {CornerRadius = UDim.new(1, 0)})
local fovStroke = outline(fovRing, C.white)
fovStroke.Transparency = 0.35
local function lineOfSight(origin, target, model, exclude)
    local delta = target - origin
    if delta.Magnitude < 0.01 then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = exclude and {exclude} or {}
    local hit = workspace:Raycast(origin, delta, params)
    return not hit or hit.Instance:IsDescendantOf(model)
end


local visual = {
    enabled = false, players = true, bots = true, entities = true,
    names = true, kinds = true, distance = true, health = false,
    highlight = false, throughWalls = true, range = 0, limit = 0, declutter = true,
}
local candidates, markers = {}, {}
local labelEntries = {}
local radar = {enabled = false, players = true, bots = true, teammates = false, range = 400, radius = 90, limit = 16}
local aim = {enabled = false, range = 250, angle = 12, smooth = 0, players = true, bots = true, teammates = false, circle = true, part = "Голова", prediction = 0}
local function tracking() return visual.enabled or radar.enabled or aim.enabled end
local trackingActive = false
local onRadarUpdate = function() end
local clearRadar = function() end
local function isEnemy(owner)
    return not owner or owner ~= player and (player.Neutral or owner.Neutral or player.Team ~= owner.Team)
end
local visualConnections = {}
local epoch = 0
local markerFolder = new("Folder", workspace, {Name = "GeomLocalMarkers"})
-- Labels are rendered in a viewport-aligned ScreenGui.
local function visualConnect(signal, callback)
    table.insert(visualConnections, signal:Connect(callback))
end
local function removeMarker(model)
    local item = markers[model]
    if not item then return end
    markers[model] = nil
    item.gui:Destroy()
    if item.highlight then item.highlight:Destroy() end
end
local function clearMarkers()
    table.clear(labelEntries)
    local models = {}
    for model in pairs(markers) do table.insert(models, model) end
    for _, model in ipairs(models) do removeMarker(model) end
end
local function addCandidate(model)
    if model and model:IsA("Model") and model:IsDescendantOf(workspace) then candidates[model] = true end
end
local function entityPart(model, humanoid)
    local p = model:FindFirstChild("HumanoidRootPart") or (humanoid and humanoid.RootPart) or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
    if p and p:IsA("BasePart") then return p end
    return nil
end
local function markerFor(model, part)
    local item = markers[model]
    if item then return item end
    local g = new("Frame", hud, {
        Name = "GeomEntityLabel", AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(104, 25), BackgroundTransparency = 1,
        BorderSizePixel = 0, Visible = false, ZIndex = 2,
    })
    local name = new("TextLabel", g, {
        Size = UDim2.new(1, 0, 0, 12), Position = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1, TextColor3 = C.white, TextStrokeTransparency = 0.15,
        TextSize = 10, Font = Enum.Font.GothamBold, TextTruncate = Enum.TextTruncate.AtEnd,
    })
    local detail = new("TextLabel", g, {
        Size = UDim2.new(1, 0, 0, 10), Position = UDim2.fromOffset(0, 12),
        BackgroundTransparency = 1, TextColor3 = C.white, TextStrokeTransparency = 0.15,
        TextSize = 9, Font = Enum.Font.GothamMedium,
    })
    local bar = new("Frame", g, {
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 23),
        Size = UDim2.fromOffset(36, 2), BackgroundColor3 = C.selected, BorderSizePixel = 0,
    })
    corner(bar, 2)
    local fill = new("Frame", bar, {Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.white, BorderSizePixel = 0})
    corner(fill, 2)
    item = {gui = g, name = name, detail = detail, bar = bar, fill = fill}
    markers[model] = item
    return item
end

local function updateVisuals()
    if not visual.enabled then clearMarkers(); return end
    local camera = workspace.CurrentCamera
    if not camera then clearMarkers(); return end
    local own = player.Character
    local ownRoot = own and own:FindFirstChild("HumanoidRootPart")
    local origin = ownRoot and ownRoot:IsA("BasePart") and ownRoot.Position or camera.CFrame.Position
    local nearby = {}
    for model in pairs(candidates) do
        if not model:IsDescendantOf(workspace) then
            candidates[model] = nil
        elseif model ~= own then
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            local owner = Players:GetPlayerFromCharacter(model)
            local tagged = CollectionService:HasTag(model, "GeomEntity")
            local kind = owner and "PLAYER" or (humanoid and "BOT" or "ENTITY")
            if not humanoid and not owner and not tagged then
                candidates[model] = nil
            elseif (not humanoid or humanoid.Health > 0)
                and ((owner and visual.players) or (not owner and humanoid and visual.bots) or (not owner and not humanoid and tagged and visual.entities)) then
                local part = entityPart(model, humanoid)
                if part then
                    local d = (part.Position - origin).Magnitude
                    if visual.range == 0 or d <= visual.range then
                        table.insert(nearby, {model = model, humanoid = humanoid, owner = owner, part = part, kind = kind, distance = d})
                    end
                end
            end
        end
    end
    table.sort(nearby, function(a, b) return a.distance < b.distance end)
    local keep, selected = {}, {}
    for _, entry in ipairs(nearby) do
        if visual.limit > 0 and #selected >= visual.limit then break end
        table.insert(selected, entry)
        keep[entry.model] = true
    end
    labelEntries = selected
    local count = #selected
    local stale = {}
    for model in pairs(markers) do if not keep[model] then table.insert(stale, model) end end
    for _, model in ipairs(stale) do removeMarker(model) end
    for i = 1, count do
        local entry = selected[i]
        local item = markerFor(entry.model, entry.part)
        local head = entry.model:FindFirstChild("Head")
        item.part = head and head:IsA("BasePart") and head or entry.part
        item.offset = item.part == head and 1.2 or 2.0
        item.allowed = visual.throughWalls or lineOfSight(camera.CFrame.Position, item.part.Position, entry.model, own)
        local name = entry.owner and entry.owner.DisplayName or entry.model.Name
        local parts = {}
        if visual.kinds then table.insert(parts, entry.kind == "PLAYER" and "PLY" or entry.kind == "ENTITY" and "ENT" or "BOT") end
        if visual.distance then table.insert(parts, tostring(math.floor(entry.distance + 0.5)) .. " st") end
        local h = entry.humanoid
        if visual.health and h then table.insert(parts, tostring(math.floor(h.Health + 0.5)) .. " HP") end
        item.name.Text = visual.names and name or ""
        item.detail.Text = table.concat(parts, " · ")
        item.bar.Visible = visual.health and h ~= nil
        if h then item.fill.Size = UDim2.fromScale(math.clamp(h.Health / math.max(1, h.MaxHealth), 0, 1), 1) end
        if visual.highlight then
            if not item.highlight then
                item.highlight = new("Highlight", markerFolder, {
                    Name = "GeomEntityOutline", Adornee = entry.model, FillTransparency = 0.91,
                    OutlineTransparency = 0.18, OutlineColor = C.white, FillColor = C.white,
                })
            end
            item.highlight.DepthMode = visual.throughWalls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
        elseif item.highlight then
            item.highlight:Destroy()
            item.highlight = nil
        end
    end
end
-- True pixel-space collision tests; labels follow the camera each rendered frame.
local labelRender
local function intersects(occupied, x, y, w, h)
    for _, box in ipairs(occupied) do
        if math.abs(x - box.x) < (w + box.w) * 0.5 + 2 and math.abs(y - box.y) < (h + box.h) * 0.5 + 2 then return true end
    end
    return false
end
local labelOverflow = new("TextLabel", hud, {
    AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -25),
    Size = UDim2.fromOffset(200, 18), BackgroundTransparency = 1,
    TextColor3 = C.muted, TextStrokeTransparency = 0.2, TextSize = 11,
    Font = Enum.Font.Gotham, Visible = false,
})
local function renderLabels()
    local camera = workspace.CurrentCamera
    if not camera then
        for _, item in pairs(markers) do item.gui.Visible = false end
        labelOverflow.Visible = false
        return
    end
    local size = camera.ViewportSize
    local occupied = {}
    local overflow = 0
    for _, entry in ipairs(labelEntries) do
        local item = markers[entry.model]
        if item then
            local part = item.part
            local found = false
            if part and part.Parent and item.allowed and size.X >= 110 and size.Y >= 30 then
                local p, onScreen = camera:WorldToViewportPoint(part.Position + Vector3.new(0, item.offset, 0))
                if onScreen and p.Z > 0 then
                    local x = math.clamp(p.X, 53, size.X - 53)
                    local y = math.clamp(p.Y, 14, size.Y - 14)
                    -- Prefer the original anchor, then alternate above/below; try adjacent columns.
                    for column = 0, 4 do
                        if found then break end
                        local dx = column == 0 and 0 or math.ceil(column / 2) * 108 * (column % 2 == 1 and 1 or -1)
                        local nx = x + dx
                        if nx >= 53 and nx <= size.X - 53 then
                            for n = 0, math.min(20, math.ceil(size.Y / 27) * 2) do
                                local dy = n == 0 and 0 or math.ceil(n / 2) * 27 * (n % 2 == 1 and -1 or 1)
                                local ny = y + dy
                                if ny >= 14 and ny <= size.Y - 14 and (not visual.declutter or not intersects(occupied, nx, ny, 104, 25)) then
                                    item.gui.Position = UDim2.fromOffset(nx, ny)
                                    table.insert(occupied, {x = nx, y = ny, w = 104, h = 25})
                                    found = true
                                    break
                                end
                            end
                        end
                    end
                    if not found then overflow += 1 end
                end
            end
            item.gui.Visible = found and not opened
        end
    end
    labelOverflow.Text = "+" .. overflow .. " меток"
    labelOverflow.Visible = overflow > 0 and not opened
end

local function stopVisuals()
    epoch += 1
    trackingActive = false
    for _, c in ipairs(visualConnections) do c:Disconnect() end
    table.clear(visualConnections)
    table.clear(candidates)
    clearMarkers()
    clearRadar()
    if labelRender then labelRender:Disconnect(); labelRender = nil end
    labelOverflow.Visible = false
end
local function startVisuals()
    if trackingActive then return end
    stopVisuals()
    trackingActive = true
    local ticket = epoch
    visualConnect(workspace.DescendantAdded, function(obj)
        if obj:IsA("Humanoid") then addCandidate(obj.Parent)
        elseif obj:IsA("Model") and (obj:FindFirstChildOfClass("Humanoid") or CollectionService:HasTag(obj, "GeomEntity")) then addCandidate(obj) end
    end)
    visualConnect(CollectionService:GetInstanceAddedSignal("GeomEntity"), addCandidate)
    visualConnect(CollectionService:GetInstanceRemovedSignal("GeomEntity"), function(model)
        if model:IsA("Model") and not model:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(model) then
            candidates[model] = nil
            removeMarker(model)
        end
    end)
    for _, obj in ipairs(CollectionService:GetTagged("GeomEntity")) do addCandidate(obj) end
    for _, p in ipairs(Players:GetPlayers()) do addCandidate(p.Character) end
    task.spawn(function()
        -- Single initial discovery, chunked to avoid a long mobile frame.
        local objects = workspace:GetDescendants()
        for i, obj in ipairs(objects) do
            if ticket ~= epoch then return end
            if obj:IsA("Humanoid") then addCandidate(obj.Parent) end
            if i % 300 == 0 then task.wait() end
        end
        while tracking() and ticket == epoch do
            updateVisuals()
            onRadarUpdate()
            task.wait(0.15)
        end
    end)
end
local function syncTracking()
    if tracking() then startVisuals() else stopVisuals() end
end
local function setVisual(key, value)
    visual[key] = value
    syncTracking()
    updateVisuals()
    if visual.enabled and not labelRender then labelRender = RunService.RenderStepped:Connect(renderLabels)
    elseif not visual.enabled and labelRender then labelRender:Disconnect(); labelRender = nil; labelOverflow.Visible = false end
end

featureRow(pages.Visuals, 1, "ESP / Метки", function() return visual.enabled end,
    function(v) setVisual("enabled", v) end, function(inner)
        local options = {
            {"players", "Игроки"}, {"bots", "Боты / NPC"}, {"entities", "Другие сущности"},
            {"names", "Имена"}, {"kinds", "Тип сущности"}, {"distance", "Расстояние"},
            {"health", "Здоровье / HP"}, {"highlight", "Контуры"}, {"throughWalls", "Сквозь стены"}, {"declutter", "Без наложений"},
        }
        for i, item in ipairs(options) do
            local key = item[1]
            toggle(inner, i, item[2], function() return visual[key] end, function(v) setVisual(key, v) end, true)
        end
        choice(inner, 11, "Дальность (studs)", {"Все", 75, 150, 250, 400, 600}, function() return visual.range == 0 and "Все" or visual.range end, function(v) setVisual("range", v == "Все" and 0 or v) end)
        choice(inner, 12, "Лимит меток", {"Все", 4, 8, 16, 32}, function() return visual.limit == 0 and "Все" or visual.limit end, function(v) setVisual("limit", v == "Все" and 0 or v) end)
    end, "ESP")

-- Category builders: only real UI functions and game information for now.
info(pages.Player, 1, player.DisplayName, "@" .. player.Name)
info(pages.Player, 2, "Профиль", "ID: " .. tostring(player.UserId))


-- Direction arrows: camera-relative bearing, including targets behind camera.
-- Red means an unobstructed ray between characters, not a guaranteed weapon hit.
local arrowItems, arrowPool, radarEntries = {}, {}, {}
local RED = Color3.fromRGB(255, 75, 75)
local function makeArrow()
    local group = new("Frame", hud, {
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(40, 30),
        BackgroundTransparency = 1, Visible = false,
    })
    local icon = new("TextLabel", group, {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(20, 9),
        Size = UDim2.fromOffset(20, 19), BackgroundTransparency = 1,
        Text = "▲", TextSize = 18, Font = Enum.Font.GothamBold,
        TextStrokeTransparency = 0.3, TextColor3 = C.white,
    })
    local dist = new("TextLabel", group, {
        Position = UDim2.fromOffset(0, 18), Size = UDim2.fromOffset(40, 12),
        BackgroundTransparency = 1, TextSize = 10, Font = Enum.Font.GothamBold,
        TextStrokeTransparency = 0.25, TextColor3 = C.white,
    })
    return {group = group, icon = icon, dist = dist}
end
clearRadar = function()
    table.clear(radarEntries)
    for model, item in pairs(arrowItems) do
        item.group.Visible = false
        table.insert(arrowPool, item)
        arrowItems[model] = nil
    end
end
onRadarUpdate = function()
    if not radar.enabled then return end
    local camera = workspace.CurrentCamera
    if not camera then clearRadar(); return end
    local own = player.Character
    local originPart = own and (own:FindFirstChild("Head") or own:FindFirstChild("HumanoidRootPart"))
    local origin = originPart and originPart:IsA("BasePart") and originPart.Position or camera.CFrame.Position
    local all = {}
    for model in pairs(candidates) do
        if model ~= own and model:IsDescendantOf(workspace) then
            local h = model:FindFirstChildOfClass("Humanoid")
            local owner = Players:GetPlayerFromCharacter(model)
            if h and h.Health > 0 and ((owner and radar.players and (radar.teammates or isEnemy(owner))) or (not owner and radar.bots)) then
                local part = entityPart(model, h)
                if part then
                    local d = (part.Position - origin).Magnitude
                    if d <= radar.range then table.insert(all, {model = model, part = part, distance = d}) end
                end
            end
        end
    end
    table.sort(all, function(a,b) return a.distance < b.distance end)
    local keep = {}
    table.clear(radarEntries)
    for i = 1, math.min(#all, radar.limit) do
        local e = all[i]
        local head = e.model:FindFirstChild("Head")
        local p = head and head:IsA("BasePart") and head or e.part
        e.visible = lineOfSight(origin, p.Position, e.model, own)
            or lineOfSight(origin, e.part.Position, e.model, own)
        keep[e.model] = true
        table.insert(radarEntries, e)
    end
    for model, item in pairs(arrowItems) do
        if not keep[model] then
            item.group.Visible = false
            table.insert(arrowPool, item)
            arrowItems[model] = nil
        end
    end
    for _, e in ipairs(radarEntries) do
        local item = arrowItems[e.model]
        if not item then
            item = table.remove(arrowPool) or makeArrow()
            arrowItems[e.model] = item
        end
        local color = e.visible and RED or C.white
        item.icon.TextColor3 = color
        item.dist.TextColor3 = color
        item.dist.Text = tostring(math.floor(e.distance + 0.5)) .. "st"
    end
end
local radarOverflow = new("TextLabel", hud, {
    AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.5, 26),
    Size = UDim2.fromOffset(100, 18), BackgroundTransparency = 1,
    TextColor3 = C.muted, TextStrokeTransparency = 0.2, TextSize = 10, Font = Enum.Font.Gotham, Visible = false,
})
local radarRender
local function setRadar(value)
    radar.enabled = value
    if radarRender then radarRender:Disconnect(); radarRender = nil end
    if value then
        syncTracking()
        onRadarUpdate()
        radarRender = RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            if not cam then return end
            local size = cam.ViewportSize
            local half = math.min(size.X, size.Y) * 0.5
            local radius = math.min(radar.radius, half - 28)
            local occupied = {}
            local overflow = 0
            for _, e in ipairs(radarEntries) do
                local item = arrowItems[e.model]
                if item and e.part.Parent then
                    local v = cam.CFrame:VectorToObjectSpace(e.part.Position - cam.CFrame.Position)
                    local angle = math.atan2(v.X, -v.Z)
                    local found = false
                    -- Try exact bearing first, then nearby angles and outward rings.
                    -- Rectangles, rather than sectors, prevent cross-sector overlap.
                    for layer = 0, 3 do
                        if found then break end
                        local rr = radius + layer * 35
                        if rr > 0 and rr <= half - 20 then
                            for n = 0, 8 do
                                local da = n == 0 and 0 or math.ceil(n / 2) * math.rad(9) * (n % 2 == 1 and 1 or -1)
                                local a = angle + da
                                local x, y = size.X * 0.5 + math.sin(a) * rr, size.Y * 0.5 - math.cos(a) * rr
                                if x >= 21 and x <= size.X - 21 and y >= 16 and y <= size.Y - 16
                                    and not intersects(occupied, x, y, 40, 30) then
                                    table.insert(occupied, {x = x, y = y, w = 40, h = 30})
                                    item.group.Position = UDim2.fromOffset(x, y)
                                    item.icon.Rotation = math.deg(angle)
                                    found = true
                                    break
                                end
                            end
                        end
                    end
                    item.group.Visible = found and not opened
                    if not found then overflow += 1 end
                elseif item then item.group.Visible = false end
            end
            radarOverflow.Text = "+" .. overflow .. " целей"
            radarOverflow.Visible = overflow > 0 and not opened
        end)
    else
        clearRadar()
        radarOverflow.Visible = false
        syncTracking()
    end
end
featureRow(pages.Visuals, 2, "Стрелки целей", function() return radar.enabled end, setRadar, function(inner)
    toggle(inner, 1, "Игроки", function() return radar.players end, function(v) radar.players = v; onRadarUpdate() end, true)
    toggle(inner, 2, "Боты / NPC", function() return radar.bots end, function(v) radar.bots = v; onRadarUpdate() end, true)
    toggle(inner, 3, "Союзники", function() return radar.teammates end, function(v) radar.teammates = v; onRadarUpdate() end, true)
    choice(inner, 4, "Радиус (px)", {55, 70, 90, 110, 140}, function() return radar.radius end, function(v) radar.radius = v end)
    choice(inner, 5, "Дальность (studs)", {100, 200, 400, 800}, function() return radar.range end, function(v) radar.range = v; onRadarUpdate() end)
    choice(inner, 6, "Лимит стрелок", {8, 16, 24, 32}, function() return radar.limit end, function(v) radar.limit = v; onRadarUpdate() end)
end, "DIR")

-- Camera aim assistance for the experience, with visible targets and frame-rate independent smoothing.
local aimTarget, aimClock = nil, 0
local aimStepName = "GeomAim_" .. tostring(player.UserId)
local function targetPart(model)
    if not model or model == player.Character or not model:IsDescendantOf(workspace) then return nil end
    local h = model:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return nil end
    local owner = Players:GetPlayerFromCharacter(model)
    if owner then
        if not aim.players or (not aim.teammates and not isEnemy(owner)) then return nil end
    elseif not aim.bots then return nil end
    local names = aim.part == "Голова" and {"Head"} or aim.part == "Грудь" and {"UpperTorso", "Torso"}
        or aim.part == "Таз" and {"LowerTorso", "HumanoidRootPart"} or {"HumanoidRootPart"}
    for _, name in ipairs(names) do
        local part = model:FindFirstChild(name)
        if part and part:IsA("BasePart") then return part end
    end
    if aim.part == "Голова" then return nil end
    return entityPart(model, h)
end
local function aimScore(camera, model)
    local part = targetPart(model)
    if not part then return nil end
    local delta = part.Position - camera.CFrame.Position
    local distance = delta.Magnitude
    if distance < 1 or distance > aim.range then return nil end
    local angle = math.deg(math.acos(math.clamp(camera.CFrame.LookVector:Dot(delta.Unit), -1, 1)))
    if angle > aim.angle then return nil end
    if not lineOfSight(camera.CFrame.Position, part.Position, model, player.Character) then return nil end
    return angle, part
end
local function findAim(camera)
    local best, score = nil, math.huge
    for model in pairs(candidates) do
        local a = aimScore(camera, model)
        if a and a < score then best, score = model, a end
    end
    return best
end
local function setAim(v)
    aim.enabled = v
    RunService:UnbindFromRenderStep(aimStepName)
    aimTarget, aimClock = nil, 0
    fovRing.Visible = false
    syncTracking()
    if v then
        RunService:BindToRenderStep(aimStepName, Enum.RenderPriority.Camera.Value + 1, function(dt)
            local camera = workspace.CurrentCamera
            if not camera then fovRing.Visible = false; return end
            local viewport = camera.ViewportSize
            local focal = viewport.Y / (2 * math.tan(math.rad(camera.FieldOfView * 0.5)))
            local diameter = 2 * focal * math.tan(math.rad(aim.angle))
            fovRing.Size = UDim2.fromOffset(diameter, diameter)
            fovRing.Visible = aim.circle and not opened
            if opened or camera.CameraType == Enum.CameraType.Scriptable then aimTarget = nil; aimClock = 0; return end
            aimClock -= dt
            local part
            if aimTarget then local _, current = aimScore(camera, aimTarget); part = current end
            if not part then
                aimTarget = findAim(camera)
                if aimTarget then local _, current = aimScore(camera, aimTarget); part = current end
            end
            if not part then aimTarget = nil; return end
            local position = part.Position + part.AssemblyLinearVelocity * aim.prediction
            if (position - camera.CFrame.Position).Magnitude < 0.01 then return end
            local goal = CFrame.lookAt(camera.CFrame.Position, position)
            if aim.smooth == 0 then
                camera.CFrame = goal
            else
                -- Smoothness is a response time in milliseconds; larger = slower.
                camera.CFrame = camera.CFrame:Lerp(goal, 1 - math.exp(-dt / (aim.smooth / 1000)))
            end
        end)
    end
end
featureRow(pages.Combat, 1, "Aim Assist", function() return aim.enabled end, setAim, function(inner)
    toggle(inner, 1, "Круг FOV", function() return aim.circle end, function(v) aim.circle = v end, true)
    choice(inner, 2, "Точка наведения", {"Голова", "Грудь", "Таз", "Центр"}, function() return aim.part end, function(v) aim.part = v; aimClock = 0 end)
    choice(inner, 3, "Предикт (сек.)", {0, 0.03, 0.06, 0.10, 0.15, 0.20}, function() return aim.prediction end, function(v) aim.prediction = v end)
    choice(inner, 4, "Угол (градусы)", {5, 8, 12, 18, 25, 35}, function() return aim.angle end, function(v) aim.angle = v; aimClock = 0 end)
    choice(inner, 5, "Плавность (мс)", {0, 25, 50, 100, 150, 250, 400}, function() return aim.smooth end, function(v) aim.smooth = v end)
    choice(inner, 6, "Дальность (studs)", {50, 120, 250, 400, 800}, function() return aim.range end, function(v) aim.range = v; aimClock = 0 end)
    toggle(inner, 7, "Игроки", function() return aim.players end, function(v) aim.players = v; aimClock = 0 end, true)
    toggle(inner, 8, "Боты / NPC", function() return aim.bots end, function(v) aim.bots = v; aimClock = 0 end, true)
    toggle(inner, 9, "Союзники", function() return aim.teammates end, function(v) aim.teammates = v; aimClock = 0 end, true)
end, "AIM")

-- Local-only noclip for testing movement in this experience.
-- Server-authoritative physics may override local collision changes.
local noclip = false
local refreshNoclip
local bindRefresh = {}
local collisionState = {}
local collisionConnection
local collisionCharacter
local function restoreCollision()
    for part, original in pairs(collisionState) do
        if part.Parent then part.CanCollide = original end
    end
    table.clear(collisionState)
    collisionCharacter = nil
end
local function updateCollision()
    local character = player.Character
    if collisionCharacter ~= character then
        restoreCollision()
        collisionCharacter = character
    end
    if not character then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if collisionState[part] == nil then
                collisionState[part] = part.CanCollide
            end
            if part.CanCollide then part.CanCollide = false end
        end
    end
    for part, original in pairs(collisionState) do
        if not part:IsDescendantOf(character) then
            if part.Parent then part.CanCollide = original end
            collisionState[part] = nil
        end
    end
end
local function setNoclip(v)
    v = v == true
    if noclip == v then return end
    noclip = v
    if collisionConnection then
        collisionConnection:Disconnect()
        collisionConnection = nil
    end
    if v then
        updateCollision()
        collisionConnection = RunService.PreSimulation:Connect(updateCollision)
    else
        restoreCollision()
    end
    if refreshNoclip then refreshNoclip(false) end
    if bindRefresh.NC then bindRefresh.NC() end
end
connect(player.CharacterRemoving, function()
    if noclip then setNoclip(false) end
end)
local noclipRow
noclipRow, refreshNoclip = toggle(pages.Other, 1, "Noclip", function() return noclip end, setNoclip)

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
            panel.Position = UDim2.new(0.5, 0, 0.5, 10)
        end
        panel.Visible = true
        backdrop.Visible = true
    end
    animate(backdrop, 0.24, {BackgroundTransparency = opened and dimBackground and 0.47 or 1})
    animate(glyph, 0.28, {Rotation = opened and 0 or -45})
    animate(ring, 0.24, {Color = opened and C.white or Color3.fromRGB(95, 95, 95)})
    animate(panelScale, opened and 0.26 or 0.17, {Scale = opened and 1 or 0.94}, opened and Enum.EasingStyle.Back or Enum.EasingStyle.Quint)
    local t = animate(panel, opened and 0.23 or 0.17, {
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
        animate(panel, 0, {Position = UDim2.fromScale(0.5, 0.5)})
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
nav.Size = UDim2.new(1, 0, 0, #categories * 32 - 3)

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
    local portrait = s.Y > s.X or s.X < 440
    local w = math.min(portrait and 420 or 500, math.max(1, s.X - 16))
    local h = math.min(portrait and 420 or 290, math.max(1, s.Y - 16))
    panel.Size = UDim2.fromOffset(w, h)
    separator.Visible = not portrait
    if portrait then
        rail.Position = UDim2.fromOffset(8, 52)
        rail.Size = UDim2.new(1, -16, 0, 45)
        rail.ScrollingDirection = Enum.ScrollingDirection.X
        rail.AutomaticCanvasSize = Enum.AutomaticSize.X
        navLayout.FillDirection = Enum.FillDirection.Horizontal
        nav.Size = UDim2.fromOffset(#categories * 97 - 3, 42)
        for _, tab in pairs(tabs) do tab.Size = UDim2.fromOffset(94, 42) end
        content.Position = UDim2.fromOffset(9, 103)
        content.Size = UDim2.new(1, -18, 1, -112)
    else
        local side = 112
        rail.Position = UDim2.fromOffset(9, 55)
        rail.Size = UDim2.new(0, side, 1, -65)
        rail.ScrollingDirection = Enum.ScrollingDirection.Y
        rail.AutomaticCanvasSize = Enum.AutomaticSize.Y
        navLayout.FillDirection = Enum.FillDirection.Vertical
        nav.Size = UDim2.new(1, 0, 0, #categories * 45 - 3)
        for _, tab in pairs(tabs) do tab.Size = UDim2.new(1, 0, 0, 42) end
        separator.Position = UDim2.fromOffset(side + 17, 56)
        content.Position = UDim2.fromOffset(side + 26, 57)
        content.Size = UDim2.new(1, -(side + 36), 1, -68)
    end
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
-- Persistent per-session mobile buttons. A drag never toggles a feature.
local bindItems = {}
local function refreshBind(key)
    local item = bindItems[key]
    if not item then return end
    local on = item.get()
    item.button.BackgroundColor3 = on and C.white or C.black
    item.button.TextColor3 = on and C.darkText or C.white
    item.stroke.Color = on and C.white or C.muted
end
local function bindButton(key, title, order, getter, setter, defaultY)
    local item = {get = getter, set = setter, enabled = false, fraction = Vector2.new(0.14, defaultY)}
    bindItems[key] = item
    local b = new("TextButton", root, {
        Name = "Bind_" .. key, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(44, 44),
        BackgroundColor3 = C.black, Text = key, Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = C.white, BorderSizePixel = 0, AutoButtonColor = false, Visible = false, ZIndex = 9,
    })
    new("UICorner", b, {CornerRadius = UDim.new(1, 0)})
    item.button, item.stroke = b, outline(b, C.muted)
    local scale = new("UIScale", b, {Scale = 1})
    local function place(p)
        local size = root.AbsoluteSize
        if size.X < 1 or size.Y < 1 then return end
        local pos = clampCenter(p)
        item.fraction = Vector2.new(pos.X / size.X, pos.Y / size.Y)
        b.Position = UDim2.fromOffset(pos.X, pos.Y)
    end
    local function reposition()
        local size = root.AbsoluteSize
        place(Vector2.new(item.fraction.X * size.X, item.fraction.Y * size.Y))
    end
    connect(root:GetPropertyChangedSignal("AbsoluteSize"), reposition)
    local dragState
    connect(b.InputBegan, function(input)
        local kind = input.UserInputType
        if dragState or (kind ~= Enum.UserInputType.Touch and kind ~= Enum.UserInputType.MouseButton1) then return end
        dragState = {input = input, kind = kind, start = Vector2.new(input.Position.X, input.Position.Y), origin = Vector2.new(b.Position.X.Offset, b.Position.Y.Offset), moved = false}
        animate(scale, 0.10, {Scale = 0.88})
    end)
    connect(UIS.InputChanged, function(input)
        local d = dragState
        if not d then return end
        if d.kind == Enum.UserInputType.Touch then if input ~= d.input then return end
        elseif input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local delta = Vector2.new(input.Position.X, input.Position.Y) - d.start
        if delta.Magnitude >= 8 then d.moved = true end
        if d.moved then place(d.origin + delta) end
    end)
    connect(UIS.InputEnded, function(input)
        local d = dragState
        if not d then return end
        if d.kind == Enum.UserInputType.Touch then if input ~= d.input then return end
        elseif input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        dragState = nil
        animate(scale, 0.20, {Scale = 1}, Enum.EasingStyle.Back)
        if not d.moved and item.enabled and input.UserInputState == Enum.UserInputState.End then
            setter(not getter())
            refreshBind(key)
            if featureRefresh[key] then featureRefresh[key](false) end
        end
    end)
    connect(UIS.WindowFocusReleased, function() dragState = nil; animate(scale, 0, {Scale = 1}) end)
    toggle(pages.Binds, order, title, function() return item.enabled end, function(v)
        item.enabled = v
        b.Visible = v
        dragState = nil
        if v then reposition(); refreshBind(key) end
    end)
    bindRefresh[key] = function() refreshBind(key) end
    reposition()
end
bindButton("AIM", "Aim Assist", 1, function() return aim.enabled end, setAim, 0.36)
bindButton("ESP", "ESP", 2, function() return visual.enabled end, function(v) setVisual("enabled", v) end, 0.48)
bindButton("NC", "Noclip", 3, function() return noclip end, setNoclip, 0.60)
bindButton("DIR", "Стрелки целей", 4, function() return radar.enabled end, setRadar, 0.72)
-- Update shortcut appearance when the equivalent menu switch changes.
connect(RunService.Heartbeat, function()
    for key, item in pairs(bindItems) do
        local current = item.get()
        if item.last ~= current then item.last = current; refreshBind(key) end
    end
end)

gui.Destroying:Connect(function()
    setAim(false)
    setRadar(false)
    if noclip then setNoclip(false) end
    visual.enabled = false
    stopVisuals()
    hud:Destroy()
    markerFolder:Destroy()
    for _, c in ipairs(connections) do c:Disconnect() end
    local objects = {}
    for obj in pairs(tweens) do table.insert(objects, obj) end
    for _, obj in ipairs(objects) do cancel(obj) end
end)

resize()
selectPage("Player", true)
