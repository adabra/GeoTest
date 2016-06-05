local strings = require('strings.game')
local gameValues = require('gameValues.gameMaster')
local gameValuesPickupItem = require('gameValues.pickupItem')
local gameValuesGameMap = require('gameValues.gameMap')
local gameValuesMinionMaster = require('gameValues.minionMaster')
local PickupItem = require('classes.pickupItem')
local Layout = require('libs.layout')
local sounds = require('sounds.sounds')

local _GameMaster = {}

function _GameMaster:new( displayGroup, statusBar, minionMaster, towerMaster, gameMap )
	local gameMaster =  {displayGroup = displayGroup, statusBar = statusBar, minionMaster = minionMaster, towerMaster = towerMaster, gameMap = gameMap}
	setmetatable( gameMaster, self )
	self.__index = self
	gameMaster:init()

	--gameMaster:placeNewPickupItem( 5, 5, gameValuesPickupItem.typeGoldCoin )
	--gameMaster:placeNewPickupItem(5,6,gameValuesPickupItem.typeZapper)
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
	self:setGameState( gameValues.stateWaiting)
	self.waveLevel = 0
	self.isGameCountdown = true
end

function _GameMaster:initPickupItemGrid()
	self.pickupItems = {}
	for y=1,self.gameMap.cellsVertically do
		self.pickupItems[y] = {}
	end
end

function _GameMaster:setGameState( gameState )
	self.gameState = gameState
end

function _GameMaster:getGameState()
	return self.gameState
end

function _GameMaster:handleGameEvent( event )

	if event.eventType == gameValuesGameMap.eventTypeTowerSelected then		
		if self:getGameState() == gameValues.stateWaveCountdown and not self.isGameCountdown then
			if self.selectedTower == event.target then
				self:deselectTower()
			else
				self:selectTower( event.target )
			end
		end

	elseif event.eventType == gameValuesGameMap.eventTypeTowerDeselected then
		self:deselectTower()

	elseif event.eventType == gameValuesMinionMaster.eventTypeMinionAttacking then
		self:decreaseBaseHealthPoints( event.amount )

	elseif event.eventType == gameValuesPickupItem.eventTypeItemCleanedUp then
		if event.x and event.y then
			local gridPos = self.gameMap:contentAreaToGrid( event.x, event.y )
			self.pickupItems[gridPos[2]][gridPos[1]] = nil
		end

	elseif event.eventType == gameValuesGameMap.eventTypeTowerBuilt then
		self:payForBasicTower()

	elseif event.eventType == gameValuesMinionMaster.eventTypeWaveDone then
		if self:getGameState() ~= gameValues.stateBaseDestroyed then
			if gameValues.timeWarp > gameValues.maxTimeWarp then
				gameValues.timeWarp = self.statusBar.gameSpeed
			end
			self.controlPanel.straightFromWave = true
			self.controlPanel:cleanUpTowerBuildingInterface()
			timer.cancel( self.itemTimer )
			self:cleanUpPickupItems()
			self:startWaveCountdown()
		end

	elseif event.eventType == gameValuesMinionMaster.eventTypeGameWon then
		if self:getGameState() ~= gameValues.stateBaseDestroyed then
			self.controlPanel:cleanUpTowerBuildingInterface()
			self:cleanUpPickupItems()
			self:gameWon()
		end
	end
end

function _GameMaster:gameWon()
	local winner = display.newImageRect( "images/visual_objects/you_win.png", Layout.mapArea.width, Layout.mapArea.height )
	winner.x = display.contentCenterX
	winner.y = display.contentCenterY
	self:pauseGame()
	audio.play(sounds.soundGameWon)
end

function _GameMaster:selectTower( tower )
	self.selectedTower = tower
	self.gameMap:selectTower( tower:getX(), tower:getY() )
	self.controlPanel:cleanUpStartWaveButton()
	self.controlPanel:createSellAndUpgradeInterface (self.controlPanel.displayGroup)
end

function _GameMaster:deselectTower( )
	self.selectedTower = nil
	self.gameMap:deselectTower()
	self.controlPanel:cleanUpCurrentInterface()
	self.controlPanel:createWaveCountdownInterface(self.controlPanel.displayGroup)
end

function _GameMaster:sellSelectedTower()
	local towerType = self.selectedTower.towerType
	self:getRefund( towerType )
	self.towerMaster:removeTower( self.selectedTower )
	self.selectedTower:cleanUp()
	self.gameMap:setMapCell(self.selectedTower.gridX, self.selectedTower.gridY, 'empty' )
	self:deselectTower()
end

function _GameMaster:getRefund( towerType )
	self.creditAmount = self.creditAmount + self:getRefundValue( towerType )
	self.statusBar:setCreditAmount(self.creditAmount)
end

