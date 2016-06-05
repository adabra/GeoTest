local Layout = require('libs.layout')

local _M = {}

_M.itemSizeModifier = 0.06 
_M.goldCoinScale = 0.5
_M.itemPath = "images/game_objects/"
_M.itemExtension = ".png"
_M.pathGoldCoinImageSheet = "images/game_objects/goldCoin.png"
_M.sequenceGoldCoin = "goldCoin"

_M.pathZapperImage = "images/game_objects/zapper.png"
_M.pathHpPackImage = "images/game_objects/hpPack.png"


_M.typeGoldCoin = "goldCoin"
_M.typeZapper = "zapper"
_M.typeHpPack = "hpPack"

_M.goldCoinTimer = 14000
_M.zapperTimer = 14000
_M.hpPackTimer = 14000


_M.durationBarHeight = Layout.mapArea.width*0.01
_M.durationBarWidth = Layout.mapArea.width*0.05

_M.eventTypeItemCleanedUp = "itemCleanedUp"

return _M