os.loadAPI("api/redString")
os.loadAPI("api/ui")
os.loadAPI("api/sovietProtocol")

local spawnNet = sovietProtocol.Protocol:new("spawnNet", 1, 1, "top")
local spawner = peripheral.find("tile_mfr_machine_autospawner_name")
local energyStorage = peripheral.find("cofh_thermalexpansion_energycell")
local chest = peripheral.find("container_chest")

local MENU_SCREEN = "monitor_3"
local INFO_SCREEN = "monitor_1"
local POWER_SCREEN = "monitor_2"
local FLUID_SCREEN = "monitor_0"

local mobs = {}
local currentMob = nil
local menu = peripheral.wrap(MENU_SCREEN)

local on = false


function emptyMobSpawner()
	chest.pullItem("up", 1)
	currentMob = nil
end

function insertMob(name)

	if mobs[name] then
		if chest.pushItem("up", mobs[name]) == 1 then
			currentMob = name
			if name == "Wither_skeleton" then
				spawner.setSpawnExact(true)
			else
				spawner.setSpawnExact(false)
			end
			return true
		end
	end

	return false
end

function enableSpawning()
	on = true
	spawnNet:send("spawner_on")
end

function disableSpawning()
	on = false
	spawnNet:send("spawner_off")
end

disableSpawning()

function updateMobList()
	emptyMobSpawner()
	items = chest.getAllStacks()
	for key, item in pairs(items) do
		if item.captured then
			if item.name == "Wither" then
				mobs["Wither_skeleton"] = key
			else
				mobs[item.captured] = key
			end
		end
	end
end

function getSystemStatus()
	local status = {}
	status.currentMob = currentMob
	return status
end

function equipMob(mob)
	local mab = mob
	return function ()
		print("Selected "..mob)
		emptyMobSpawner()
		insertMob(mab)
	end
end

function mobMenu(i)
	local x, y = menu.getSize()
	for mob, location in pairs(mobs) do
		do
			local button = ui.Button:new()
			button.width = x
			button.y = i
			button.screen = menu
			button.height = 1
			button.text = mob
			button.callback = equipMob(mob)
			if mob == currentMob then
				button.colour = colors.green
			else
				if i % 2 == 1 then
					button.colour = colors.orange
				else
					button.colour = colors.yellow
				end
			end
			button:draw()

			i = i+button.height
		end
	end
end

function runButton()
	local x, y = menu.getSize()
	local button = ui.Button:new()
	button.width = math.floor(x/2)
	button.height = 3
	button.y = 1
	button.screen = menu

	button.callback = function()
		on = not on
	end

	if on then
		button.text = "Stop"
		button.colour = colors.red
		button.callback = disableSpawning
	else
		button.text = "Start"
		button.colour = colors.green
		button.callback = enableSpawning
	end

	button:draw()
end

function drawMenu()
	menu.clear()
	ui.resetScreen(menu)
	menu.setTextScale(1.5)
	buttonMapping = {}
	local i = 5
	local x, y = menu.getSize()
	runButton()
	i = mobMenu(i)
end

function useButton(x, y)
	local button = ui.buttonMapping[y]
	if button then
		if button.x < x  and x < (button.x + button.width) then
			if buttonMapping[y].callback then
				buttonMapping[y].callback()
			end
		end
	end
end

updateMobList()

for mob, location in pairs(mobs) do

	print(mob.." "..location)

end

while true do
	drawMenu()
	local event, param1, param2, param3, param4 = os.pullEvent()
	if event == "monitor_touch" then
		local side = param1
		local x = param2
		local y = param3

		if side == MENU_SCREEN then
			ui.runCallback(x, y)
		end
	end
end
