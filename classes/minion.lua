local gameValues = require('gameValues.minion')
local HealthBar = require('classes.healthBar')

local _Minion = {}

function _Minion:new( displayGroup, gameMap, minionMaster, minionType )
	local minion = {
		displayGroup = displayGroup, 
		gameMap = gameMap, 
		path = gameMap.path, 
		minionMaster = minionMaster, 
		minionType = minionType
	}
	setmetatable( minion, self )
	self.__index = self

	minion:init()
	return minion
end

function _Minion:init()
	local start = self.gameMap:gridToContentArea( unpack(self.path:getStartPosition()) )
	self.x = start[1] - self.gameMap.cellWidth/2
	self.y = start[2] - self.gameMap.cellHeight/2
	self.currentTileIndex = 0
	self.status = gameValues.statusWaiting
	self.slow = 1
	self:initMinionType()
end

function _Minion:initMinionType()
	self.units = gameValues[self.minionType .. 'MinionUnitsMovedPerFrame']
	self.maxHealthPoints = gameValues[self.minionType .. 'MinionMaxHP']
	self.healthPoints = self.maxHealthPoints
end

function _Minion:start()
	self:setupSprite() 
	self.status = gameValues.statusMoving
	self:updateNextDestination()
end

function _Minion:setupSprite()
	if self.minionType == gameValues.typeBasicMinion then
		self:setupBasicMinionSprite()
	elseif self.minionType == gameValues.typeLightMinion then
		self:setupLightMinionSprite()
	elseif self.minionType == gameValues.typeHeavyMinion then
		self:setupHeavyMinionSprite()
	elseif self.minionType == gameValues.typeBoss1Minion then
		self:setupBoss1MinionSprite()
	end

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

function _Minion:takeFire( damage, slow )
	self:takeDamage(damage)
	if self:getStatus() == gameValues.statusMoving then
		self:applySlow(slow)
	end
end

function _Minion:takeDamage( amount, percent )
	local percent = percent or false
	if percent then
		self.healthPoints = math.floor( self.healthPoints*(amount/100) )
	else
		self.healthPoints = self.healthPoints - amount
	end

	if self.healthPoints <= 0 then
		self:die()
	end
end

function _Minion:applySlow( slow )
	if slow<self.slow then
		self.units = gameValues.basicMinionUnitsMovedPerFrame * slow
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
	self:hide()
end

function _Minion:die()
	self.status = gameValues.statusDead
	self.minionMaster:died()
	self:hide()
end

function _Minion:hide()
	if self.sprite then
		self.sprite:removeSelf()
		self.sprite = nil
	end

	if self.healthBar then
		self.healthBar:hide()
	end
end

function _Minion:cleanUp()
	if self.healthBar then
		self.healthBar:cleanUp()
	end
	self = nil
end

function _Minion:setupBasicMinionSprite()
	self.sprite = display.newCircle( self.displayGroup, self.x, self.y, 10 )
	self.sprite:setFillColor( 0, 1, 0 )
end

function _Minion:setupLightMinionSprite()
	self.sprite = display.newCircle( self.displayGroup, self.x, self.y, 7 )
	self.sprite:setFillColor( 1, 0, 0 )
end

function _Minion:setupHeavyMinionSprite()
	self.sprite = display.newCircle( self.displayGroup, self.x, self.y, 13 )
	self.sprite:setFillColor( 0, 0, 1 )
end

function _Minion:setupBoss1MinionSprite()
	self.sprite = display.newCircle( self.displayGroup, self.x, self.y, 17 )
	self.sprite:setFillColor( 0, 0, 0 )
end

return _Minion