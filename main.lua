local players = require("players.players")
local creatures = require("creatures.creatures")
local utils = require("utils")
local actions = require("actions")

-- header
print([[
================================================================
            _
 _         | |
| | _______| |---------------------------------------------\
|:-)_______|==[]============================================>
|_|        | |---------------------------------------------/
           |_|

---------------------------------------------------------------

                       SIMULADOR DE BATALHA

===============================================================
          Você escolhe seu personagem e se prepara para lutar.
                        É hora da batalha.
  ]])

-- Initialize random seed
math.randomseed(os.time())

while true do
	utils.printLine()
	-- Escolha do personagem
	print("Escolha seu personagem:")
	for i, player in ipairs(players) do
		print(string.format("%d. %s - %s", i, player.name, player.description))
	end
	print(string.format("%d. Sair", #players + 1))
	local chosenPlayerIndex = utils.ask()
	if chosenPlayerIndex == #players + 1 then
		print("Obrigado por jogar! Até a próxima!")
		break
	end
	local chosenPlayer = players[chosenPlayerIndex]
	if chosenPlayer then
		print(string.format("Você escolheu: %s", chosenPlayer.name))
		-- break
	else
		print("Escolha inválida. Tente novamente.")
		goto continue
	end
	utils.printLine()
	-- Seleção aleatória da criatura
	local randomCreatureIndex = math.random(1, #creatures)
	local chosenCreature = creatures[randomCreatureIndex]
	print(string.format("Um %s apareceu!", chosenCreature.name))
	-- Escolha da ação do personagem
	while true do
		print("O que você deseja fazer?")
		local validActions = actions.getValidActions(chosenPlayer)
		for i, validAction in ipairs(validActions) do
			print(string.format("%d. %s", i, validAction.description))
		end
		local chosenActionIndex = utils.ask()
		local chosenAction = validActions[chosenActionIndex]
		local isValidAction = chosenAction ~= nil
		-- Simular o turno do jogador
		if isValidAction then
			chosenAction.execute(chosenPlayer, chosenCreature)
		else
			print("Sua ação é inválida. Você perdeu a vez!")
		end
		if chosenCreature.health <= 0 then
			print()
			utils.printLine()
			print()
			print("🥳")
			print(string.format("%s prevaleceu e venceu %s.", chosenPlayer.name, chosenCreature.name))
			print("Parabéns!!!")
			print()
			break
		end
		-- Simular o turno da criatura
		utils.printLine()
		local validCreatureActions = actions.getValidActions(chosenCreature)
		local chosenCreatureAction = validCreatureActions[math.random(1, #validCreatureActions)]
		chosenCreatureAction.execute(chosenCreature, chosenPlayer)
		if chosenPlayer.health <= 0 then
			print()
			utils.printLine()
			print()
			print("😭")
			print(string.format("%s não foi capaz de vencer %s.", chosenPlayer.name, chosenCreature.name))
			print("Quem sabe na próxima vez...")
			print()
			break
		end
	end
	::continue::
end
