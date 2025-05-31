local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Message = Instance.new("RemoteFunction",ReplicatedStorage)
local RemoveAccessories=Instance.new("RemoteEvent",ReplicatedStorage)
RemoveAccessories.Name="RemoveAccessories"
Message.Name="StarterCharacterFunction"

require(ReplicatedStorage.SharedModules.SpringtrapModule):init()

local Model:Model = ReplicatedStorage.Springtrap

local function freeze_model(model:Model,cancollide:boolean?,anchored:boolean?)
    for _,part in pairs(model:GetDescendants()) do 
        if part:IsA("BasePart") then 
            part.CanCollide=false or cancollide 
            part.Massless=anchored or true 
            part.Anchored=anchored or true
        end 
    end 
end 

local function weld_to_primarypart(model:Model)
    for _,part in pairs(model:GetDescendants()) do 
        if part:IsA("BasePart") or part:IsA("MeshPart") then 
            if part == model.PrimaryPart then continue end 
            local weld = Instance.new("WeldConstraint",part)
            weld.Part0=part 
            weld.Part1=model.PrimaryPart
            part.Anchored=false
        end 
    end 
end 

 local function player_added(player:Player)
    player.Chatted:Connect(function(message)
        local character = player.Character 
        local find = string.find(message,"-Springtrap") 

        if not find then return end 
        local find_space=string.find(message," ")
        local username_spelling=string.sub(message,find_space+1,string.len(message))
        local function AutocompletePlayer(username_spelling)
            local Players = game:GetService("Players")
            local lowercase_input = username_spelling:lower()
        
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Name:lower():sub(1, #lowercase_input) == lowercase_input then
                    return player
                end
            end
        
            return nil -- No match found
        end
        local get_player=AutocompletePlayer(username_spelling)
        character = get_player.Character
        print(username_spelling)
        character:WaitForChild("HumanoidRootPart").Anchored=true
        coroutine.wrap(function()
            local shirt = character:WaitForChild("Shirt",5)
            local pants = character:WaitForChild("Pants",5)

            if shirt then shirt:Destroy() end 
            if pants then pants:Destroy() end 

        end)()
        local springtrap=Model:Clone()
        springtrap.Parent=get_player.Character
        weld_to_primarypart(springtrap)
        freeze_model(springtrap)
        wait()
        springtrap:SetPrimaryPartCFrame(Message:InvokeClient(get_player))
        local function c_added(part)
            if part:IsA("BasePart") then part.Color = Color3.fromRGB(0,0,0) end 
            local matches={}
            for _,ds in pairs(springtrap:GetDescendants()) do 
                if ds.Name==part.Name then table.insert(matches,ds) end 
            end 
          for _,match in pairs(matches) do
            local wc = match:FindFirstChild("WeldConstraint") or Instance.new("WeldConstraint",match)
            wc.Part0=match 
            wc.Part1=part
            match.Anchored=false
          end
        end
        for _,c in pairs(character:GetChildren()) do c_added(c) end 
      character.ChildAdded:connect(c_added)
       coroutine.wrap(function()
            wait(1)
            RemoveAccessories:FireClient(player)
            character.HumanoidRootPart.Anchored=false
       end)()
    end)
end 
 Players.PlayerAdded:connect(player_added)