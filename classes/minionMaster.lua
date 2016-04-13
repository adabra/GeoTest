local Minion = require('classes.minion')
local gameValues = require('gameValues.minion')

local _MinionMaster = {}

function _MinionMaster:new( displayGroup, gameMap )
	local minionMaster = {displayGroup = displayGroup, gameMap = gameMap}
	minionMaster.minionDamage = { basic = gameValues.basicMinionDamage }
	setmetatable( minionMaster, self )
	self.__index = self
	
	minionMaster.minions = {}
	return minionMaster
end

function _MinionMaster:createMinion( minionType )
	if (minionType == gameValues.typeBasicMinion) then
		self:createBasicMinion()
	end
end

function _MinionMaster:createBasicMinion()
	self:newMinion( Minion:new( self.displayGroup, self.gameMap , self, gameValues.typeBasicMinion) )
end

function _MinionMaster:newMinion( minion )
	table.insert(self.minions, minion)
	
	--self.waitingMinions[#self.waitingMinions+1] = minion
end

function _MinionMaster:sendNextMinion()
	for k,minion in pairs(self.minions) do
		if ( minion:getStatus() == gameValues.statusWaiting ) then
			minion:start()
			return true
		end
	end
	
	return false

	--local nextMinion = self.waitingMinions[#self.waitingMinions]
	--self.waitingMinions[#self.waitingMinions] = nil
	
	--self.movingMinions[#self.movingMinions+1] = nextMinion
end

function _MinionMaster:cleanUpMinion( minion )
end


function _MinionMaster:moveMinions()
	for k,minion in pairs(self.minions) do
		if (minion:getStatus() == gameValues.statusMoving) then
			minion:move()
		end
	end
end

function _MinionMaster:setGameMaster( gameMaster )
	self.gameMaster = gameMaster
end

function _MinionMaster:attackedBase( minionType )
	self.gameMaster:decreaseBaseHealthPoints( self.minionDamage[minionType])
end

return _MinionMaster