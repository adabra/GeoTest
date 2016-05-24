local Layout = require('libs.layout')
local utils = require('libs.utils')

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
_M.basicMinionMaxHP = 280
_M.basicMinionMetersPerSecond = 5
--_M.basicMinionUnitsMovedPerFrame = utils.metersPerSecondToCoronaPixelsPerFrame(_M.basicMinionMetersPerSecond, 96.5/display.contentWidth)--1
--print("basic minion speed, " .. _M.basicMinionMetersPerSecond .. " = " .. _M.basicMinionUnitsMovedPerFrame .. "units per frame")
_M.basicMinionDamage = 20

-- Light minion values
_M.lightMinionMaxHP = 300
_M.lightMinionMetersPerSecond = 9
--_M.lightMinionUnitsMovedPerFrame = utils.metersPerSecondToCoronaPixelsPerFrame(_M.lightMinionMetersPerSecond, 96.5/display.contentWidth)--3
--print("light minion speed, " .. _M.lightMinionMetersPerSecond .. " = " .. _M.lightMinionUnitsMovedPerFrame .. "units per frame")
_M.lightMinionDamage = 10

-- Heavy minion values
_M.heavyMinionMaxHP = 1000
_M.heavyMinionMetersPerSecond = 3
--_M.heavyMinionUnitsMovedPerFrame = utils.metersPerSecondToCoronaPixelsPerFrame(_M.heavyMinionMetersPerSecond, 96.5/display.contentWidth)--0.6
--print("heavy minion speed, " .. _M.heavyMinionMetersPerSecond .. " = " .. _M.heavyMinionUnitsMovedPerFrame .. "units per frame")
_M.heavyMinionDamage = 30

-- Boss1 minion values
_M.boss1MinionMaxHP = 10000
_M.boss1MinionMetersPerSecond = 2
--_M.boss1MinionUnitsMovedPerFrame = utils.metersPerSecondToCoronaPixelsPerFrame(_M.boss1MinionMetersPerSecond, 96.5/display.contentWidth)--0.6
--print("boss1 minion speed, " .. _M.boss1MinionMetersPerSecond .. " = " .. _M.boss1MinionUnitsMovedPerFrame .. "units per frame")
_M.boss1MinionDamage = 100

return _M