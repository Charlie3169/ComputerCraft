require('moves')

TURTLE_NUMBER_OF_SLOTS = 16

function displayInventory()
end

function displayCurrentFuel()
    print('Current fuel level is: ' .. turtle.getFuelLevel)   
end

function displayCurrentFuelPercentage()
    print('Current fuel percentage is: ' .. 100 * (turtle.getFuelLevel / turtle.getFuelLimit) )
end

function displayCoordinates()
    print('X:' .. currentX .. 'Y:' .. currentY .. 'Z:' .. currentZ )
end

--- Returns true if every inventory slot is taken up by something
function isInventoryFull()
    for i=0,TURTLE_NUMBER_OF_SLOTS,1 do
        if turtle.getItemCount(i) == 0 then return false end
    end
    return true
end

--Probably move this out of here eventually
function needsFuel()
    -- Given the location(s) of a known fuel statiosn, calculate xyz diff from the current location to each one and take the minimum
    -- This would return back an absolute minimum amount of fuel needed under perfect circumstances
    local distanceFromStation = distanceInBlocks(currentX, currentY, currentZ,
            REFUELING_STATION_COORDS[1], REFUELING_STATION_COORDS[2], REFUELING_STATION_COORDS[3])
    if(distanceFromStation * 2 > turtle.getFuelLevel()) then
        return true
    end
    return false
end