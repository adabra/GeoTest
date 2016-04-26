local Layout = require('libs.layout')
local Colors = require('libs.colors')
local widget = require('widget')
local strings = require('strings.game')
local VisualObject = require('classes.visualObject')
local gameValues = require('gameValues.controlPanel')
local gameValuesGameMaster = require('gameValues.gameMaster')

local _ControlPanel = {}

function _ControlPanel:new( displayGroup, gameMap, gameMaster )
	local controlPanel = { gameMap = gameMap, gameMaster = gameMaster, displayGroup = displayGroup}
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
	if (self.towerButtons) then
		self.gameMap:hideBuildPosBackground()

		for row=0,#self.towerButtons do
			for col=0,#self.towerButtons[row] do
				self.towerButtons[row][col].status = "idle"
				self.towerButtons[row][col]:setLabel(self.towerButtons[row][col].status)
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

	self.gameMaster:setPathBuildingAllowed( true )
end

function _ControlPanel:cleanUpGameCreatorInterface()
	if (self.pathTooShortText) then
		self.pathTooShortText:removeSelf( )
		self.pathTooShortText = nil
	end

	self:cleanUpMapOverlay( self.pathBuildingOverlay )

	self.addVisualsButton:removeSelf()
	self.addVisualsButton = nil

	self.proceedToGameButton:removeSelf()
	self.proceedToGameButton = nil
end

function _ControlPanel:createStartGameInterface( displayGroup )
	self.currentState = gameValues.stateStartGameInterface
	self:createDifficultyPicker( displayGroup )
	self:createStartGameButton( displayGroup )
	self.startGameOverlay = self:createMapOverlay( displayGroup, strings.startGameOverlayText, false )
	self.gameMap:showPlayer()
end

function _ControlPanel:cleanUpStartGameInterface()
	self:cleanUpMapOverlay( self.startGameOverlay )
	self.startGameButton:removeSelf( )
	self.startGameButton = nil
end

function _ControlPanel:createDifficultyPicker( displayGroup )

end

function _ControlPanel:createStartGameButton( displayGroup )
	self.startGameButton = self:createButton(
		displayGroup,
		0,1,
		strings.startGameButton,
		function()
			self:cleanUpStartGameInterface()
			--self:createTowerBuildingInterface( displayGroup )
			self.gameMaster:startGame()
			self:createWaveCountdownInterface( displayGroup )
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
		end,
		Layout.controlPanelArea.width,
		Layout.controlPanelArea.height/2)
end

function _ControlPanel:createWaveCountdownInterface( displayGroup )
	self.currentState = gameValues.stateWaveCountdownInterface
	if not self.nextWaveText then
		self:createNextWaveText( displayGroup )
		self:createSellAndUpgradeInstructions( displayGroup )
	end
	self:createStartWaveButton( displayGroup )
end

function _ControlPanel:cleanUpWaveCountdownInterface()
	self.nextWaveText:removeSelf( )
	self.nextWaveText = nil

	self.sellAndUpgradeInstructions:removeSelf( )
	self.sellAndUpgradeInstructions = nil

	if self.startWaveButton then
		self:cleanUpStartWaveButton()	
	end
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

function _ControlPanel:createSellAndUpgradeInstructions( displayGroup )
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
			self:createTowerBuildingInterface( displayGroup )
			self.gameMaster:skipWaveCountdown()
		end,
		Layout.controlPanelArea.width,
		Layout.controlPanelArea.height/2)
end

function _ControlPanel:cleanUpStartWaveButton()
	self.startWaveButton:removeSelf( )
	self.startWaveButton = nil
end

function _ControlPanel:createSellAndUpgradeInterface( displayGroup )
	self.currentState = gameValues.stateSellAndUpgradeInterface
	self.upgradeTowerButton = self:createButton(
		displayGroup,
		0,1,
		strings.upgradeTowerButton,
		function()
			self:cleanUpSellAndUpgradeInterface()
			self:createUpgradeTowerInterface( displayGroup )
		end,
		Layout.controlPanelArea.width/2,
		Layout.controlPanelArea.height/2
		)
	self.sellTowerButton = self:createButton(
		displayGroup,
		1,1,
		strings.sellTowerButton,
		function()
			self:cleanUpSellAndUpgradeInterface()
			self:createSellTowerInterface( displayGroup )
		end,
		Layout.controlPanelArea.width/2,
		Layout.controlPanelArea.height/2
		)
end

function _ControlPanel:cleanUpSellAndUpgradeInterface( )
	self.upgradeTowerButton:removeSelf()
	self.upgradeTowerButton = nil

	self.sellTowerButton:removeSelf()
	self.sellTowerButton = nil
end

function _ControlPanel:createUpgradeTowerInterface( displayGroup )
	self.currentState = gameValues.stateUpgradeTowerInterface
	local function upgradeButton( upgradeChoice )
		self:cleanUpUpgradeTowerInterface()
		self:createConfirmUpgradeInterface( displayGroup, upgradeChoice )
	end

	self.upgrade1Button = self:createButton(
		displayGroup,
		0,1,
		strings.upgrade1,
		function()
			upgradeButton( gameValues.upgrade1 )
		end,
		Layout.controlPanelArea.width/3,
		Layout.controlPanelArea.height/2
		)

	self.upgrade2Button = self:createButton(
		displayGroup,
		1,1,
		strings.upgrade2,
		function()
			upgradeButton( gameValues.upgrade2 )
		end,
		Layout.controlPanelArea.width/3,
		Layout.controlPanelArea.height/2
		)

	self.upgrade3Button = self:createButton(
		displayGroup,
		2,1,
		strings.upgrade3,
		function()
			upgradeButton( gameValues.upgrade3 )
		end,
		Layout.controlPanelArea.width/3,
		Layout.controlPanelArea.height/2
		)
