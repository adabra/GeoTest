local _M = {}

_M.typeBasicLevel1 = "basicLevel1"

_M.typeDamageLevel2 = "damageLevel2"
_M.typeDamageLevel3 = "damageLevel3"
_M.typeDamageLevel4 = "damageLevel4"
_M.typeDamageLevel5 = "damageLevel5"

_M.typeRangeLevel2 = "rangeLevel2"
_M.typeRangeLevel3 = "rangeLevel3"
_M.typeRangeLevel4 = "rangeLevel4"
_M.typeRangeLevel5 = "rangeLevel5"

_M.typeSlowLevel2 = "slowLevel2"
_M.typeSlowLevel3 = "slowLevel3"
_M.typeSlowLevel4 = "slowLevel4"
_M.typeSlowLevel5 = "slowLevel5"

_M.damageBasicLevel1 = 2

_M.damageDamageLevel2 = _M.damageBasicLevel1 * 2
_M.damageDamageLevel3 = _M.damageBasicLevel1 * 3
_M.damageDamageLevel4 = _M.damageBasicLevel1 * 4
_M.damageDamageLevel5 = _M.damageBasicLevel1 * 5

_M.damageRangeLevel2 = _M.damageBasicLevel1
_M.damageRangeLevel3 = _M.damageBasicLevel1
_M.damageRangeLevel4 = _M.damageBasicLevel1
_M.damageRangeLevel5 = _M.damageBasicLevel1

_M.damageSlowLevel2 = _M.damageBasicLevel1
_M.damageSlowLevel3 = _M.damageBasicLevel1
_M.damageSlowLevel4 = _M.damageBasicLevel1
_M.damageSlowLevel5 = _M.damageBasicLevel1

_M.slowBasicLevel1 = 1

_M.slowDamageLevel2 = _M.slowBasicLevel1
_M.slowDamageLevel3 = _M.slowBasicLevel1
_M.slowDamageLevel4 = _M.slowBasicLevel1
_M.slowDamageLevel5 = _M.slowBasicLevel1

_M.slowRangeLevel2 = _M.slowBasicLevel1
_M.slowRangeLevel3 = _M.slowBasicLevel1
_M.slowRangeLevel4 = _M.slowBasicLevel1
_M.slowRangeLevel5 = _M.slowBasicLevel1

_M.slowSlowLevel2 = _M.slowBasicLevel1*0.6
_M.slowSlowLevel3 = _M.slowBasicLevel1*0.5
_M.slowSlowLevel4 = _M.slowBasicLevel1*0.4
_M.slowSlowLevel5 = _M.slowBasicLevel1*0.3

_M.rangeBasicLevel1 = 1.5

_M.rangeDamageLevel2 = _M.rangeBasicLevel1
_M.rangeDamageLevel3 = _M.rangeBasicLevel1
_M.rangeDamageLevel4 = _M.rangeBasicLevel1
_M.rangeDamageLevel5 = _M.rangeBasicLevel1

_M.rangeRangeLevel2 = _M.rangeBasicLevel1*2
_M.rangeRangeLevel3 = _M.rangeBasicLevel1*3
_M.rangeRangeLevel4 = _M.rangeBasicLevel1*4
_M.rangeRangeLevel5 = _M.rangeBasicLevel1*5

_M.rangeSlowLevel2 = _M.rangeBasicLevel1
_M.rangeSlowLevel3 = _M.rangeBasicLevel1
_M.rangeSlowLevel4 = _M.rangeBasicLevel1
_M.rangeSlowLevel5 = _M.rangeBasicLevel1



_M.imagePath = "/images/game_objects/"
_M.pathTowerImageSheet = "/images/game_objects/towers.png"
_M.imageExtension = ".png"
_M.itemSizeModifier = 0.06

return _M