function _GameMaster:upgradeSelectedTower( upgradeChoice )
	local towerLevel = self.selectedTower.level
	if self:canAffordUpgrade( upgradeChoice, towerLevel ) then
		self.selectedTower:upgrade( upgradeChoice )
		self:payForUpgrade( upgradeChoice, towerLevel )
		self.gameMap:deselectTower()
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
	self:startWaveCountdown()
	self:resumeGame()
end

function _GameMaster:restartGame()
	self.minionMaster:clearWave()
	self.baseHealthPoints = gameValues.maxBaseHealthPoints
	self.statusBar:setBaseHealthPoints( self. baseHealthPoints )
	self.waveLevel = self.waveLevel - 1
	self.isGameCountdown = true
	self:startGame()
end

function _GameMaster:startWaveCountdown()
	self:setGameState(gameValues.stateWaveCountdown)
	local countdownTime
	if self.isGameCountdown then
		self.controlPanel:createGameCountdownInterface( self.controlPanel.displayGroup)
		self.waveCountdown = gameValues.gameCountdownTime
	else 
		self.controlPanel:createWaveCountdownInterface( self.controlPanel.displayGroup )
		self.waveCountdown = gameValues.waveCountdownTime
	end
	countdownTime = self.waveCountdown

	self.controlPanel:updateWaveCountdown( self.waveCountdown )
	self.waveCountdownTimer = timer.performWithDelay(
		1000, 
		function()
			if self.waveCountdown>1 then
				self.waveCountdown = self.waveCountdown-1
				self.controlPanel:updateWaveCountdown( self.waveCountdown)
			else
				self:startNextWave()
			end
		end,
		countdownTime
		 )
end

function _GameMaster:skipWaveCountdown()
	if (self:getGameState() == gameValues.stateWaveCountdown) then
		if self.waveCountdownTimer then
			self.creditAmount = self.creditAmount + self.waveCountdown 
			self.statusBar:setCreditAmount( self.creditAmount )
			timer.cancel( self.waveCountdownTimer )
			self.waveCountdownTimer = nil
		end
		self:startNextWave()
	end
end


function _GameMaster:startNextWave()
	self:deselectTower()
	self:setGameState(gameValues.stateOngoingWave)
	self.isGameCountdown = false
	self.gameMap:deselectTower()
	self.controlPanel:readyForNewWave()
	self.waveLevel = self.waveLevel + 1
	self.statusBar:setWaveLevel( self.waveLevel )
	self.minionMaster:sendWave( self.waveLevel )
	self:startPlacingPickupItems()
	print("Wave " .. self.waveLevel .. " at " .. gameValues.timeWarp .. "x speed.")
	--self.gameMap.player:setPosition( display.contentHeight - 600, display.contentWidth - 300 )
end

function _GameMaster:playerCellChanged( newX, newY )
	self:checkPickupItems( newX, newY )
end

function _GameMaster:checkPickupItems( x, y )
	if self.pickupItems[y][x] then
		self:useItem( self.pickupItems[y][x].itemType )

	end
	if self.pickupItems[y][x] then
		self.pickupItems[y][x]:cleanUp()
		self.pickupItems[y][x] = nil
	end
end

function _GameMaster:startPlacingPickupItems()
	local items = {gameValuesPickupItem.typeGoldCoin, gameValuesPickupItem.typeHpPack, gameValuesPickupItem.typeZapper}
	self.itemTimer = timer.performWithDelay( gameValues.itemDelay*(1/gameValues.timeWarp), 
		function()
			-- Place coin within gameValues.coinMaxSpawnDistance cells of player position
			local coinPos = self:findValidItemPosition( gameValues.coinMinSpawnDistance, gameValues.coinMaxSpawnDistance )		
			self:placeNewPickupItem( coinPos.x, coinPos.y, gameValuesPickupItem.typeGoldCoin)

			-- Place zapper/hpPack between Y and Z cells away from player position
			local powerUpPos = self:findValidItemPosition( gameValues.powerUpMinSpawnDistance, gameValues.powerUpMaxSpawnDistance)
			local powerUpItem = items[math.random(2,3)]
			self:placeNewPickupItem( powerUpPos.x, powerUpPos.y, powerUpItem)
			audio.play( sounds.soundPowerUpSpawned )
		end,
		0)
end

function _GameMaster:findValidItemPosition( minDistance, maxDistance)
	local x
	local y
	local count = 0
	repeat 
		x = self:findItemAxisPosition( 'x', minDistance, maxDistance ) 
		y = self:findItemAxisPosition( 'y', minDistance, maxDistance )

		count = count +1
	until self:validateItemPosition( x, y ) or count > 100

	return {x = x, y = y}
end

