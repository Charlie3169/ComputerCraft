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
            while not turtle.drop() and turtle.getItemCount() > 0 do 
                --TODO Add logic here to go to another chest if the one in front is full
            end
        end
    end
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
end