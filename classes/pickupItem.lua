local gameValues = require('gameValues.pickupItem')
local Layout = require('libs.layout')
local colors = require('libs.colors')

local _PickupItem = {}

function _PickupItem:new( displayGroup, itemType, cellSize )
	local pickupItem = {displayGroup = displayGroup, itemType = itemType, cellSize = cellSize}
	setmetatable( pickupItem, self )
	self.__index = self
	pickupItem:initializeItem( itemType, gameMap )
	return pickupItem
end

function _PickupItem:initializeItem( itemType )
	self.sprite = self:setupSprite( itemType )
	self.durationBar = self:setupDurationBar()
	self.eventListeners = {}
	self:initTimer()
end

function _PickupItem:setPosition( x, y )
	self.sprite.x = x
	self.sprite.y = y
end

function _PickupItem:cleanUp()
	self:cleanUpDurationBar()

	if self.sprite then
		self.sprite:removeSelf( )
		self.sprite = nil
	end

	if self.myTimer then
		timer.cancel(self.myTimer)
	end

	self = nil
end

function _PickupItem:fireGameEvent( event )
	for k,listener in pairs(self.eventListeners) do
		listener:handleGameEvent( event )
	end
end

function _PickupItem:addListener( listener )
	table.insert(self.eventListeners, listener)
end

function _PickupItem:initTimer()
	local duration = gameValues[self.itemType .. 'Timer']
	local frequency = 1000/30
	self.myTimer = timer.performWithDelay( frequency, 
		function()
	 		self:updateDurationBar(duration)
	 		duration = duration - frequency
	 		if duration <= 0 then
	 			self:fireGameEvent( {eventType = gameValues.eventTypeItemCleanedUp, pos = {x =self.sprite.x, y=self.sprite.y }})
	 			self:cleanUp()
	 		end
	 	end,
	 	math.ceil(duration/frequency)
	 )
end

function _PickupItem:setupSprite( itemType )
	if itemType == gameValues.typeGoldCoin then
		return self:setupGoldCoinSprite()
	elseif itemType == gameValues.typeZapper then
		return self:setupZapperSprite()
	elseif itemType == gameValues.typeHpPack then 	
		return self:setupHpPackSprite()
	end
end

function _PickupItem:setupDurationBar()
	local durationBar = {}
	durationBar.background = display.newRect( 
		self.displayGroup, 
		self.sprite.x, 
		self.sprite.y - (self.cellSize * 0.4), 
		gameValues.durationBarWidth, 
		gameValues.durationBarHeight )
	durationBar.background:setFillColor( 0, 0, 0 )
	
	durationBar.foreground = display.newRect( 
		self.displayGroup, 
		self.sprite.x, 
		self.sprite.y - (self.cellSize * 0.4), 
		gameValues.durationBarWidth, 
		gameValues.durationBarHeight )
	durationBar.foreground:setFillColor( unpack(colors.slowLaser) )

	return durationBar
end

function _PickupItem:updateDurationBar( duration )
	self.durationBar.foreground.width = gameValues.durationBarWidth * duration/gameValues[self.itemType..'Timer']

	self.durationBar.background.x = self.sprite.x
	self.durationBar.background.y = self.sprite.y - (self.cellSize * 0.4)

	self.durationBar.foreground.x = self.sprite.x - (gameValues.durationBarWidth - self.durationBar.foreground.width)/2
	self.durationBar.foreground.y = self.sprite.y - (self.cellSize * 0.4)

end

function _PickupItem:cleanUpDurationBar()
	if self.durationBar.background then
		self.durationBar.background:removeSelf( )
		self.durationBar.background = nil
	end

	if self.durationBar.foreground then
		self.durationBar.foreground:removeSelf( )
		self.durationBar.foreground = nil
	end
end

function _PickupItem:setupGoldCoinSprite()
	local imageSheetOptions =
	{
       frames =
	    {
	        {x = 0, y = 0, width = 84, height = 84},
	        {x = 84, y = 0, width = 66, height = 84},
	        {x = 150, y = 0, width = 50, height = 84},
	        {x = 200, y = 0, width = 15, height = 84},
	        {x = 215, y = 0, width = 50, height = 84},
	        {x = 265, y = 0, width = 66, height = 84},
	    },
	}
	

	local imageSheet = graphics.newImageSheet( gameValues.pathGoldCoinImageSheet, imageSheetOptions )

	-- sequences table
	local sequenceGoldCoin = {
	    -- consecutive frames sequence
	    {
	        name = gameValues.sequenceGoldCoin,
	        start = 1,
	        count = 6,
	        time = 750,
	        loopCount = 0,
	        loopDirection = "forward"
	    },
	}

	local mySprite = display.newSprite( self.displayGroup, imageSheet, sequenceGoldCoin )
	mySprite:scale( gameValues.goldCoinScale, gameValues.goldCoinScale )
	mySprite:play()
	return mySprite
end

function _PickupItem:setupZapperSprite()
	local sprite = display.newImageRect( self.displayGroup, gameValues.pathZapperImage, self.cellSize*0.4, self.cellSize*0.6 )
	return sprite
end

function _PickupItem:setupHpPackSprite()
	local sprite = display.newImageRect( self.displayGroup, gameValues.pathHpPackImage, self.cellSize*0.6, self.cellSize*0.6 )
	return sprite
end

return _PickupItem