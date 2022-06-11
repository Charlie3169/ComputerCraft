require('configs')
--require('os') -- this is automatically included on the turtles

currentX = 0
currentY = 0
currentZ = 0
currentDirection = {"+Z", "-X", "-Z", "+X"} --Idx 1,2,3,4
currentDirectionIndex = 0

--Make this go 1 2 3 4 if you can
TURTLE_DIRECTION_POS_X = 4 --East
TURTLE_DIRECTION_POS_Z = 1 --South
TURTLE_DIRECTION_NEG_X = 2 --West
TURTLE_DIRECTION_NEG_Z = 3 --North


COORDINATES_TRACKED = false 
-- Honestly we might as well always at least track coords relative to the starting position
-- Once we get GPS going we can just correctly initialize them

MOVING_Y_AFTER_X_Z = false --Used when you want the robot to remain the same Y until X and Z are aligned
ENABLE_MINING_FOR_MOVING = false
ASSERT_NO_MINING_FOR_MOVING = false --Used when it absolutely shouldn't mine to escape

SLEEP_SECS_FOR_MOVING = 5


function isFacingX()
    return currentDirectionIndex % 2 == 0
end


function isFacingZ()
    return currentDirectionIndex % 2 == 1
end



-- moves n units forward
-- Ensures n is positive. If n is negative, return the difference as a negative.
-- (i.e. if n is 3 and it moves 2, return -1)
function move(n) 
	finishedSleep = false
    stepsTaken = 0
    isNegative = n < 0
    n = math.abs(n)
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
    return isNegative and -(n-stepsTaken) or (n-stepsTaken)
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
--- If ENABLE_MINING_FOR_MOVING is true, the turtle will mine in front of it to move
--- * This makes it very easy to mine out an area using this function.
-- @param X: target x coordinate
-- @param Y: target y coordinate
-- @param Z: target z coordinate
-- @param (optional) x: starting x coordinate
-- @param (optional) y: starting y coordinate
-- @param (optional) z: starting z coordinate
function moveTo(X, Y, Z, x, y, z), x, y, z)
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
            n_x = move(n_x)
        end

        if n_z ~= 0 then --trying to move in the z direction
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
            n_z = move(n_z)
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
            elseif not ENABLE_MINING_FOR_MOVING and not ASSERT_NO_MINING_FOR_MOVING then 
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

--- Moves a certain number of steps in each direction. 
--- Designed to be able to be used without coordinates
function moveSteps(n_x, n_y, n_z)
    n_x = n_x or 0
    n_y = n_y or 0
    n_z = n_z or 0
    moveTo(n_x, n_y, n_z, 0, 0, 0)
end

-- Functions that add on to the existing movement functionality
-- We should start using these in place of the default ones
function enhancedLeft()

    turtle.turnLeft()
    if direction ~= 1 then
        direction = direction - 1
    else
        direction = 4
    end
end

function enhancedRight()

    turtle.turnRight()
    if direction ~= 4 then
        direction = direction + 1
    else
        direction = 1 
    end    
end


function enhancedForward()
    if turtle.forward() then
        if direction == 4 then currentX = currentX + 1        
        elseif direction == 1 then currentZ = currentZ + 1
        elseif direction == 2 then currentX = currentX - 1
        elseif direction == 3 then currentZ = currentZ - 1
        end   
    end   
end

function enhancedBack()
    if turtle.back() then
        if direction == 4 then currentX = currentX - 1        
        elseif direction == 1 then currentZ = currentZ - 1
        elseif direction == 2 then currentX = currentX + 1
        elseif direction == 3 then currentZ = currentZ + 1
        end   
    end   
end

function getCurrentCoordinates()
    --getCoords using a call to the central satellite 
    --set current X Y and Z

end


--Probably move this out of here eventually
function returnToRefuelStation()
    -- Given the location(s) of a known fuel statiosn, calculate xyz diff from the current location to each one and take the minimum
    -- This would return back an absolute minimum amount of fuel needed under perfect circumstances
    local distanceFromStation = 100
    if(distanceFromStation * 2 > turtle.getFuelLevel()) then
        moveTo(X, Y, Z)
    end
end



