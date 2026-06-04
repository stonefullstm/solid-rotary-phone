local actions = require("actions")
local creatures = {}

creatures[#creatures + 1] = {
	name = "Dragon",
	description = "Uma criatura poderosa e feroz que cospe fogo.",
	maxHealth = 20,
	health = 20,
	attack = 30,
	defense = 20,
	speed = 5,
	actions = {
		actions.createBasicAttack("Ataque de fogo"),
		actions.createWait("Aguardar"),
	},
}

creatures[#creatures + 1] = {
	name = "Slime",
	description = "Uma criatura gelatinosa que se move lentamente.",
	maxHealth = 10,
	health = 10,
	attack = 8,
	defense = 3,
	speed = 2,
	actions = {
		actions.createBasicAttack("Ataque ácido"),
		actions.createWait("Aguardar"),
	},
}

return creatures
