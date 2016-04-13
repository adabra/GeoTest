local _TowerMaster = {}

function _TowerMaster:new( minionMaster )
	local towerMaster = { minionMaster = minionMaster }
	setmetatable( towerMaster, self )
	self.__index = self
	towerMaster.towers = {}
	return towerMaster
end


function _TowerMaster:operateTowers()
	for k,tower in pairs(self.towers) do
		tower:findTargets( self.minionMaster.minions )
	end
end

function _TowerMaster:addTower( tower )
	table.insert( self.towers, tower )
end

return _TowerMaster