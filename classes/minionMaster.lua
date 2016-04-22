local Minion = require('classes.minion')
local gameValuesMinion = require('gameValues.minion')
local gameValues = require('gameValues.minionMaster')

local _MinionMaster = {}

function _MinionMaster:new( displayGroup, gameMap )
	local minionMaster = {displayGroup = displayGroup, gameMap = gameMap}
	minionMaster.minionDamage = { basic = gameValuesMinion.basicMinionDamage }
	setmetatable( minionMaster, self )
	self.__index = self
	
	minionMaster.minions = {}
	return minionMaster
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
	timer.performWithDelay( 
		self.waves[waveLevel].timeBetweenMinions, 
		function() 
			self:sendNextMinion() 
		end, 
		self.waves[waveLevel].numberOfMinions )
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
		self:fireGameEvent( {eventType = gameValues.eventTypeWaveDone } )
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