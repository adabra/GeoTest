local _PickupItem = {}

function _PickupItem:new( )
	local pickupItem = {}
	setmetatable( pickupItem, self )
	self.__index = self
	return pickupItem
end

return _PickupItem