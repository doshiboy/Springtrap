local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Abilities=ReplicatedStorage.Abilities
local SpringtrapModule={
    server={},
    client={controls_conn=nil,keybinds={},on_cooldown=nil,sitting=nil},
}

local COOLDOWN=1

local ANIMATIONIDS=require(script.Parent.Animations)
local SFX=ReplicatedStorage.SFXSpringtrap

local comm:RemoteEvent

local MovesModules={}
local LoadedAnimations={}

SpringtrapModule.__index=SpringtrapModule

function SpringtrapModule.server:create_animations()
    for animation_name,id in pairs(ANIMATIONIDS) do 
        local instance=Instance.new("Animation",ReplicatedStorage)
        instance.Name=animation_name.."_SpringtrapAnimation"
        instance.AnimationId="rbxassetid://"..tostring(id)
    end 
end

function SpringtrapModule.client:load_animations()
    coroutine.wrap(function()
        local player=Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")

        for anim_name,_ in pairs(ANIMATIONIDS) do 
            LoadedAnimations[anim_name]=humanoid:LoadAnimation(ReplicatedStorage:WaitForChild(anim_name.."_SpringtrapAnimation"))
        end 
        LoadedAnimations.Idle:Play()
    end)()
end

function SpringtrapModule.server:get_abilities()
    for _,module in pairs(Abilities:GetChildren()) do 
        MovesModules[module.Name]=require(module)
        MovesModules[module.Name]:init()
    end 
end

function SpringtrapModule.client:get_abilities()
    for _,module in pairs(Abilities:GetChildren()) do 
        MovesModules[module.Name]=require(module)
        MovesModules[module.Name]:init()
    end 
end

function SpringtrapModule.server:init()
    comm=Instance.new("RemoteEvent",ReplicatedStorage)
    comm.Name="SpringtrapComm"
    self:create_animations()
    self:get_abilities()
end

local function got_target(mouse,player)
    if not mouse.Target then return nil end 
    if not mouse.Target:FindFirstAncestorOfClass("Model") then return nil end 
    if not mouse.Target:FindFirstAncestorOfClass("Model"):FindFirstChild("Humanoid") then return nil end 
    local dist=(mouse.Target.Position-player.Character.Head.Position).Magnitude
    if dist>22.50 then return nil end 
    return true 
end

function SpringtrapModule.client:controls_listener()
    local Mouse = self.player:GetMouse()
    Mouse.TargetFilter=self.player.Character
    self.controls_conn = UserInputService.InputBegan:Connect(function(InputObject:InputObject)
        if self.on_cooldown then return end 
        local key = InputObject.KeyCode
        local module
        for ability_name,ability_key in pairs(self.keybinds) do 
            if ability_key == key then 
                local got = got_target(Mouse,self.player)
                self.on_cooldown=true 
                if ability_name=="Sit" then if not self.sitting then self.sitting=true LoadedAnimations[ability_name]:Play() self.player.Character.HumanoidRootPart.Anchored=true 
             else self.sitting=nil LoadedAnimations[ability_name]:Stop() LoadedAnimations.Action:Play() LoadedAnimations.Action:AdjustSpeed(2.5) self.player.Character.HumanoidRootPart.Anchored=false end end
                if ability_name == "GrabAttack1" or ability_name=="GrabAttack2" then 
                    self.sitting=nil 
                    LoadedAnimations.Sit:Stop()
                if not got then 
                    LoadedAnimations.GrabMiss:Play()
                else 
                LoadedAnimations[ability_name]:Play()
                end
            end 
            if got then 
                MovesModules[ability_name]:Execute()
            end
                coroutine.wrap(function()
                    wait(COOLDOWN)
                    self.on_cooldown=nil
                end)()
            end 
        end 
    end)
end

function SpringtrapModule.client:map_keys()
    for module_name,module in pairs(MovesModules) do 
        self.keybinds[module_name]=module.keybind
    end     
end

function SpringtrapModule.client:init()
    comm=ReplicatedStorage:WaitForChild("SpringtrapComm")
    self:map_keys()
    self:controls_listener()
    self:load_animations()
end

function SpringtrapModule:GetModules()
    for _,ability in pairs(Abilities:GetChildren()) do 
        MovesModules[ability.Name]=require(ability)
    end 
end

function SpringtrapModule:init()
    self:GetModules()
    if RunService:IsServer() then 
        self = setmetatable({},SpringtrapModule)
        self.server:init()
    elseif RunService:IsClient() then 
        self = setmetatable({},SpringtrapModule)
        self.client.player=game.Players.LocalPlayer
        self.client:init()

        local character = self.client.player.Character or self.client.player.CharacterAdded:Wait() 
        local Hum = character:WaitForChild("Humanoid")
        Hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        local DeathAnim = LoadedAnimations.IdleDeath

        Hum.HealthChanged:Connect(
            function()
                if Hum.Health <= 0 then
                    DeathAnim:Play()
                end
            end
        )

        DeathAnim.Stopped:Connect(
            function()
                Hum.Health = 0
                Hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            end
        )
    end 
    
end

return SpringtrapModule