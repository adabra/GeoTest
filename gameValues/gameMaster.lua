local _M = {}

_M.gameCountdownTime = 5
_M.waveCountdownTime = 20
_M.maxBaseHealthPoints = 100
_M.creditStartAmount = 1000
_M.goldCoinAmount = 10
_M.startGameCountdown = 20
_M.firstWave = 1

_M.damageLevel2 = "damageLevel2"
_M.damageLevel3 = "damageLevel3"
_M.damageLevel4 = "damageLevel4"
_M.damageLevel5 = "damageLevel5"

_M.rangeLevel2 = "rangeLevel2"
_M.rangeLevel3 = "rangeLevel3"
_M.rangeLevel4 = "rangeLevel4"
_M.rangeLevel5 = "rangeLevel5"

_M.slowLevel2 = "slowLevel2"
_M.slowLevel3 = "slowLevel3"
_M.slowLevel4 = "slowLevel4"
_M.slowLevel5 = "slowLevel5"

_M.basicLevel1Cost = 30

_M.damageLevel2Cost = _M.basicLevel1Cost
_M.damageLevel3Cost = _M.damageLevel2Cost
_M.damageLevel4Cost = _M.damageLevel2Cost
_M.damageLevel5Cost = _M.damageLevel2Cost

_M.rangeLevel2Cost = 30
_M.rangeLevel3Cost = _M.rangeLevel2Cost
_M.rangeLevel4Cost = _M.rangeLevel2Cost
_M.rangeLevel5Cost = _M.rangeLevel2Cost

_M.slowLevel2Cost = 30
_M.slowLevel3Cost = _M.slowLevel2Cost
_M.slowLevel4Cost = _M.slowLevel2Cost
_M.slowLevel5Cost = _M.slowLevel2Cost


_M.basicLevel1Value = _M.basicLevel1Cost

local towerTypes = {"damage", "range", "slow"}
for k,towerType in pairs(towerTypes) do
	for i=2,5 do
		_M[towerType .. 'Level' .. i .. 'Value'] = _M.basicLevel1Value*2
		for j=2,5 do
			if j<i then
				_M[towerType .. 'Level' .. i .. 'Value'] = _M[towerType .. 'Level' .. i .. 'Value'] + _M[towerType .. 'Level' .. j .. 'Cost']
			end
		end
	end
end

_M.printTowerRefundvalues = function()
	for k,towerType in pairs(towerTypes) do
		for i=2,5 do
			print(towerType .. 'Level' .. i .. 'Value' .. ":" .. _M[towerType .. 'Level' .. i .. 'Value'])
		end
	end
end


-- Game States
_M.stateWaiting = "stateWaiting" -- Game not started
_M.statebaseDestroyed = "baseDestroyed"
_M.stateGameCountdown = "gameCountdown"
_M.stateOngoingWave = "ongoingWave"

--Wave balancing--

-- Time from first minion spawns to last minion (potentially) reaches goal
_M.waveTime = 0

-- Time from a minion spawns until said minion (potentially) reaches goal
_M.pathTime = 0

-- Number of minions spawned per wave
_M.minionsPerWave = 0


return _M