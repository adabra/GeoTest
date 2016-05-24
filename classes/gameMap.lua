local Colors = require("libs.colors")
local Maps = require("maps.maps")
local Layout = require("libs.layout")
local Tower = require('classes.tower')
local Path = require('classes.path')
local gameValues = require('gameValues.gameMap')
local Set = require('libs.set')

local _GameMap = {
	width = gameValues.defaultWidth, 
	height = gameValues.defaultHeight, 
	cellSize = gameValues.defaultCellSize, 
	gridStrokeWidth = gameValues.gridStrokeWidth, 
	level = gameValues.defaultLevel }

function _GameMap:new( displayGroup, o )
	local gameMap = o or {}
	setmetatable( gameMap, self )
	self.__index = self
	gameMap.map = Maps[gameMap.level]
	gameMap.width = gameMap.map.widthInMeters
	gameMap.height = gameMap.map.heightInMeters
	gameMap.myDisplayGroup = displayGroup
	gameMap.backgroundGroup = display.newGroup()
	gameMap.myDisplayGroup:insert( gameMap.backgroundGroup )
    gameMap.mapImg = display.newImageRect( gameMap.backgroundGroup, gameMap.map.image,  Layout.mapArea.width, Layout.mapArea.height )
    gameMap.mapImg.x = Layout.mapArea.centerX
    gameMap.mapImg.y = Layout.mapArea.centerY
    gameMap.gridGroup = display.newGroup()
    gameMap.myDisplayGroup:insert( gameMap.gridGroup )
    gameMap:init()
    gameMap:drawGrid()
	return gameMap
end

function _GameMap:init()
	
	if self.grid then
		print( "Map already initialized, use GameMap.reset() to reset map." )
		return nil
	end

	self.cellsHorizontally = math.floor( self.width / self.cellSize )
	self.cellsVertically = math.floor( self.height / self.cellSize )

	-- For use in contentAreaToGrid()
	self.cellWidth = Layout.mapArea.width/self.cellsHorizontally
	self.cellHeight = Layout.mapArea.height/self.cellsVertically
	---
	
	local map = {}
	for y = 1,self.cellsVertically do
		map[y] = {}
		for x = 1,self.cellsHorizontally do
			map[y][x] = 'empty'
		end
	end

	self.grid = map
	self.playerCellListeners = {}
end

function _GameMap:setPlayer ( player )
	if (not self.player) then
		self.player = player
		self.playerCellBackground = display.newRect( self.gridGroup, 0, 0, self.cellWidth, self.cellHeight )
		self.playerCellBackground:setFillColor( unpack(Colors.gridOrange) )
		self.playerCellBackground.anchorX = 1
		self.playerCellBackground.anchorY = 1
		self.playerCellBackground.alpha = 0
		self:updateGrid()
		self.playerCellBackground.alpha = 0.5
	else
		print ("Player already initialized")
	end
end

function _GameMap:getPlayerPosition()
	return self.player:getPosition()
end

function _GameMap:getPlayerCell()
	local playerPos = self:getPlayerPosition()
	local playerCell = self:contentAreaToGrid(playerPos.x, playerPos.y)
	return {x = playerCell[1], y = playerCell[2]}
end

function _GameMap:hidePlayer()
	if ( self.player ) then
		self.player:hide()
		self.playerCellBackground.alpha = 0
	end
end

function _GameMap:showPlayer()
	if (self.player) then
		self.player:show()
		self.playerCellBackground.alpha = 0.5
	end
end

function _GameMap:setTowerMaster( towerMaster )
	self.towerMaster = towerMaster
end

function _GameMap:updateBuildPosBackground(dx, dy)
	if (not self.buildPosBackground) then
		self.buildPosBackground = display.newRect( self.gridGroup, 0, 0, self.cellWidth, self.cellHeight )
		self.buildPosBackground:setFillColor( unpack(Colors.buildPosGreen) )
		self.buildPosBackground.anchorX = 1
		self.buildPosBackground.anchorY = 1
	end

	self.buildPosBackground.alpha = 0.3
	local playerGridPos = self:contentAreaToGrid(self.player:getXPosition(), self.player:getYPosition())
	local cellContentAreaCoords = self:gridToContentArea(playerGridPos[1]+dx, playerGridPos[2]+dy) 
	self.buildPosBackground.x = cellContentAreaCoords[1]
	self.buildPosBackground.y = cellContentAreaCoords[2]

end

function _GameMap:hideBuildPosBackground()
	if (self.buildPosBackground) then
		self.buildPosBackground.alpha = 0
	end
end

function _GameMap:selectTower( x, y )	
	self:showDeselectOverlay()
	self:showTowerHighlight( x, y )
end


function _GameMap:showTowerHighlight( x, y )
	if not self.towerHighlight then
		self.towerHighlight = display.newRect( self.gridGroup, 0, 0, self.cellWidth, self.cellHeight )
		self.towerHighlight:setFillColor( unpack(Colors.buildPosGreen) )
	end
	self.towerHighlight.alpha = 0.5
	self.towerHighlight.x = x
	self.towerHighlight.y = y
