local utils = require("utils")

local actions = {}

-- Fabrica: cria uma acao de ataque basico
function actions.createBasicAttack(label, damageMultiplier)
	damageMultiplier = damageMultiplier or 1
	return {
		description = label or "Atacar",
		targetRequired = true,
		requirement = nil,
		execute = function(actor, target)
			-- logica de calculo de dano (usando actor.attack, target.defense, etc.)
			local successChance = target.speed == 0 and 1 or actor.speed / target.speed
			local success = math.random() <= successChance
			-- calula o dano causado ao target
			local rawDamage = actor.attack - math.random() * target.defense
			local damage = math.max(1, math.ceil(rawDamage))
			-- apresenta o resultado do ataque
			if success then
				print(string.format("%s atacou e causou %d pontos de dano", actor.name, damage))
				target.health = target.health - damage
				local healthRate = math.floor((target.health / target.maxHealth) * 10)
				print(string.format("%s: %s", target.name, utils.getProgressBar(healthRate)))
			else
				print(string.format("%s errou o ataque", actor.name))
			end
		end,
	}
end

-- Fabrica: cria uma acao de cura
function actions.createHeal(label, healAmount, potionCost)
	return {
		description = label or "Curar",
		targetRequired = false,
		requirement = function(actor)
			return actor.potions >= (potionCost or 1)
		end,
		execute = function(actor, target)
			_ = target
			-- logica de cura
			actor.health = math.min(actor.maxHealth, actor.health + healAmount)
			actor.potions = actor.potions - potionCost
			print(string.format("%s usou uma poção de cura e recuperou %d pontos de vida", actor.name, healAmount))
		end,
	}
end

-- Fabrica: cria uma ação de espera
function actions.createWait(label)
	return {
		description = label or "Esperar",
		targetRequired = false,
		requirement = nil,
		execute = function(actor, target)
			_ = target
			print(string.format("%s decidiu esperar", actor.name))
		end,
	}
end

-- Fabrica: cria uma ação de defesa
function actions.createDefense(label, defenseMultiplier)
	defenseMultiplier = defenseMultiplier or 2
	return {
		description = label or "Defender",
		targetRequired = false,
		requirement = nil,
		execute = function(actor, target)
			_ = target
			actor.defense = actor.defense * defenseMultiplier
			print(string.format("%s se preparou para defender", actor.name))
		end,
	}
end

-- Dado um ator, retorna acoes validas (filtra por requirement)
function actions.getValidActions(actor)
	local valid = {}
	for _, action in ipairs(actor.actions) do
		if action.requirement == nil or action.requirement(actor) then
			table.insert(valid, action)
		end
	end
	return valid
end

return actions