function _GameMaster:findItemAxisPosition( axis, minDistance, maxDistance )
	local playerPosition = self.gameMap:getPlayerCell()

	local sign = math.random( 2 )
	if sign == 2 then
		sign = -1
	end

	local dimensions = {x = self.gameMap.cellsHorizontally, y = self.gameMap.cellsVertically}
	local pos
	local count = 0
	repeat
		sign=sign*-1
		pos = playerPosition[axis] + (sign*math.random( minDistance, maxDistance ))
		count = count +1
	until ( pos >= 1 and pos<=dimensions[axis] ) or count > 100

	return pos
end

function _GameMaster:validateItemPosition( x, y )
	return not self.pickupItems[y][x]
end


function _GameMaster:placeNewPickupItem( x, y, type )
	local newItem = PickupItem:new( self.displayGroup, type, self.gameMap.cellWidth)
	newItem:setPosition( unpack(self.gameMap:gridToContentAreaMidCell( x, y )) )
	newItem:addListener( self )
	self.pickupItems[y][x] = newItem
end

function _GameMaster:useItem( itemType )
	if itemType == gameValuesPickupItem.typeGoldCoin then
		local amount
		
		if self.waveLevel < 5 then
			amount = gameValues.goldCoinAmountEarly
		else
			amount = gameValues.goldCoinAmountLate
		end

		self.creditAmount = self.creditAmount + amount
		self.statusBar:setCreditAmount( self.creditAmount )
		audio.play(sounds.soundPowerUpPickedUp)

		if self:canAffordBasicTower() then
			self.controlPanel:cleanUpNotEnoughCreditsOverlay()
		end

	elseif itemType == gameValuesPickupItem.typeZapper then
		self.minionMaster:damageMinions(gameValues.zapperAmount*self.waveLevel)
		audio.play(sounds.soundZapperUsed)

	elseif itemType == gameValuesPickupItem.typeHpPack then
		self.baseHealthPoints = self.baseHealthPoints + gameValues.hpPackAmount
		self.statusBar:setBaseHealthPoints(self.baseHealthPoints)
		audio.play(sounds.soundPowerUpPickedUp)
	end
end

function _GameMaster:cleanUpPickupItems()
	for y=1,self.gameMap.cellsVertically do
		for x = 1,self.gameMap.cellsHorizontally do
			if self.pickupItems[y][x] then
				self.pickupItems[y][x]:cleanUp()
				self.pickupItems[y][x] = nil
			end
		end
	end
end

function _GameMaster:setTimeWarp( percent )
	gameValues.timeWarp = gameValues.maxTimeWarp * percent
end

function _GameMaster:getTimeWarp( )
	return gameValues.timeWarp
end

function _GameMaster:canAffordBasicTower()
	return self.creditAmount >= gameValues.basicLevel1Cost
end

function _GameMaster:canAffordUpgrade( upgradeChoice, towerLevel )
	return self.creditAmount >= self:getUpgradeCost(upgradeChoice)
end

function _GameMaster:payForUpgrade( upgradeChoice, towerLevel )
	self.creditAmount = self.creditAmount - self:getUpgradeCost(upgradeChoice)
	self.statusBar:setCreditAmount(self.creditAmount)
	self.controlPanel:checkCreditAmount( self.creditAmount )
end

function _GameMaster:payForBasicTower()
	self.creditAmount = self.creditAmount - gameValues.basicLevel1Cost
	self.statusBar:setCreditAmount(self.creditAmount)
	self.controlPanel:checkCreditAmount( self.creditAmount )
end

function _GameMaster:getUpgradeCost( upgradeChoice )
	return gameValues[upgradeChoice .. 'Level' .. self.selectedTower.level+1 .. 'Cost']
end

function _GameMaster:getRefundValue( towerType )
	return gameValues[towerType .. 'Level' .. self.selectedTower.level .. 'Value']
end


function _GameMaster:createNewItem()
end

function _GameMaster:gameLost()
	self.baseHealthPoints = 0
	self.controlPanel:cleanUpTowerBuildingInterface()
	self:setGameState( gameValues.stateBaseDestroyed )
	self.controlPanel:createGameLostInterface( self.controlPanel.displayGroup )
	self:cleanUpPickupItems()
	self:pauseGame()
	audio.play( sounds.soundGameLost )
end

function _GameMaster:pauseGame()
	self.isGameLoopRunning = false
	timer.cancel( self.itemTimer )
end

function _GameMaster:resumeGame()
	self.isGameLoopRunning = true
end

function _GameMaster:isGameRunning()
	return self.isGameLoopRunning
end

function _GameMaster:decreaseBaseHealthPoints( amount )

	self.baseHealthPoints = self.baseHealthPoints - amount
	if self.baseHealthPoints <= 0 then
		self:gameLost()
	end
	self.statusBar:setBaseHealthPoints( self.baseHealthPoints )

end

function _GameMaster:setControlPanel( controlPanel )
	self.controlPanel = controlPanel
end

return _GameMaster

--[[
function _GameMaster:sendNextWave()
	local waveCountdown = gameValues.waveCountdownTime

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
--]]