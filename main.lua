-- Hide status bar
display.setStatusBar(display.HiddenStatusBar)

-- Hide navigation bar on Android
if platform == 'Android' then
	native.setProperty('androidSystemUiVisibility', 'immersiveSticky')
end

-- Set up composer
local composer = require('composer')
composer.recycleOnSceneChange = true -- Automatically remove scenes from memory

-- Load audio
local sounds = require('sounds.sounds')
audio.setVolume( 0.2 )

-- Show menu scene
composer.gotoScene('scenes.mainMenu')


-- Map screenshot scene
--composer.gotoScene( "test.mapCreator")

--straight to game for testing purposes
--composer.gotoScene( "scenes.game", {params = { level = 7 } } )

--testing
--composer.gotoScene( "scenes.test" )