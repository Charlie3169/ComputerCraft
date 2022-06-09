--- Mines a straight line in the current direction
-- @param length number of blocks to mine
-- @param doMineUp (optional) mines above while traversing
-- @param doMineDown (optional) mines below while traversing
-- @return {number of blocks mined, mined straight, mined above, mined below}
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
            if not turtle.attack() and not turtle.detect() and not turtle.dig() then
                sleep(0.5)
            end
        end
    end
    return blocksMined
end


        
