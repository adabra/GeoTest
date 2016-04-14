local gameValues = require('gameValues.pickupItem')
local Layout = require('libs.layout')

local _PickupItem = {}

function _PickupItem:new( displayGroup, itemType )
	local pickupItem = {displayGroup = displayGroup, itemType = itemType}
	setmetatable( pickupItem, self )
	self.__index = self
	pickupItem:initializeItem( itemType )
	return pickupItem
end

function _PickupItem:initializeItem( itemType )
	self.sprite = self:setupSprite( itemType )
	
	print(gameValues.itemPath .. itemType .. gameValues.itemExtension)
	print("YEAHHHHHHHH")
end


function _PickupItem:setPosition( x, y )
	self.sprite.x = x
	self.sprite.y = y
end

function _PickupItem:activate()
	self:useItem( self.itemType )
	self.sprite:removeSelf()
	self.sprite = nil
	self = nil
end

function _PickupItem:useItem( itemType )
	print ("ITEM USED: " .. itemType)
end

function _PickupItem:setupSprite( itemType )
	--[[
	self.sprite = display.newImageRect( 
		self.displayGroup, 
		gameValues.itemPath .. itemType .. gameValues.itemExtension, 
		Layout.mapArea.height * gameValues.itemSizeModifier,
		Layout.mapArea.height * gameValues.itemSizeModifier )
	--]]

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
	

	local playerImageSheet = graphics.newImageSheet( gameValues.pathGoldCoinImageSheet, imageSheetOptions )

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

	local mySprite = display.newSprite( self.displayGroup, playerImageSheet, sequenceGoldCoin )
	mySprite:scale( gameValues.goldCoinScale, gameValues.goldCoinScale )
	mySprite:play()
	return mySprite
end

return _PickupItem