local gameValues = require('gameValues.tower')
local Layout = require('libs.layout')
local utils = require('libs.utils')
local colors = require('libs.colors')

local _Tower = {}

function _Tower:new( displayGroup, x, y, type, cellSize, gridX, gridY )
	local tower = {x = x, y = y, towerType = type, displayGroup = displayGroup, cellSize = cellSize, onCoolDown = false, cooldownStarted = 0, gridX=gridX, gridY = gridY }
	setmetatable( tower, self )
	self.__index = self
	tower:init()
	return tower
end

function _Tower:init()
	self:setUpSprite( self.displayGroup )
	self.level = 1
end

function _Tower:setUpSprite2( displayGroup )
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
	self.sprite.tower = self
end


function _Tower:addEventListener( eventName, listener )
	self.sprite:addEventListener( eventName, listener )
end

function _Tower:removeEventListener( eventName, listener )
	self.sprite:removeEventListener( eventName, listener )
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

function _Tower:upgrade( upgradeChoice )
	self.towerType = upgradeChoice
	self.level = self.level + 1
	self.sprite:setSequence( gameValues['type' .. utils.firstToUpper( upgradeChoice ) .. 'Level' .. self.level ])
end

function _Tower:findTargets( minions )
		local target
		local minHp = 999999
		for k,minion in pairs(minions) do
			if (self:inRange( minion ) and minion:getStatus() == "moving" ) then
				if (minion:getHealthPoints() < minHp) then
					target = minion
					minHp = target:getHealthPoints()
				end
			end
		end
		if target then
			self:fire ( target )
		
		elseif self.fireSprite then
			self.fireSprite:removeSelf()
			self.fireSprite = nil
		end
end

function _Tower:inRange( minion )
	local distance = math.sqrt( (self.x-minion.x)*(self.x-minion.x) + (self.y-minion.y)*(self.y-minion.y) )
	return distance < self.cellSize*self:getRange()
end


function _Tower:fire( minion )

	if self.fireSprite then
		self.fireSprite:removeSelf()
	end	

	self:rotateTowardMinion( minion )

	self.fireSprite = display.newLine( self.displayGroup, self.x, self.y, minion.x, minion.y  )
	self.fireSprite:setStrokeColor( unpack(colors[self.towerType .. 'Laser']) )
	self.fireSprite.strokeWidth = 3

	minion:takeFire( 
		self:getDamage(), 
		self:getSlow() )
end

function _Tower:getSlow()
	return self:getValue('slow')
end

function _Tower:getRange()
	return self:getValue('range')
end

function _Tower:getDamage()
	return self:getValue('damage')
end

function _Tower:getValue( value )
	return gameValues[value .. utils.firstToUpper(self.towerType) .. 'Level' .. self.level]
end


function _Tower:rotateTowardMinion( minion )
	local minionX = minion.sprite.x
	local minionY = minion.sprite.y
	local towerX = self.sprite.x
	local towerY = self.sprite.y

	local dx = towerX - minionX
	local dy = towerY - minionY
	
	local angle = math.atan2( dx, -dy ) * 180/math.pi

	self.sprite.rotation = angle 	
end

function _Tower:cleanUpSprite()
	self.sprite:removeSelf( )
	self.sprite = nil
end

function _Tower:cleanUp( )
	self:cleanUpSprite()
	self = nil
end

function _Tower:setUpSprite( itemType )

	local imageSheetOptions =
	{
       frames =
	    {
	    	-- basic 
	    	{x = 0, y = 0, width = 93, height = 84},

	    	-- slow
	    	{x = 93, y = 0, width = 104, height = 84},
	    	{x = 197, y = 0, width = 103, height = 84},
	    	{x = 0, y = 84, width = 82, height = 84},
	    	{x = 82, y = 84, width = 97, height = 84},

	    	-- range
	    	{x = 179, y = 84, width = 104, height = 84},
	    	{x = 0, y = 168, width = 103, height = 84},
	    	{x = 103, y = 168, width = 82, height = 84},
	    	{x = 185, y = 168, width = 97, height = 84},

	    	-- damage
	    	{x = 300, y = 0, width = 104, height = 84},
	    	{x = 283, y = 84, width = 103, height = 84},
	    	{x = 282, y = 168, width = 82, height = 84},
	    	{x = 0, y = 252, width = 97, height = 84},

	    },
	}
	

	local playerImageSheet = graphics.newImageSheet( gameValues.pathTowerImageSheet, imageSheetOptions )

	local towerTypes = {'Slow', 'Range', 'Damage'}
	local sequences = { 
		{
	        name = gameValues.typeBasic,
	        start = 1, 
	        count = 1, 
	        time = 1000, 
	        loopCount = 0, 
	        loopDirection = "forward"
	    }
	}

	for i=1,#towerTypes do
		for j=2,5 do
			sequences[#sequences+1] = {
		        name = gameValues['type' .. towerTypes[i] .. 'Level' .. j],
		        start = (i-1)*4 + j, 
		        count = 1, 
		        time = 1000, 
		        loopCount = 0, 
		        loopDirection = "forward"
	    	}
			--print("ADDING SEQUENCE: " .. gameValues['type' .. towerTypes[i] .. 'Level' .. j])
			local index = (i-1)*4 + j
			--print("Start:" ..  index)
	    end
	end

	self.sprite = display.newSprite( self.displayGroup, playerImageSheet, sequences )
	self.sprite:scale( 0.7, 0.7 )

	self.sprite.x = self:getX()
	self.sprite.y = self:getY()
	self.sprite.tower = self
end

return _Tower