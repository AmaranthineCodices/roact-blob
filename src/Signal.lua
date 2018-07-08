--[[
	Pure-Lua Signal.
	Events are invoked synchronously in the order that they are connected.

	Mostly API-compatible with Roblox events. Lacks a Wait method.
]]

local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({
		_connections = {},
	}, Signal)
end

function Signal:Fire(...)
	for _, connection in ipairs(self._connections) do
		connection._listener(...)
	end
end

function Signal:Connect(listener)
	assert(typeof(listener) == "function", "listener must be a function")

	local handle
	handle = {
		_listener = listener,
		Connected = true,
		Disconnect = function()
			for i = #self._connections, 1, -1 do
				if self._connections[i]._listener == listener then
					table.remove(self._connections, i)
					handle.Connected = false
					break
				end
			end
		end
	}

	table.insert(self._connections, handle)

	return handle
end

function Signal:Destroy()
	for _, connection in ipairs(self._connections) do
		connection.Connected = false
	end

	self._connections = {}
	setmetatable(self, nil)
end

return Signal
