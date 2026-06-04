local players = require("players.players")
local creatures = require("creatures.creatures")

for _, player in ipairs(players) do
	print(player.name)
	print(player.actions[1].description)
end

for _, creature in ipairs(creatures) do
	print(creature.name)
end
