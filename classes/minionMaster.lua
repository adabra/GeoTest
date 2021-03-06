local Minion = require('classes.minion')
local gameValuesMinion = require('gameValues.minion')
local gameValuesGameMaster = require('gameValues.gameMaster')
local gameValues = require('gameValues.minionMaster')
local widget = require('widget')
local utils = require('libs.utils')

local _MinionMaster = {}

function _MinionMaster:new( displayGroup, gameMap )
	local minionMaster = {displayGroup = displayGroup, gameMap = gameMap}
	setmetatable( minionMaster, self )
	self.__index = self
	minionMaster:init()
	return minionMaster
end

function _MinionMaster:init()
	self.minionDamage = { 
		basic = gameValuesMinion.basicMinionDamage, 
		light = gameValuesMinion.lightMinionDamage,
		heavy = gameValuesMinion.heavyMinionDamage,
		boss1 = gameValuesMinion.boss1MinionDamage }
	-------
	for i=0,9 do
			self.minionDamage['minion' .. i] = gameValuesMinion['minion'..i..'MinionDamage']
	end
	--------
	self.minions = {}
	self.waves = self:initWaves()
end

function _MinionMaster:setMinionSpeeds( mapWidth )
	self.basicMinionUnitsMovedPerFrame = utils.metersPerSecondToCoronaPixelsPerFrame(gameValuesMinion.basicMinionMetersPerSecond, mapWidth/display.contentWidth)--1
	self.lightMinionUnitsMovedPerFrame = utils.metersPerSecondToCoronaPixelsPerFrame(gameValuesMinion.lightMinionMetersPerSecond, mapWidth/display.contentWidth)--3
	self.heavyMinionUnitsMovedPerFrame = utils.metersPerSecondToCoronaPixelsPerFrame(gameValuesMinion.heavyMinionMetersPerSecond, mapWidth/display.contentWidth)--0.6
	self.boss1MinionUnitsMovedPerFrame = utils.metersPerSecondToCoronaPixelsPerFrame(gameValuesMinion.boss1MinionMetersPerSecond, mapWidth/display.contentWidth)--0.6

	-----
	for i=0,9 do
		self['minion'..i..'MinionUnitsMovedPerFrame'] = utils.metersPerSecondToCoronaPixelsPerFrame(gameValuesMinion['minion'..i..'MinionMetersPerSecond'], mapWidth/display.contentWidth)
	end
	-----
end

function _MinionMaster:createMinion( minionType )
	self:newMinion( Minion:new( self.displayGroup, self.gameMap , self, minionType) )
end

