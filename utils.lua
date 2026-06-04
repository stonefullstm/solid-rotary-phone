local utils = {}

function utils.printLine()
	print("================================================================")
end
--- Função para criar uma barra de progresso
--- @attribute number
--- @return string
---
function utils.getProgressBar(attribute)
	local emptyChar = "☐"
	local fullChar = "◼"
	local result = ""
	for i = 1, 10, 1 do
		-- Simula operador ternário: (condição) and valor_se_verdadeiro or valor_se_falso
		result = result .. (i <= attribute and fullChar or emptyChar)
	end
	return result
end

---
--- Função para imprimir as informações de uma criatura
--- @param creature table
---
function utils.printCreature(creature)
	local healthRate = math.floor((creature.health / creature.maxHealth) * 10)
	print("| " .. creature.name)
	print("|")
	print("| " .. creature.description)
	print("|")
	print("| Atributos")
	print("|     Ataque:       " .. utils.getProgressBar(creature.attack))
	print("|     Defesa:       " .. utils.getProgressBar(creature.defense))
	print("|     Vida:         " .. utils.getProgressBar(healthRate))
	print("|     Velocidade:   " .. utils.getProgressBar(creature.speed))
end

function utils.ask()
	io.write("> ")
	local answer = io.read("*n")
	return answer
end

return utils
