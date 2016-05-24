local Layout = require("libs.layout")
local gameValues = require('gameValues.player')
local utils = require('libs.utils')

local _Player = {x = gameValues.defaultPlayerXPosition, y = gameValues.defaultPlayerYPosition }

function _Player:new( displayGroup )
	local player = {}
	setmetatable( player, self )
	self.__index = self
	player.sprite = player:setupSprite( displayGroup )
	player.sprite:setSequence( gameValues.sequenceDownWalk )
	player.direction = gameValues.directionDown
	return player
end

function _Player:setupSpriteCircle( displayGroup )
	return display.newCircle( displayGroup, self.x, self.y, 10 )
end

function _Player:setSpeed( gameMapWidth )
	self.unitsMovedPerSecond = utils.metersPerSecondToCoronaPixelsPerFrame( gameValues.playerMetersPerSecond, gameMapWidth/display.contentWidth)
end

function _Player:hide()
	self.sprite.alpha = 0
end

function _Player:show()
	self.sprite.alpha = 1
end

function _Player:directionChanged( newDirection )
	return newDirection ~= self.direction
end

function _Player:getXPosition()
	return self.x
end

function _Player:getYPosition()
	return self.y
end

function _Player:getPosition()
	return {x = self.x, y = self.y}
end

function _Player:setPosition( x, y )
	local validPosition = true
	-- +/- 1 for buffer
	local minX = x-self.sprite.width/2 -1
	local maxX = x+self.sprite.width/2 +1
	local minY = y-self.sprite.height/2 -1
	local maxY = y+self.sprite.height/2 +1
	if (minX < Layout.mapArea.minX or maxX > Layout.mapArea.maxX) then
		print ("Trying to set player position with invalid x-value, was (" .. 
			minX .. ", " .. maxX .. "), min = " .. Layout.mapArea.minX .. ", max = " .. Layout.mapArea.maxX .. ".")
		validPosition = false
	end

	if (minY < Layout.mapArea.minY or maxY > Layout.mapArea.maxY) then
		print ("Trying to set player position with invalid y-value, was (" .. 
			minY .. ", " .. maxY .. "), min = " .. Layout.mapArea.minY .. ", max = " .. Layout.mapArea.maxY .. ".")
		validPosition = false
	end

	if (not validPosition ) then
		return
	end

	self.x = x
	self.y = y
	self.sprite.x = x
	self.sprite.y = y

end

function _Player:move( directions, superSpeed )
	local direction = {0,0}
	for k,v in pairs(directions) do
		direction[1] = direction[1] + v[1]
		direction[2] = direction[2] + v[2]
	end

	local units = self.unitsMovedPerSecond
	
	if (superSpeed) then
		units = units * 3
	end

	self:setPosition( self.x + direction[1]*units, self.y + direction[2]*units)
	
	local newDir
	local standStill = false
	--animation
	if (direction[2] < 0 ) then
		newDir = gameValues.directionUp
	elseif (direction[2] > 0 ) then
		newDir = gameValues.directionDown
	elseif (direction[1] > 0) then
		newDir = gameValues.directionRight
	elseif (direction[1] < 0 ) then
		newDir = gameValues.directionLeft
	else
		newDir = self.direction
		standStill = true
	end

	if ( self:directionChanged( newDir ) ) then
		self.sprite:setSequence( newDir .. "Walk" )
		self.sprite:play()
		self.direction = newDir
	elseif (standStill) then
		self.sprite:pause()
	end
end	

function _Player:setupSprite( displayGroup )
	local imageSheetOptions =
	{
    --array of tables representing each frame (required)
    frames =
	    {
	        -- FRAME (1,1):
	        {x = 0, y = 0, width = 67, height = 93},
	        -- FRAME (1,2):
	        {x = 67, y = 0, width = 67, height = 93},
	        -- FRAME (2,1):
	        {x = 0, y = 93, width = 65, height = 91},
	        -- FRAME (2,2):
	        {x = 65, y = 93, width = 65, height = 91},
	        -- FRAME (3,1):
	        {x = 0, y = 184, width = 67, height = 93},
	        -- FRAME (3,2):
	        {x = 67, y = 184, width = 67, height = 93},
	        -- FRAME (4,1):
	        {x = 0, y = 277, width = 64, height = 91},
	        -- FRAME (4,2):
	        {x = 64, y = 277, width = 64, height = 91},


	    },
	}

	local playerImageSheet = graphics.newImageSheet( gameValues.pathAlienImageSheet, imageSheetOptions )

	-- sequences table
	local sequences_walkingAlien = {
	    -- consecutive frames sequence
	    {
	        name = gameValues.sequenceLeftWalk,
	        start = 1,
	        count = 2,
	        time = 500,
	        loopCount = 0,
	        loopDirection = "forward"
	    },

	    {
	        name = gameValues.sequenceUpWalk,
	        start = 3,
	        count = 2,
	        time = 500,
	        loopCount = 0,
	        loopDirection = "forward"
	    },

	    {
	        name = gameValues.sequenceRightWalk,
	        start = 5,
	        count = 2,
	        time = 500,
	        loopCount = 0,
	        loopDirection = "forward"
	    },

	    {
	        name = gameValues.sequenceDownWalk,
	        start = 7,
	        count = 2,
	        time = 500,
	        loopCount = 0,
	        loopDirection = "forward"
	    },
	}

	local mySprite = display.newSprite( displayGroup, playerImageSheet, sequences_walkingAlien )
	mySprite:scale( gameValues.spriteScale, gameValues.spriteScale )
	return mySprite
end

--[[
function _Player:updatePosition(latitude, longitude)

	local myLocalLat = latitude - minLat
	local myLocalLon = longitude - minLon

	local xVal = myLocalLon * xAxisModifier
	local yVal = mapCenterY+(mapHeight/2) - (myLocalLat * yAxisModifier)

	if (not myPos) then
		myPos = display.newCircle( xVal, yVal, 10 )
	else
		myPos.x = xVal
		myPos.y = yVal
	end

	myPos:setFillColor( math.random(), math.random(), math.random() )
	print ( "Position updated" )
	print ( "new position: " .. latitude ..", " .. longitude)

end
--]]


return _Player