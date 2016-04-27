local Layout = require('libs.layout')
local colors = require('libs.colors')
local gameValuesGameMaster = require('gameValues.gameMaster')
local gameValues = require('gameValues.statusBar')
local StatusBarField = require('classes.statusBarField')

local _StatusBar = {}

function _StatusBar:new( displayGroup )
	local statusBar = {}
	setmetatable( statusBar, self )
	self.__index = self
	statusBar:init( displayGroup )
	return statusBar
end

function _StatusBar:init( displayGroup )
	self.remainingWidth = Layout.statusBarArea.width
	self:createBackground ( displayGroup )
	self.fields = {}

	self.baseHealthPointsField = StatusBarField:new( 
		displayGroup, 
		gameValuesGameMaster.maxBaseHealthPoints .. "/" .. gameValuesGameMaster.maxBaseHealthPoints, 
		"baseHealthPoints", 
		"baseHealthPoints" )
	self:addField( self.baseHealthPointsField )

	self.creditField = StatusBarField:new( 
		displayGroup, 
		gameValuesGameMaster.creditStartAmount, 
		"goldCoin", 
		"credits" )
	self:addField( self.creditField )

	self.waveField = StatusBarField:new(
		displayGroup,
		gameValuesGameMaster.firstWave,
		"wave",
		"wave")
	self:addField( self.waveField )
	--self:createWaveField( displayGroup )
end

function _StatusBar:addField( field )
	if (self:getRemainingWidth() >= field.width) then
		self:placeOnStatusBar( field )
		field:setVisible( true )
		table.insert(self.fields, field)
	else
		print("Couldn't add field " .. field.name .. ", statusbar width exceeded.")
	end
end

function _StatusBar:getRemainingWidth()
	return self.remainingWidth
end

function _StatusBar:placeOnStatusBar( field )
	local externalFieldPadding = 0
	if (#self.fields > 0) then
		externalFieldPadding = gameValues.externalFieldPadding
	else
		externalFieldPadding = gameValues.edgePadding
	end

	field:setPosition( self:getRemainingWidth() - field.width - externalFieldPadding )
	self.remainingWidth = self:getRemainingWidth() - field.width - externalFieldPadding
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
	text = gameValuesGameMaster.maxBaseHealthPoints .. " / " .. gameValuesGameMaster.maxBaseHealthPoints, 
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
	local textOptions = {
	parent = displayGroup, 
	text = gameValuesGameMaster.creditStartAmount, 
	x = Layout.statusBarArea.width*0.5, 
	y = Layout.statusBarArea.centerY , 
	width = 0, 
	height = 0, 
	font = native.systemFont,
	align = "center" 
	} 
	self.creditAmountText = display.newText( textOptions )
end

function _StatusBar:createWaveField( displayGroup )
end

function _StatusBar:createLevelField( displayGroup )
end

function _StatusBar:setBaseHealthPoints( amount )
	self.baseHealthPointsField:setText( amount .. "/" .. gameValuesGameMaster.maxBaseHealthPoints )
end

function _StatusBar:setCreditAmount( amount )
	self.creditField:setText( amount )
end

function _StatusBar:setWaveLevel( level )
	self.waveField:setText( level )
end

return _StatusBar