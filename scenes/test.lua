local composer = require( "composer" )
local scene = composer.newScene()
local widget = require('widget')
 
---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------
 
-- local forward references should go here
local tower = require('classes.tower')
local eachframe = require('libs.eachframe')
local Set = require('libs.set')
local ControlPanel = require('classes.controlPanel')
local widget = require('widget')
local Layout = require('libs.layout')
local Colors = require('libs.colors')
local myTower
local background
---------------------------------------------------------------------------------
 
-- "scene:create()"
function scene:create( event )
 
   local sceneGroup = self.view
 
   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.



   background = display.newRect( sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
   background:setFillColor( 1,1,1 )

--[[
   local frame = display.newRect( sceneGroup, display.contentCenterX, display.contentCenterY, 200, 200 )
   frame:setFillColor( 1,1,1, 0 )
   frame:setStrokeColor( 1, 0, 0 )
   frame.strokeWidth = 5
 --  frame.alpha = 0
 	myTower = tower:new( sceneGroup, display.contentCenterX, display.contentCenterY, 'basic', 100 )
 	eachframe.add(self)



	 	-- Handle press events for the buttons
	local function onSwitchPress( event )
	    local switch = event.target
	    print( "Switch with ID '"..switch.id.."' is on: "..tostring(switch.isOn) )
	end
	--]]

   local button = widget.newButton( {
		x = Layout.controlPanelArea.centerX,
		y = Layout.controlPanelArea.centerY,
		-- Visual options
		shape = "rect",
		fillColor = { default = Colors.controlPanelGrey, over = Colors.controlPanelButtonDown },
		strokeColor = { default= Colors.controlPanelButtonStroke, over = Colors.controlPanelButtonStroke },
		strokeWidth = 3,
		width = 200,
		height = 200,
		label = "LOL",
		fontSize = 40,
		labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
		emboss = true,
		--Behavior
		onRelease = nil
		} )
   button:removeSelf()
   print(button)
   button = nil
   print(button)

end
 

local function onTouchEvent( event )
	if not touch then
		touch = display.newCircle( event.x, event.y, 10 )
		touch:setFillColor( 1,0,0 )
	else
		touch.x = event.x
		touch.y = event.y
	end
	myTower:rotateTowardMinion( {sprite = {x = event.x, y = event.y} } )
end

function scene:eachFrame()

end

function scene:show( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.
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
 
---------------------------------------------------------------------------------
 
-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
Runtime:addEventListener( "touch", onTouchEvent )
 
---------------------------------------------------------------------------------
 
return scene