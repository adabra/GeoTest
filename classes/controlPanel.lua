local Layout = require('libs.layout')
local Colors = require('libs.colors')
local widget = require('widget')
local strings = require('strings.game')
local VisualObject = require('classes.visualObject')
local gameValues = require('gameValues.controlPanel')
local gameValuesGameMaster = require('gameValues.gameMaster')
local gameValuesTower = require('gameValues.tower')

local _ControlPanel = {}

function _ControlPanel:new( displayGroup, gameMap, gameMaster, level )
	local controlPanel = { gameMap = gameMap, gameMaster = gameMaster, displayGroup = displayGroup, level = level}
	setmetatable( controlPanel, self )
	self.__index = self
	controlPanel:init()
	return controlPanel
end

function _ControlPanel:init()
	self.buttonWidth = Layout.controlPanelArea.width*0.33333
	self.buttonHeight = Layout.controlPanelArea.height*0.33333
	self:createBackground( self.displayGroup )
	self:createPathBuildingInterface( self.displayGroup )
	self.gameMap:addPlayerCellListener( self )
end

function _ControlPanel:playerCellChanged( newX, newY )
	self:cancelBuildingProcess()
end

function _ControlPanel:cancelBuildingProcess()
	if (self.towerButtons and self.towerButtons[1][1]) then
		self.gameMap:hideBuildPosBackground()

		for row=0,#self.towerButtons do
			for col=0,#self.towerButtons[row] do
				self.towerButtons[row][col].status = "idle"
				self.towerButtons[row][col]:setLabel("T")--self.towerButtons[row][col].status)
				self.towerButtonsOverlay[row][col]:setFillColor( unpack(Colors.cancelRed) )
			end
		end

		self.overlayGroup.alpha = 0
	end
end


function _ControlPanel:createBackground( displayGroup )
	self.background = display.newRect( displayGroup, Layout.controlPanelArea.centerX, 
		Layout.controlPanelArea.centerY, Layout.controlPanelArea.width, Layout.controlPanelArea.height )
	self.background:setFillColor( unpack( Colors.controlPanelGrey ) )
end

function _ControlPanel:createPathBuildingInterface( displayGroup )
	self.currentState = gameValues.statePathBuildingInterface
	self.pathBuildingOverlay = self:createMapOverlay( displayGroup, strings.pathBuildingInstructions, true )

	self.addVisualsButton = self:createButton( 
		displayGroup, 
		0, 1,
		strings.proceedToAddVisualsButton,
		function()
			self:cleanUpGameCreatorInterface()
			self:createAddVisualsInterface( displayGroup )
		end,
		Layout.controlPanelArea.width*0.5,
		Layout.controlPanelArea.height*0.5 
	)

	self.proceedToGameButton = self:createButton( 
		displayGroup,
		1, 1,
		strings.proceedToGameButton,
		function()
			if (self.gameMap:getPath():getLength() >= gameValues.minimumPathLength) then 
				self:cleanUpGameCreatorInterface()
				--self:createTowerBuildingInterface( displayGroup )
				self:createStartGameInterface( displayGroup )
				self.gameMaster:setPathBuildingAllowed( false )
			else
				if (not self.pathTooShortText) then
					local textOptions = {
						parent = displayGroup, 
						text = strings.pathTooShort, 
						x = Layout.controlPanelArea.centerX, 
						y = Layout.controlPanelArea.minY + Layout.controlPanelArea.height*0.25, 
						width = Layout.mapArea.width*0.95, 
						height = 0, 
						font = native.systemFont,
						align = "center" 
					}
					self.pathTooShortText = display.newText( textOptions )	
				end
			end
		end,
		Layout.controlPanelArea.width*0.5,
		Layout.controlPanelArea.height*0.5
	)

	self.quickGameButton = self:createButton(
		displayGroup,
		0,0,
		strings.quickGameButton,
		function()
			self:cleanUpGameCreatorInterface()
			local paths = {
				{
					{7,1},
					{7,2},
					{7,3},
					{6,3},
					{6,4},
					{6,5},
					{6,6},
					{6,7},
					{6,8},
					{6,9},
					{5,9},
					{5,10},
					{5,11},
					{4,11}
				},

				{
				},

				{
					{8,2},
					{7,2},
					{7,3},
					{7,4},
					{7,5},
					{6,5},
					{6,6},
					{6,7},
					{5,7},
					{5,8},
					{5,9},
					{5,10},
					{4,10},
				},
				
				{
					{6,8},
					{7,8},
					{7,9},
					{7,10},
					{7,11},
					{8,11},
					{9,11},
					{10,11},
					{11,11},
					{12,11},
					{13,11},
					{14,11},
					{15,11},


				},

				{
					{2,3},
					{3,3},
					{3,2},
					{4,2},
					{5,2},
					{6,2},
					{7,2},
					{7,3},
					{7,4},
					{8,4},
					{8,5},
				},

				{

				},

				{

				}

			}
			for k,tile in pairs(paths[self.level]) do
				self.gameMap:updatePath( tile[1], tile[2], true )
			end
			self:createStartGameInterface( self.displayGroup )
		end,
		Layout.controlPanelArea.width*0.5,
		Layout.controlPanelArea.height*0.5
		)

	self.gameMaster:setPathBuildingAllowed( true )
	--self:createDifficultySlider( displayGroup )
	--self:createDifficultySliderText( displayGroup )
