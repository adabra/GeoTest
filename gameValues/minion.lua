local Layout = require('libs.layout')
local utils = require('libs.utils')

local _M = {}

_M.healthBarWidth = Layout.mapArea.width*0.05
_M.healthBarHeight = Layout.mapArea.width*0.01

-- Minion statuses
_M.statusWaiting = "waiting"
_M.statusMoving = "moving"
_M.statusDone = "done"
_M.statusDead = "dead"

-- Minion types
_M.typeBasicMinion = "basic"
_M.typeLightMinion = "light"
_M.typeHeavyMinion = "heavy"
_M.typeBoss1Minion = "boss1"

-- Basic minion values
_M.basicMinionMaxHP = 250
_M.basicMinionMetersPerSecond = 5
_M.basicMinionDamage = 20

-- Light minion values
_M.lightMinionMaxHP = 300
_M.lightMinionMetersPerSecond = 9
_M.lightMinionDamage = 10

-- Heavy minion values
_M.heavyMinionMaxHP = 1000
_M.heavyMinionMetersPerSecond = 3
_M.heavyMinionDamage = 30

-- Boss1 minion values
_M.boss1MinionMaxHP = 10000
_M.boss1MinionMetersPerSecond = 2
_M.boss1MinionDamage = 100

---------------------
_M.typeMinion0Minion = "minion0"
_M.minion0MinionMetersPerSecond = 5
_M.minion0MinionDamage = 5
_M.minion0MinionMaxHP = 250

local extraHP = 300
for i=1,7 do
	_M['typeMinion'..i..'Minion'] = 'minion'..i
	_M['minion'..i..'MinionMetersPerSecond'] = _M.minion0MinionMetersPerSecond 
	_M['minion'..i..'MinionDamage'] = _M['minion'..(i-1)..'MinionDamage'] + 5
	_M['minion'..i..'MinionMaxHP'] = _M['minion'..(i-1)..'MinionMaxHP'] + extraHP
	if i>4 then
		_M['minion'..i..'MinionMaxHP'] = _M['minion'..i..'MinionMaxHP'] + extraHP
	end
	print('minion'..i..': '.. _M['minion'..i..'MinionMaxHP'] .. '(+' .. _M['minion'..i..'MinionMaxHP'] - _M['minion'..(i-1)..'MinionMaxHP'] .. ')')
end

return _M