end

function _ControlPanel:cleanUpUpgradeTowerInterface( )
	self.upgrade1Button:removeSelf( )
	self.upgrade1Button = nil

	self.upgrade2Button:removeSelf( )
	self.upgrade2Button = nil

	self.upgrade3Button:removeSelf( )
	self.upgrade3Button = nil
end

function _ControlPanel:createSellTowerInterface( displayGroup )
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
		strings.confirmSaleButton,
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
	self.cancelSaleButton:removeSelf( )
	self.cancelSaleButton = nil

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
		strings.confirmUpgradeButton,
		function()
			self:cleanUpConfirmUpgradeInterface()
			self:createWaveCountdownInterface( displayGroup )
			self.gameMaster:upgradeSelectedTower( upgradeChoice )
		end,
		Layout.controlPanelArea.width/2,
		Layout.controlPanelArea.height/2
		)
end

function _ControlPanel:cleanUpConfirmUpgradeInterface( )
	self.cancelUpgradeButton:removeSelf( )
	self.cancelUpgradeButton = nil

	self.confirmUpgradeButton:removeSelf( )
	self.confirmUpgradeButton = nil
end


function _ControlPanel:createGameLostInterface( displayGroup )
	self.currentState = gameValues.stateGameLostInterface
	self.gameLostOverlay = self:createMapOverlay( displayGroup, strings.baseDestroyed, false )
	self:createRestartGameButton( displayGroup )
end

function _ControlPanel:cleanUpGameLostInterface()
	self:cleanUpMapOverlay( self.gameLostOverlay )
	self.restartGameButton:removeSelf( )
	self.restartGameButton = nil
end

function _ControlPanel:createMapOverlay( displayGroup, text, tapToRemove)
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
		overlayBackground:addEventListener("tap", function() self:cleanUpMapOverlay( overlay ) return true end )
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
	self.overlayGroup = display.newGroup()
	self.overlayGroup.alpha = 0.5
	--displayGroup:insert( self.overlayGroup )
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
end

function _ControlPanel:cleanUpTowerBuildingInterface()
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
end

function _ControlPanel:createTowerBuildingButton( displayGroup, x, y, label )
	
	local button
	local function onRelease()

		if (button.status  == "idle" ) then
			button.status = "pressed"
			button:setLabel(button.status)
			self.overlayGroup.alpha = 0.3
			self.towerButtonsOverlay[y][x]:setFillColor( unpack(Colors.buildPosGreen) )
			self.gameMap:updateBuildPosBackground(x-1, y-1)
			
			for row=0,#self.towerButtons do
				for col=0,#self.towerButtons[row] do
					if ( not (x==col and y==row ) ) then 
						self.towerButtons[row][col].status = "cancel"
						self.towerButtons[row][col]:setLabel(self.towerButtons[row][col].status)
					end
				end
			end

		elseif (button.status == "pressed") then
			self.towerButtonsOverlay[y][x]:setFillColor( unpack(Colors.cancelRed) )
			self.overlayGroup.alpha=0
			if( self.gameMaster:canAffordBasicTower()) then
				self.gameMap:buildTower( x-1, y-1 )
			end
			self.gameMap:hideBuildPosBackground()

			for row=0,#self.towerButtons do
				for col=0,#self.towerButtons[row] do
					self.towerButtons[row][col].status = "idle"
					self.towerButtons[row][col]:setLabel(self.towerButtons[row][col].status)
				end
			end

		elseif (button.status == "cancel") then
			self:cancelBuildingProcess()
		end
	end
	
	button = self:createButton( displayGroup, x, y, "BUILD", onRelease )
	button:setLabel(button.status)
	
	return button
end

function _ControlPanel:createButton( displayGroup, x, y, label, onRelease, buttonWidth, buttonHeight )
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
	return button
end	

function _ControlPanel:placeVisualObject( visualObject, x, y, imageBoxWidth, imageBoxHeight )
	local imageBoxWidth = imageBoxWidth or self.buttonWidth
	local imageBoxHeight = imageBoxHeight or self.buttonHeight
	visualObject:setX( Layout.controlPanelArea.minX+((x+0.5)*imageBoxWidth) )
	visualObject:setY( Layout.controlPanelArea.minY+((y+0.5)*imageBoxHeight) )
	visualObject:setBasePosition( visualObject:getX(), visualObject:getY() )
end

function _ControlPanel:readyForNewWave()
	if self.currentState == gameValues.statePathBuildingInterface then
		self:cleanUpGameCreatorInterface()
	elseif self.currentState == gameValues.stateStartGameInterface then
		self:cleanUpStartGameInterface()
	elseif self.currentState == gameValues.stateAddVisualsInterface then
		self:cleanUpAddVisualsInterface()
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
	
	if self.sellAndUpgradeInstructions then
		self:cleanUpWaveCountdownInterface()
	end

	if not self.towerButtons[1][1] then
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