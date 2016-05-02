local composer = require( "composer" )
local scene = composer.newScene()


 
---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------
 
-- local forward references should go here
local GameMap = require( "classes.gameMap" )
local Utils = require( "libs.utils" )
local Player = require("classes.player")
local Layout = require("libs.layout")
local eachframe = require('libs.eachframe')
local widget = require('widget')
local strings = require('strings.game')
local ControlPanel = require('classes.controlPanel')
local Minion = require('classes.minion')
local MinionMaster = require( 'classes.minionMaster' )
local TowerMaster = require('classes.towerMaster')
local GameMaster = require('classes.gameMaster')
local StatusBar = require('classes.statusBar')
local gameValues = require('gameValues.game')

local gameMap
local player
local pressedKeys = {}
local speedButtonPressed
local onTapEvent
local minion
local frontGroup
local mapGroup
local minionMaster
local towerMaster
local controlPanel
local gameMaster

---------------------------------------------------------------------------------
 
-- "scene:create()"
function scene:create( event )
 
   local sceneGroup = self.view 
   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.
   local currentLevel = event.params.level
   mapGroup = display.newGroup()
   sceneGroup:insert( mapGroup )
   mapGroup:addEventListener( "tap", onTapEvent)
   gameMap = GameMap:new( mapGroup, {cellSize = gameValues.cellSizeInMeters, level = currentLevel} )
   
   frontGroup = display.newGroup( )
   sceneGroup:insert( frontGroup )

   player = Player:new( frontGroup )
   player:setPosition(Layout.mapArea.width/2, Layout.mapArea.height/2)
   gameMap:setPlayer( player )
   gameMap:hidePlayer()

   minionMaster = MinionMaster:new( frontGroup, gameMap )

   towerMaster = TowerMaster:new( minionMaster )
   gameMap:setTowerMaster( towerMaster )

   local statusBarGroup = display.newGroup( )
   sceneGroup:insert( statusBarGroup )
   local statusBar = StatusBar:new( statusBarGroup )

   gameMaster = GameMaster:new( frontGroup, statusBar, minionMaster, towerMaster, gameMap )
   minionMaster:setGameMaster( gameMaster )


   local controlPanelGroup = display.newGroup()
   sceneGroup:insert( controlPanelGroup )
   controlPanel = ControlPanel:new( controlPanelGroup, gameMap, gameMaster )   
   gameMaster:setControlPanel( controlPanel )

end
 
-- "scene:show()"
function scene:show( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.

      eachframe.add(self) -- Each frame self:eachFrame() is called
   end
end
 
-- "scene:hide()"
function scene:hide( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
      -- Called when the scene is on screen (but is about to go off screen).
      -- Insert code here to "pause" the scene.
      -- Example: stop timers, stop animation, stop audio, etc.
   elseif ( phase == "did" ) then
      -- Called immediately after scene goes off screen.
   end
end
 
-- "scene:destroy()"
function scene:destroy( event )
 
   local sceneGroup = self.view
 
   -- Called prior to the removal of scene's view ("sceneGroup").
   -- Insert code here to clean up the scene.
   -- Example: remove display objects, save state, etc.
end
 

function scene:eachFrame()
	player:move( pressedKeys, speedButtonPressed )
   	if gameMaster:isGameRunning() then

	   minionMaster:moveMinions()

	   towerMaster:operateTowers()

	   gameMap:updateGrid()
	end
end


 -- Called when a location event has been received
local function onLocationEvent( event )
      -- Check for error (user may have turned off Location Services)
      if event.errorCode then
         native.showAlert( "GPS Location Error", event.errorMessage, {"OK"} )
         print( "Location error: " .. tostring( event.errorMessage ) )
      elseif (player) then
         local newPosition = gameMap:calculateXY( event.latitude, event.longitude )
         player:setPosition( newPosition[1], newPosition[2] )
      end
end

--local arrows = {w = "up", s = "down", a = "left", d = "right"}
--local wasd = {up = "w", down = "s", left = "a", right = "d"}
local directions = {up = {0,-1}, down = {0,1}, left = {-1,0}, right = {1,0}}
-- Called when a key event has been received

local function onKeyEvent( event )
   -- Print which key was pressed down/up
   local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
   print( message )

   -- If the "back" key was pressed on Android or Windows Phone, prevent it from backing out of the app
   if ( event.keyName == "back" ) then
      local platformName = system.getInfo( "platformName" )
      if ( platformName == "Android" ) or ( platformName == "WinPhone" ) then
         return true
      end
   end


   local direction
   if ( event.keyName == "w" or event.keyName == "up" ) then
      direction = "up"
   elseif ( event.keyName == "s" or event.keyName == "down" ) then
      direction = "down"
   elseif ( event.keyName == "a" or event.keyName == "left" ) then
      direction = "left"
   elseif ( event.keyName == "d" or event.keyName == "right" ) then
      direction = "right"
   end

   if (direction) then
      if (event.phase == "up" ) then
         pressedKeys[direction] = nil
      elseif (event.phase == "down") then
         pressedKeys[direction] = directions[direction]
      end
      speedButtonPressed = event.isShiftDown 
      return true
   end

   print ("direction invalid, not moving")

    -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
    -- This lets the operating system execute its default handling of the key
   return false
end

function onTapEvent( event )
   if (gameMaster:isPathBuildingAllowed()) then
      gameMap:updatePath( event.x, event. y)
   else
      mapGroup:removeEventListener("tap", onTapEvent )
   end
end


---------------------------------------------------------------------------------
 
-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
 
Runtime:addEventListener( "location", onLocationEvent )
Runtime:addEventListener( "key", onKeyEvent )
--Testing GPS
--[[
local myGPSEvent = {name="location", latitude = 63.418959, longitude = 10.402984}
timer.performWithDelay(1500, function() 
   Runtime:dispatchEvent( myGPSEvent ) 
   myGPSEvent.latitude = myGPSEvent.latitude - 0.00001
   myGPSEvent.longitude = myGPSEvent.longitude + 0.00001
   end)
--]]

---------------------------------------------------------------------------------
 
return scene