local Set = require('libs.set')

local _TowerMaster = {}

function _TowerMaster:new( minionMaster )
	local towerMaster = { minionMaster = minionMaster }
	setmetatable( towerMaster, self )
	self.__index = self
	towerMaster.towers = {}
	return towerMaster
end


function _TowerMaster:operateTowers()
	for i=1,#self.towers do
		self.towers[i]:findTargets( self.minionMaster.minions )
	end
end

function _TowerMaster:addTower( tower )
	Set.addToSet( self.towers, tower )
end

function _TowerMaster:removeTower( tower )
	Set.removeFromSet( self.towers, tower )
end

return _TowerMaster