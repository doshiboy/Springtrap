local Taunt2={keybind=Enum.KeyCode.F}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local sfx = ReplicatedStorage.SFXSpringtrap.Taunt2


Taunt2.__index=Taunt2
Taunt2.client={}
Taunt2.server={}

local comm

function Taunt2:Execute()
    ReplicatedStorage.Taunt2Comm:FireServer()
end

function Taunt2.server:init()
    comm = Instance.new("RemoteEvent",ReplicatedStorage)
    comm.Name="Taunt2Comm"

    comm.OnServerEvent:Connect(function(player)
        local sound = sfx:Clone()
        sound.Parent=player.Character.PrimaryPart
        sound:Play()
        Debris:AddItem(sound,1)
    end)
end

function Taunt2.client:init()
    comm=ReplicatedStorage:WaitForChild("Taunt2Comm")
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