end

function _GameMap:deselectTower()
	self:hideDeselectOverlay()
	self:hideTowerHighlight()
end

function _GameMap:hideTowerHighlight()
	if self.towerHighlight then
		self.towerHighlight.alpha = 0
	end
end

function _GameMap:showDeselectOverlay()
	if not self.deselectOverlay then
		self.deselectOverlay = display.newRect( 
			self.myDisplayGroup, 
			Layout.mapArea.centerX, Layout.mapArea.centerY, 
			Layout.mapArea.width, Layout.mapArea.height )
		self.deselectOverlay:addEventListener( "tap", 
			function() 
			self:fireGameEvent({eventType = gameValues.eventTypeTowerDeselected})
			return true
			end )
		self.deselectOverlay:setFillColor( unpack(Colors.cancelRed) )
	end
	self.deselectOverlay.alpha = 0.3
end

function _GameMap:hideDeselectOverlay()
	if self.deselectOverlay then
		self.deselectOverlay.alpha = 0
	end
end

function _GameMap:updateGrid()
	local playerGridPos = self:contentAreaToGrid(self.player:getXPosition(), self.player:getYPosition())
	local cellContentAreaCoords = self:gridToContentArea(playerGridPos[1], playerGridPos[2])
	
	-- For cell change-check
	local playerCellBackgroundGridPos = self:contentAreaToGrid(
		self.playerCellBackground.x - self.cellWidth/2, 
		self.playerCellBackground.y - self.cellHeight/2)

	if (playerCellBackgroundGridPos[1] ~= playerGridPos[1] or playerCellBackgroundGridPos[2] ~= playerGridPos[2]) then
		self:firePlayerCellChangedEvent( playerGridPos[1], playerGridPos[2] )
	end

	self.playerCellBackground.y = cellContentAreaCoords[2]
	self.playerCellBackground.x = cellContentAreaCoords[1] 
		
end

function _GameMap:firePlayerCellChangedEvent( newX, newY )
	for k,listener in pairs(self.playerCellListeners) do
		if type(listener) == "table" then
			listener:playerCellChanged( newX, newY )
		end
	end
end

function _GameMap:addPlayerCellListener( listener )
	Set.addToSet( self.playerCellListeners, listener)
	Set.printSet(self.playerCellListeners)
end

function _GameMap:removePlayerCellListener( listener )
	Set.removeFromSet( self.playerCellListeners, listener )
end


function _GameMap:printGameMap()
	local map = self.grid

	for y = 1,self.cellsVertically do
		local row = ""
		for x = 1,self.cellsHorizontally do
			row = row .. map[y][x]
		end
		print( row )
	end
end


function _GameMap:setMapCell( x, y, value )
	local map = self.grid
	map[y][x] = value
end

function _GameMap:getMapCell( x, y )
	local map = self.grid
	return map[y][x]
end

-- Calculates the grid coordinates from the (x,y) content area coords
function _GameMap:contentAreaToGrid( x, y )
	-- +1 to coordinates because tables are 1 indexed
	local gridX = math.floor( (x-Layout.mapArea.minX)/self.cellWidth ) + 1
	local gridY = math.floor ( (y-Layout.mapArea.minY)/self.cellHeight ) + 1
	return {gridX, gridY}
end

function _GameMap:gridToContentArea( x, y )
	local contentAreaX = Layout.mapArea.minX + x*self.cellWidth
	local contentAreaY = Layout.mapArea.minY + y*self.cellHeight
	return {contentAreaX, contentAreaY}
end

function _GameMap:gridToContentAreaMidCell( x, y )
	local coords = self:gridToContentArea( x, y )
	coords[1] = coords[1] - self.cellWidth/2
	coords[2] = coords[2] - self.cellHeight/2
	return coords
end

function _GameMap:showGrid( shown )
	if ( not self.gridGroup) then
		print ("Grid not yet drawn. Use drawGrid( displaygroup ) to draw grid first.")
		return nil
	end
	if (shown) then
		self.gridGroup.alpha = 0.7
	else 
		self.gridGroup.alpha = 0
	end
end

