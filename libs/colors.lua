local _M = {}

_M.gridOrange = { 250/256, 180/256, 30/256 }
_M.controlPanelGrey = { 96/250, 112/256, 117/256 }
_M.controlPanelButtonDown = {73/256, 87/256, 92/256 }
_M.controlPanelButtonStroke = {69/256, 143/256, 168/256 }
_M.pathTileBrown = { 0.9, 0.7, 0.5 }
_M.startTileBlue = { 66/256, 192/256, 235/256 }
_M.endTileRed = { 235/256, 102/256, 66/256 }
_M.buildPosGreen = {0, 1, 0}
_M.cancelRed = {1, 0, 0}
_M.basicLaser = {1, 0, 0}
_M.damageLaser = {187/256, 108/256, 46/256}--{163/256, 99/256, 49/256}
_M.rangeLaser = {124/256, 152/256, 101/256}--{101/256, 128/256, 79/256}
_M.slowLaser = {62/256, 136/256, 161/256}--{51/256, 114/256, 135/256}

for k,v in pairs(_M) do
	v.r = v[1]
	v.g = v[2]
	v.b = v[3]
end



return _M