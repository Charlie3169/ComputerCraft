require('moves')

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