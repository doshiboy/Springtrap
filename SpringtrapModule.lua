--[[
    SpringtrapModule.lua
    ---------------------
    This module controls the client and server functionality of a custom Springtrap character,
    including abilities, animations, audio taunts, and keybindings.
--]]

-- Services
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Folder containing ability modules
local Abilities = ReplicatedStorage.Abilities

-- Module table structure
local SpringtrapModule = {
    server = {},
    client = {
        controls_conn = nil, -- connection to input listener
        keybinds = {},       -- maps ability names to keybinds
        on_cooldown = nil,   -- cooldown state
        sitting = nil        -- toggle for Sit animation
    }
}

-- Internal constants
local COOLDOWN = 1 -- cooldown between ability uses

-- Animation ID mapping
local ANIMATIONIDS = {
    Idle = 125411286829662,
    GrabAttack1 = 104969106372571,
    GrabAttack1Victim = 72774066554927,
    GrabAttack2 = 91990648016325,
    Action = 104969106372571,
    Sit = 90167183524516,
    GrabAttack2Victim = 96298597168385,
    GrabMiss = 70844000559137,
    IdleDeath = 109955652099967,
}

-- Reference to sound effects
local SFX = ReplicatedStorage.SFXSpringtrap

-- Internal communication RemoteEvent
local comm

-- Ability modules and loaded animations
local MovesModules = {}
local LoadedAnimations = {}

SpringtrapModule.__index = SpringtrapModule

-- Server: Creates animation instances with IDs and stores them in ReplicatedStorage
function SpringtrapModule.server:create_animations()
    for animation_name, id in pairs(ANIMATIONIDS) do 
        local instance = Instance.new("Animation", ReplicatedStorage)
        instance.Name = animation_name .. "_SpringtrapAnimation"
        instance.AnimationId = "rbxassetid://" .. tostring(id)
        instance:SetAttribute("SpeedModifier", 1.5)
    end 
end

-- Client: Loads animations into Humanoid
function SpringtrapModule.client:load_animations()
    coroutine.wrap(function()
        local player = Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")

        for anim_name, _ in pairs(ANIMATIONIDS) do 
            LoadedAnimations[anim_name] = humanoid:LoadAnimation(ReplicatedStorage:WaitForChild(anim_name .. "_SpringtrapAnimation"))
        end 
        LoadedAnimations.Idle:Play() -- Start idle animation
    end)()
end

-- Server: Loads and initializes ability modules
function SpringtrapModule.server:get_abilities()
    for _, module in pairs(Abilities:GetChildren()) do 
        MovesModules[module.Name] = require(module)
        MovesModules[module.Name]:init()
    end 
end

-- Client: Loads and initializes ability modules
function SpringtrapModule.client:get_abilities()
    for _, module in pairs(Abilities:GetChildren()) do 
        MovesModules[module.Name] = require(module)
        MovesModules[module.Name]:init()
    end 
end

-- Server: Initializes animations and abilities, creates RemoteEvent
function SpringtrapModule.server:init()
    comm = Instance.new("RemoteEvent", ReplicatedStorage)
    comm.Name = "SpringtrapComm"
    self:create_animations()
    self:get_abilities()
end

-- Utility: Determines if a mouse target is valid and within range
local function got_target(mouse, player)
    if not mouse.Target then return nil end 
    if not mouse.Target:FindFirstAncestorOfClass("Model") then return nil end 
    if not mouse.Target:FindFirstAncestorOfClass("Model"):FindFirstChild("Humanoid") then return nil end 
    local dist = (mouse.Target.Position - player.Character.Head.Position).Magnitude
    if dist > 22.50 then return nil end 
    return true 
end

