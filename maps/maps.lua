local Utils = require( "libs.utils" )

local _M = {}

local mapsPath = "images/maps/"

--_M[1] = {image = mapsPath .. "map_full2.png", topLeft = {63.422553, 10.395192}, bottomRight = {63.410390, 10.410548}}
--_M[2] = {image = mapsPath .. "map_full2_70p.png", topLeft = {63.422553, 10.395192}, bottomRight = {63.414001, 10.410548}}
--_M[3] = {image = mapsPath .. "glos_map_TESTING_70p.png", topLeft = { 63.419475, 10.401068 }, bottomRight = { 63.415252, 10.408708 } }
_M[1] = {image = mapsPath .. "hogskoleparken_closeup.png", topLeft = {63.416966, 10.401329}, bottomRight = {63.416429, 10.402293} }
_M[2] = {image = mapsPath .. "hogskoleparken.png", topLeft = {63.417008, 10.400676}, bottomRight = {63.415989, 10.402616} }
_M[3] = {image = mapsPath .. "hogskoleparken_lower.png", topLeft = {63.416560, 10.400124}, bottomRight = {63.415487, 10.402046}}
_M[4] = {image = mapsPath .. "hovedbygget.png", topLeft = {63.421532, 10.400542}, bottomRight = {63.419394, 10.404392}}
_M[5] = {image = mapsPath .. "hovedbygget_closeup.png", topLeft = {63.420944, 10.400432}, bottomRight = {63.419882, 10.402364}}
_M[6] = {image = mapsPath .. "glos.png", topLeft = {63.417783, 10.402651}, bottomRight = {63.416709, 10.404580}}
_M[7] = {image = mapsPath .. "glos_closeup.png", topLeft = {63.417423, 10.403042}, bottomRight = {63.416963, 10.403973}}

for i = 1,#_M do
	local topLeftPoint = Utils.newPoint( _M[i].topLeft )
	local topRightPoint = Utils.newPoint({_M[i].topLeft[1], _M[i].bottomRight[2]})
	local bottomLeftPoint = Utils.newPoint({_M[i].bottomRight[1], _M[i].topLeft[2]})
	_M[i].widthInDegrees = topRightPoint.longitude-topLeftPoint.longitude
	_M[i].heightInDegrees = topLeftPoint.latitude-bottomLeftPoint.latitude
	_M[i].widthInMeters = Utils.calculateDistance( topLeftPoint , topRightPoint )
	_M[i].heightInMeters = Utils.calculateDistance(	topLeftPoint, bottomLeftPoint )
end

for i=#_M+1,9 do
	_M[i] = ""
end


return _M