end

function _ControlPanel:cleanUpGameCreatorInterface()
	print("CLEANING UP Game Creator Interface")
	if (self.pathTooShortText) then
		self.pathTooShortText:removeSelf( )
		self.pathTooShortText = nil
	end

	self:cleanUpMapOverlay( self.pathBuildingOverlay )

	self.addVisualsButton:removeSelf()
	self.addVisualsButton = nil

	self.proceedToGameButton:removeSelf( )
	self.proceedToGameButton = nil	

	self.quickGameButton:removeSelf( )
	self.quickGameButton = nil
end

function _ControlPanel:createStartGameInterface( displayGroup )
	self.currentState = gameValues.stateStartGameInterface
	self:createStartGameButton( displayGroup )
	self.startGameOverlay = self:createMapOverlay( displayGroup, strings.startGameOverlayText, false )
	self:createDifficultySlider( displayGroup )
	self:createDifficultySliderText( displayGroup )
	self.gameMap:showPlayer()
end

function _ControlPanel:cleanUpStartGameInterface()
	print("CLEANING UP Start Game Interface")
	self:cleanUpMapOverlay( self.startGameOverlay )
	self.startGameButton:removeSelf( )
	self.startGameButton = nil
	
	if self.difficultySlider then
		self.difficultySlider:removeSelf( )
		self.difficultySlider = nil

		self:cleanUpDifficultySliderText()
	end

end

function _ControlPanel:createStartGameButton( displayGroup )
	self.startGameButton = self:createButton(
		displayGroup,
		0,1,
		strings.startGameButton,
		function()
			self:cleanUpStartGameInterface()
			self.gameMaster:startGame()
		end,
		Layout.controlPanelArea.width,
		Layout.controlPanelArea.height/2 )
end

function _ControlPanel:createRestartGameButton( displayGroup )
	self.restartGameButton = self:createButton(
		displayGroup,
		0,1,
		strings.restartGameButton,
		function()
			self:cleanUpGameLostInterface()
			self.gameMaster:restartGame()
		end,
		Layout.controlPanelArea.width,
		Layout.controlPanelArea.height/2)
end

function _ControlPanel:createGameCountdownInterface( displayGroup )
	self.currentState = gameValues.stateGameCountdownInterface

	local options = {
		parent = displayGroup,
		text = strings.gameCountdownText .. gameValuesGameMaster.gameCountdownTime .. '!',
		x = Layout.controlPanelArea.centerX,
		y = Layout.controlPanelArea.centerY,
		width = Layout.controlPanelArea.width,
		height = 0,
		font = native.systemFont,
		align = "center"
	}
	self.gameCountdownText = display.newText( options )
end

function _ControlPanel:cleanUpGameCountdownInterface()
	self.gameCountdownText:removeSelf( )
	self.gameCountdownText = nil
end


function _ControlPanel:createWaveCountdownInterface( displayGroup )
	self:cleanUpWaveCountdownInterface()
	self.currentState = gameValues.stateWaveCountdownInterface
	if not self.startWaveButton then
		if not self.nextWaveText then
			self:createNextWaveText( displayGroup )
			self:createSellAndUpgradeInstructionsOverlay( displayGroup )
			self:createDifficultySlider( displayGroup )
			self:createDifficultySliderText( displayGroup )
		end
		self:createStartWaveButton( displayGroup )
	end