function _GameMap:drawGrid()
	local cellSize = self.cellSize
	local width = self.width
	local height = self.height
	local gridStrokeWidth = self.gridStrokeWidth

	local cellsHorizontally = math.floor( width / cellSize )
	local cellsVertically = math.floor( height / cellSize )
	
	for i = 0,cellsHorizontally do
		local myLine = display.newLine( 
			self.gridGroup, 
			Layout.mapArea.minX + Layout.mapArea.width*i*(1/cellsHorizontally), Layout.mapArea.minY, 
			Layout.mapArea.minX + Layout.mapArea.width*i*(1/cellsHorizontally), Layout.mapArea.maxY 
			)
		myLine:setStrokeColor( Colors.gridOrange.r, Colors.gridOrange.g, Colors.gridOrange.b )
		myLine.strokeWidth = gridStrokeWidth
	end

	for i = 0,cellsVertically do
		local myLine = display.newLine( 
			self.gridGroup, 
			Layout.mapArea.minX, Layout.mapArea.minY + Layout.mapArea.height*i*(1/cellsVertically), 
			Layout.mapArea.maxX, Layout.mapArea.minY + Layout.mapArea.height*i*(1/cellsVertically) 
			)
		myLine:setStrokeColor( Colors.gridOrange.r, Colors.gridOrange.g, Colors.gridOrange.b )
		myLine.strokeWidth = gridStrokeWidth
	end
	self.gridGroup.alpha = 0.7
end

function _GameMap:calculateXY(latitude, longitude)

	local myLocalLat = latitude - self.map.bottomRight[1]
	local myLocalLon = longitude - self.map.topLeft[2]

	local xAxisModifier = Layout.mapArea.width / self.map.widthInDegrees
	local yAxisModifier = Layout.mapArea.height / self.map.heightInDegrees

	local xVal = Layout.mapArea.minX + ( myLocalLon * xAxisModifier )
	local yVal = Layout.mapArea.maxY - (myLocalLat * yAxisModifier )

	return {xVal, yVal}
end 

function _GameMap:buildTower( dx, dy )
	local playerGridPos = self:contentAreaToGrid(self.player:getXPosition(), self.player:getYPosition())
	local towerGridPos = {playerGridPos[1]+dx, playerGridPos[2]+dy}
	if (self:getMapCell( towerGridPos[1], towerGridPos[2] ) ~= 'empty') then
		print ("Cell " .. towerGridPos[1] .. ", " .. towerGridPos[2] .. " already occupied. Build aborted.")
		return 
	else
		print ("Building tower at " .. towerGridPos[1] .. ", " .. towerGridPos[2])
		self:setMapCell( towerGridPos[1], towerGridPos[2], 'tower')
		local tower = Tower:new(self.backgroundGroup, 
			self:gridToContentArea( towerGridPos[1], towerGridPos[2])[1] - self.cellWidth*0.5, 
			self:gridToContentArea( towerGridPos[1], towerGridPos[2])[2] - self.cellHeight*0.5, 
			'basic', self.cellWidth,
			towerGridPos[1], towerGridPos[2])
		tower:addEventListener( "tap", 
			function()
				self:fireGameEvent( {eventType = gameValues.eventTypeTowerSelected, target = tower} )
			end )
		self.towerMaster:addTower( tower )
		self:fireGameEvent( { eventType = gameValues.eventTypeTowerBuilt } )
	end
end

function _GameMap:buildPath()
	local playerGridPos = self:contentAreaToGrid(self.player:getXPosition(), self.player:getYPosition())
	if (self:getMapCell( playerGridPos[1], playerGridPos[2] ) ~= 'empty') then
		print ("Cell " .. playerGridPos[1] .. ", " .. playerGridPos[2] .. " already occupied. Build aborted.")
		return 
	else
		print ("Building path at " .. playerGridPos[1] .. ", " .. playerGridPos[2])
		self:setMapCell( playerGridPos[1], playerGridPos[2], 'path')
		local path = Path:new(self.backgroundGroup, 
			playerGridPos[1]*self.cellWidth - self.cellWidth*0.5, 
			playerGridPos[2]*self.cellHeight - self.cellHeight*0.5, 
			self.cellWidth, self.cellHeight)
	end
end

function _GameMap:updatePath(x, y)
	if (not self.path) then
		self.path = Path:new(self.backgroundGroup, self)
	end

	local cellPos = self:contentAreaToGrid(x, y)
	
	if ( self:getMapCell( cellPos[1], cellPos[2] ) == 'empty' ) then
		if (self.path:addTile( cellPos[1], cellPos[2] ) ) then
			self:setMapCell(cellPos[1], cellPos[2], 'path')
		end

	elseif ( self:getMapCell( cellPos[1], cellPos[2] ) == 'path' ) then
		if ( self.path:removeTile( cellPos[1], cellPos[2] ) ) then
			self:setMapCell(cellPos[1], cellPos[2], 'empty')
		end
	else
		print( "Cell " .. cellPos[1] .. ", " .. cellPos[2] .. " not buildable or removable.") 
	end
end

function _GameMap:getPath()
	if (not self.path) then
		self.path = Path:new(self.backgroundGroup, self)
	end
	return self.path
end

function _GameMap:addGameEventListener( listener )
	if not self.gameEventListeners then
		self.gameEventListeners = {}
	end
	table.insert(self.gameEventListeners, listener)
end

function _GameMap:fireGameEvent( event )
	for k,listener in pairs(self.gameEventListeners) do
		listener:handleGameEvent( event )
	end
end


return _GameMap