local TweenService = game:GetService("TweenService")

local tweeninfo = TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local function Animate(object, startPosition, endPosition, gui)
	local tween = TweenService:Create(object, tweeninfo, {Position = endPosition})
	tween:Play()
	print("Message Shown")

	tween.Completed:Connect(function()
		wait(2)
		print("Message Completed")
		object.Position = startPosition 
		gui.Enabled = false
		wait(1)
		object.Position = UDim2.new(0.416, 0, 0.134, 0)
	end)
end

local function DisplayText(gui,timeperchar,message) 
	local text = gui.TextLabel
	text.Text = ""

	local timePerCharacter = timeperchar
	local messageLength = #message

	for i = 1, messageLength do
		text.Text = string.sub(message, 1, i)
		wait(timePerCharacter)
	end
end

return {
	Animate = Animate,
	DisplayText = DisplayText,
}
