
local GrabAttack2 = {keybind=Enum.KeyCode.G,
client={},
server={}}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player
local Mouse
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local Align=require(ReplicatedStorage.SharedModules.Align)


local comms={
	GrabAttack2Event="RemoteEvent",
}

GrabAttack2.__index=GrabAttack2

function GrabAttack2.client:get_comms()
	for comm_name,_ in pairs(comms) do 
		comms[comm_name]=ReplicatedStorage:WaitForChild(comm_name)
	end 
end

function GrabAttack2:Execute()
	local mouse = Players.LocalPlayer:GetMouse()
	ReplicatedStorage.GrabAttack2Event:FireServer(mouse.Target)
end

function GrabAttack2.client:init()
	Player = Players.LocalPlayer
	Mouse=Player:GetMouse()
	Mouse.TargetFilter=Player.Character
	self:get_comms()
end

function GrabAttack2.server:create_comms()
	for comm_name,comm_type in pairs(comms) do 
		comms[comm_name]=Instance.new(comm_type,ReplicatedStorage)
		comms[comm_name].Name=comm_name
	end 

	comms.GrabAttack2Event.OnServerEvent:Connect(function(player:Player,target)
		if not target then return end 
		local character=target:FindFirstAncestorOfClass("Model")
		if not character then return end 
		local root = character:FindFirstChild("HumanoidRootPart")
		if not root then return end

		
		
		local function if_is_player(other_player:Player)

		end 

		local function if_is_dummy()
			character.Humanoid:LoadAnimation(ReplicatedStorage.GrabAttack2Victim_SpringtrapAnimation):Play()
			Align(player,character,1.675)
			root.AssemblyLinearVelocity=player.Character.HumanoidRootPart.CFrame.LookVector*85+Vector3.new(0,75,0)
			character.Humanoid:TakeDamage(50)
		end 
		local get_other=Players:GetPlayerFromCharacter(character)
		if get_other then 
			if_is_player(get_other)
		else 
			if_is_dummy()
		end 	
	end)
end
 
function GrabAttack2.server:init()
	self:create_comms()
end

function GrabAttack2:init()
	self=setmetatable({},GrabAttack2)
	if RunService:IsServer() then 
		self.server:init()
	elseif RunService:IsClient() then 
		self.client:init()
	end 
end

return GrabAttack2
