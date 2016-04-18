local strings = require('strings.game')
local gameValues = require('gameValues.gameMaster')
local gameValuesPickupItem = require('gameValues.pickupItem')
local PickupItem = require('classes.pickupItem')
local Layout = require('libs.layout')

local _GameMaster = {}

function _GameMaster:new( displayGroup, statusBar, minionMaster, gameMap )
	local gameMaster =  {displayGroup = displayGroup, statusBar = statusBar, minionMaster = minionMaster, gameMap = gameMap}
	setmetatable( gameMaster, self )
	self.__index = self
	gameMaster:init()
	--[[
	local nextItem = PickupItem:new( displayGroup, 'gold_1')
	nextItem:setPosition( Layout.mapArea.centerX, Layout.mapArea.centerY )

	timer.performWithDelay( 300, function() local nextItem2 = PickupItem:new( displayGroup, 'gold_1')
	nextItem2:setPosition( Layout.mapArea.centerX*0.6, Layout.mapArea.centerY*1.5 ) end )
	

	local nextItem3 = PickupItem:new( displayGroup, 'gold_1')
	nextItem3:setPosition( Layout.mapArea.centerX*0.9, Layout.mapArea.centerY*0.3 )

	local nextItem4 = PickupItem:new( displayGroup, 'gold_1')
	nextItem4:setPosition( Layout.mapArea.centerX*1.4, Layout.mapArea.centerY*0.4 )

	--]]
	gameMaster:placeNewPickupItem( 5, 5, gameValuesPickupItem.typeGoldCoin )
	gameMaster:placeNewPickupItem(5,6,gameValuesPickupItem.typeGoldCoin)
	return gameMaster
end

function _GameMaster:init()
	self.pathBuildingAllowed = true
	self.baseHealthPoints = gameValues.maxBaseHealthPoints
	self.gameMap:addPlayerCellListener( self )
	self:initPickupItemGrid()
	self.creditAmount = gameValues.creditStartAmount
end

function _GameMaster:initPickupItemGrid()
	self.pickupItems = {}
	for y=1,self.gameMap.cellsVertically do
		self.pickupItems[y] = {}
	end
end

function _GameMaster:setDifficulty( difficulty )
	self.gameDifficulty = difficulty
end

function _GameMaster:isPathBuildingAllowed()
	return self.pathBuildingAllowed
end

function _GameMaster:setPathBuildingAllowed( boolean )
	self.pathBuildingAllowed = boolean
end

function _GameMaster:startGame()
	print("GAME STARTED!")
	--self:setPathBuildingAllowed(false)
	self:sendNextWave()
end

function _GameMaster:playerCellChanged( newX, newY )
	self:checkPickupItems( newX, newY )
end

function _GameMaster:checkPickupItems( x, y )
	if self.pickupItems[y][x] then
		self:useItem( self.pickupItems[y][x].itemType )
		self.pickupItems[y][x]:cleanUp()
		self.pickupItems[y][x] = nil
	end
end

function _GameMaster:placeNewPickupItem( x, y, type )
	local newItem = PickupItem:new( self.displayGroup, type)
	newItem:setPosition( unpack(self.gameMap:gridToContentAreaMidCell( x, y )) )
	self.pickupItems[y][x] = newItem
end

function _GameMaster:useItem( itemType )
	if itemType == gameValuesPickupItem.typeGoldCoin then
		self.creditAmount = self.creditAmount + gameValues.goldCoinAmount
		self.statusBar:setCreditAmount( self.creditAmount )
	end
end

function _GameMaster:canAffordBasicTower()
	return self.creditAmount >= gameValues.basicTowerCost
end

function _GameMaster:payForBasicTower()
	self.creditAmount = self.creditAmount - gameValues.basicTowerCost
	self.statusBar:setCreditAmount(self.creditAmount)
end

function _GameMaster:sendNextWave()
	local waveCountdown = gameValues.waveCountdown

	local textOptions = {
		parent = self.displayGroup, 
		text = strings.waveCountdownText .. waveCountdown, 
		x = Layout.mapArea.centerX, 
		y = Layout.mapArea.minY + Layout.mapArea.height*0.1, 
		width = Layout.mapArea.width*0.95, 
		height = 0, 
		font = native.systemFont,
		align = "center" 
	}
	self.waveCountdownText = display.newText( textOptions )
	self.waveCountdownText:setFillColor( 0, 0, 0 )

	timer.performWithDelay( 1000, function() 
			if (waveCountdown>1) then
				waveCountdown = waveCountdown - 1
				self.waveCountdownText.text = strings.waveCountdownText .. waveCountdown
			elseif (waveCountdown == 1) then
				waveCountdown = waveCountdown - 1
				self.waveCountdownText.text = strings.waveComingText
				timer.performWithDelay( 400, function() 
					self.minionMaster:createMinion("basic")
					self.minionMaster:sendNextMinion() 
				end,
				5 )
			else
				self.waveCountdownText:removeSelf()
				self.waveCountdownText = nil
				
			end
		end, 
		waveCountdown+1 )
end

function _GameMaster:createNewItem()
end



function _GameMaster:decreaseBaseHealthPoints( amount )

	self.baseHealthPoints = self.baseHealthPoints - amount
	if self.baseHealthPoints <= 0 then
		self.baseHealthPoints = 0
		--self.controlPanel:cleanUpTowerBuildingInterface()
		self.controlPanel:createGameLostInterface( self.displayGroup )
	end
	self.statusBar:setBaseHealthPoints( self.baseHealthPoints )
end

function _GameMaster:setControlPanel( controlPanel )
	self.controlPanel = controlPanel
end

return _GameMaster