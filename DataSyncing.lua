local DataStoreService = game:GetService("DataStoreService")
local playerDataStore = DataStoreService:GetDataStore("myDataStore")

local function loadData(player, key)
	local success, result = pcall(function()
		return playerDataStore:GetAsync(player.UserId .. "-" .. key)
	end)

	if success then
		return result
	else
		print("Failed to load " .. key .. " data for " .. player.Name)
		warn(result)
		return nil
	end
end

local function saveData(player, key, value)
	local success, result = pcall(function()
		playerDataStore:SetAsync(player.UserId .. "-" .. key, value)
	end)

	if not success then
		print("Failed to save " .. key .. " data for " .. player.Name)
		warn(result)
	end
end

game.Players.PlayerAdded:Connect(function(player)
	local Attributes = Instance.new("Folder")
	Attributes.Name = "EXAMPLE" --// NAME OF THE FOLDER YOU WANT THE VALUES TO BE PARENTED TO 
	Attributes.Parent = player

	
	local dataKeys = {} --// NAMES OF THE DATA VALUES YOU WANT TO SAVE AND LOAD GOES HERE
	
	for _, key in ipairs(dataKeys) do
		local value = Instance.new("NumberValue")
		value.Name = key
		value.Parent = Attributes

		local loadedValue = loadData(player, key)
		if loadedValue then
			value.Value = loadedValue
		end
	end
end)

game.Players.PlayerRemoving:Connect(function(player)
	local dataKeys = {} --// NAMES OF THE DATA VALUES YOU WANT TO SAVE AND LOAD GOES HERE

	local dataUpdates = {}

	for _, key in ipairs(dataKeys) do
		local value = player:FindFirstChild("EXAMPLE"):FindFirstChild(key)
		if value then
			saveData(player, key, value.Value)
			table.insert(dataUpdates, {
				key = ("%d-%s"):format(player.UserId, key),
				value = value.Value
			})
		end
	end

	local success, result = pcall(function()
		playerDataStore:UpdateAsync(player.UserId, function(oldData)
			local newData = oldData or {}
			for _, update in ipairs(dataUpdates) do
				newData[update.key] = update.value
			end
			return newData
		end)
	end)

	if not success then
		print("Failed to save data updates for " .. player.Name)
		warn(result)
	end
end)
