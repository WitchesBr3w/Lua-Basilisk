local player = game.Players.LocalPlayer
local tool = script.Parent
local mouse = player:GetMouse()
local cooldown = false
local isequipped=  false
local animations = game.ReplicatedStorage.Animations
local idle = animations["Pistol Idle"]

local magAmount = tool:GetAttribute("MagAmount")
local totalammo = tool:GetAttribute("Ammo")

tool.Equipped:Connect(function()
	local playergui = player.PlayerGui
	local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
		local animtrack = animator:LoadAnimation(idle)
		if animator then
			animtrack:Play()
			isequipped = true
		end
		local unequipConnection
		unequipConnection = tool.Unequipped:Connect(function()
			if animtrack.IsPlaying then
				animtrack:Stop()
				playergui.AmmoHud.Enabled = false
				isequipped = false
			end
		end)
	end
	tool.Handle.GunEquip:Play()
	if playergui.AmmoHud then
		playergui.AmmoHud.Enabled = true
		player.PlayerGui.AmmoHud.Frame.AmmoCount.Text = tostring(magAmount)
		player.PlayerGui.AmmoHud.Frame.MagSize.Text = tostring(totalammo)
	end
end)

tool.Activated:Connect(function()
	if cooldown or magAmount == 0 then
		return
	end
	
	cooldown = true
	tool.Handle.GunFire:Play()

	tool.Handle.Fire:FireServer(mouse.Hit.Position)
		
	local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
	
	if humanoid then
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if animator then
			local animtrack = animator:LoadAnimation(game.ReplicatedStorage.Animations["Pistol Fire"])
			animtrack:Play()
		end
	end
	

	magAmount = magAmount - 1
	player.PlayerGui.AmmoHud.Frame.AmmoCount.Text = tostring(magAmount)
	wait(0.4)
	cooldown = false
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
	if not gameProcessedEvent and input.KeyCode == Enum.KeyCode.R and isequipped then
		if magAmount < 6 and totalammo > 0 then
			local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
			if humanoid then
				local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
				if animator then
					local animtrack = animator:LoadAnimation(game.ReplicatedStorage.Animations.Reload)
					animtrack:Play()
				end
			end
			tool.Handle.GunReload:Play()
			cooldown = true
			local bulletsToReload = math.min(7 - magAmount, totalammo)
			magAmount = magAmount + bulletsToReload
			totalammo = totalammo - bulletsToReload

			player.PlayerGui.AmmoHud.Frame.AmmoCount.Text = tostring(magAmount)
			player.PlayerGui.AmmoHud.Frame.MagSize.Text = tostring(totalammo)
			wait(1.6)
			cooldown = false
		end
	end
end)
