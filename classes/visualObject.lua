local Layout = require('libs.layout')
local gameValues = require('gameValues.visualObject')

local _VisualObject = {imagePath = "images/visual_objects/", 
	imageSizes = {bush = {5, 5}, tree = {5,5}, car = {5,5}, cone = {5,5}, rock = {5,5}, duck_yellow = {5,5}, duck_white = {5,5}, target={5,5} }, 
	images = {},
	baseX = 0, baseY = 0
}

function _VisualObject:new( displayGroup, backgroundDisplayGroup, visualObjectType )
	local visualObject = {displayGroup = displayGroup, backgroundDisplayGroup = backgroundDisplayGroup}
	setmetatable( visualObject, self )
	self.__index = self
	visualObject.onTouchEvent = function( event ) visualObject:onTouchEventInternal( event ) end
	visualObject:createSprite( displayGroup, visualObjectType )
	visualObject.moving = false
	return visualObject
end

function _VisualObject:generateImageSizes()
	
	for visualObject,size in pairs(self.imageSizes) do
		self.imageSizes[visualObject] = {
			size[1]*gameValues.imageSizeModifier * Layout.mapArea.height, 
			size[2]*gameValues.imageSizeModifier * Layout.mapArea.height
		}
		table.insert( self.images, visualObject)
	end

end

function _VisualObject:getTypes()
	return self.images
end

function _VisualObject:createSprite( displayGroup, visualObjectType )
	self.sprite = display.newImageRect( displayGroup, self.imagePath .. visualObjectType .. ".png", 
		self:getImageWidth( visualObjectType ), self:getImageHeight( visualObjectType ) )

	self.visualObjectType = visualObjectType
	self.sprite:addEventListener( "touch", self.onTouchEvent )
end

function _VisualObject:getImageWidth( visualObjectType )
	return self.imageSizes[visualObjectType][1]
end

function _VisualObject:getImageHeight( visualObjectType )
	return self.imageSizes[visualObjectType][2]
end

function _VisualObject:setX( x )
	self.sprite.x = x
end

function _VisualObject:setY( y )
	self.sprite.y = y
end

function _VisualObject:getX()
	return self.sprite.x
end

function _VisualObject:getY()
	return self.sprite.y
end

function _VisualObject:setBasePosition( x, y )
	self.baseX = x
	self.baseY = y
end

function _VisualObject:onTouchEventInternal( event )
	
	if (event.phase == "began") then
		self.moving = true
	elseif (event.phase == "moved" and self.moving) then
		self.sprite.x = event.x
		self.sprite.y = event.y
	elseif (event.phase == "ended") then
		self.moving = ended
		if (self.sprite.x >= Layout.mapArea.minX and 
			self.sprite.x <= Layout.mapArea.maxX and 
			self.sprite.y >=Layout.mapArea.minY and 
			self.sprite.y+self.sprite.height/2 <= Layout.mapArea.maxY) then
				self.sprite:removeEventListener( "touch", self.onTouchEvent )
				self.sprite:removeSelf( )
				self.backgroundDisplayGroup:insert(self.sprite)
				self.sprite:addEventListener("tap", function(event) 
					event.target:removeSelf()
					event.target = nil
					return true
					end)
				self:createSprite( self.displayGroup, self.visualObjectType )
				self:setX( self.baseX )
				self:setY( self.baseY )
		else
			self.sprite.x = self.baseX
			self.sprite.y = self.baseY
		end

	end
end

_VisualObject:generateImageSizes()
return _VisualObject