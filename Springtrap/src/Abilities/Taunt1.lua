local Taunt1={keybind=Enum.KeyCode.T}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")



Taunt1.__index=Taunt1
Taunt1.client={}
Taunt1.server={}


function Taunt1:Execute()
    ReplicatedStorage.Taunt1Comm:FireServer()
end

function Taunt1.client:init()
end

function Taunt1:init()
    self = setmetatable({},Taunt1)
    if RunService:IsServer() then 
        self.server:init()
    elseif RunService:IsClient() then 
        self.client:init()
    end 
end

return Taunt1