local folder = game.Workspace.TeamPart
local RunService = game:GetService("RunService")
local currentMessage = nil

local teamDictionary = {
	{
		teamName = "Blue", --// NAME OF TEAM GOES HERE
		teamPath = game.Teams.Blue, --// PATH TO TEAM GOES HERE
		Part = folder.Blue,
	},
	{
		teamName = "Red", --// NAME OF TEAM GOES HERE
		teamPath = game.Teams.Red, --// PATH TO TEAM GOES HERE
		Part = folder.Red,
	}
}

local function CreateMessage(text, parent)
	if currentMessage then
		return 
	end

	local message = Instance.new("Message")
	currentMessage = message
	message.Text = text
	message.Parent = parent

	game:GetService("Debris"):AddItem(message, 2) 

	message.Destroying:Connect(function()
		currentMessage = nil
	end)
end


local function getTeamSize(team)
	local count = 0
	for _, player in pairs(game.Players:GetPlayers()) do
		if player.Team == team then
			count += 1
		end
	end
	return count
end


local function isTeamImbalanced()
	local blueCount = getTeamSize(game.Teams.Blue)
	local redCount = getTeamSize(game.Teams.Red)
	return math.abs(blueCount - redCount) > 1
end

local function switchPlayerTeam(player, newTeam)
	if player.Team ~= newTeam then
		player.Team = newTeam
		print(player.Name .. " switched to " .. newTeam.Name)
	end
end

local debounce = {}
local function canSwitchPlayer(player)
	if debounce[player] and debounce[player] + 5 > os.time() then
		return false
	end
	debounce[player] = os.time()
	return true
end

for _, teamData in pairs(teamDictionary) do
	teamData.Part.Touched:Connect(function(hit)
		local player = game.Players:GetPlayerFromCharacter(hit.Parent)
		local humanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid")

		if player and humanoid and player.Team ~= teamData.teamPath then
			local blueCount = getTeamSize(game.Teams.Blue)
			local redCount = getTeamSize(game.Teams.Red)

			if math.abs((teamData.teamPath == game.Teams.Blue and blueCount + 1 or redCount + 1) 
				- (teamData.teamPath == game.Teams.Red and blueCount or redCount)) <= 1 then
				if canSwitchPlayer(player) then
					switchPlayerTeam(player, teamData.teamPath)
					player:LoadCharacter()
				end
			else
				CreateMessage("Teams are imbalanced! Please join the other team.",player.PlayerGui)
			end
		end
	end)
end

RunService.Heartbeat:Connect(function()
	if isTeamImbalanced() then
		CreateMessage("Teams are imbalanced! Rebalancing...",game.Workspace)

		local blueCount = getTeamSize(game.Teams.Blue)
		local redCount = getTeamSize(game.Teams.Red)

		for _, player in pairs(game.Players:GetPlayers()) do
			if blueCount > redCount + 1 and player.Team == game.Teams.Blue then
				if canSwitchPlayer(player) then
					switchPlayerTeam(player, game.Teams.Red)
					blueCount -= 1
					redCount += 1
				end
			elseif redCount > blueCount + 1 and player.Team == game.Teams.Red then
				if canSwitchPlayer(player) then
					switchPlayerTeam(player, game.Teams.Blue)
					redCount -= 1
					blueCount += 1
				end
			end

			if math.abs(blueCount - redCount) <= 1 then
				break
			end
		end
	end
end)
