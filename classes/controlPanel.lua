Layout = require('libs.layout')
Colors = require('libs.colors')
widget = require('widget')
strings = require('strings.game')
VisualObject = require('classes.visualObject')
gameValues = require('gameValues.controlPanel')

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
			self:createTowerBuildingInterface( displayGroup )

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
		end,
		Layout.controlPanelArea.width,
		Layout.controlPanelArea.height/2)
end

function _ControlPanel:createGameLostInterface( displayGroup )
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
				self.gameMaster:payForBasicTower()
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