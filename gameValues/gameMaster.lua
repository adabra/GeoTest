_M = {}

_M.waveCountdownTime = 20
_M.maxBaseHealthPoints = 100
_M.creditStartAmount = 100
_M.goldCoinAmount = 10
_M.basicTowerCost = 30
_M.startGameCountdown = 20
_M.firstWave = 1


-- Game States
_M.stateWaiting = "stateWaiting" -- Game not started
_M.statebaseDestroyed = "baseDestroyed"
_M.stateGameCountdown = "gameCountdown"

--Wave balancing--

-- Time from first minion spawns to last minion (potentially) reaches goal
_M.waveTime = 0

-- Time from a minion spawns until said minion (potentially) reaches goal
_M.pathTime = 0

-- Number of minions spawned per wave
_M.minionsPerWave = 0


return _M