os.loadAPI("redString")
os.loadAPI("sovietProtocol")

sovietProtocol.init("top", 1, 1)
spawner = peripheral.wrap("tile_mfr_machine_autospawner_name_0")
energyStorage = peripheral.wrap("cofh_thermalexpansion_energycell_0")
chest = peripheral.wrap("container_chest_0")

MENU_SCREEN = "monitor_3"
INFO_SCREEN = "monitor_1"
POWER_SCREEN = "monitor_2"
FLUID_SCREEN = "monitor_0"

powerIndicator = peripheral.wrap(POWER_SCREEN)
fluidIndicator = peripheral.wrap(FLUID_SCREEN)

print("starting Stat Monitoring")

function getEnergyFraction(storage)
	return storage.getEnergyStored("")/storage.getMaxEnergyStored("")
end

function getFluidFraction(tank)
	return tank.amount/tank.capacity
end

function getSystemStatus()
	local status = {}
	status.currentMob = currentMob
	return status
end

function resetScreen(screen)
	local x,y = screen.getSize()
	for xpos=1, x do
		for ypos=1, y do
			screen.setCursorPos(xpos,ypos)
			screen.setBackgroundColor(colors.black)
			screen.write(" ")
		end
	end
end

function pad(output, length)
	for i =1, length do 
		output.write(" ")
	end
end

Button ={
	width = 1,
	height = 1,
	screen = nil,
	text = "",
	x = 1,
	y = 1,
	colour = colors.white,
	callback = nil
}

function Button:new()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Button:draw()
	self.screen.setCursorPos(self.x, self.y)
	self.screen.setBackgroundColor(self.colour)
	length = string.len(self.text)
	textLine = self.y + math.floor(self.height/2)
	for i = self.y, self.y + self.height-1 do
		buttonMapping[i] = self
		self.screen.setCursorPos(self.x, i)
		padding = math.floor((self.width - length)/2)
		if i == textLine then
			pad(self.screen, padding)
			self.screen.write(self.text)
			pad(self.screen, self.width - (padding+length))
		else
			pad(self.screen, self.width)
		end
	end
end

function Button:init(screen, text, x, y, width, height, colour, callback)

end

function drawBar(screen, fraction, colour)
	screen.clear()
	resetScreen(screen)
	screen.setBackgroundColor(colour)
	screen.setTextScale(0.5)

	local x, y = screen.getSize()

	linesToFill = math.floor(y*fraction)

	local i = y 

	for i=0, linesToFill do
		screen.setCursorPos(1, y-i)
		pad(screen, x)
	end
end

function drawPower()
	local power = getEnergyFraction(energyStorage)
	if power ~= previousPower then
		drawBar(powerIndicator, power, colors.red)
		previousPower = power
	end
end

function drawFluid()
	local fluid = getFluidFraction(spawner.getTankInfo("")[1])
	if fluid ~= previousFluid then
		drawBar(fluidIndicator, fluid, colors.green)
		previousFluid = fluid
	end
end

function useButton(x, y)
	local button = buttonMapping[y]
	if button then
		if button.x < x  and x < (button.x + button.width) then
			if buttonMapping[y].callback then
				buttonMapping[y].callback()
			end
		end
	end
end

while true do
	drawPower()
	drawFluid()
	
	sleep(1)
end
