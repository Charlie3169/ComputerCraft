direction = false

function flipDirection()
	if direction then
		turtle.turnRight()
	else
		turtle.turnLeft()
	end
end 

for i=1,6 do
	for j=1,11 do
		turtle.dig()
		turtle.forward()
	end
	flipDirection()
	turtle.dig()
	turtle.forward()
	flipDirection()
	direction = not direction
end