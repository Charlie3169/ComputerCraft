function mineGeneratedCobble()
    local sleepTime = 1
    local hasFuel = true

    while(hasFuel) do
        turtle.dig()
        --os.sleep(sleepTime)
        print('Fuel Level' .. turtle.getFuelLevel())
    end
end

mineGeneratedCobble()