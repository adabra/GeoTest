local Layout = require('libs.layout')

local _M = {}

_M.healthBarWidth = Layout.mapArea.width*0.05
_M.healthBarHeight = Layout.mapArea.width*0.02
_M.basicMinionMaxHP = 1000
_M.basicMinionUnitsMovedPerFrame = 1
_M.basicMinionDamage = 20
_M.statusWaiting = "waiting"
_M.statusMoving = "moving"
_M.statusDone = "done"
_M.statusDead = "dead"
_M.typeBasicMinion = "basic"

return _M