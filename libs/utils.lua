
local _M = {}

--Calculates the distance between to latlon points in meters
function _M.calculateDistance(point1, point2)

	--localizing functions
	local sin = math.sin
    local cos = math.cos
    local sqrt = math.sqrt
    local atan2 = math.atan2
    local rad = math.rad


	local R = 6371
	local lat1 = rad(point1.latitude)
	local lat2 = rad(point2.latitude)
	local dLat = rad(point2.latitude - point1.latitude)
	local dLon = rad(point2.longitude - point1.longitude)

	local a = (sin(dLat*0.5))^2 + (cos(lat1)*cos(lat2)*(sin(dLon*0.5))^2)
	local c = 2 * atan2(sqrt(a), sqrt(1-a))

	local d = R*c

	return d*1000
end

function _M.newPoint( latlon )
	local point =  {latitude = latlon[1], longitude = latlon[2]}
	point.x = point.longitude
	point.y = point.latitude
	return point
end

function _M.firstToUpper( str )
    return (str:gsub("^%l", string.upper))
end


return _M