end

function _ControlPanel:cleanUpWaveCountdownInterface()
	print("CLEANING UP Wave Countdown Interface")
	if self.nextWaveText then
		self.nextWaveText:removeSelf( )
		self.nextWaveText = nil
	end

	if self.difficultySlider then
		self.difficultySlider:removeSelf( )
		self.difficultySlider = nil

		self:cleanUpDifficultySliderText()
	end

	if self.sellAndUpgradeInstructionsOverlay then
		self:cleanUpMapOverlay( self.sellAndUpgradeInstructionsOverlay )
		--self.sellAndUpgradeInstructions:removeSelf( )
		--self.sellAndUpgradeInstructions = nil
	end

	if self.startWaveButton then
		self:cleanUpStartWaveButton()
	end
end

function _ControlPanel:createDifficultySlider( displayGroup )

	-- Slider listener
	local function sliderListener( event )
		if event.value < 10 then
			event.value = 10
		end
	    self.gameMaster:setTimeWarp( event.value/100 )
	end

	self.difficultySlider = widget.newSlider(
	    {
	    	x = Layout.controlPanelArea.minX + Layout.controlPanelArea.width*0.75,
	    	y = Layout.controlPanelArea.minY + Layout.controlPanelArea.height*0.25,
	        width = Layout.controlPanelArea.width*0.4,
	        value = self.gameMaster:getTimeWarp()*50,
	        listener = sliderListener
	    }
	)
end

function _ControlPanel:createDifficultySliderText( displayGroup )
	local options = {
		parent = displayGroup,
		text = gameValuesGameMaster.minTimeWarp .. 'x',
		x = Layout.controlPanelArea.width*0.58,
		y = Layout.controlPanelArea.minY + Layout.controlPanelArea.height*0.4,
		width = 0,
		height = 0,
		font = native.systemFont,
		fontSize = Layout.controlPanelArea.width*0.04,
		align = "center"
	}

	self.difficultySliderMinText = display.newText( options )

	options.text = gameValuesGameMaster.midTimeWarp .. 'x'
	options.x = Layout.controlPanelArea.width*0.75

	self.difficultySliderMidText = display.newText( options )

	options.text = gameValuesGameMaster.maxTimeWarp .. 'x'
	options.x = Layout.controlPanelArea.width*0.95

	self.difficultySliderMaxText = display.newText( options )
end

function _ControlPanel:cleanUpDifficultySliderText(  )
	self.difficultySliderMaxText:removeSelf( )
	self.difficultySliderMaxText = nil

	self.difficultySliderMidText:removeSelf( )
	self.difficultySliderMidText = nil

	self.difficultySliderMinText:removeSelf( )
	self.difficultySliderMinText = nil
end

function _ControlPanel:createNextWaveText( displayGroup )
	local options = {
		parent = displayGroup,
		text = strings.nextWaveText .. "\n" .. gameValuesGameMaster.waveCountdownTime,
		x = Layout.controlPanelArea.width*0.25,
		y = Layout.controlPanelArea.minY + Layout.controlPanelArea.height*0.25,
		width = Layout.controlPanelArea.width/2,
		height = 0,
		font = native.systemFont,
		align = "center"
	}
	self.nextWaveText = display.newText( options )
end


function _ControlPanel:updateNextWaveText( text )
	if self.nextWaveText then
		self.nextWaveText.text = text
	end
end

function _ControlPanel:updateWaveCountdown( countdown )
	if self.gameCountdownText then
		self.gameCountdownText.text = strings.gameCountdownText .. countdown .. '!'
	end

	if self.nextWaveText then
		self.nextWaveText.text = strings.nextWaveText .. "\n" .. countdown
	end

	if self.startWaveButton then
		self.startWaveButton:setLabel( strings.startWaveButton .. countdown )
	end
end

function _ControlPanel:createSellAndUpgradeInstructionsOverlay( displayGroup )
	if self.straightFromWave then
		self.sellAndUpgradeInstructionsOverlay = self:createMapOverlay( 
			displayGroup, 
			strings.sellAndUpgradeInstructions, 
			true, 
			true)
	end
	--[[
	local options = {
		parent = displayGroup,
		text = strings.sellAndUpgradeInstructions,
		x = Layout.controlPanelArea.width*0.75,
		y = Layout.controlPanelArea.minY + Layout.controlPanelArea.height*0.25,
		width = Layout.controlPanelArea.width/2,
		height = 0,
		font = native.systemFont,
		align = "center"
	}
	self.sellAndUpgradeInstructions = display.newText( options )
	--]]
