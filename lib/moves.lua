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

--Whenever the turtle starts a job, make this the coordinates to go to 
jobStart = {0,0,0}
--Whenever the turtle's job is interrupted, make this the coordinates to go back to
jobInterrupt = {0,0,0} 

COORDINATES_TRACKED = false 
-- Honestly we might as well always at least track coords relative to the starting position
-- Once we get GPS going we can just correctly initialize them

MOVING_Y_AFTER_X_Z = false --Used when you want the robot to remain the same Y until X and Z are aligned
OFFSET_Y_BEFORE_MOVING = 10
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
        moved = enhancedForward()

		while not moved and not finishedSleep do
			bool,x = turtle.inspect()
			if turtle.detect() and ENABLE_MINING_FOR_MOVING then
				turtle.dig()
            else -- try sleeping to see if the block will become available
                finishedSleep = true
                os.sleep(SLEEP_SECS_FOR_MOVING)
            end
            moved = enhancedForward()
		end

        if moved then stepsTaken = stepsTaken + 1 end
	end
    return isNegative and -(n-stepsTaken) or (n-stepsTaken)
end


function moveDown(n)
    finishedSleep = false
    stepsTaken = 0
	for i=1,n,1 do
        moved = enhancedDown()
		while not moved and not finishedSleep do
			bool,x = turtle.inspectDown()
			if turtle.detectDown() and ENABLE_MINING_FOR_MOVING then
				turtle.digDown()
            else -- try sleeping to see if the block will become available
                finishedSleep = true
                os.sleep(SLEEP_SECS_FOR_MOVING)
            end
            moved = enhancedDown()
		end

        if moved then stepsTaken = stepsTaken + 1 end
	end
    return n-stepsTaken
end


function moveUp(n)
	finishedSleep = false
    stepsTaken = 0
	for i=1,n,1 do
        moved = enhancedUp()
		while not moved and not finishedSleep do
			bool,x = turtle.inspectUp()
			if turtle.detectUp() and ENABLE_MINING_FOR_MOVING then
				turtle.digUp()
            else -- try sleeping to see if the block will become available
                finishedSleep = true
                os.sleep(SLEEP_SECS_FOR_MOVING)
            end
            moved = enhancedUp()
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
--- @param X: target x coordinate
--- @param Y: target y coordinate
--- @param Z: target z coordinate
--- @param (optional) x: starting x coordinate
--- @param (optional) y: starting y coordinate
--- @param (optional) z: starting z coordinate
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

    if MOVING_Y_AFTER_X_Z then 
        moveVertically(OFFSET_Y_BEFORE_MOVING)
        n_y = n_y - OFFSET_Y_BEFORE_MOVING --Track this to move down later
    end 


    stillNeedsToMove = n_x~=0 or n_y~=0 or n_z~=0

    while stillNeedsToMove do 

        thisLoopX = n_x
        thisLoopY = n_y
        thisLoopZ = n_z        
    
        if n_x ~= 0 then --trying to move in the x direction
            if n_x > 0 then turnTo(TURTLE_DIRECTION_POS_X)
            elseif n_x < 0 then turnTo(TURTLE_DIRECTION_NEG_X) end
            n_x = move(n_x)
        end

        if n_z ~= 0 then --trying to move in the z direction
            if n_z > 0 then turnTo(TURTLE_DIRECTION_POS_Z)
            elseif n_z < 0 then turnTo(TURTLE_DIRECTION_NEG_Z) end
            n_z = move(n_z)
        end

        if n_y ~= 0 then --trying to move in the y direction
            if (MOVING_Y_AFTER_X_Z and n_x == 0 and n_z == 0) or not MOVING_Y_AFTER_X_Z then
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
    return n_x == 0 and n_z == 0 and n_y == 0
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
    local worked = turtle.turnLeft()
    if currentDirectionIndex ~= 1 then
        currentDirectionIndex = currentDirectionIndex - 1
    else
        currentDirectionIndex = 4
    end
    return worked
end

function enhancedRight()
    local worked = turtle.turnRight()
    if currentDirectionIndex ~= 4 then
        currentDirectionIndex = currentDirectionIndex + 1
    else
        currentDirectionIndex = 1 
    end    
    return worked
end

function enhancedForward()
    local worked = turtle.forward()
    if worked then
        if currentDirectionIndex == TURTLE_DIRECTION_POS_X then currentX = currentX + 1        
        elseif currentDirectionIndex == TURTLE_DIRECTION_POS_Z then currentZ = currentZ + 1
        elseif currentDirectionIndex == TURTLE_DIRECTION_NEG_X then currentX = currentX - 1
        elseif currentDirectionIndex == TURTLE_DIRECTION_NEG_Z then currentZ = currentZ - 1
        end   
    end
    return worked   
end

function enhancedBack()
    local worked = turtle.back()
    if worked then
        if currentDirectionIndex == TURTLE_DIRECTION_POS_X then currentX = currentX - 1        
        elseif currentDirectionIndex == TURTLE_DIRECTION_POS_Z then currentZ = currentZ - 1
        elseif currentDirectionIndex == TURTLE_DIRECTION_NEG_X then currentX = currentX + 1
        elseif currentDirectionIndex == TURTLE_DIRECTION_NEG_Z then currentZ = currentZ + 1
        end   
    end   
    return worked
end

function enhancedUp()
    local worked = turtle.up()
    if worked then
        currentY = currentY + 1 
    end
    return worked   
end

function enhancedDown()
    local worked = turtle.down()
    if worked then
        currentY = currentY - 1
    end
    return worked   
end

---Turns to direction. Should use the constants defined at the top.
function turnTo(direction)
    local diff = direction - currentDirectionIndex
    if diff == -3 then enhancedRight()
    elseif diff == 3 then enhancedLeft() 
    else 
        while diff > 0 do
            enhancedRight()
            diff = diff - 1
        end
        while diff < 0 do
            enhancedLeft()
            diff = diff + 1
        end
    end 
    return currentDirectionIndex == direction
end    


function getCurrentCoordinates()
    --getCoords using a call to the central satellite 
    --set current X Y and Z
end


--- @param direction direction to look to unload.
function returnToUnloadingStation(direction)
    local worked = true
    direction = direction or UNLOADING_STATION_COORDS[4]
    worked = worked and moveTo(UNLOADING_STATION_COORDS[1],UNLOADING_STATION_COORDS[2],UNLOADING_STATION_COORDS[3])
    worked = worked and turnTo(direction)
    return worked
end


--- @param direction direction to look to refuel.
function returnToRefuelingStation(direction)
    local worked = true
    direction = direction or REFUELING_STATION_COORDS[4]
    worked = worked and moveTo(REFUELING_STATION_COORDS[1],REFUELING_STATION_COORDS[2],REFUELING_STATION_COORDS[3])
    worked = worked and turnTo(direction)
    return worked
end        