function _MinionMaster:newMinion( minion )
	table.insert(self.minions, minion)
	print("minion added: ")
	print(self.minions[#self.minions])
	--self.waitingMinions[#self.waitingMinions+1] = minion
end

function _MinionMaster:initWaves()
	local waves = {}

	for i=0,9 do
		table.insert( waves, {
			timeBetweenMinions = 2000,
			{minionType=gameValuesMinion['typeMinion'..i..'Minion'], numberOfMinions =5}
			})
	end
	--[[
	table.insert( waves, { 
		timeBetweenMinions = 1650,
		{minionType = gameValuesMinion.typeBasicMinion, numberOfMinions = 5}
		} )
	table.insert( waves, {
		timeBetweenMinions = 1500,
		{minionType = gameValuesMinion.typeBasicMinion, numberOfMinions = 3},
		{minionType = gameValuesMinion.typeLightMinion, numberOfMinions = 3},
		{minionType = gameValuesMinion.typeBasicMinion, numberOfMinions = 3},
		{minionType = gameValuesMinion.typeLightMinion, numberOfMinions = 3},
		} ) 
	
	table.insert( waves, {
		timeBetweenMinions = 500,
		{minionType = "basic", numberOfMinions = 1}
		} ) 
	table.insert( waves, {
		timeBetweenMinions = 500,
		{minionType = "basic", numberOfMinions = 1}
		} ) 
	table.insert( waves, {
		timeBetweenMinions = 500,
		{minionType = "basic", numberOfMinions = 1}
		} ) 
	table.insert( waves, {
		timeBetweenMinions = 500,
		{minionType = "basic", numberOfMinions = 1}
		} ) 
	table.insert( waves, {
		timeBetweenMinions = 500,
		{minionType = "basic", numberOfMinions = 1}
		} ) 
	table.insert( waves, {
		timeBetweenMinions = 500,
		{minionType = "basic", numberOfMinions = 1}
		} ) 
	table.insert( waves, {
		timeBetweenMinions = 500,
		{minionType = "basic", numberOfMinions = 1}
		} ) 

--]]

	for i=1,#waves do
		waves[i].totalNumberOfMinions = 0
		for j=1,#waves[i] do
			waves[i].totalNumberOfMinions = waves[i].totalNumberOfMinions + waves[i][j].numberOfMinions
		end
	end
--[[
	local options = {
		x = 100,
		y = 100,
		onPress = function() self:wavePrint() return true end,
		label = "print wave",
		shape = 'rect',
		fillColor = {default = {0,0,0}, over = {0.5,0.5,0.5}}
	}
	self.wavePrintButton = widget.newButton( options )
--]]

	self.numberOfWaves = #waves
	return waves
end

function _MinionMaster:wavePrint()
	for i=1,#self.minions do
		print(self.minions[i])
	end
	print("--------")
end

function _MinionMaster:createWave( waveLevel )
	self.lastWave = false

	if (self.numberOfWaves == waveLevel) then
		self.lastWave = true
	end

	local waveBlueprint = self.waves[waveLevel]

	for subWave=1,#waveBlueprint do
		for minion=1,waveBlueprint[subWave].numberOfMinions do
			self:createMinion( waveBlueprint[subWave].minionType )
		end
	end
end

function _MinionMaster:clearWave()
	self:wavePrint()
	for i=1,#self.minions do
		local minion = self.minions[i]
		minion:hide()
		minion:cleanUp()

	end
	self.minion = {}
end


function _MinionMaster:sendNextMinion()
	for k,minion in pairs(self.minions) do
		if ( minion:getStatus() == gameValuesMinion.statusWaiting ) then
			minion:start()
			return true
		end
	end
	
	return false

	--local nextMinion = self.waitingMinions[#self.waitingMinions]
	--self.waitingMinions[#self.waitingMinions] = nil
	
	--self.movingMinions[#self.movingMinions+1] = nextMinion
end

function _MinionMaster:sendWave( waveLevel )
	self.activeMinions = self.waves[waveLevel].totalNumberOfMinions
	self:createWave( waveLevel )
	print("Total number of minions: " .. self.waves[waveLevel].totalNumberOfMinions)
	print("Time between minions: " .. self.waves[waveLevel].timeBetweenMinions*(1/gameValuesGameMaster.timeWarp))
	timer.performWithDelay( 
		self.waves[waveLevel].timeBetweenMinions*(1/gameValuesGameMaster.timeWarp), 
		
		function() 
			self:sendNextMinion() 
		end, 

		self.waves[waveLevel].totalNumberOfMinions )
end

function _MinionMaster:cleanUpMinion( minion )
end


function _MinionMaster:moveMinions()
	for k,minion in pairs(self.minions) do
		if (minion:getStatus() == gameValuesMinion.statusMoving) then
			minion:move()
		end
	end
end

function _MinionMaster:damageMinions( amount, percent )
	for k,minion in pairs(self.minions) do
		if minion:getStatus() == gameValuesMinion.statusMoving then
			minion:takeDamage( amount, percent )
		end
	end
end

function _MinionMaster:setGameMaster( gameMaster )
	self.gameMaster = gameMaster
end

function _MinionMaster:attackedBase( minionType )
	self:fireGameEvent( {eventType = gameValues.eventTypeMinionAttacking, amount = self.minionDamage[minionType]})
	self:minionDone()
end

function _MinionMaster:died()
	self:minionDone()
end

function _MinionMaster:minionDone()
	self.activeMinions = self.activeMinions - 1
	if self.activeMinions == 0 then
		if self.lastWave then
			self:fireGameEvent( {eventType= gameValues.eventTypeGameWon} )
		else
			self:fireGameEvent( {eventType = gameValues.eventTypeWaveDone } )
		end
	end
end

function _MinionMaster:addGameEventListener( listener )
	if not self.gameEventListeners then
		self.gameEventListeners = {}
	end
	table.insert(self.gameEventListeners, listener)
end

function _MinionMaster:fireGameEvent( event )
	for k,listener in pairs(self.gameEventListeners) do
		listener:handleGameEvent( event )
	end
end

return _MinionMaster