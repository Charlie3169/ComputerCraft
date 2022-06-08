require('configs')
--require('os') -- this is automatically included on the turtles

currentX = 0
currentY = 0
currentZ = 0
currentDirection = {"+Z", "-X", "-Z", "+X"} --Idx 1,2,3,4
currentDirectionIndex = 0

TURTLE_DIRECTION_POS_X = 4
TURTLE_DIRECTION_POS_Z = 1
TURTLE_DIRECTION_NEG_X = 2
TURTLE_DIRECTION_NEG_Z = 3 

COORDINATES_TRACKED = false
MOVING_Y_AFTER_X_Z = false --Used when you want the robot to remain the same Y until X and Z are aligned
ENABLE_MINING_FOR_MOVING = false

SLEEP_SECS_FOR_MOVING = 5


function move(n) --moves n units forward
	finishedSleep = false
    stepsTaken = 0
	for i=1,n,1 do
        moved = turtle.forward()

		while not moved and not finishedSleep do
			bool,x = turtle.inspect()
			if turtle.detect() and ENABLE_MINING_FOR_MOVING then
				turtle.dig()
            else -- try sleeping to see if the block will become available
                finishedSleep = true
                os.sleep(SLEEP_SECS_FOR_MOVING)
            end
            moved = turtle.forward()
		end

        if moved then stepsTaken = stepsTaken + 1 end
	end
    return n-stepsTaken
end


function moveDown(n)
    finishedSleep = false
    stepsTaken = 0
	for i=1,n,1 do
        moved = turtle.down()
		while not moved and not finishedSleep do
			bool,x = turtle.inspectDown()
			if turtle.detectDown() and ENABLE_MINING_FOR_MOVING then
				turtle.digDown()
            else -- try sleeping to see if the block will become available
                finishedSleep = true
                os.sleep(SLEEP_SECS_FOR_MOVING)
            end
            moved = turtle.down()
		end

        if moved then stepsTaken = stepsTaken + 1 end
	end
    return n-stepsTaken
end


function moveUp(n)
	finishedSleep = false
    stepsTaken = 0
	for i=1,n,1 do
        moved = turtle.up()
		while not moved and not finishedSleep do
			bool,x = turtle.inspectUp()
			if turtle.detectUp() and ENABLE_MINING_FOR_MOVING then
				turtle.digUp()
            else -- try sleeping to see if the block will become available
                finishedSleep = true
                os.sleep(SLEEP_SECS_FOR_MOVING)
            end
            moved = turtle.up()
		end

        if moved then stepsTaken = stepsTaken + 1 end
	end
    return n-stepsTaken
end


function moveVertically(n)
    if n<0 then
        return -moveDown(-n)
    else
        return moveUp(n)
    end
end


--- Move to X,Y,Z from x,y,z
--- If x,y,z are not included, use coordinates that are tracked. 
--- If coordinates not tracked, throw an error.
-- @param X: target x coordinate
-- @param Y: target y coordinate
-- @param Z: target z coordinate
-- @param (optional) x: starting x coordinate
-- @param (optional) y: starting y coordinate
-- @param (optional) z: starting z coordinate
function moveTo(X, Y, Z, x, y, z)
    x = x~=nil and x or (COORDINATES_TRACKED and currentX or x)
    y = y~=nil and y or (COORDINATES_TRACKED and currentY or y) 
    z = z~=nil and z or (COORDINATES_TRACKED and currentZ or z)
    assert(x~=nil, "No valid coordinate system. x is null in moveTo(coords).")
    assert(y~=nil, "No valid coordinate system. y is null in moveTo(coords).")
    assert(z~=nil, "No valid coordinate system. z is null in moveTo(coords).")
    n_x = X - x
    n_y = Y - y
    n_z = Z - z 

    stillNeedsToMove = n_x~=0 or n_y~=0 or n_z~=0

    while stillNeedsToMove do 

        thisLoopX = n_x
        thisLoopY = n_y
        thisLoopZ = n_z        
    
        if n_x ~= 0 then --trying to move in the x direction
            isNegative = n_x < 0
            offset = 0
            if (currentDirectionIndex == TURTLE_DIRECTION_NEG_X and n_x > 0) or (currentDirectionIndex == TURTLE_DIRECTION_POS_X and n_x < 0) then
                turtle.turnLeft()
                turtle.turnLeft()
                offset = 2
            elseif (currentDirectionIndex == TURTLE_DIRECTION_POS_Z and n_x > 0) or (currentDirectionIndex == TURTLE_DIRECTION_NEG_Z and n_x < 0) then
                turtle.turnLeft()
                offset = -1
            elseif (currentDirectionIndex == TURTLE_DIRECTION_POS_Z and n_x < 0) or (currentDirectionIndex == TURTLE_DIRECTION_NEG_Z and n_x > 0) then
                turtle.turnRight()
                offset = 1         
            end
            currentDirectionIndex = (currentDirectionIndex + offset) % #(currentDirection)
            if isNegative then 
                n_x = -move(-n_x) 
            else
                n_x = move(n_x)
            end
        end

        if n_z ~= 0 then --trying to move in the z direction
            isNegative = n_z < 0
            offset = 0
            if (currentDirectionIndex == TURTLE_DIRECTION_NEG_Z and n_z > 0) or (currentDirectionIndex == TURTLE_DIRECTION_POS_Z and n_z < 0) then
                turtle.turnLeft()
                turtle.turnLeft()
                offset = 2
            elseif (currentDirectionIndex == TURTLE_DIRECTION_POS_X and n_z < 0) or (currentDirectionIndex == TURTLE_DIRECTION_NEG_X and n_z > 0) then
                turtle.turnLeft()
                offset = -1
            elseif (currentDirectionIndex == TURTLE_DIRECTION_POS_X and n_z > 0) or (currentDirectionIndex == TURTLE_DIRECTION_NEG_X and n_z < 0) then
                turtle.turnRight()
                offset = 1            
            end
            currentDirectionIndex = (currentDirectionIndex + offset) % #(currentDirection)
            if isNegative then 
                n_z = -move(-n_z) 
            else
                n_z = move(n_z)
            end
        end

        if n_y ~= 0 then --trying to move in the y direction
            if (MOVING_Y_AFTER_X_Z and n_x == 0 and x_z == 0) or not MOVING_Y_AFTER_X_Z then
                n_y = moveVertically(n_y)
            end
        end

        -- If the turtle hasn't moved, try enabling movement in the y direction, or enable mining.
        if thisLoopX == n_x and thisLoopY == n_y and thisLoopZ == n_z then
            if not MOVING_Y_AFTER_X_Z then 
                MOVING_Y_AFTER_X_Z = true
            elseif not ENABLE_MINING_FOR_MOVING then 
                ENABLE_MINING_FOR_MOVING = true
            else
                ENABLE_MINING_FOR_MOVING = false
                MOVING_Y_AFTER_X_Z = false
                print("Cannot move to location.")
                Exit()
            end
        end

        stillNeedsToMove = n_x~=0 or n_y~=0 or n_z~=0
    end

end

