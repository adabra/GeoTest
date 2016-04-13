local _CLASS = {value1 = "default"}

function _CLASS:new( o )
	local OBJECT = o or {}
	setmetatable( OBJECT, self )
	self.__index = self
	return OBJECT
end

function _CLASS:getValue1()
	return self.value1
end

function _CLASS:setValue1( newValue )
	self.value1 = newValue
end

return _CLASS