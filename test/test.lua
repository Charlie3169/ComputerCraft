package.path = package.path .. ";../lib/?.lua"
require('mining')

UNLOADING_STATION_COORDS = {-657,119,731,3}
REFUELING_STATION_COORDS = {-657,119,731,1}

currentX = -653
currentY = 120
currentZ = 736
currentDirectionIndex = 3
COORDINATES_TRACKED = true

targetDig = {-653,119,731}

moveTo(targetDig[1],targetDig[2],targetDig[3])
digArea(2,-1,2,-1)