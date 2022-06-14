require('moves')

TURTLE_NUMBER_OF_SLOTS = 16
TURTLE_DONT_UNLOAD_SLOTS = {} --dict that contains values for slots the turtle shouldn't unload
TURTLE_FUEL_SLOT = 16

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
    for i=1,TURTLE_NUMBER_OF_SLOTS,1 do
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

function unloadAll()
    bool,x = turtle.inspect()
    assert(x["name"] == "minecraft:chest", "Did not detect a chest, will not unload.")
    for i=1,TURTLE_NUMBER_OF_SLOTS,1 do
        turtle.select(i)
        if not TURTLE_DONT_UNLOAD_SLOTS[i] then
            while turtle.getItemCount() > 0 and not turtle.drop() do 
                --TODO Add logic here to go to another chest if the one in front is full
            end
        end
    end
    return true
end

-- Refuel, assuming that the turtle is facing a chest
function refuel()
    bool,x = turtle.inspect()
    assert(x["name"] == "minecraft:chest", "Did not detect a chest, will not refuel.")
    turtle.select(TURTLE_FUEL_SLOT)
	turtle.suck(64 - turtle.getItemCount(14))

	--Refuel using designated charcoal slot
	if turtle.getFuelLevel() ~= "unlimited" then
		if turtle.getFuelLimit() then
			while turtle.getFuelLevel() < turtle.getFuelLimit() and turtle.getItemCount(14) > 1 do
				turtle.refuel(1)
			end
		end
	end
    return true
end


--- Function to handle interrupts
--- For now, just handle out of fuel events and inventory full events
--- TODO Handle pathfinding bugs out
--- @param offset_y (optional) move an offset from the start of the job before pathing
function handleInterrupts(offset_y)
    local worked = true
    local wasMiningWhileMoving = ENABLE_MINING_FOR_MOVING
    local invenFull = isInventoryFull()
    local outOfFuel = needsFuel()
    if invenFull or outOfFuel then
        ENABLE_MINING_FOR_MOVING = false
        jobInterrupt = {currentX, currentY, currentZ}
        worked = worked and moveTo(jobStart[1], jobStart[2], jobStart[3])
        assert(worked, "Failed to move to the start of the job") 
        if offset_y then moveVertically(-offset_y) end
        if invenFull then
            worked = worked and returnToUnloadingStation()
            assert(worked, "Failed to move to the unloading station") 
            worked = worked and unloadAll()
            assert(worked, "Failed to unload all items.") 
        end
        if outOfFuel then
            worked = worked and returnToRefuelStation()
            assert(worked, "Failed to move to the refueling station") 
            worked = worked and refuel()
            assert(worked, "Failed to refuel.") 
        end
        worked = worked and moveTo(jobStart[1], jobStart[2], jobStart[3])
        assert(worked, "Failed to move back to the start of the job") 
        worked = worked and moveVertically(offset_y)
        assert(worked, "Failed to move vertically to the offset of the start of the job.") 
        worked = worked and moveTo(jobInterrupt[1], jobInterrupt[2], jobInterrupt[3])
        assert(worked, "Failed to move to where the job was interrupted.") 
        ENABLE_MINING_FOR_MOVING = wasMiningWhileMoving
    end
end


--- Function to finish job
--- For now, just handle out of fuel events and inventory full events
--- @param offset_y (optional) move an offset from the start of the job before pathing
function finishJob(offset_y)
    local worked = true
    local outOfFuel = needsFuel()
    ENABLE_MINING_FOR_MOVING = false

    assert(moveTo(jobStart[1], jobStart[2], jobStart[3]), "Failed to move to the start of the job") 
    if offset_y then moveVertically(-offset_y) end

    --Always unload after job is done
    assert(returnToUnloadingStation(), "Failed to move to the unloading station") 
    assert(unloadAll(), "Failed to unload all items.") 

    --Refuel if needed
    if outOfFuel then
        assert(returnToRefuelStation(), "Failed to move to the refueling station") 
        assert(refuel(), "Failed to refuel.") 
    end
end