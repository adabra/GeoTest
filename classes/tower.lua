local gameValues = require('gameValues.tower')

local _Tower = {}

function _Tower:new( displayGroup, x, y, type, cellSize )
	local tower = {x = x, y = y, towerType = type, displayGroup = displayGroup, cellSize = cellSize, onCoolDown = false, cooldownStarted = 0 }
	setmetatable( tower, self )
	self.__index = self
	tower:setUpSprite( displayGroup )
	return tower
end

function _Tower:setUpSprite( displayGroup )
	print ("tower loc: " .. self:getX() .. ", " .. self:getY())
	--[[
	self.sprite = display.newCircle( displayGroup, self:getX(), self:getY(), 20 )
	self.sprite:setFillColor( 1, 0, 0 )
	-]]
	self.sprite = display.newImageRect( displayGroup, 
		gameValues.imagePath .. self.towerType .. gameValues.imageExtension, 
		Layout.mapArea.height * gameValues.itemSizeModifier, 
		Layout.mapArea.height * gameValues.itemSizeModifier )
	self.sprite.x = self:getX()
	self.sprite.y = self:getY()
end

function _Tower:getX()
	return self.x
end

function _Tower:getY()
	return self.y
end

function _Tower:setPosition( x, y )
	self.x = x
	self.y = y
end

function _Tower:getType()
	return self.towerType
end

function _Tower:setType( type )
	self.towerType = type
end

function _Tower:findTargets( minions )
	--[[
	if self.onCooldown then
		cooldownTimer = os.time() - self.cooldownStarted
		if (cooldownTimer >= gameValues.basicTowerCooldownTime) then
			self.onCooldown = false
		end
	end

	if not self.onCooldown then
--]]
		local target
		local minHp = 999999
		for k,minion in pairs(minions) do
			if (self:inRange( minion ) and minion:getStatus() == "moving" ) then
				if (minion:getHealthPoints() < minHp) then
					target = minion
				end
			end
		end
		if target then
			self:fire ( target )
		
		elseif self.fireSprite then
			self.fireSprite:removeSelf()
			self.fireSprite = nil
		end
	--end
end

function _Tower:inRange( minion )
	local distance = math.sqrt( (self.x-minion.x)*(self.x-minion.x) + (self.y-minion.y)*(self.y-minion.y) )
	return distance < self.cellSize*gameValues.basicTowerFiringRangeModifier
end


function _Tower:fire( minion )

	if self.fireSprite then
		self.fireSprite:removeSelf()
	end	


	self.fireSprite = display.newLine( self.displayGroup, self.x, self.y, minion.x, minion.y  )
	self.fireSprite:setStrokeColor( 1, 0, 0 )
	self.fireSprite.strokeWidth = 3


	--if not self.onCooldown then
	minion:takeFire( gameValues.basicTowerDamage, gameValues.basicTowerEffect )
	--	self.onCooldown = true
	--	self.cooldownStarted = os.time()
	--end
end




return _Tower