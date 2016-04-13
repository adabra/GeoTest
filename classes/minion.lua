local gameValues = require('gameValues.minion')
local HealthBar = require('classes.healthBar')

local _Minion = {}

function _Minion:new( displayGroup, gameMap, minionMaster, minionType )
	local minion = {displayGroup = displayGroup, gameMap = gameMap, path = gameMap.path, minionMaster = minionMaster, minionType = minionType}
	setmetatable( minion, self )
	self.__index = self
	local start = minion.gameMap:gridToContentArea( unpack(minion.path:getStartPosition()) )
	minion.x = start[1] - minion.gameMap.cellWidth/2
	minion.y = start[2] - minion.gameMap.cellHeight/2
	minion.currentTileIndex = 0
	minion.units = gameValues.basicMinionUnitsMovedPerFrame
	minion.status = gameValues.statusWaiting
	minion.maxHealthPoints = gameValues.basicMinionMaxHP 
	minion.healthPoints = minion.maxHealthPoints
	return minion
end

function _Minion:start()
	self:setupSprite() 
	self.sprite:setFillColor( 0, 1, 0 )
	self.status = gameValues.statusMoving
	self:updateNextDestination()
end

function _Minion:setupSprite()
	self.sprite = display.newCircle( self.displayGroup, self.x, self.y, 10 )
	self.healthBar = HealthBar:new( self.displayGroup, self )
end

function _Minion:updateSprite()
	if self.sprite then
		self.x = self.x + self.direction[1]*self.units
		self.y = self.y + self.direction[2]*self.units
		self.sprite.x = self.x
		self.sprite.y = self.y
		self.healthBar:updateSprite()
	end
end

function _Minion:move()
	self:updateSprite()
	if (self.direction[1] ~= 0) then
		if (self.x*self.direction[1] >= self.nextDestination[1]*self.direction[1] ) then
			self:updateNextDestination()
		end
	elseif (self.direction[2] ~= 0) then
		if (self.y*self.direction[2] >= self.nextDestination[2]*self.direction[2] ) then
			self:updateNextDestination()
		end
	end
end

function _Minion:updateNextDestination()
	self.currentTileIndex = self.currentTileIndex + 1
	if (self.path:isLastTile( self.currentTileIndex ) ) then
		self:attackBase()

		return
	end
	self.currentTile = self.path:getTile(self.currentTileIndex)
	self.nextTile = self.path:getTile(self.currentTileIndex+1)

	self.direction = {self.nextTile[1] - self.currentTile[1], self.nextTile[2] - self.currentTile[2]}

	--self.nextDestination[1] = self.nextDestination[1]+self.direction[1]*self.gameMap.cellWidth
	--self.nextDestination[2] = self.nextDestination[2]+self.direction[2]*self.gameMap.cellHeight

	self.nextDestination = self.gameMap:gridToContentArea( unpack(self.nextTile) )
	self.nextDestination[1] = self.nextDestination[1] - self.gameMap.cellWidth/2 
	self.nextDestination[2] = self.nextDestination[2] - self.gameMap.cellHeight/2
end

function _Minion:takeFire( damage, effect )
	self.healthPoints = self.healthPoints - damage
	if self.healthPoints <= 0 then
		self:die()
	end
end

function _Minion:getHealthPoints()
	return self.healthPoints
end

function _Minion:getStatus()
	return self.status
end

function _Minion:setStatus( status )
	self.status = status
end

function _Minion:attackBase()
	self.status = gameValues.statusDone
	self.minionMaster:attackedBase( self.minionType )
	self:cleanUp()
end

function _Minion:die()
	self.status = gameValues.statusDead
	self:cleanUp()
end

function _Minion:cleanUp()
	self.sprite:removeSelf()
	self.sprite = nil
	self.healthBar:cleanUp()
end

return _Minion