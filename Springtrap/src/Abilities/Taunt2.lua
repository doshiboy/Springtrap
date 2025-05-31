local Taunt2={keybind=Enum.KeyCode.F}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")



Taunt2.__index=Taunt2
Taunt2.client={}
Taunt2.server={}


function Taunt2:Execute()
    ReplicatedStorage.Taunt2Comm:FireServer()
end


function Taunt2.client:init()
end

function Taunt2:init()
    self = setmetatable({},Taunt2)
    if RunService:IsServer() then 
        self.server:init()
    elseif RunService:IsClient() then 
        self.client:init()
    end 
end

return Taunt2