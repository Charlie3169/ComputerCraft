-- The zone where we don't want turtles to mine
-- Format is x,y,z,X,Y,Z and should be from one corner to another
HOME_ZONE_COORDS = {0, 0, 0, 1, 1, 1}

--- This function populates HOME_ZONE_COORDS given the initial parameters.
--- Enforces that x < X, y < Y, z < Z after calculations.
-- @param x: starting x coordinate
-- @param y: starting y coordinate
-- @param z: starting z coordinate
-- @param n_x: number of blocks to extend in x direction
-- @param n_y: number of blocks to extend in y direction
-- @param n_z: number of blocks to extend in z direction
-- @param (optional) startFromMiddleX: flag that says that the starting x coordinate should be applied forward AND backwards (i.e. starting from the middle)
-- @param (optional) startFromMiddleY: flag that says that the starting y coordinate should be applied forward AND backwards (i.e. starting from the middle)
-- @param (optional) startFromMiddleZ: flag that says that the starting z coordinate should be applied forward AND backwards (i.e. starting from the middle)
function homeZonePropogation(x, y, z, n_x, n_y, n_z, startFromMiddleX, startFromMiddleY, startFromMiddleZ)
    startFromMiddleX = startFromMiddleX or false --defaults to false
    startFromMiddleY = startFromMiddleY or false --defaults to false
    startFromMiddleZ = startFromMiddleZ or false --defaults to false
    newX = startFromMiddleX and (x - n_x) or x -- inline conditional
    newY = startFromMiddleY and (y - n_y) or y
    newZ = startFromMiddleZ and (z - n_z) or z
    X = x + n_x
    Y = y + n_y
    Z = z + n_z
    x = math.min(newX, X)
    y = math.min(newY, Y)
    z = math.min(newZ, Z)
    X = math.max(newX, X)
    Y = math.max(newY, Y)
    Z = math.max(newZ, Z)
    HOME_ZONE_COORDS = {x, y, z, X, Y, Z}
end