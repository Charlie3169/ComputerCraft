homeX = 449
homeY = 74
homeZ = -1238
startX = 449
startY = 92
startZ = -1199
goalX = 474
goalY = 92
goalZ = -1179

layersOfTrees=2 --layers in the y direction
slotForOakSapling=16
slotForRubberSapling=15
direction=0 -- 0 is +x, 1 is -x
tree=0 -- 0 is oak, rubber is 1
treeDifferenceInLayers=7 --Difference of stacked trees' heights
treeDifferenceInWidth=4 --Difference between trees on same plane
collectSaplings = true --Whether the turtle will suck up saplings or not
cycle = 0 --Counter for number of cycles completed

----TRY NOT TO MODIFY ANYTHING BELOW -----


--Blocks that the roomba should detect
TableOfNames = {}
TableOfNames["MineFactoryReloaded:rubberwood.sapling"] = 1
TableOfNames["MineFactoryReloaded:rubberwood.log"] = 1
TableOfNames["minecraft:log"] = 1
TableOfNames["minecraft:sapling"] = 1
TableOfNames["minecraft:leaves"] = 1
TableOfNames["MineFactoryReloaded:rubberwood.leaves"] = 1

saplingTable = {}
saplingTable["MineFactoryReloaded:rubberwood.sapling"] = 1
saplingTable["minecraft:sapling"] = 1

function move(n) --moves n units forward
	for i=1,n,1 do
		while not turtle.forward() do
			bool,x = turtle.inspect()
			if turtle.detect() and TableOfNames[x["name"]] then
				turtle.dig()
			end
		end
	end
end

function moveDown(n)
	for i=1,n,1 do
		while not turtle.down() do
			bool,x = turtle.inspectDown()
			if turtle.detectDown() and TableOfNames[x["name"]] then
				turtle.digDown()
			end
		end
	end
end

function moveUp(n)
	for i=1,n,1 do
		while not turtle.up() do
			bool,x = turtle.inspectUp()
			if turtle.detectUp() and TableOfNames[x["name"]] then
				turtle.digUp()
			end
		end
	end
end

--Assuming starting from goal+4 (at the turtle return point) facing +X, ends facing -X
function moveToHome()

	moveUp(10)

	turtle.turnLeft() --Now facing -Z
	move(goalZ-homeZ)

	turtle.turnLeft() --Now facing -X
	move((goalX+5) - homeX)

	moveDown((goalY+10)-homeY)
end


--Assuming starting from home facing +Z
--Also assuming that the turtle is on the same X coordinate as goal
function moveToStart()
	moveUp(startY-homeY)

	turtle.turnRight() -- Facing -X
	move(1)
	turtle.turnLeft() -- Facing +Z

	move(startZ-homeZ)

	turtle.turnLeft() -- Facing +X and first tree
end

function charTreePickup()
    --Assuming this is starting here and facing away from the tree
    --s 0 s s s
    --s 0 C 0 0
    --s 0 T 0 s
    --0 0 0 0 s
    --s s s 0 s

		turtle.turnRight()
		while not turtle.back() do end
		for i=1,4 do
			fullLineSuckCW()
		end
		move(1)
		turtle.turnLeft()

end

--Clockwise rotation for charTreePickup
--e.g. starting from right of C facing down
function fullLineSuckCW()
	turtle.suck()
	move(1)
	for i=1,2 do
		suckLeft()
		move(1)
	end
	suckLeft()
	while not turtle.back() do end
	turtle.turnRight()
end

function suckRight()
	turtle.suck()
	turtle.turnRight()
	turtle.suck()
	turtle.turnLeft()
end

function suckLeft()
	turtle.suck()
	turtle.turnLeft()
	turtle.suck()
	turtle.turnRight()
end

function jonPickup()

    suckForward()
		turtle.suck()
    turtle.turnRight()
    --Exit center
    suckForward()
    innerSuck()
    suckForward()

		for i=1,3 do
			turtle.turnRight()

			suckForward()
			suckForward()
			innerSuck()
			suckForward()
			innerSuck()

			suckForward()
		end

    --Final edge and return
    turtle.turnRight()
    suckForward()
    suckForward()
    turtle.turnLeft()
    while not turtle.back() do end

end

function innerSuck()
    turtle.turnRight()
    turtle.suck()
    turtle.turnLeft()
end

function suckForward()
    turtle.suck()
		bool,x = turtle.inspect()
		if turtle.detect() and not saplingTable[x["name"]] and TableOfNames[x["name"]] then
			turtle.dig()
		end
    move(1)
