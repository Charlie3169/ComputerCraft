
--movesX = 0
--movesY = 0
--movesZ = 0
--solid

--layerComplete = false

--worldInformation = {}
--worldInformation["X"] = movesX
--worldInformation["Y"] = movesY    
--worldInformation["Z"] = movesZ
--wolrdInformation["Solid"] = 



turnDirection = true

function canvas()
    turtle.turnLeft()
    if turtle.detect() then

end


function digLayer()
    while not layerComplete do
        if turtle.detect() then
            turtle.dig()
            turtle.forward()
            canvas()
        else
            turtle.place(1)
            turtle.turnLeft()
            turtle.forward()
            turtle.turnRight()
        end
    end
    
end

--Digs a pyramid
turnDirection = true
function digCone()
    --Initial side length 
    i = 3
    --Pyramid depth
    depth = 5
    

    for index0=1, depth do 

        turtle.digDown()
        turtle.down()

        cornerDistance = (i-1) / 2

        --Moves to the left corner
        for index=1, cornerDistance do
            turtle.dig()
            turtle.forward()       
        end
        turtle.turnLeft()
        for index=1, cornerDistance do
            turtle.dig()
            turtle.forward()
        end
        turtle.turnLeft()




        --Zigzags through the area
        for index=1,i  do

            for index2=1,i - 1 do
                turtle.dig()
                turtle.forward()
            end

            if index2 != i  then

                directionSwap()
                turtle.dig()
                turtle.forward()           

                directionSwap()                
                turnDirection = not turnDirection
            end

            

        end

        --Moves back the center
        turtle.turnRight()
        for index=1, cornerDistance do
            turtle.forward()       
        end
        turtle.turnRight()
        for index=1, cornerDistance do
            turtle.forward()
        end        

        i = i + 2

    end

end

function directionSwap()
    if turnDirection then
        turtle.turnLeft()
    else
        turtle.turnRight()
    end
end

digCone()

--Jon thing
function charTreePickup()
    --Assuming this is starting here and facing away from the tree
    --s 0 s s s
    --s 0 C 0 0 
    --s 0 T 0 s 
    --0 0 0 0 s
    --s s s 0 s

    urMom()
    urMom()

    rotate()

    urMom()
    urMom()
    urMom()
    
    rotate()

    urMom()
    urMom()
    urMom()
    
    rotate()

    urMom()
    urMom()
    urMom()

    rotate()

    urMom()  

end

function rotate()
    turtle.turnLeft()
    turtle.forward()
    turtle.turnLeft()
    turtle.forward()
    turtle.turnLeft()
end

function urMom()

    turtle.suck()
    turtle.turnLeft()
    turtle.suck()
    turtle.forward()
    turtle.turnRight()
    turtle.suck()

end


function jonPickup()

    suckForward()

    turtle.turnRight()
    --Exit center
    suckForward()
    innerSuck()
    suckForward()
    --First full edge
    turtle.turnRight()

    suckForward()
    suckForward()
    innerSuck()
    suckForward()
    innerSuck()

    suckForward()
    --Second full edge
    turtle.turnRight()
    
    suckForward()
    suckForward()
    innerSuck()
    suckForward()
    innerSuck()

    suckForward()
    --Third full edge
    turtle.turnRight()
    
    suckForward()
    suckForward()
    innerSuck()
    suckForward()
    innerSuck()

    suckForward()
    
    --Final edge and return
    turtle.turnRight()
    suckForward()
    suckForward()
    turtle.turnLeft()
    turtle.back()

end

function innerSuck()
    turtle.turnRight()
    turtle.suck()
    turtle.turnLeft()
end

function suckForward()
    turtle.suck()
    turtle.forward()
end





--Find ores
valuableBlocks = {}
valuableBlocks["minecraft:iron"] = 1
valuableBlocks["minecraft:coal"] = 1
valuableBlocks["minecraft:gold"] = 1
valuableBlocks["minecraft:diamond"] = 1
valuableBlocks["minecraft:redstone"] = 1

x = 0
y = 0
z = 0
direction = 1 
-- 1 = X+ (East)
-- 2 = Z+ (South)
-- 3 = X- (West)
-- 4 = Z- (North)
-- Turning right is direction +1

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
        if direction == 1 then x = x + 1        
        elseif direction == 2 then z = z + 1
        elseif direction == 3 then x = x - 1
        elseif direction == 4 then z = z - 1
        end   
    end   
end

function enhancedBack()
    if turtle.back() then
        if direction == 1 then x = x - 1        
        elseif direction == 2 then z = z - 1
        elseif direction == 3 then x = x + 1
        elseif direction == 4 then z = z + 1
        end   
    end   
end

function enhancedUp()
    if turtle.up() then
        y = y + 1
    end
end

function enhancedDown()
    if turtle.down() then
        y = y - 1
    end
end


function oreMiner()

    bool, w = turtle.inspect()
    cx = x
    cy = Y
    cz = z
    
    if valuableBlocks[w["name"]] then
        turtle.dig()
        enhancedForward()
        oreMiner(cx, cy, cz)

    else

    end

    --Detect ore
    --Mine first block
    --Move forward
    --Scan for new ore
    --get current location
    --for each ore discovered, rerun
    --pass in location
    --at the end of each run, return to starting point

    end

function returnToOrigin()
    


    

    

end



--Should mine to a depth and then start strip mining in a grid
function mainLoop(length, depth)
    for i = 1, depth do
        turtle.dig()
        enhancedDown()
    end

    while x < 



end


-- Dont remember what this is for
function digMove(n, m)
    for i=1, n do
        if turtle.inspect == valuableBlocks then
            oreMiner()

        else
            turtle.dig()
            turtle.enhancedForward()
            currentDirection = currentDirection + 1
        end

        
        
    end

end







