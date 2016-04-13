local _M ={ statusBarArea = {}, mapArea = {}, controlPanelArea = {} }

_M.statusBarArea.width = display.contentWidth
_M.statusBarArea.height = display.contentHeight*0.05
_M.statusBarArea.centerX = _M.statusBarArea.width/2
_M.statusBarArea.centerY = _M.statusBarArea.height/2

_M.statusBarArea.minX = _M.statusBarArea.centerX - _M.statusBarArea.width/2
_M.statusBarArea.maxX = _M.statusBarArea.centerX + _M.statusBarArea.width/2
_M.statusBarArea.minY = _M.statusBarArea.centerY - _M.statusBarArea.height/2
_M.statusBarArea.maxY = _M.statusBarArea.centerY + _M.statusBarArea.height/2

_M.mapArea.width = display.contentWidth
_M.mapArea.height = display.contentHeight*0.7
_M.mapArea.centerX = _M.mapArea.width/2
_M.mapArea.centerY = _M.statusBarArea.height + _M.mapArea.height/2

_M.mapArea.minX = _M.mapArea.centerX - _M.mapArea.width/2
_M.mapArea.maxX = _M.mapArea.centerX + _M.mapArea.width/2
_M.mapArea.minY = _M.mapArea.centerY - _M.mapArea.height/2
_M.mapArea.maxY = _M.mapArea.centerY + _M.mapArea.height/2

_M.controlPanelArea.width = display.contentWidth
_M.controlPanelArea.height = display.contentHeight - _M.statusBarArea.height - _M.mapArea.height
_M.controlPanelArea.centerX = _M.controlPanelArea.width/2
_M.controlPanelArea.centerY = _M.statusBarArea.height + _M.mapArea.height + _M.controlPanelArea.height/2

_M.controlPanelArea.minX = _M.controlPanelArea.centerX - _M.controlPanelArea.width/2
_M.controlPanelArea.maxX = _M.controlPanelArea.centerX + _M.controlPanelArea.width/2
_M.controlPanelArea.minY = _M.controlPanelArea.centerY - _M.controlPanelArea.height/2
_M.controlPanelArea.maxY = _M.controlPanelArea.centerY + _M.controlPanelArea.height/2

return _M 