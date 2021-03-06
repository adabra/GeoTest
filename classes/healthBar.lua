local gameValues = require('gameValues.minion')
local colors = require('libs.colors')

local _HealthBar = {value1 = "default"}

function _HealthBar:new( displayGroup, minion )
	local healthBar = {displayGroup = displayGroup, minion = minion}
	setmetatable( healthBar, self )
	self.__index = self
	healthBar:setupSprite()
	return healthBar
end

function _HealthBar:setupSprite()
	self.healthBarFrame = display.newRect( self.displayGroup, 0, 0,
		gameValues.healthBarWidth, gameValues.healthBarHeight )
	
	self.healthBarRed = display.newRect( self.displayGroup, 0, 0, 
		gameValues.healthBarWidth, gameValues.healthBarHeight )
	self.healthBarGreen = display.newRect( self.displayGroup, 0, 0, 
		gameValues.healthBarWidth, gameValues.healthBarHeight)
	self.healthBarRed:setFillColor( 1, 0, 0 )
	self.healthBarGreen:setFillColor( unpack(colors.healthBarGreen) )
	self.healthBarFrame:setFillColor( 0, 0, 0, 0 )
	self.healthBarFrame:setStrokeColor( 0, 0, 0 )
	self.healthBarFrame.strokeWidth = 2
	--self.healthBarGreen.anchorX = 0
	--self.healthBarGreen.anchorY = 0
	self:updateSprite()
end

function _HealthBar:updateSprite()
	self:updateBarPosition( self.healthBarRed, false )
	self:updateBarSize( self.healthBarGreen )
	self:updateBarPosition( self.healthBarGreen, true )
	self:updateBarPosition( self.healthBarFrame, false )
end

function _HealthBar:updateBarPosition( bar, anchorLeft )
	bar.y = self.minion.y - self.minion.sprite.height
	bar.x = self.minion.x
	if anchorLeft then
		bar.x = bar.x - (gameValues.healthBarWidth - bar.width)/2
	end 
end

function _HealthBar:updateBarSize( bar )
	bar.width = gameValues.healthBarWidth*(self.minion:getHealthPoints()/self.minion.maxHealthPoints)
end

function _HealthBar:hide()
	if self.healthBarRed then
		self.healthBarRed:removeSelf( )
		self.healthBarGreen:removeSelf( )
		self.healthBarFrame:removeSelf( )
		self.healthBarRed = nil
		self.healthBarGreen = nil
		self.healthBarFrame = nil
	end
end

function _HealthBar:cleanUp()	
	self = nil
end

function _HealthBar:getValue1()
	return self.value1
end

function _HealthBar:setValue1( newValue )
	self.value1 = newValue
end

return _HealthBar