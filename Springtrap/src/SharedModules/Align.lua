

return function (player,character,duration)
	local hold_down=Instance.new("BodyPosition")
	local p_root = player.Character.HumanoidRootPart
	local pos = p_root.Position
	hold_down.Position=pos
	local force=15000
	player.Character.HumanoidRootPart.Anchored=true
	hold_down.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
	hold_down.Parent = p_root
    local align = Instance.new("AlignPosition",player.Character["Right Arm"])
			align.Attachment1=player.Character["Right Arm"]:FindFirstChild("RightGripAttachment")
			align.Attachment0=character.HumanoidRootPart.RootAttachment
			align.RigidityEnabled=true
			align.Responsiveness=200
			align.MaxForce=math.huge
			align.MaxAxesForce=Vector3.new(math.huge,math.huge,math.huge)
			align.MaxVelocity=math.huge
align.ReactionForceEnabled=false
			local align_o = Instance.new("AlignOrientation",player.Character["Right Arm"])
			align_o.Attachment1 = player.Character["Right Arm"]:FindFirstChild("RightGripAttachment")
			align_o.Attachment0=character.HumanoidRootPart.RootAttachment
			align_o.RigidityEnabled=true
			align_o.Responsiveness=200
			align_o.MaxTorque=math.huge
			align_o.MaxAngularVelocity=math.huge
			align_o.ReactionTorqueEnabled=false
            wait(duration)
            align:Destroy()
			hold_down:Destroy()
            align_o:Destroy()
			coroutine.wrap(function()
				wait(.75)
				player.Character.HumanoidRootPart.Anchored=false

			end)()
end