end

function _ControlPanel:createStartWaveButton( displayGroup )
	self.startWaveButton = self:createButton(
		displayGroup,
		0,1,
		strings.startWaveButton,
		function()
			self:cleanUpWaveCountdownInterface()
			--self:cleanUpStartWaveButton()
			--self:createSellAndUpgradeInterface( displayGroup )
			--self:createTowerBuildingInterface( displayGroup )
			self.gameMaster:skipWaveCountdown()
		end,
		Layout.controlPanelArea.width,
		Layout.controlPanelArea.height/2,
		true)
end

function _ControlPanel:cleanUpStartWaveButton()
	if self.startWaveButton then
		self:cleanUpButtonIcon( self.startWaveButton )
		self.startWaveButton:removeSelf()
		self.startWaveButton = nil
	end
end

function _ControlPanel:createSellAndUpgradeInterface( displayGroup )
	self.currentState = gameValues.stateSellAndUpgradeInterface
	if (self.gameMaster.selectedTower.level < 4) then
	self.upgradeTowerButton = self:createButton(
		displayGroup,
		0,1,
		strings.upgradeTowerButton,
		function()
			self:cleanUpSellAndUpgradeInterface()
			print (self.gameMaster.selectedTower.towerType)
			if (self.gameMaster.selectedTower.towerType == gameValues.basic) then
				self:createUpgradeTowerInterface( displayGroup )	
			else 
				self:createConfirmUpgradeInterface( displayGroup, self.gameMaster.selectedTower.towerType )
			end
			
			
		end,
		Layout.controlPanelArea.width/2,
		Layout.controlPanelArea.height/2
		)
	else
		self.upgradeTowerButton = self:createButton(
			displayGroup,
			0,1,
			strings.upgradeTowerUnavailable,
			function() end,
			Layout.controlPanelArea.width/2,
			Layout.controlPanelArea.height/2
		)
		self.upgradeTowerButton:setEnabled( false )
	end

	local value = self:getRefundValue( self.gameMaster.selectedTower )
	self.sellTowerButton = self:createButton(
		displayGroup,
		1,1,
		strings.sellTowerButton .. ' (' .. value .. ')',
		function()
			self:cleanUpSellAndUpgradeInterface()
			self:createSellTowerInterface( displayGroup, value )
		end,
		Layout.controlPanelArea.width/2,
		Layout.controlPanelArea.height/2,
		true
		)
end

function _ControlPanel:getRefundValue( tower )
	return gameValuesGameMaster[ tower.towerType .. 'Level' .. tower.level .. 'Value']
end

function _ControlPanel:getUpgradeCost( tower )
	if tower.towerType ~= gameValues.basic then
		return gameValuesGameMaster[ tower.towerType .. 'Level' .. tower.level+1 .. 'Cost']
	else
		return gameValuesGameMaster.damageLevel2Cost
	end
end

function _ControlPanel:cleanUpSellAndUpgradeInterface( )
	print("CLEANING UP Sell And Upgrade Interface")
	self.upgradeTowerButton:removeSelf()
	self.upgradeTowerButton = nil

	self:cleanUpButtonIcon( self.sellTowerButton )
	self.sellTowerButton:removeSelf( )
	self.sellTowerButton = nil
end

function _ControlPanel:createUpgradeTowerInterface( displayGroup )
	self.currentState = gameValues.stateUpgradeTowerInterface
	local function upgradeButton( upgradeChoice )
		self:cleanUpUpgradeTowerInterface()
		self:createConfirmUpgradeInterface( displayGroup, upgradeChoice )
	end

	self.upgradeDamageButton = self:createButton(
		displayGroup,
		0,1,
		strings.upgradeDamage .. '\n(' .. gameValuesGameMaster.damageLevel2Cost .. ')',
		function()
			upgradeButton( gameValues.upgradeDamage )
		end,
		Layout.controlPanelArea.width/3,
		Layout.controlPanelArea.height/2,
		true
		)

	self.upgradeSlowButton = self:createButton(
		displayGroup,
		1,1,
		strings.upgradeSlow .. '\n(' .. gameValuesGameMaster.slowLevel2Cost .. ')',
		function()
			upgradeButton( gameValues.upgradeSlow )
		end,
		Layout.controlPanelArea.width/3,
		Layout.controlPanelArea.height/2,
		true
		)

	self.upgradeRangeButton = self:createButton(
		displayGroup,
		2,1,
		strings.upgradeRange .. '\n(' .. gameValuesGameMaster.rangeLevel2Cost .. ')',
		function()
			upgradeButton( gameValues.upgradeRange )
		end,
		Layout.controlPanelArea.width/3,
		Layout.controlPanelArea.height/2,
		true
		)
