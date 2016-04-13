-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
-- Your code here
local widget = require("widget")
display.setStatusBar( display.DefaultStatusBar )
--system.setLocationAccuracy()
--system.setLocationThreshold()

--Tap counter
local ctr = 1
--Table of map corners
local mapCorners = {}
--Reference to the timer function running every second to update the user's position
local updateUserPosition
--Boolean indicate whether the timer function above is assigned
local trackingUserPosition
--Variables for map position calculations on custom map
local topLeftCorner = {63.420230, 10.395619}
local topRightCorner = {63.420238,10.411260}
local bottomLeftCorner = {63.415487, 10.395791}
local bottomRightCorner = {63.415529, 10.411259}

local maxLat = (topLeftCorner[1]+topRightCorner[1])/2
local minLat = (bottomRightCorner[1]+bottomLeftCorner[1])/2
local maxLon = (topRightCorner[2]+bottomRightCorner[2])/2
local minLon = (topLeftCorner[2]+bottomLeftCorner[2])/2
print( "lats and lons calculated" )
print( "maxLat: " .. maxLat )
print( "minLat: " .. minLat )
print( "maxLon: " .. maxLon )
print( "minLon: " .. minLon )

local diffLon = maxLon-minLon
local diffLat = maxLat-minLat

local mapWidth = display.actualContentWidth
local mapHeight = display.actualContentHeight/2.5

local mapCenterX = display.contentCenterX
local mapCenterY = display.contentCenterY*1.7094

local xAxisModifier = mapWidth/diffLon
local yAxisModifier = mapHeight/diffLat

print("-------------")
print (system.getInfo("environment"))
print("-------------")

-- Create background
local myBackground = display.newRect( display.contentCenterX, display.contentCenterY, 
	display.actualContentWidth, display.actualContentHeight )
myBackground:setFillColor(197/256, 227/256, 186/256)

--Create placeholder for map when running on simulator
local myMap1PlaceHolder = display.newRect( display.contentCenterX, display.contentCenterY/2.5, 
	display.actualContentWidth, display.actualContentHeight/2.5 )

--Create custom map, screen shot of live map
local mapImageString = "images/glos_map_zoom_2.png"
local myCustomMap = display.newImageRect( mapImageString, display.actualContentWidth, display.actualContentHeight/2.5 )
myCustomMap.x = display.contentCenterX
myCustomMap.y = display.contentCenterY*1.7094

local myMap
if (system.getInfo( "environment" ) == "device" ) then
--Create live map
	myMap = native.newMapView( display.contentCenterX, display.contentCenterY/2.5, 
		display.actualContentWidth, display.actualContentHeight/2.5 )
	myMap.isScrollEnabled = false
	myMap.isZoomEnabled = false
	print ("zooom1:")
	print(mapImageString == "images/glos_map_zoom_1.png")
	print ("zooom2:")
	print(mapImageString == "images/glos_map_zoom_2.png")
	local mapRegion
	if (mapImageString == "images/glos_map_zoom_1.png") then
		--glos_map_zoom_1 region
		mapRegion = { midlat = 63.417845, midlon = 10.403515, latdiff= 0.005006, londiff = 0.01759755 }
	elseif (mapImageString == "images/glos_map_zoom_2.png") then
		--glos_map_zoom_2 region
		mapRegion = { midlat = 63.417845, midlon = 10.403515, latdiff= 0.003006, londiff = 0.01059755 }
	end	

	timer.performWithDelay( 7000, myMap:setRegion( mapRegion.midlat, mapRegion.midlon, mapRegion.latdiff, mapRegion.londiff, true ))
end

--Create list of strings to be cycled thorugh in instructions
local stringList = {"Please tap the top left corner", "Please tap the top right corner", "Please tap the bottom of the map", "Good jrrb :)"}

local myInstruction = display.newText( stringList[1], display.contentCenterX, display.contentCenterY, native.systemFontBold, 15 )
myInstruction:setFillColor(0,0,0)


--Listener for map taps
local function mapLocationListener( event )
	if ( ctr < 4 ) then
		print ("In mapLocationListener, ctr " .. ctr)
		print( "name: " .. event.name )
		print( "latitude: " .. event.latitude )
		print( "longitude: " .. event.longitude )
		if (ctr == 1) then
			mapCorners["maxLat"] = event.latitude
			mapCorners["minLon"] = event.longitude
		elseif (ctr == 2) then
			mapCorners["maxLon"] = event.longitude
		else
			mapCorners["minLat"] = event.latitude
		end
		ctr = ctr+1
		myInstruction.text = stringList[ctr]
		if (ctr == 4) then
			myMap:addMarker( mapCorners["minLat"], mapCorners["minLon"], {title="min,min"} )
			myMap:addMarker( mapCorners["minLat"], mapCorners["maxLon"], {title="min,max"} )
			myMap:addMarker( mapCorners["maxLat"], mapCorners["minLon"], {title="max,min"} )
			myMap:addMarker( mapCorners["maxLat"], mapCorners["maxLon"], {title="max,max"} )
			--timer.performWithDelay( 1000, updateUserPosition, 0 )
		end 
	else
			print("maxLat: " .. mapCorners["maxLat"])
			print("maxLon: " .. mapCorners["maxLon"])
			print("minLat: " .. mapCorners["minLat"])
			print("minLon: " .. mapCorners["minLon"])
	end
