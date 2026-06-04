local creatures = {}

creatures[#creatures + 1] = {
	name = "Dragon",
	description = "Uma criatura poderosa e feroz que cospe fogo.",
	maxHealth = 20,
	health = 20,
	attack = 30,
	defense = 20,
	speed = 5,
}

creatures[#creatures + 1] = {
	name = "Slime",
	description = "Uma criatura gelatinosa que se move lentamente.",
	maxHealth = 10,
	health = 10,
	attack = 8,
	defense = 3,
	speed = 3,
}

return creatures
