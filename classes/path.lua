local colors = require('libs.colors')

local _Path = {}

function _Path:new( displayGroup, gameMap )
	local path = { displayGroup = displayGroup, gameMap = gameMap}
	setmetatable( path, self )
	self.__index = self
	--path:setUpSprite( displayGroup )
	path.tiles = {}
	path.displayObjects = {}
	return path
end

--[[
function _Path:setUpSprite( displayGroup )
	print ("path loc: " .. self:getX() .. ", " .. self:getY())
	self.sprite = display.newRect( displayGroup, self:getX(), self:getY(), self.width, self.height )
	self.sprite:setFillColor( 0.9, 0.7, 0.5 )
end
--]]

function _Path:addTileImage( pos, first )
	first = first or false
	local cellContentAreaCoords = self.gameMap:gridToContentArea(pos[1], pos[2])
	local image = display.newRect( self.displayGroup, 
		cellContentAreaCoords[1], cellContentAreaCoords[2], 
		self.gameMap.cellWidth, self.gameMap.cellHeight )
	
	if first then
		image:setFillColor( unpack(colors.startTileBlue) )
	else
		image:setFillColor( unpack(colors.endTileRed) )
	end

	image.anchorX = 1
	image.anchorY = 1
	self.displayObjects[pos[1]..","..pos[2]] = image

	if (#self.tiles > 2) then
		local nextToLast = self:peek(1)
		self.displayObjects[nextToLast[1]..","..nextToLast[2]]:setFillColor( unpack(colors.pathTileBrown) )
	end
	
	return image
end




function _Path:getStartPosition()
	if ( #self.tiles > 0 ) then
		return self.tiles[1]
	end
end

function _Path:isLastTile( index )
	return index == #self.tiles
end


function _Path:addTile( x, y )
	if (#(self.tiles) == 0 ) then
		self:push( {x, y} )
		self:addTileImage( {x,y}, true )
		print( "First tile successfully added to path.")
		return true
	else
		for i=1,#self.tiles do
			if (i == #self.tiles) then
				if ( _Path.isNeighbor( {x, y}, self.tiles[i] ) ) then
					self:push( {x,y} )
					self:addTileImage( {x,y} )
					print( "Tile successfully added to path.")
					return true
				else
					print "Invalid tile placement, must be adjacent to current head of path."
					return false
				end
			else
				if (_Path.isNeighbor( {x, y}, self.tiles[i] ) ) then
					print( "Invalid tile placement, cannot be neighbor to any tile apart from current head of path.")
					return false
				end
			end 
		end
	end
	--self:updateDirections()
end

function _Path:removeTile( x, y )
	if (self:peek()[1] == x and self:peek()[2] == y) then
		self:pop()
		self.displayObjects[x..","..y]:removeSelf()
		self.displayObjects[x..","..y] = nil

		if (#self.tiles > 1) then
			local last = self:peek()
			self.displayObjects[last[1]..","..last[2]]:setFillColor( unpack(colors.endTileRed) )
		end
		
		print( "Tile successfully removed from path.")
		return true
		--self:updateDirections()
	else
		print( "Only end of path can be removed.")
		return false
	end
end

function _Path:updateDirections()
	if (#self.tiles > 1 ) then
		self.directions[#self.directions] = { self:peek()[1] - self:peek(1)[1], self:peek()[2] - self:peek(1)[2] } 
	end
end

function _Path:pop()
	if (#self.tiles > 0) then
		local last = self.tiles[#self.tiles]
		self.tiles[#self.tiles] = nil
		return last
	end
end

function _Path:push( tile )
	self.tiles[#self.tiles+1] = tile
end

function _Path:peek( i )
	i = i or 0
	if (#self.tiles > 0) then
		return self.tiles[#self.tiles - i]
	else
		return nil
	end
end

function _Path.isNeighbor(cell1, cell2)
	local xDiff = math.abs(cell1[1] - cell2[1])
	local yDiff = math.abs(cell1[2] - cell2[2])
	return (xDiff==1 and yDiff==0) or (xDiff==0 and yDiff==1) 
end
			

function _Path:getTile( index )
	if (index > 0 and index <= #self.tiles) then
		return self.tiles[index]
	else
		return nil
	end
end

function _Path:getLength()
	return #self.tiles
end


return _Path