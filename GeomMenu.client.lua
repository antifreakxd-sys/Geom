-- GEOM UI 4.0 | monochrome, responsive, touch-first
-- LocalScript: StarterPlayer > StarterPlayerScripts
-- All UI is created locally. Gameplay controls can be added to the category builders.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
text(header, "CONTROL PANEL  /  4.0", 9, UDim2.fromOffset(2, 27), UDim2.fromOffset(185, 12), C.muted)
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
    tab.Size = UDim2.new(1, 0, 0, 29)
    local marker = new("Frame", tab, {
        Position = UDim2.fromOffset(0, 8), Size = UDim2.new(0, 2, 1, -16),
        BackgroundColor3 = C.white, BackgroundTransparency = 1, BorderSizePixel = 0,
    })
    corner(marker, 2)
    text(tab, index, 9, UDim2.fromOffset(7, 0), UDim2.fromOffset(16, 29), C.muted)
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
    b.Size = UDim2.new(1, 0, 0, compact and 34 or 42)
    if not compact then outline(b) end
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
    arrow.Size = UDim2.fromOffset(40, 40)
    local chevron = new("Frame", arrow, {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
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
    text(row, title, 13, UDim2.fromOffset(43, 0), UDim2.new(1, -98, 0, 44), C.white, true)
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
        LayoutOrder = order, Size = UDim2.new(1, 0, 0, 56),
        BackgroundTransparency = 1,
    })
    text(row, title, 11, UDim2.fromOffset(8, 0), UDim2.new(1, -16, 0, 19), C.muted)
    local left = button(row, "−", C.panel)
    left.Position = UDim2.fromOffset(8, 20)
    left.Size = UDim2.fromOffset(36, 34)
    local right = button(row, "+", C.panel)
    right.AnchorPoint = Vector2.new(1, 0)
    right.Position = UDim2.new(1, -8, 0, 20)
    right.Size = UDim2.fromOffset(36, 34)
    local value = text(row, "", 12, UDim2.fromOffset(46, 20), UDim2.new(1, -92, 0, 34), C.white, true)
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
local visual = {
    enabled = false, players = true, bots = true, entities = true,
    names = true, kinds = true, distance = true, health = false,
    highlight = false, throughWalls = false, range = 150, limit = 8, declutter = true,
}
local candidates, markers = {}, {}
local visualConnections = {}
local epoch = 0
local markerFolder = new("Folder", workspace, {Name = "GeomLocalMarkers"})
-- BillboardGui instances are direct PlayerGui children for supported rendering.
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
    local g = new("BillboardGui", playerGui, {
        Name = "GeomEntityLabel", Adornee = part, Size = UDim2.fromOffset(104, 25),
        StudsOffsetWorldSpace = Vector3.new(0, 2.8, 0), LightInfluence = 0,
        AlwaysOnTop = visual.throughWalls, MaxDistance = visual.range,
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
    if not visual.enabled then return end
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
                    if d <= visual.range then
                        table.insert(nearby, {model = model, humanoid = humanoid, owner = owner, part = part, kind = kind, distance = d})
                    end
                end
            end
        end
    end
    table.sort(nearby, function(a, b) return a.distance < b.distance end)
    local keep, selected, occupied = {}, {}, {}
    for _, entry in ipairs(nearby) do
        if #selected >= visual.limit then break end
        local head = entry.model:FindFirstChild("Head")
        local anchor = head and head:IsA("BasePart") and head.Position or entry.part.Position
        local screen, onScreen = camera:WorldToViewportPoint(anchor + Vector3.new(0, head and 1.2 or 2.0, 0))
        local overlaps = false
        if onScreen and visual.declutter then
            for _, p in ipairs(occupied) do
                if math.abs(p.X - screen.X) < 106 and math.abs(p.Y - screen.Y) < 28 then overlaps = true; break end
            end
        end
        if onScreen and not overlaps then
            table.insert(selected, entry); table.insert(occupied, screen); keep[entry.model] = true
        end
    end
    local count = #selected
    local stale = {}
    for model in pairs(markers) do if not keep[model] then table.insert(stale, model) end end
    for _, model in ipairs(stale) do removeMarker(model) end
    for i = 1, count do
        local entry = selected[i]
        local item = markerFor(entry.model, entry.part)
        local head = entry.model:FindFirstChild("Head")
        item.gui.Adornee = (head and head:IsA("BasePart")) and head or entry.part
        item.gui.StudsOffsetWorldSpace = Vector3.new(0, (head and head:IsA("BasePart")) and 1.2 or 2.0, 0)
        item.gui.AlwaysOnTop = visual.throughWalls
        item.gui.MaxDistance = visual.range
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
local function stopVisuals()
    epoch += 1
    for _, c in ipairs(visualConnections) do c:Disconnect() end
    table.clear(visualConnections)
    table.clear(candidates)
    clearMarkers()
end
local function startVisuals()
    stopVisuals()
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
        while visual.enabled and ticket == epoch do
            updateVisuals()
            task.wait(0.20)
        end
    end)
end
local function setVisual(key, value)
    visual[key] = value
    if key == "enabled" then
        if value then startVisuals() else stopVisuals() end
    else
        updateVisuals()
    end
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
        choice(inner, 11, "Дальность (studs)", {75, 150, 250, 400, 600}, function() return visual.range end, function(v) setVisual("range", v) end)
        choice(inner, 12, "Лимит меток", {4, 8, 12, 16}, function() return visual.limit end, function(v) setVisual("limit", v) end)
    end, "ESP")

