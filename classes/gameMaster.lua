local strings = require('strings.game')
local gameValues = require('gameValues.gameMaster')
local gameValuesPickupItem = require('gameValues.pickupItem')
local gameValuesGameMap = require('gameValues.gameMap')
local gameValuesMinionMaster = require('gameValues.minionMaster')
local PickupItem = require('classes.pickupItem')
local Layout = require('libs.layout')

local _GameMaster = {}

function _GameMaster:new( displayGroup, statusBar, minionMaster, gameMap )
	local gameMaster =  {displayGroup = displayGroup, statusBar = statusBar, minionMaster = minionMaster, gameMap = gameMap}
	setmetatable( gameMaster, self )
	self.__index = self
	gameMaster:init()

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
	self.gameMap:addGameEventListener( self )
	self.minionMaster:addGameEventListener( self )
	self.gameInCountdown = false
	self:initRefundValues()
end

function _GameMaster:initPickupItemGrid()
	self.pickupItems = {}
	for y=1,self.gameMap.cellsVertically do
		self.pickupItems[y] = {}
	end
end

function _GameMaster:initRefundValues()
	self.refundValues = {basic = gameValues.basicTowerCost}
end

function _GameMaster:handleGameEvent( event )
	if event.eventType == gameValuesGameMap.eventTypeTowerSelected then
		if self.gameInCountdown then
			self:selectTower( event.target )
		end
	elseif event.eventType == gameValuesGameMap.eventTypeTowerDeselected then
		self:deselectTower()
	elseif event.eventType == gameValuesMinionMaster.eventTypeMinionAttacking then
		self:decreaseBaseHealthPoints( event.amount )
	elseif event.eventType == gameValuesMinionMaster.eventTypeWaveDone then
		self.controlPanel:cleanUpTowerBuildingInterface()
		self:startWaveCountdown()
	end
end

function _GameMaster:selectTower( tower )
	self.selectedTower = tower
	self.gameMap:selectTower( tower:getX(), tower:getY() )
	self.controlPanel:createSellAndUpgradeInterface (self.controlPanel.displayGroup)
end

function _GameMaster:deselectTower( )
	self.selectedTower = nil
	self.gameMap:deselectTower()
end

function _GameMaster:sellSelectedTower()
	local towerType = self.selectedTower.towerType
	self:getRefund( towerType )
	self.selectedTower:cleanUp()
	self:deselectTower()
end

function _GameMaster:getRefund( towerType )
	self.creditAmount = self.creditAmount + self.refundValues[towerType]
	self.statusBar:setCreditAmount(self.creditAmount)
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
	self:startWaveCountdown()
	self:sendNextWave()
end

function _GameMaster:startGameCountdown()
	local startGameCountdown = gameValues.startGameCountdown

	local textOptions = {
		parent = self.controlPanel.displayGroup, 
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
end

function _GameMaster:startWaveCountdown( waveNumber )
	self.gameInCountdown = true
	self.controlPanel:createWaveCountdownInterface( self.controlPanel.displayGroup )
	self.waveCountdownTimer = timer.performWithDelay( 
		gameValues.waveCountdown,
		function()
			self:startNextWave()
		end )
end

function _GameMaster:startNextWave()
	self.gameMap:deselectTower()
	self.controlPanel:readyForNewWave()
	self.waveLevel = self.waveLevel + 1
	self.statusBar:setWaveLevel( self.waveLevel )
	self.minionMaster:sendWave( self.waveLevel )
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
		self.controlPanel:cleanUpTowerBuildingInterface()
		--self.controlPanel:createGameLostInterface( self.controlPanel.displayGroup )
	end
	self.statusBar:setBaseHealthPoints( self.baseHealthPoints )
end

function _GameMaster:setControlPanel( controlPanel )
	self.controlPanel = controlPanel
end

return _GameMaster