end

function _ControlPanel:cleanUpUpgradeTowerInterface( )
	print("CLEANING UP Upgrade Tower Interface")
	self:cleanUpButtonIcon( self.upgradeDamageButton )
	self.upgradeDamageButton:removeSelf( )
	self.upgradeDamageButton = nil

	self:cleanUpButtonIcon( self.upgradeRangeButton )
	self.upgradeRangeButton:removeSelf( )
	self.upgradeRangeButton = nil

	self:cleanUpButtonIcon( self.upgradeSlowButton )
	self.upgradeSlowButton:removeSelf( )
	self.upgradeSlowButton = nil
end

function _ControlPanel:createSellTowerInterface( displayGroup, value )
	self.currentState = gameValues.stateSellTowerInterface
	self.cancelSaleButton = self:createButton(
		displayGroup,
		0,1,
		strings.cancelSaleButton,
		function()
			self:cleanUpSellTowerInterface()
			self:createWaveCountdownInterface( displayGroup )
			self.gameMaster:deselectTower()
		end,
		Layout.controlPanelArea.width/2,
		Layout.controlPanelArea.height/2
		)

	self.confirmSaleButton = self:createButton(
		displayGroup,
		1,1,
		strings.confirmSaleButton .. ' (' .. value .. ')',
		function()
			self:cleanUpSellTowerInterface()
			self:createWaveCountdownInterface( displayGroup )
			self.gameMaster:sellSelectedTower()
		end,
		Layout.controlPanelArea.width/2,
		Layout.controlPanelArea.height/2
		)
end

function _ControlPanel:cleanUpSellTowerInterface( )
	print("CLEANING UP Sell Tower Interface")
	self.cancelSaleButton:removeSelf( )
	self.cancelSaleButton = nil

	self:cleanUpButtonIcon( self.confirmSaleButton )
	self.confirmSaleButton:removeSelf( )
	self.confirmSaleButton = nil
end

function _ControlPanel:createConfirmUpgradeInterface( displayGroup, upgradeChoice )
	self.currentState = gameValues.stateConfirmUpgradeInterface
	self.cancelUpgradeButton = self:createButton(
		displayGroup,
		0,1,
		strings.cancelUpgradeButton,
		function()
			self:cleanUpConfirmUpgradeInterface()
			self:createWaveCountdownInterface( displayGroup )
			self.gameMaster:deselectTower()
		end,
		Layout.controlPanelArea.width/2,
		Layout.controlPanelArea.height/2
		)

	self.confirmUpgradeButton = self:createButton(
		displayGroup,
		1,1,
		strings.confirmUpgradeButton .. ' (' .. self:getUpgradeCost( self.gameMaster.selectedTower ) .. ')' ,
		function()
			self:cleanUpConfirmUpgradeInterface()
			self:createWaveCountdownInterface( displayGroup )
			self.gameMaster:upgradeSelectedTower( upgradeChoice )
		end,
		Layout.controlPanelArea.width/2,
		Layout.controlPanelArea.height/2,
		true
		)
end

function _ControlPanel:cleanUpConfirmUpgradeInterface( )
	print("CLEANING UP Confirm Upgrade Interface")
	self.cancelUpgradeButton:removeSelf()
	self.cancelUpgradeButton = nil

	self.confirmUpgradeButton:removeSelf()
	self.confirmUpgradeButton = nil
end


function _ControlPanel:createGameLostInterface( displayGroup )
	self.currentState = gameValues.stateGameLostInterface
	self.gameLostOverlay = self:createMapOverlay( displayGroup, strings.baseDestroyed, false )
	self:createRestartGameButton( displayGroup )
