local actions = require("actions")

local players = {}

players[#players + 1] = {
	name = "Violet",
	description = "Uma jovem guerreira determinada a vencer batalhas e salvar seu reino.",
	maxHealth = 10,
	health = 10,
	attack = 4,
	defense = 2,
	speed = 2,
	potions = 3,
	actions = {
		actions.createBasicAttack("Atacar com espada"),
		actions.createHeal("Usar poção de cura", 5, 1),
		actions.createDefense("Defender", 2),
	},
}

players[#players + 1] = {
	name = "August",
	description = "Um jovem guerreiro destemido e focado em ajudar outros guerreiros.",
	maxHealth = 15,
	health = 15,
	attack = 6,
	defense = 2,
	speed = 1,
	potions = 3,
	actions = {
		actions.createBasicAttack("Atacar com machado"),
		actions.createHeal("Usar poção de cura", 5, 1),
		actions.createDefense("Defender", 2),
	},
}

return players
