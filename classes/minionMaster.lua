local Minion = require('classes.minion')
local gameValuesMinion = require('gameValues.minion')
local gameValues = require('gameValues.minionMaster')

local _MinionMaster = {}

function _MinionMaster:new( displayGroup, gameMap )
	local minionMaster = {displayGroup = displayGroup, gameMap = gameMap}
	setmetatable( minionMaster, self )
	self.__index = self
	minionMaster:init()
	return minionMaster
end

function _MinionMaster:init()
	self.minionDamage = { basic = gameValuesMinion.basicMinionDamage }
	self.minions = {}
	self.waves = self:initWaves()
end

function _MinionMaster:createMinion( minionType )
	if (minionType == gameValuesMinion.typeBasicMinion) then
		self:createBasicMinion()
	end
end

function _MinionMaster:createBasicMinion()
	self:newMinion( Minion:new( self.displayGroup, self.gameMap , self, gameValuesMinion.typeBasicMinion) )
end

function _MinionMaster:newMinion( minion )
	table.insert(self.minions, minion)
	
	--self.waitingMinions[#self.waitingMinions+1] = minion
end

function _MinionMaster:initWaves()
	local waves = {}
	waves[1] = { 
		timeBetweenMinions = 500,
		{minionType = "basic", numberOfMinions = 1},
		{minionType = "basic", numberOfMinions = 1} } 
	waves[2] = {
		timeBetweenMinions = 2000,
		{minionType = "basic", numberOfMinions = 10}
	}	


	for i=1,#waves do
		waves[i].totalNumberOfMinions = 0
		for j=1,#waves[i] do
			waves[i].totalNumberOfMinions = waves[i].totalNumberOfMinions + waves[i][j].numberOfMinions
		end
	end

	self.numberOfWaves = #waves
	return waves
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
	print("Time between minions: " .. self.waves[waveLevel].timeBetweenMinions)
	timer.performWithDelay( 
		self.waves[waveLevel].timeBetweenMinions, 
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