end

if (system.getInfo( "environment" ) == "device") then
	myMap:addEventListener( "mapLocation", mapLocationListener )
end

local myPos
updateUserPosition = function(latitude, longitude)

	local myLocalLat = latitude - minLat
	local myLocalLon = longitude - minLon

	local xVal = myLocalLon * xAxisModifier
	local yVal = mapCenterY+(mapHeight/2) - (myLocalLat * yAxisModifier)

	if (not myPos) then
		myPos = display.newCircle( xVal, yVal, 10 )
	else
		myPos.x = xVal
		myPos.y = yVal
	end

	myPos:setFillColor( math.random(), math.random(), math.random() )
	print ( "Position updated" )
	print ( "new position: " .. latitude ..", " .. longitude)

end

local function onSystemEvent( event )

    local eventType = event.type

    if ( eventType == "applicationStart" ) then
        --occurs when the application is launched and all code in "main.lua" is executed
    elseif ( eventType == "applicationExit" ) then
        --occurs when the user or OS task manager quits the application
    elseif ( eventType == "applicationSuspend" ) then
        --perform all necessary actions for when the device suspends the application, i.e. during a phone call
        if (trackingUserPosition) then
        	--timer.cancel( updateUserPosition )
        end
    elseif ( eventType == "applicationResume" ) then
        --perform all necessary actions for when the app resumes from a suspended state
        if (trackingUserPosition) then
        	--timer.performWithDelay( 1000, updateUserPosition, 0 )
        end
    elseif ( eventType == "applicationOpen" ) then
        --occurs when the application is asked to open a URL resource (Android and iOS only)
    end
end

Runtime:addEventListener( "system", onSystemEvent )

local lastPositionUpdate = os.time()
local updateInterval = 500
locationHandler = function( event )
	print ("in locationHandler")
	-- Check for error (user may have turned off Location Services)
	if event.errorCode then
		native.showAlert( "GPS Location Error", event.errorMessage, {"OK"} )
		print( "Location error: " .. tostring( event.errorMessage ) )
	else
		--[[
		local currentTime = os.time()
		local timePassed = currentTime - lastPositionUpdate
		
		if ( timePassed >= updateInterval ) then
			updateUserPosition( event.latitude, event.longitude )
			lastUpdate = currentTime
		end
		--]]
		updateUserPosition (event.latitude, event.longitude)
--[[
		local latitudeText = string.format( '%.4f', event.latitude )
		
		local longitudeText = string.format( '%.4f', event.longitude )
		
		local altitudeText = string.format( '%.3f', event.altitude )
	
		local accuracyText = string.format( '%.3f', event.accuracy )
		
		local speedText = string.format( '%.3f', event.speed )
	
		local directionText = string.format( '%.3f', event.direction )
	
		-- Note: event.time is a Unix-style timestamp, expressed in seconds since Jan. 1, 1970
		local timeText = string.format( '%.0f', event.time )
--]]		


	end
end

		
--
-- Check if this platform supports location events
--
if not system.hasEventSource( "location" ) then
	msg = display.newText( "Location events not supported on this platform", 0, 230, native.systemFontBold, 13 )
	msg.x = display.contentWidth/2		-- center title
	msg:setFillColor( 1,1,1 )
end

-- Activate location listener
Runtime:addEventListener( "location", locationHandler )

--[[
local myLoc = {63.416294, 10.404904}
local myLat = myLoc[1]
local myLon = myLoc[2]

updateUserPosition(myLat, myLon)
myEvent = {name = "location", latitude = 65, longitude = 10}
Runtime:dispatchEvent( myEvent )
--]]


--[[
timer.performWithDelay( 5000, function()
	print ("ADDING MARKERS AFTER 5 SECs")
myMap:addMarker( minLat, minLon, {title="min,min"} )
myMap:addMarker( minLat, maxLon, {title="min,max"} )
myMap:addMarker( maxLat, minLon, {title="max,min"} )
myMap:addMarker( maxLat, maxLon, {title="max,max"} )
end)


local mapCorners = {}

local stringList = {}
for i=1,4 do
	stringList[i] = "Please press the "
	if (i==1) then
		stringList[i] = stringList[i] .. "top left"
	elseif (i==2) then
		stringList[i] = stringList[i] .. "top right"
	elseif (i==3) then
		stringList[i] = stringList[i] .. "bottom left"
	else
		stringList[i] = stringList[i] .. "bottom right"
	end
	stringList[i] = stringList[i] .. " corner."
end
print (stringList)

local myInstruction = display.newText( stringList[1], display.contentCenterX, display.contentCenterY*1.5, native.systemFont, 15 )

local ctr = 1


local function myTapListener( event )
	print (ctr .. " myMap tapped")
	print ( event.x, event.y)
	local myCircle = display.newCircle( event.x, event.y, 10 )
	myCircle:setFillColor(0,1,0)
	ctr = ctr + 1
	myInstruction.text = stringList[ctr]
	if ctr==4 then display.captureScreen() end
	return true
end

local myTapEvent = {name="tap", x=display.actualContentWidth/4, y=display.actualContentHeight/4, numTaps=1}
myMap:addEventListener( "tap", myTapListener )
--myMap:dispatchEvent( myTapEvent )
--]]