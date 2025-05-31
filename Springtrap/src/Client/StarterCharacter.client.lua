local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Message:RemoteFunction = ReplicatedStorage:WaitForChild("StarterCharacterFunction")
local RemoveAccessories:RemoteEvent = ReplicatedStorage:WaitForChild("RemoveAccessories")
local SpringtrapModule=require(ReplicatedStorage.SharedModules.SpringtrapModule)

local Player = game.Players.LocalPlayer

local function invoked()
    repeat wait() until Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    return Player.Character.HumanoidRootPart.CFrame
end 

Message.OnClientInvoke=invoked

RemoveAccessories.OnClientEvent:Connect(function()
    if not Player.Character or not Player.Character:FindFirstChild("Humanoid") then return end 
    Player.Character.Humanoid:RemoveAccessories()
    SpringtrapModule:init()
end)