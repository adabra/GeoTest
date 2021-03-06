local composer = require( "composer" )
local scene = composer.newScene()
---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------
 
-- local forward references should go here
local maps = require("maps.maps")
local Button = require("classes.button")
local color = require("libs.colors")
---------------------------------------------------------------------------------
 
-- "scene:create()"
function scene:create( event )
 
   local sceneGroup = self.view
 
   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.
   local background = display.newRect( sceneGroup, display.contentWidth/2, display.contentHeight/2, 
      display.contentWidth, display.contentHeight )
   background.fill = {
      type = "gradient",
      color1 = color.gridOrange,
      color2 = {0, 0, 0}
   }

   for i=0,#maps-1 do
      local button = Button:new( {
         x = display.contentWidth/4 * (1+(i%3)),
         y = display.contentHeight/4 * (1+math.floor( i/3 )),
         label = i+1,
         width = display.contentWidth/5,
         onRelease = function()
            composer.gotoScene( "scenes.game", {time = 500, effect = "fade", params = { level = i+1} } )
         end
         })
      sceneGroup:insert( button )
   end

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
 
---------------------------------------------------------------------------------
 
return scene