-- Category builders: only real UI functions and game information for now.
info(pages.Player, 1, player.DisplayName, "@" .. player.Name)
info(pages.Player, 2, "Профиль", "ID: " .. tostring(player.UserId))


-- Camera aim assistance for the experience: only visible live targets, no firing.
-- NPC models opt in using the GeomAimTarget tag; player targets require game opt-in.
local aim = {enabled = false, range = 120, angle = 12, smooth = 8, players = false}
local aimTarget, aimClock = nil, 0
local aimStepName = "GeomAim_" .. tostring(player.UserId)
local function targetPart(model)
    if not model or model == player.Character or not model:IsDescendantOf(workspace) then return nil end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return nil end
    local part = model:FindFirstChild("HumanoidRootPart")
    return part and part:IsA("BasePart") and part or nil
end
local function aimScore(camera, model)
    local part = targetPart(model)
    if not part then return nil end
    local delta = part.Position - camera.CFrame.Position
    local distance = delta.Magnitude
    if distance < 1 or distance > aim.range then return nil end
    local angle = math.deg(math.acos(math.clamp(camera.CFrame.LookVector:Dot(delta.Unit), -1, 1)))
    if angle > aim.angle then return nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = player.Character and {player.Character} or {}
    local hit = workspace:Raycast(camera.CFrame.Position, delta, params)
    if hit and not hit.Instance:IsDescendantOf(model) then return nil end
    return angle, part
end
local function findAim(camera)
    local best, score = nil, math.huge
    local function consider(model)
        if not model:IsA("Model") then return end
        local a = aimScore(camera, model)
        if a and a < score then best, score = model, a end
    end
    for _, model in ipairs(CollectionService:GetTagged("GeomAimTarget")) do
        if not Players:GetPlayerFromCharacter(model) then consider(model) end
    end
    if aim.players and workspace:GetAttribute("GeomPvPAimAssist") == true then
        for _, other in ipairs(Players:GetPlayers()) do
            if other ~= player and other.Character and (player.Neutral or other.Neutral or player.Team ~= other.Team) then
                consider(other.Character)
            end
        end
    end
    return best
end
local function setAim(v)
    aim.enabled = v
    RunService:UnbindFromRenderStep(aimStepName)
    aimTarget, aimClock = nil, 0
    if v then
        RunService:BindToRenderStep(aimStepName, Enum.RenderPriority.Camera.Value + 1, function(dt)
            local camera = workspace.CurrentCamera
            if not camera or opened or camera.CameraType == Enum.CameraType.Scriptable then aimTarget = nil; aimClock = 0; return end
            aimClock -= dt
            if aimClock <= 0 then aimTarget = findAim(camera); aimClock = 0.12 end
            if not aimTarget then return end
            local owner = Players:GetPlayerFromCharacter(aimTarget)
            if owner and (not aim.players or workspace:GetAttribute("GeomPvPAimAssist") ~= true or (not player.Neutral and not owner.Neutral and player.Team == owner.Team)) then aimTarget = nil; return end
            local part = targetPart(aimTarget)
            if not part then aimTarget = nil; return end
            local delta = part.Position - camera.CFrame.Position
            if delta.Magnitude < 1 or delta.Magnitude > aim.range then aimTarget = nil; return end
            camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, part.Position), 1 - math.exp(-aim.smooth * dt))
        end)
    end
end
featureRow(pages.Combat, 1, "Aim Assist", function() return aim.enabled end, setAim, function(inner)
    choice(inner, 1, "Угол (градусы)", {5, 8, 12, 18, 25}, function() return aim.angle end, function(v) aim.angle = v end)
    choice(inner, 2, "Плавность", {3, 5, 8, 12, 16}, function() return aim.smooth end, function(v) aim.smooth = v end)
    choice(inner, 3, "Дальность (studs)", {50, 80, 120, 180}, function() return aim.range end, function(v) aim.range = v end)
    toggle(inner, 4, "Игроки (PvP)", function() return aim.players end, function(v) aim.players = v; aimClock = 0 end, true)
end, "AIM")

-- Noclip state is acknowledged by the server; no client-only physics bypass.
local noclip = player:GetAttribute("GeomNoclipActive") == true
local function setNoclip(v)
    local remote = ReplicatedStorage:FindFirstChild("GeomMovement")
    if remote and remote:IsA("RemoteEvent") then remote:FireServer(v) end
end
local refreshNoclip
local bindRefresh = {}
local function syncNoclip()
    noclip = player:GetAttribute("GeomNoclipActive") == true
    if refreshNoclip then refreshNoclip(false) end
    if bindRefresh.NC then bindRefresh.NC() end
end
connect(player:GetAttributeChangedSignal("GeomNoclipActive"), syncNoclip)
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
    local w = math.min(460, math.max(1, s.X - 16))
    local h = math.min(248, math.max(1, s.Y - 16))
    local narrow = w < 410
    local side = narrow and 88 or 100
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
-- Update shortcut appearance when the equivalent menu switch changes.
connect(RunService.Heartbeat, function()
    for key, item in pairs(bindItems) do
        local current = item.get()
        if item.last ~= current then item.last = current; refreshBind(key) end
    end
end)

gui.Destroying:Connect(function()
    setAim(false)
    if noclip then setNoclip(false) end
    visual.enabled = false
    stopVisuals()
    markerFolder:Destroy()
    for _, c in ipairs(connections) do c:Disconnect() end
    local objects = {}
    for obj in pairs(tweens) do table.insert(objects, obj) end
    for _, obj in ipairs(objects) do cancel(obj) end
end)

resize()
selectPage("Player", true)
