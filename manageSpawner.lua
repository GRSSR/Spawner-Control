os.loadAPI("redString")
os.loadAPI("ui")
os.loadAPI("sovietProtocol")

sovietProtocol.init("top", 1, 1)
spawner = peripheral.wrap("tile_mfr_machine_autospawner_name_0")
energyStorage = peripheral.wrap("cofh_thermalexpansion_energycell_0")
chest = peripheral.wrap("container_chest_0")

MENU_SCREEN = "monitor_3"
INFO_SCREEN = "monitor_1"
POWER_SCREEN = "monitor_2"
FLUID_SCREEN = "monitor_0"

mobs = {}
currentMob = nil
menu = peripheral.wrap(MENU_SCREEN)

on = false


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
	sovietProtocol.send(1, 1, "spawner_on", "", "")
end

function disableSpawning()
	on = false
	sovietProtocol.send(1, 1, "spawner_off", "", "")
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
