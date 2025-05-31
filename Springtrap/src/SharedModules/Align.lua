local function Align(player, character, duration)
    -- Create a new BodyPosition instance to control the player's position
    local hold_down = Instance.new("BodyPosition")
    local p_root = player.Character.HumanoidRootPart
    local pos = p_root.Position
    
    -- Set the initial position of BodyPosition to match the player's current position
    hold_down.Position = pos
    local force = 15000
    
    -- Anchor the HumanoidRootPart to prevent it from moving due to physics
    player.Character.HumanoidRootPart.Anchored = true
    
    -- Set the maximum force for BodyPosition to a very high value
    hold_down.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    
    -- Parent the BodyPosition instance to the HumanoidRootPart
    hold_down.Parent = p_root

    -- Create an AlignPosition instance to align the player's right arm with the character's root part
    local align = Instance.new("AlignPosition", player.Character["Right Arm"])
    align.Attachment1 = player.Character["Right Arm"]:FindFirstChild("RightGripAttachment")
    align.Attachment0 = character.HumanoidRootPart.RootAttachment
    align.RigidityEnabled = true
    align.Responsiveness = 200
    align.MaxForce = math.huge
    align.MaxAxesForce = Vector3.new(math.huge, math.huge, math.huge)
    align.MaxVelocity = math.huge
    
    -- Disable reaction force to prevent the arm from resisting alignment
    align.ReactionForceEnabled = false

    -- Create an AlignOrientation instance to align the player's right arm with the character's root part in terms of orientation
    local align_o = Instance.new("AlignOrientation", player.Character["Right Arm"])
    align_o.Attachment1 = player.Character["Right Arm"]:FindFirstChild("RightGripAttachment")
    align_o.Attachment0 = character.HumanoidRootPart.RootAttachment
    align_o.RigidityEnabled = true
    align_o.Responsiveness = 200
    align_o.MaxTorque = math.huge
    align_o.MaxAngularVelocity = math.huge
    
    -- Disable reaction torque to prevent the arm from resisting orientation alignment
    align_o.ReactionTorqueEnabled = false

    -- Wait for the specified duration before removing the alignments and BodyPosition
    wait(duration)
    
    -- Destroy the AlignPosition instance
    align:Destroy()
    
    -- Destroy the BodyPosition instance
    hold_down:Destroy()

    -- Destroy the AlignOrientation instance
    align_o:Destroy()

    -- Unanchor the HumanoidRootPart after a short delay
    coroutine.wrap(function()
        wait(0.75)
        player.Character.HumanoidRootPart.Anchored = false
    end)()
end