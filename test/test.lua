package.path = package.path .. ";../lib/?.lua"
require('mining')

UNLOADING_STATION_COORDS = {-662,123,729,TURTLE_DIRECTION_NEG_Z}
REFUELING_STATION_COORDS = {-662,123,729,TURTLE_DIRECTION_POS_Z}

currentX = -653
currentY = 120
currentZ = 736
currentDirectionIndex = 3
COORDINATES_TRACKED = true
MOVING_Y_AFTER_X_Z = false --Used when you want the robot to remain the same Y until X and Z are aligned
OFFSET_Y_BEFORE_MOVING = 10
ENABLE_MINING_FOR_MOVING = false
ASSERT_NO_MINING_FOR_MOVING = false --Used when it absolutely shouldn't mine to escape

SLEEP_SECS_FOR_MOVING = 1

targetDig = {-653,119,742}

moveTo(targetDig[1],targetDig[2],targetDig[3])
digArea(35,-30,35,-15)
