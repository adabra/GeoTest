local utils = require( "libs.utils" )
local maps = require("maps.maps")
local gameMap = require( "classes.gameMap" )
display.setStatusBar(display.HiddenStatusBar)

--[[
local topLeft = {63.422553, 10.395192}
local bottomRight = {63.410390, 10.410548}
--]]


local map = maps[1]
--Checking distance calculations
local calculatedWidth = utils.calculateDistance( 
	utils.newPoint(map.topLeft), utils.newPoint({map.topLeft[1], map.bottomRight[2]}) )
local calculatedHeight = utils.calculateDistance(  
	utils.newPoint(map.topLeft), utils.newPoint({map.bottomRight[1], map.topLeft[2]}) )
local actualWidth = 764.28
local actualHeight = 1353.71
local widthError = math.abs( actualWidth - calculatedWidth )
local heightError = math.abs( actualHeight - calculatedHeight )
print( "width: " ..  calculatedWidth)
print("error: " .. widthError .. ", which is " .. (widthError/actualWidth)*100 .. "%.")
print( "height: " .. calculatedHeight )
print("error: " ..  heightError ..", which is " .. (heightError/actualHeight)*100 .. "%.")
--

local background = display.newGroup( )
local grid = display.newGroup( )

local mapImg = display.newImageRect( background, map.image,  display.contentWidth, display.contentHeight )
mapImg.x = display.contentCenterX
mapImg.y = display.contentCenterY





myGameMap = gameMap:new( {width = calculatedWidth, height = calculatedHeight, cellSize = 100})
myGameMap:init()
myGameMap:setMapCell( 10, 10, '*')
myGameMap:printGameMap()
print("----")
myGameMap:drawGrid( grid ) 