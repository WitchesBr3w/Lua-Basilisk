local attribute = script.Parent:GetAttribute("Damage")
local TweenModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("GuiModule"))

local muzzle = script.Parent.Handle.Muzzle
local killcooldown = false
local tool = script.Parent

script.Parent.Handle.Fire.OnServerEvent:Connect(function(player, mouseposition)

    tool.Handle.GunFire:Play()

    if not attribute then
        warn("Attribute 'Damage' not found.")
        return
    end

    if killcooldown then
        return
    end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {
        tool,
        muzzle,
        tool.Handle,
        tool.Parent:FindFirstChildWhichIsA("Humanoid"),
        tool.Parent,
        game.Players:GetPlayerFromCharacter(tool.Parent)
    }

    local origin = muzzle.Position
    local direction = (mouseposition - origin).Unit

    local result = workspace:Raycast(origin, direction * 1000, raycastParams)
    if not result then return end

    local hitPart = result.Instance
    local hitPosition = result.Position

    if not hitPart or not hitPart.Parent then return end

    local hitHumanoid = hitPart.Parent:FindFirstChildWhichIsA("Humanoid")

    if not hitHumanoid then
        print("Humanoid not found!")
        return
    end

    if hitHumanoid.Health <= 0 then
        return
    end

    -- Apply damage
    hitHumanoid.Health = hitHumanoid.Health - attribute

    -- Check for kill
    if hitHumanoid.Health <= 0 then
        local statvalues = player:FindFirstChild("StatValues")
        local stuffFolder = player:FindFirstChild("Stuff")
        local playergui = player.PlayerGui

        if statvalues and stuffFolder then
            local cash = statvalues:WaitForChild("Cash")
            local totalkills = statvalues:WaitForChild("TotalKills")
            local killstreak = stuffFolder:WaitForChild("KillStreak")

            cash.Value = cash.Value + 5
            totalkills.Value = totalkills.Value + 1
            killstreak.Value = killstreak.Value + 1

            local gui = playergui:WaitForChild("Message")
            gui.Enabled = true

            local text = gui.TextLabel
            text.Text = "Kill Streak: " .. tostring(killstreak.Value)

            local startPosition = text.Position
            local endPosition = text.Position + UDim2.new(0, 0, -0.05, 0)

            TweenModule.Animate(text, startPosition, endPosition, gui)
        end
    end
end)