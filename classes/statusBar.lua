local Layout = require('libs.layout')
local colors = require('libs.colors')
local gameValues = require('gameValues.gameMaster')

local _StatusBar = {}

function _StatusBar:new( displayGroup )
	local statusBar = {}
	setmetatable( statusBar, self )
	self.__index = self
	statusBar:init( displayGroup )
	return statusBar
end

function _StatusBar:init( displayGroup )
	self:createBackground ( displayGroup )
	self:createHealthPointField( displayGroup )
	self:createCreditField( displayGroup )
	self:createWaveField( displayGroup )
end

function _StatusBar:createBackground( displayGroup )
	self.background = display.newRect( displayGroup, 
		Layout.statusBarArea.centerX, Layout.statusBarArea.centerY, 
		Layout.statusBarArea.width, Layout.statusBarArea.height )
	self.background:setFillColor( unpack(colors.controlPanelGrey) )
end

function _StatusBar:createHealthPointField( displayGroup )
		local textOptions = {
		parent = displayGroup, 
		text = gameValues.maxBaseHealthPoints .. " / " .. gameValues.maxBaseHealthPoints, 
		x = Layout.statusBarArea.width*0.85, 
		y = Layout.statusBarArea.centerY , 
		width = 0, 
		height = 0, 
		font = native.systemFont,
		align = "center" 
	} 
	self.baseHealthPointsText = display.newText( textOptions )
end

function _StatusBar:createCreditField( displayGroup )
end

function _StatusBar:createWaveField( displayGroup )
end

function _StatusBar:createLevelField( displayGroup )
end

function _StatusBar:setBaseHealthPoints( amount )
		self.baseHealthPointsText.text = amount .. " / " .. gameValues.maxBaseHealthPoints
end


return _StatusBar