local Taunt1={keybind=Enum.KeyCode.T}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local sfx = ReplicatedStorage.SFXSpringtrap.Taunt1


Taunt1.__index=Taunt1
Taunt1.client={}
Taunt1.server={}

local comm

function Taunt1:Execute()
    ReplicatedStorage.Taunt1Comm:FireServer()
end

function Taunt1.server:init()
    comm = Instance.new("RemoteEvent",ReplicatedStorage)
    comm.Name="Taunt1Comm"

    comm.OnServerEvent:Connect(function(player)
        local sound = sfx:Clone()
        sound.Parent=player.Character.PrimaryPart
        sound:Play()
        Debris:AddItem(sound,1)
    end)
end

function Taunt1.client:init()
    comm=ReplicatedStorage:WaitForChild("Taunt1Comm")
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