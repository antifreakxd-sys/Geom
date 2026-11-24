-- Geom movement tools: ServerScriptService > Script
-- Studio and the individual experience owner can use noclip by default.
-- To grant access to a trusted tester, set their GeomCanNoclip attribute on the server.
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local group = "GeomGhost"
pcall(function() PhysicsService:RegisterCollisionGroup(group) end)
local function configure()
    for _, g in ipairs(PhysicsService:GetRegisteredCollisionGroups()) do
        PhysicsService:CollisionGroupSetCollidable(group, g.name, false)
    end
end
configure()
local remote = Instance.new("RemoteEvent")
remote.Name = "GeomMovement"
remote.Parent = ReplicatedStorage
local states = {}
local function permitted(p)
    return RunService:IsStudio() or (game.CreatorType == Enum.CreatorType.User and game.CreatorId == p.UserId)
        or p:GetAttribute("GeomCanNoclip") == true
end
local function restore(p)
    local state = states[p]
    if not state then return end
    states[p] = nil
    if state.added then state.added:Disconnect() end
    for part, previous in pairs(state.parts) do
        if part.Parent and part.CollisionGroup == group then
            part.CollisionGroup = previous
        end
    end
end
local function start(p)
    restore(p)
    local char = p.Character
    if not char then return false end
    configure()
    local state = {parts = {}}
    states[p] = state
    local function add(part)
        if part:IsA("BasePart") and state.parts[part] == nil then
            state.parts[part] = part.CollisionGroup
            part.CollisionGroup = group
        end
    end
    state.added = char.DescendantAdded:Connect(add)
    for _, obj in ipairs(char:GetDescendants()) do add(obj) end
    return true
end
local function publish(p, value)
    p:SetAttribute("GeomNoclipActive", value)
    remote:FireClient(p, value)
end
local last = {}
remote.OnServerEvent:Connect(function(p, value)
    if typeof(value) ~= "boolean" then return end
    local now = os.clock()
    if value and now - (last[p] or -10) < 0.15 then
        remote:FireClient(p, states[p] ~= nil)
        return
    end
    last[p] = now
    if value and permitted(p) then
        publish(p, states[p] ~= nil or start(p))
    else
        restore(p)
        publish(p, false)
    end
end)
local function setup(p)
    p:SetAttribute("GeomNoclipActive", false)
    p.CharacterRemoving:Connect(function() restore(p); publish(p, false) end)
    p:GetAttributeChangedSignal("GeomCanNoclip"):Connect(function()
        if not permitted(p) then restore(p); publish(p, false) end
    end)
end
Players.PlayerAdded:Connect(setup)
for _, p in ipairs(Players:GetPlayers()) do setup(p) end
Players.PlayerRemoving:Connect(function(p) restore(p); last[p] = nil end)