end

function _ControlPanel:cleanUpGameLostInterface()
	print("CLEANING UP Game Lost Interface")
	self:cleanUpMapOverlay( self.gameLostOverlay )
	self.restartGameButton:removeSelf( )
	self.restartGameButton = nil
end

function _ControlPanel:createMapOverlay( displayGroup, text, tapToRemove, spawnIfTrue)
	local overlayBackground = display.newRect( displayGroup, Layout.mapArea.centerX, Layout.mapArea.centerY, Layout.mapArea.width, Layout.mapArea.height )
	overlayBackground:setFillColor( 0, 0, 0 )
	overlayBackground.alpha = 0.5


	local overlayTextOptions = {
		parent = displayGroup, 
		text = text, 
		x = Layout.mapArea.centerX, 
		y = Layout.mapArea.centerY, 
		width = Layout.mapArea.width*0.95, 
		height = 0, 
		font = native.systemFont,
		align = "center"
	}

	local overlayText = display.newText( overlayTextOptions )
	local overlay = {background = overlayBackground, text = overlayText}

	if (tapToRemove) then
		overlayBackground:addEventListener("tap", function() 
			self:cleanUpMapOverlay( overlay )
			if spawnIfTrue then
				self.straightFromWave = false
			end 
			return true 
			end )
	end

	return overlay
end

function _ControlPanel:cleanUpMapOverlay( mapOverlay )
	if (mapOverlay.background) then
		mapOverlay.background:removeSelf( )
		mapOverlay.background = nil
		mapOverlay.text:removeSelf( )
		mapOverlay.text = nil
	end
end


function _ControlPanel:createAddVisualsInterface( displayGroup )
	self.currentState = gameValues.stateAddVisualsInterface
	self.addVisualsOverlay = self:createMapOverlay( displayGroup, strings.addVisualsInstructions, true)

	self.backToPathBuildingInterfaceButton = self:createButton(
		displayGroup,
		0,0,
		strings.backToPathBuildingInterfaceButton,
		function()
			self:cleanUpAddVisualsInterface()
			self:createPathBuildingInterface( displayGroup )
			self:cleanUpMapOverlay( self.pathBuildingOverlay )
		end
	)

	local visualObjectTypes = VisualObject:getTypes()
	self.visualObjects = {}
	local index = 1
	for y=0,2 do
		for x=0,2 do
			if not(y == 0 and x == 0) then
				local visualObject = VisualObject:new( displayGroup, self.gameMap.backgroundGroup, visualObjectTypes[index] )
				table.insert(self.visualObjects, visualObject)
				self:placeVisualObject(visualObject, x, y )
				index = index + 1
			end
		end
	end
end

function _ControlPanel:cleanUpAddVisualsInterface()
	print("CLEANING UP Add Visuals Interface")
	self:cleanUpMapOverlay( self.addVisualsOverlay )

	self.backToPathBuildingInterfaceButton:removeSelf( )
	self.backToPathBuildingInterfaceButton = nil

	for i=1,8 do
		self.visualObjects[i].sprite:removeSelf( )
		self.visualObjects[i].sprite = nil
		self.visualObjects[i] = nil
	end
end


function _ControlPanel:createTowerBuildingInterface( displayGroup )
	print("CREATING TOWER BUILDING INTERFACE YEAH")
	self.currentState = gameValues.stateTowerBuildingInterface
	self.towerButtonsOverlay = {}
	self.towerButtons = {}
	self.topGroup = display.newGroup( )
	self.overlayGroup = display.newGroup()
	self.overlayGroup.alpha = 0.5
	self.topGroup:insert( self.overlayGroup )
	
	for y=0,2 do
		self.towerButtonsOverlay[y] = {}
		self.towerButtons[y] = {}
		for x=0,2 do
			self.towerButtons[y][x] = self:createTowerBuildingButton( displayGroup, x, y, x .. "," .. y )
			self.towerButtonsOverlay[y][x] = display.newRect( self.overlayGroup, 
				Layout.controlPanelArea.minX+(x*self.buttonWidth),
				Layout.controlPanelArea.minY+(y*self.buttonHeight),
				self.buttonWidth, 
				self.buttonHeight )
			self.towerButtonsOverlay[y][x].anchorX = 0
			self.towerButtonsOverlay[y][x].anchorY = 0
			self.towerButtonsOverlay[y][x]:setFillColor( unpack(Colors.cancelRed) )
		end
		self.overlayGroup.alpha = 0
	end

	self:checkCreditAmount( self.gameMaster.creditAmount )
