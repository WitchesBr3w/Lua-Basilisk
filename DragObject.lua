--//Put this under any sort of part as a script 
--//Make sure to also include a BoolValue instance as a child named "Dragged" along with a drag detector

local part = script.Parent
local drag = part.PlayerDrag

local partAttachment = Instance.new("Attachment")
partAttachment.Parent = part

local alignPosition = Instance.new("AlignPosition")
alignPosition.Attachment0 = partAttachment
alignPosition.Responsiveness = 100
alignPosition.Parent = part

local RunService = game:GetService("RunService")
local connection

drag.DragStart:Connect(function(player)
	local character = player.Character
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	
	local stringvalue = Instance.new("StringValue")
	stringvalue.Parent = part
	stringvalue.Value = player.Name
	
	part.Dragged.Value = true
	
	if character and humanoid and humanoid.Health ~= 0 then
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local hrpAttachment = hrp:FindFirstChild("RootAttachment") or hrp:FindFirstChildWhichIsA("Attachment")

			alignPosition.Attachment1 = hrpAttachment
			alignPosition.Enabled = true

			connection = RunService.Heartbeat:Connect(function()
				if (part.Position - hrp.Position).Magnitude >= 15 then
					drag.Enabled = false
					if connection then
						connection:Disconnect()
						connection = nil
					end
				elseif (part.Position - hrp.Position).Magnitude <= 15 then
					drag.Enabled = true
				end
				wait(0.5)
				drag.Enabled = true
			end)
		end
	end
end)

drag.DragEnd:Connect(function(player)
	alignPosition.Attachment1 = nil
	alignPosition.Enabled = false
	if part:FindFirstChildWhichIsA("StringValue") then
		part:FindFirstChildWhichIsA("StringValue"):Destroy()
	end
	part.Dragged.Value = false
end)
