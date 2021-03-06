os.loadAPI("api/redString")
os.loadAPI("api/sovietProtocol")
os.loadAPI("api/ui")

local spawnNet = sovietProtocol.Protocol:new("spawnNet", 1, 1, "top")
local spawner = peripheral.find("tile_mfr_machine_autospawner_name")
local energyStorage = peripheral.find("cofh_thermalexpansion_energycell")
local chest = peripheral.find("container_chest")

local MENU_SCREEN = "monitor_3"
local INFO_SCREEN = "monitor_1"
local POWER_SCREEN = "monitor_2"
local FLUID_SCREEN = "monitor_0"

local powerIndicator = peripheral.wrap(POWER_SCREEN)
local fluidIndicator = peripheral.wrap(FLUID_SCREEN)

print("starting Stat Monitoring")

function getEnergyFraction(storage)
	return storage.getEnergyStored("")/storage.getMaxEnergyStored("")
end

function getFluidFraction(tanks)
	local capacity = 0
	local amount = 0
	if type(tanks) ~= "table" then
		local tanks = {tanks}
	end
	for key, tank in pairs(tanks) do
		if not tank.amount then
			tank.amount = 0
		end
		amount = amount + tank.amount
		capacity = capacity + tank.capacity

	end
	return amount/capacity
end

function getSystemStatus()
	local status = {}
	status.currentMob = currentMob
	return status
end

function getAttachedTanks() 
	local tanks = {}
	local candidate
	for key, periph in pairs(peripheral.getNames()) do
		candidate = peripheral.wrap(periph)
		if candidate.getTankInfo ~= nil then
			tanks[#tanks+1] = candidate.getTankInfo("")[1]
		end
	end
	return tanks
end

function drawBar(screen, fraction, colour)
	screen.clear()
	ui.resetScreen(screen)
	screen.setBackgroundColor(colour)
	screen.setTextScale(0.5)

	local x, y = screen.getSize()

	linesToFill = math.floor(y*fraction)

	local i = y 

	for i=0, linesToFill do
		screen.setCursorPos(1, y-i)
		ui.pad(screen, x)
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
	local fluid = getFluidFraction(getAttachedTanks())
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