end

function _ControlPanel:cleanUpTowerBuildingInterface()
	print("CLEANING UP Tower Building Interface")
	for y=0,#self.towerButtons do
		for x=0,#self.towerButtons[y] do

			if self.towerButtons[y][x] then
				self.towerButtons[y][x]:removeSelf( )
				self.towerButtons[y][x] = nil

				self.towerButtonsOverlay[y][x]:removeSelf( )
				self.towerButtonsOverlay[y][x] = nil
			end
		end
	end	
	self:cleanUpNotEnoughCreditsOverlay()
end

function _ControlPanel:checkCreditAmount( amount )
	if not self.gameMaster:canAffordBasicTower() then
		if not self.notEnoughCreditsOverlay then
			self.notEnoughCreditsOverlay = display.newRect( self.topGroup, 
				Layout.controlPanelArea.centerX, 
				Layout.controlPanelArea.centerY, 
				Layout.controlPanelArea.width, 
				Layout.controlPanelArea.height )
			self.notEnoughCreditsOverlay:setFillColor( unpack(Colors.cancelRed) )
			self.notEnoughCreditsOverlay.alpha = 0.3
			self:towerButtonsSetEnabled(false)
		end
	end
end

function _ControlPanel:cleanUpNotEnoughCreditsOverlay()
	if self.notEnoughCreditsOverlay then
		self.notEnoughCreditsOverlay:removeSelf()
		self.notEnoughCreditsOverlay = nil
		self:towerButtonsSetEnabled( true )
	end
end

function _ControlPanel:createTowerBuildingButton( displayGroup, x, y, label )
	
	local button
	local label
	local function onRelease()

		if (button.status  == "idle" ) then
			button.status = "pressed"
			button:setLabel("T")--button.status)
			self.overlayGroup.alpha = 0.3
			self.towerButtonsOverlay[y][x]:setFillColor( unpack(Colors.buildPosGreen) )
			self.gameMap:updateBuildPosBackground(x-1, y-1)
			
			for row=0,#self.towerButtons do
				for col=0,#self.towerButtons[row] do
					if ( not (x==col and y==row ) ) then 
						self.towerButtons[row][col].status = "cancel"
						self.towerButtons[row][col]:setLabel("X")--self.towerButtons[row][col].status)
					end
				end
			end

		elseif (button.status == "pressed") then
			label = ""
			self.towerButtonsOverlay[y][x]:setFillColor( unpack(Colors.cancelRed) )
			self.overlayGroup.alpha=0
			if( self.gameMaster:canAffordBasicTower()) then
				self.gameMap:buildTower( x-1, y-1 )
			end
			self.gameMap:hideBuildPosBackground()

			for row=0,#self.towerButtons do
				for col=0,#self.towerButtons[row] do
					self.towerButtons[row][col].status = "idle"
					self.towerButtons[row][col]:setLabel("T")--self.towerButtons[row][col].status)
				end
			end

		elseif (button.status == "cancel") then
			self:cancelBuildingProcess()
		end
	end
	
	button = self:createButton( displayGroup, x, y, "BUILD", onRelease )
	button:setLabel("T")--button.status)
	
	return button
end

function _ControlPanel:towerButtonsSetEnabled( areEnabled )
	for y=0,#self.towerButtons do
		for x=0,#self.towerButtons[y] do

			if self.towerButtons[y][x] then
				self.towerButtons[y][x]:setEnabled( areEnabled )
			end

		end
	end
end

function _ControlPanel:createButton( displayGroup, x, y, label, onRelease, buttonWidth, buttonHeight, icon )
	local buttonWidth = buttonWidth or self.buttonWidth
	local buttonHeight = buttonHeight or self.buttonHeight
	local button = widget.newButton( {
		x = Layout.controlPanelArea.minX+(x*buttonWidth),
		y = Layout.controlPanelArea.minY+(y*buttonHeight),
		-- Visual options
		shape = "rect",
		fillColor = { default = Colors.controlPanelGrey, over = Colors.controlPanelButtonDown },
		strokeColor = { default= Colors.controlPanelButtonStroke, over = Colors.controlPanelButtonStroke },
		strokeWidth = buttonWidth*0.01,
		width = buttonWidth*0.985,
		height = buttonHeight*0.985,
		label = label,
		fontSize = 40,
		labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
		emboss = true,
		--Behavior
		onRelease = onRelease
		} )

	button.anchorX = 0
	button.anchorY = 0
	button.status = "idle"
	--self:updateNextXY()
	displayGroup:insert(button)
	-- Icon
	if icon then
		self:placeButtonIcon( button )
	end
	return button
