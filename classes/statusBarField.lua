local gameValues = require('gameValues.statusBarField')
local Layout = require('libs.layout')

local _StatusBarField = {}

function _StatusBarField:new( displayGroup, value, icon, name )
	local statusBarField =  {}
	setmetatable( statusBarField, self )
	self.__index = self
	statusBarField:init( displayGroup, value, icon, name)
	return statusBarField
end

function _StatusBarField:init( displayGroup, value, icon, name )
	self.name = name

	local textOptions = {
	parent = displayGroup, 
	text = value, 
	x = Layout.statusBarArea.width*0.85, 
	y = Layout.statusBarArea.centerY , 
	width = 0, 
	height = 0, 
	font = native.systemFont,
	align = "right" 
	} 
	self.text = display.newText( textOptions )
	self.text.anchorX = 0

	if icon then
		self.icon = display.newImageRect( 
			displayGroup, 
			gameValues.imagePath .. icon .. gameValues.imageExtension, 
			Layout.statusBarArea.height*0.7, 
			Layout.statusBarArea.height*0.7 )
		self.icon.anchorX = 0
		self.icon.y = Layout.statusBarArea.centerY
	else
		self.icon = {width = 0}
	end

	self.width = self.icon.width + gameValues.internalFieldPadding + self.text.width
end

function _StatusBarField:setPosition( x )
	self.icon.x = x
	self.text.x = self.icon.x + self.icon.width + gameValues.internalFieldPadding
end

function _StatusBarField:setVisible( bool )
	if bool then
		self.text.alpha = 1
		self.icon.alpha = 1
	else
		self.text.alpha = 0
		self.icon.alpha = 0
	end
end

function _StatusBarField:setText( text )
	self.text.text = text
end

return _StatusBarField