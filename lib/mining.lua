require("moves")
require("statusUpdates")

--- Mines a straight line in the current direction
--- @param length number of blocks to mine
--- @param doMineUp (optional) mines above while traversing
--- @param doMineDown (optional) mines below while traversing
--- @return {number of blocks mined, mined straight, mined above, mined below}
function digLine(length, doMineUp, doMineDown)
    assert(length > 0, "Length must be greater than 0")
    doMineUp = doMineUp or false
    doMineDown = doMineDown or false
    blocksMined = {0, 0, 0, 0} --total mined, mined straight, mined above, mined below
    for i=1,length,1 do
        if turtle.detect() and turtle.dig() then 
            blocksMined[1], blocksMined[2] = blocksMined[1] + 1, blocksMined[2] + 1 
        end
        if doMineUp and turtle.detectUp() and turtle.digUp() then 
            blocksMined[1], blocksMined[3] = blocksMined[1] + 1, blocksMined[3] + 1  
        end
        if doMineDown and turtle.detectDown() and turtle.digDown() then 
            blocksMined[1], blocksMined[4] = blocksMined[1] + 1, blocksMined[4] + 1  
        end
        while not turtle.forward() do
            if not turtle.attack() and turtle.detect() and not turtle.dig() then
                sleep(0.5)
            end
        end
    end
    return blocksMined
end


--- Mines out an area, starting at a corner.
--- Mines in rows in the x direction, travels z direction and then y direction. 
--- TODO: Checks if the inventory is full or if the turtle needs refueling after every x row 
--- @param n_x number of blocks in the x direction to mine
--- @param n_y number of blocks in the y direction to mine
--- @param n_z number of blocks in the z direction to mine
--- @param offset_y number of blocks to go in the y direction before starting
function digArea(n_x, n_y, n_z, offset_y, goToStartForInterrupts)
    offset_y = offset_y or 0
    --Automatically go to job start before going to refuel/unload
    if goToStartForInterrupts==nil then goToStartForInterrupts = true end
    ENABLE_MINING_FOR_MOVING = true --Set this to true to make the turtle mine for this function only
    assert(moveVertically(offset_y) == 0, "Did not move all the way vertically.")
    jobStart = {currentX, currentY, currentZ}
    local move_x = n_x --These variables necessary to keep track of these between layers
    local move_y = n_y
    local move_z = n_z 
    local keepMining = true --Keep mining until n_y == 0

    while keepMining do
        while move_z ~= 0 do --This loop will do every row except one, so make it move in the x again
            moveSteps(move_x, 0, 0)
            move_x = -move_x
            handleInterrupts(offset_y)
            moveSteps(0, 0, move_z / math.abs(move_z)) --moves 1 unit in the correct z direction
            move_z = move_z < 0 and move_z + 1 or move_z - 1
            
        end
        moveSteps(move_x, 0, 0)
        move_x = -move_x
        if move_y ~= 0 then 
            moveSteps(0, move_y / math.abs(move_y), 0) --moves 1 unit in the correct y direction
            move_y = move_y < 0 and move_y + 1 or move_y - 1
        else
            keepMining = false
        end
        --At this point, the turtle will be in the opposite corner that it started from.
        --The move_x variable will be correct at this point, so just reverse the z
        move_z = math.pow(-1, (n_y - move_y) % 2) * n_z --Reversing it every y layer
    end
    finishJob(offset_y)
end
        