end	

function _ControlPanel:placeButtonIcon( button )
	button.buttonIcon = display.newImageRect( 
		self.displayGroup, 
		gameValues.buttonIconImagePath, 
		Layout.statusBarArea.height*0.7, 
		Layout.statusBarArea.height*0.7 )
	button.buttonIcon.y = button.y + button.height/2
	button.buttonIcon.x = button.x + button.width*0.9
	--button.buttonIcon.x = display.contentCenterX
	--button.buttonIcon.y = display.contentCenterY
end

function _ControlPanel:cleanUpButtonIcon( button )
	if button.buttonIcon then
		button.buttonIcon:removeSelf( )
		button.buttonIcon = nil
	end
end


function _ControlPanel:placeVisualObject( visualObject, x, y, imageBoxWidth, imageBoxHeight )
	local imageBoxWidth = imageBoxWidth or self.buttonWidth
	local imageBoxHeight = imageBoxHeight or self.buttonHeight
	visualObject:setX( Layout.controlPanelArea.minX+((x+0.5)*imageBoxWidth) )
	visualObject:setY( Layout.controlPanelArea.minY+((y+0.5)*imageBoxHeight) )
	visualObject:setBasePosition( visualObject:getX(), visualObject:getY() )
end

function _ControlPanel:cleanUpCurrentInterface()
	if self.currentState == gameValues.statePathBuildingInterface then
		self:cleanUpGameCreatorInterface()
	elseif self.currentState == gameValues.stateStartGameInterface then
		self:cleanUpStartGameInterface()
	elseif self.currentState == gameValues.stateAddVisualsInterface then
		self:cleanUpAddVisualsInterface()
	elseif self.currentState == gameValues.stateGameCountdownInterface then
		self:cleanUpGameCountdownInterface()
	elseif self.currentState == gameValues.stateWaveCountdownInterface then
		self:cleanUpWaveCountdownInterface()
	elseif self.currentState == gameValues.stateSellAndUpgradeInterface then
		self:cleanUpSellAndUpgradeInterface()
	elseif self.currentState == gameValues.stateUpgradeTowerInterface then
		self:cleanUpUpgradeTowerInterface()
	elseif self.currentState == gameValues.stateSellTowerInterface then
		self:cleanUpSellTowerInterface()
	elseif self.currentState == gameValues.stateConfirmUpgradeInterface then
		self:cleanUpConfirmUpgradeInterface()
	elseif self.currentState == gameValues.stateGameLostInterface then
		self:cleanUpGameLostInterface()
	end
end

function _ControlPanel:readyForNewWave()
	self:cleanUpCurrentInterface()
	
	if self.sellAndUpgradeInstructions then
		self:cleanUpWaveCountdownInterface()
	end

	if not self.towerButton or self.towerButtons[1][1] then
		self:createTowerBuildingInterface( self.displayGroup )
	end
	
end

--[[

function _ControlPanel:createTowerButton( displayGroup )
	local function onRelease()
		self.gameMap:buildTower()
	end
	self.towerButton = self:createButton( displayGroup, self.nextX, self.nextY, strings.towerButton, onRelease)
end

function _ControlPanel:createMinionButton( displayGroup )
	local function onRelease()
		self.gameMaster:spawnMinion( 'basic')
		self.gameMaster:sendNextMinion()
	end
	self.pathButton = self:createButton( displayGroup, self.nextX, self.nextY, strings.minionButton, onRelease)
end

function _ControlPanel:updateNextXY()
	self.nextX = (self.nextX+1)%3
	if (self.nextX == 0 ) then
		if (self.nextY < 3 ) then
			self.nextY = self.nextY+1
		else 
			print("MAXIMUM NUMBER OF BUTTONS IN CONTROL PANEL REACHED, OVERWRITING")
		end
	end
end
--]]

return _ControlPanel