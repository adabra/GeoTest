local _M = {}


_M.path = "/audio/"
_M.mp3 = ".mp3"
_M.wav = ".wav"

function _M:loadSound( name, fileType )
	local fileType = fileType or self.mp3
	return audio.loadSound( self.path .. name .. fileType )
end

_M.isLaserPlaying = false


_M.powerUpSpawned = "powerUpSpawned"
_M.powerUpPickedUp = "powerUpPickedUp"
_M.zapperUsed = "zapperUsed"
_M.gameWon = "gameWon"
_M.gameLost = "gameLost"
_M.laserFire = "laserFire"
_M.minionAttack = "minionAttack"
_M.minionDead = "minionDead"

_M.soundPowerUpSpawned = _M:loadSound( _M.powerUpSpawned, _M.wav )
_M.soundPowerUpPickedUp = _M:loadSound( _M.powerUpPickedUp )
_M.soundZapperUsed = _M:loadSound( _M.zapperUsed)
_M.soundGameWon = _M:loadSound( _M.gameWon, _M.wav )
_M.soundGameLost = _M:loadSound ( _M.gameLost, _M.wav ) 
_M.soundLaserFire = _M:loadSound( _M.laserFire)
_M.soundMinionAttack = _M:loadSound( _M.minionAttack )
_M.soundMinionDead = _M:loadSound( _M.minionDead )

return _M