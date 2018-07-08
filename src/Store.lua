local Signal = require(script.Parent.Signal)

local Store = {}
Store.None = newproxy(true)
Store.__index = Store

function Store.new(initialState)
	return setmetatable({
		State = initialState,
		Changed = Signal.new(),
	}, Store)
end

function Store:SetState(partialState)
	local newState = {}

	for key, value in pairs(self.state) do
		newState[key] = value
	end

	for key, newValue in pairs(partialState) do
		if newValue == Store.None then
			newValue = nil
		end

		newState[key] = newValue
	end

	self.State = newState
	self.Changed:Fire(newState)
end

return Store
