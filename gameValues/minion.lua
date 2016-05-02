local Layout = require('libs.layout')

local _M = {}

_M.healthBarWidth = Layout.mapArea.width*0.05
_M.healthBarHeight = Layout.mapArea.width*0.02

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
_M.basicMinionMaxHP = 500
_M.basicMinionUnitsMovedPerFrame = 1
_M.basicMinionDamage = 20

-- Light minion values
_M.lightMinionMaxHP = 300
_M.lightMinionUnitsMovedPerFrame = 3
_M.lightMinionDamage = 10

-- Heavy minion values
_M.heavyMinionMaxHP = 1000
_M.heavyMinionUnitsMovedPerFrame = 0.6
_M.heavyMinionDamage = 30

-- Boss1 minion values
_M.boss1MinionMaxHP = 10000
_M.boss1MinionUnitsMovedPerFrame = 0.6
_M.boss1MinionDamage = 100

return _M