-- Client: Handles keypresses for abilities and their effects
function SpringtrapModule.client:controls_listener()
    local Mouse = self.player:GetMouse()
    Mouse.TargetFilter = self.player.Character

    self.controls_conn = UserInputService.InputBegan:Connect(function(InputObject)
        if self.on_cooldown then return end 

        local key = InputObject.KeyCode

        for ability_name, ability_key in pairs(self.keybinds) do 
            if ability_key == key then 
                local got = got_target(Mouse, self.player)
                self.on_cooldown = true

                -- Handle Sit toggle
                if ability_name == "Sit" then
                    if not self.sitting then
                        self.sitting = true
                        LoadedAnimations[ability_name]:Play()
                        self.player.Character.HumanoidRootPart.Anchored = true
                    else
                        self.sitting = nil
                        LoadedAnimations[ability_name]:Stop()
                        LoadedAnimations.Action:Play()
                        LoadedAnimations.Action:AdjustSpeed(2.5)
                        self.player.Character.HumanoidRootPart.Anchored = false
                    end
                end

                -- Handle grab attacks
                if ability_name == "GrabAttack1" or ability_name == "GrabAttack2" then 
                    self.sitting = nil
                    LoadedAnimations.Sit:Stop()

                    if not got then 
                        LoadedAnimations.GrabMiss:Play()
                    else 
                        LoadedAnimations[ability_name]:Play()
                    end
                end 

                -- Execute ability logic if target is valid
                if got then 
                    MovesModules[ability_name]:Execute()
                end

                -- Start cooldown
                coroutine.wrap(function()
                    wait(COOLDOWN)
                    self.on_cooldown = nil
                end)()
            end 
        end 
    end)
end

-- Client: Maps each ability module to its associated keybind
function SpringtrapModule.client:map_keys()
    for module_name, module in pairs(MovesModules) do 
        self.keybinds[module_name] = module.keybind
    end     
end

-- Client: Full initialization for the player-side logic
function SpringtrapModule.client:init()
    comm = ReplicatedStorage:WaitForChild("SpringtrapComm")
    self:map_keys()
    self:controls_listener()
    self:load_animations()
end

-- Shared: Loads modules without initializing them
function SpringtrapModule:GetModules()
    for _, ability in pairs(Abilities:GetChildren()) do 
        MovesModules[ability.Name] = require(ability)
    end 
end

-- Server: Sets up taunt sound RemoteEvents and playback
function SpringtrapModule:TauntsHandler()
    -- Taunt 1 setup
    local _comm = Instance.new("RemoteEvent", ReplicatedStorage)
    _comm.Name = "Taunt1Comm"
    _comm.OnServerEvent:Connect(function(player)
        local sfx = ReplicatedStorage.SFXSpringtrap.Taunt1
        local sound = sfx:Clone()
        sound.Parent = player.Character.PrimaryPart
        sound:Play()
        Debris:AddItem(sound, 1)
    end)

    -- Taunt 2 setup
    local comm2 = Instance.new("RemoteEvent", ReplicatedStorage)
    comm2.Name = "Taunt2Comm"
    comm2.OnServerEvent:Connect(function(player)
        local sfx = ReplicatedStorage.SFXSpringtrap.Taunt2
        local sound = sfx:Clone()
        sound.Parent = player.Character.PrimaryPart
        sound:Play()
        Debris:AddItem(sound, 1)
    end)
end

-- Master initializer (called when module is required)
function SpringtrapModule:init()
    self:GetModules()
    self:TauntsHandler()

    if RunService:IsServer() then 
        self = setmetatable({}, SpringtrapModule)
        self.server:init()
    elseif RunService:IsClient() then 
        self = setmetatable({}, SpringtrapModule)
        self.client.player = Players.LocalPlayer
        self.client:init()

        -- Handle custom death animation
        local character = self.client.player.Character or self.client.player.CharacterAdded:Wait() 
        local Hum = character:WaitForChild("Humanoid")
        Hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        local DeathAnim = LoadedAnimations.IdleDeath

        -- Play death animation when health hits 0
        Hum.HealthChanged:Connect(function()
            if Hum.Health <= 0 then
                DeathAnim:Play()
            end
        end)

        -- Force death state after animation
        DeathAnim.Stopped:Connect(function()
            Hum.Health = 0
            Hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end)
    end 
end

-- Return the module table
return SpringtrapModule
 