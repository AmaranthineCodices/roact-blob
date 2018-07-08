--[[
	Provides a Store to a Roact tree using the context API. Also provides a
	higher-order component for using the provided Store.
]]

local Roact = require(script.Parent.Parent.Roact)

local contextKey = newproxy(true)
local StoreProvider = Roact.PureComponent:extend("Blob.StoreProvider")

function StoreProvider:init(props)
	self._context[contextKey] = props.store
end

function StoreProvider:render()
	return Roact.oneChild(self.props[Roact.Children])
end

local function withStore(component, storeKey)
	storeKey = storeKey or "Store"

	local wrappedComponent = Roact.PureComponent:extend(("Blob.WrappedComponent(%s)"):format(tostring(component)))

	function wrappedComponent:init()
		local store = self._context[contextKey]

		if store == nil then
			error(("this component is not descended from a Blob.StoreProvider component!\n%s"):format(
				self:getElementTraceback()), 0)
		end

		self._store = store
		self.state = {
			_storeState = store.State,
		}
	end

	function wrappedComponent:didMount()
		self._storeConnection = self._store.Changed:Connect(function(newState)
			self:setState({
				_storeState = newState
			})
		end)
	end

	function wrappedComponent:willUnmount()
		self._storeConnection:Disconnect()
	end

	function wrappedComponent:render()
		local mergedProps = {}

		for key, value in pairs(self.props) do
			mergedProps[key] = value
		end

		mergedProps[storeKey] = self._store
		return Roact.createElement(component, mergedProps)
	end

	return wrappedComponent
end

return {
	Provider = StoreProvider,
	Consumer = withStore,
}
