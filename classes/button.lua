local widget = require("widget")

local _Button = { 
      x = display.contentWidth/2,
      y = display.contentHeight/2,
      -- Visual options
      shape = "roundedrect",
      fillColor = { default={ 226/256, 91/256, 133/256 }, over={ 1, 0.2, 0.5, 1 } },
      strokeColor = { default={ 245/256, 152/256, 157/256 }, over={ 0.4, 0.1, 0.2 } },
      strokeWidth = 20,
      width = 500,
      height = 200,
      label = "DEFAULT LABEL",
      fontSize = 50,
      labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
      emboss = true,
      --Behavior
      onRelease = function()
      	print( "BUTTON PRESSED, NO ACTION SPECIFIED" )
      end
}

function _Button:new( o )
	local button = o or {}
	setmetatable( button, self )
	self.__index = self

	local widgetButton = widget.newButton( {
      x = button.x,
      y = button.y,
      -- Visual options
      shape = button.shape,
      fillColor = button.fillColor,
      strokeColor = button.strokeColor,
      strokeWidth = button.strokeWidth,
      width = button.width,
      height = button.height,
      label = button.label,
      fontSize = button.fontSize,
      labelColor = button.labelColor,
      emboss = button.emboss,
      --Behavior
      onRelease = button.onRelease
} )

	return widgetButton
end

return _Button