end

--Suck (most) squares around a tree
function suckAround()
	jonPickup()
end


function chopUp()
	for i=1,(treeDifferenceInLayers - 1)*layersOfTrees,1 do

		bool,x = turtle.inspectUp()
		while turtle.detectUp() and TableOfNames[x["name"]] and not turtle.digUp() do end

		bool, x = turtle.inspect()
		if turtle.detect() and not saplingTable[x["name"]] and TableOfNames[x["name"]] then
			turtle.dig()
		end

		moveUp(1)
	end

end


function goDownAndPlant()
	for i=1,2 do
		bool, x = turtle.inspect()
		if turtle.detect() and not saplingTable[x["name"]] and TableOfNames[x["name"]] then
			turtle.dig()
		end
		move(1)
	end
	turtle.turnRight()
	turtle.turnRight()

	for i=1,(treeDifferenceInLayers - 1)*layersOfTrees do

		if turtle.inspectDown() then
			bool, x=turtle.inspectDown()
			if not saplingTable[x["name"]] and TableOfNames[x["name"]] then
				turtle.digDown()
			end
		end

		moveDown(1)
		if collectSaplings then
			if turtle.getItemCount(slotForOakSapling)	> 1 or
										turtle.getItemCount(slotForRubberSapling) > 1 then

				if tree==1 and turtle.getItemCount(slotForRubberSapling) <= 1 then
					tree=0
					turtle.select(slotForOakSapling)
				elseif tree==0 and turtle.getItemCount(slotForOakSapling) <= 1 then
					tree=1
					turtle.select(slotForRubberSapling)
				elseif tree==1 then
					turtle.select(slotForRubberSapling)
				elseif tree==0 then
					turtle.select(slotForOakSapling)
				end

				if tree==1 then
					if turtle.place() then
						tree = 0
						turtle.select(slotForOakSapling)
					end
				elseif tree==0 then
					if turtle.place() then
						tree = 1
						turtle.select(slotForRubberSapling)
					end
				end
			end
		end
	end

	turtle.turnRight()
	turtle.turnRight()
	suckAround()
end

function chopEverything()
--	T		T		T		T		T
--	T		T		T		T		T
--	T		T		T		T		T
--
--									R
--
-- Above diagram has 3 rows and 5 columns

	numOfRowsForLoop = (goalZ - startZ)/5+1
	numOfColumnsForLoop = (goalX - startX)/5
	for row=1,numOfRowsForLoop,1 do
  	for columns=1,numOfColumnsForLoop,1 do
  		chopUp()
  		goDownAndPlant()
  		move(treeDifferenceInWidth - 1)
  	end

  	chopUp()
  	goDownAndPlant()

    if row<numOfRowsForLoop then
      if direction==1 then
        turtle.turnLeft()
    	elseif direction==0 then
    		turtle.turnRight()
    	end

    	move(treeDifferenceInWidth + 1)

    	if direction==1 then
    		turtle.turnLeft()
    		direction=0
    	elseif direction==0 then
    		turtle.turnRight()
    		direction=1
    	end
    else
      move(4)
    end
  end
end



function homeErrands()

	--Where the turtle lands should be a chest full of coal/charcoal for refueling
	turtle.select(14)
	turtle.suck(64 - turtle.getItemCount(14))

	--Refuel using designated charcoal slot
	if turtle.getFuelLevel() ~= "unlimited" then
		if turtle.getFuelLimit() then
			while turtle.getFuelLevel() < turtle.getFuelLimit() and turtle.getItemCount(14) > 1 do
				turtle.refuel(1)
			end
		end
	end

	turtle.turnRight()
	move(1)

	for i=1,13,1 do
		turtle.select(i)
		while not turtle.drop() and turtle.getItemCount() > 0 do end
	end

	turtle.turnRight()
	turtle.turnRight()
	move(1)
end

function run()
	cycle = cycle + 1
	print("Cycle: " .. cycle)
	startingFuel = turtle.getFuelLevel()
	print("Starting Fuel: " .. startingFuel)
	moveToStart()
	chopEverything()
	moveToHome()
	homeErrands()
	endingFuel = turtle.getFuelLevel()
	print("Ending Fuel: " .. endingFuel)
	print("Fuel Consumed: " .. (startingFuel - endingFuel))
	os.sleep(300) --300 second waiting
	run()
end

run()
