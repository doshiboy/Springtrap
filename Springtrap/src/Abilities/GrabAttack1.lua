
local GrabAttack1 = {keybind=Enum.KeyCode.H,
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
	GrabAttack1Event="RemoteEvent",
}

GrabAttack1.__index=GrabAttack1

local function disable_cancollide(parent)
	
end 

function GrabAttack1.client:get_comms()
	for comm_name,_ in pairs(comms) do 
		comms[comm_name]=ReplicatedStorage:WaitForChild(comm_name)
	end 
end

function GrabAttack1:Execute()
	local mouse = Players.LocalPlayer:GetMouse()
	ReplicatedStorage.GrabAttack1Event:FireServer(mouse.Target)
end

function GrabAttack1.client:init()
	Player = Players.LocalPlayer
	Mouse=Player:GetMouse()
	Mouse.TargetFilter=Player.Character
	self:get_comms()
end

function GrabAttack1.server:create_comms()
	for comm_name,comm_type in pairs(comms) do 
		comms[comm_name]=Instance.new(comm_type,ReplicatedStorage)
		comms[comm_name].Name=comm_name
	end 

	comms.GrabAttack1Event.OnServerEvent:Connect(function(player:Player,target)
		if not target then return end 
		local character=target:FindFirstAncestorOfClass("Model")
		if not character then return end 
		local root = character:FindFirstChild("HumanoidRootPart")
		if not root then return end

		
		
		local function if_is_player(other_player:Player)

		end 

		local function if_is_dummy()
for _,i in pairs(character:GetDescendants()) do if i:IsA("BasePart") or i:IsA("MeshPart") or i:IsA("UnionOperation") then 
	 i.Massless=i.Massless i.Anchored=false end end 	
			character.Humanoid:LoadAnimation(ReplicatedStorage.GrabAttack1Victim_SpringtrapAnimation):Play()
			Align(player,character,2)
			wait()
			root.AssemblyLinearVelocity=player.Character.Head.CFrame.LookVector*125+Vector3.new(0,-150,0)
			character.Humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
			character.Humanoid.Health=0
			local c = character.Head
			if c:FindFirstChild("Neck") then c.Neck:Destroy() end 
			c.Parent=workspace
			c.Position+=Vector3.new(0,5,0)
			coroutine.wrap(function()
				wait(.3)
			c.AssemblyLinearVelocity=Vector3.new(math.huge,math.huge,math.huge)
				
			end)()
	
		end 
		local get_other=Players:GetPlayerFromCharacter(character)
		if get_other then 
			if_is_player(get_other)
		else 
			if_is_dummy()
		end 	
	end)
end
 
function GrabAttack1.server:init()
	self:create_comms()
end

function GrabAttack1:init()
	self=setmetatable({},GrabAttack1)
	if RunService:IsServer() then 
		self.server:init()
	elseif RunService:IsClient() then 
		self.client:init()
	end 
end

return GrabAttack1
