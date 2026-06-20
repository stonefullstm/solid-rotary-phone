# Plano: Versao Orientada a Objetos

## Objetivo

Transformar o simulador baseado em tabelas planas para uma arquitetura orientada a objetos em Lua, usando metatables e prototipos, **sem dependencias externas**.

---

## 1. Padrao OO em Lua (Escolha Tecnica)

Lua nao tem `class` nativo. Tres abordagens comuns:

| Abordagem | Complexidade | Performance | Flexibilidade |
|-----------|-------------|-------------|---------------|
| **A) Prototipos com `__index`** (recomendado) | Baixa | Boa | Alta |
| B) Fechos (closures) por instancia | Baixa | Ruim (muita memoria) | Media |
| C) Lib externa (middleclass, 30log) | Baixa p/ usar | Media | Alta |

**Escolha: Abordagem A** — cada "classe" e uma tabela com metodos, instancias usam `setmetatable(obj, { __index = Classe })`. Heranca feita com `setmetatable(SubClasse, { __index = SuperClasse })`.

---

## 2. Hierarquia de Classes

```
Entity (classe base)
├── Player (jogadores)
└── Creature (criaturas/inimigos)
```

```
Entity
  ├── name: string
  ├── description: string
  ├── maxHealth: number
  ├── health: number
  ├── attack: number
  ├── defense: number
  ├── speed: number
  ├── actions: Action[]
  │
  ├── Entity:new(o) → Entity          -- construtor
  ├── Entity:isAlive() → bool
  ├── Entity:takeDamage(amount)
  ├── Entity:heal(amount)
  ├── Entity:getValidActions() → Action[]
  ├── Entity:getHealthBar() → string
  ├── Entity:getStatBar(attr, max?) → string
  └── Entity:getStatsDisplay() → string   (substitui printCreature)

Player : Entity
  ├── potions: number
  ├── Player:new(o) → Player
  └── Player:usePotion(healAmount) → bool

Creature : Entity
  ├── Creature:new(o) → Creature
  └── Creature:chooseAction() → Action    (IA)
```

### Diagrama de metatables

```
instancia (player "Violet")
  __index → Player (tabela de metodos)
               __index → Entity (tabela de metodos)

instancia (creature "Dragon")
  __index → Creature (tabela de metodos)
               __index → Entity (tabela de metodos)
```

---

## 3. Estrutura de Arquivos Proposta

```
simulador-multiplos-personagens/
├── classes/
│   ├── entity.lua          -- classe base Entity
│   ├── player.lua          -- subclasse Player
│   └── creature.lua        -- subclasse Creature
├── actions/
│   ├── actions.lua         -- modulo de fabricas de acoes (mantido, adaptado)
│   └── ai.lua              -- (opcional) logica de IA extraida
├── combat/
│   └── combat.lua          -- loop de combate (ja planejado no PLANO.md)
├── data/
│   ├── players.lua         -- dados dos jogadores (instanciacao)
│   └── creatures.lua       -- dados das criaturas (instanciacao)
├── utils.lua               -- utilitarios (mantido)
└── main.lua                -- ponto de entrada
```

**Mudancas em relacao ao atual:**
- `players/players.lua` → `data/players.lua` (so instancia, nao define estrutura)
- `creatures/creatures.lua` → `data/creatures.lua` (so instancia)
- Novos: `classes/entity.lua`, `classes/player.lua`, `classes/creature.lua`
- `actions.lua` pode ficar na raiz ou em `actions/` (detalhe cosmetico)

---

## 4. Implementacao das Classes

### 4.1. `classes/entity.lua` — Classe Base

```lua
local Entity = {}

function Entity:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    -- Valores default
    o.health = o.health or o.maxHealth or 10
    o.maxHealth = o.maxHealth or 10
    o.attack = o.attack or 1
    o.defense = o.defense or 1
    o.speed = o.speed or 1
    o.actions = o.actions or {}

    return o
end

function Entity:isAlive()
    return self.health > 0
end

function Entity:takeDamage(amount)
    local actual = math.max(0, amount)
    self.health = math.max(0, self.health - actual)
    return actual
end

function Entity:heal(amount)
    local healed = math.min(amount, self.maxHealth - self.health)
    self.health = math.min(self.maxHealth, self.health + amount)
    return healed
end

function Entity:getValidActions()
    local valid = {}
    for _, action in ipairs(self.actions) do
        if action.requirement == nil or action.requirement(self) then
            valid[#valid + 1] = action
        end
    end
    return valid
end

function Entity:getStatBar(value, maxValue)
    -- usa utils.getProgressBar internamente
end

function Entity:getHealthBar()
    return self:getStatBar(self.health, self.maxHealth)
end

function Entity:getStatsDisplay()
    -- retorna string formatada com nome, descricao, barras
end

return Entity
```

### 4.2. `classes/player.lua` — Subclasse Player

```lua
local Entity = require("classes.entity")

local Player = Entity:new()  -- Player herda de Entity

function Player:new(o)
    o = o or {}
    -- Chama construtor da base via Entity.new
    local instance = Entity.new(self, o)
    -- Player herda metodos de Entity
    setmetatable(Player, { __index = Entity })

    instance.potions = o.potions or 0
    return instance
end

function Player:usePotion(healAmount)
    if self.potions <= 0 then
        return false
    end
    self.potions = self.potions - 1
    self:heal(healAmount)
    return true
end

return Player
```

**Atencao:** O padrao de heranca em Lua com `Entity:new()` + `Player:new()` tem uma sutileza. A forma mais limpa:

```lua
-- classes/entity.lua
local Entity = {}
Entity.__index = Entity

function Entity.new(o)
    local self = setmetatable(o or {}, Entity)
    self.health = self.health or self.maxHealth or 10
    -- ...
    return self
end

-- classes/player.lua
local Entity = require("classes.entity")
local Player = setmetatable({}, { __index = Entity })
Player.__index = Player

function Player.new(o)
    local self = Entity.new(o)               -- cria instancia base
    setmetatable(self, Player)               -- troca metatable para Player
    self.potions = o.potions or 0
    return self
end

-- Metodos so de Player
function Player:usePotion(healAmount)
    -- ...
end

return Player
```

### 4.3. `classes/creature.lua` — Subclasse Creature

```lua
local Entity = require("classes.entity")

local Creature = setmetatable({}, { __index = Entity })
Creature.__index = Creature

function Creature.new(o)
    local self = Entity.new(o)
    setmetatable(self, Creature)
    -- Creature nao tem potions, mas pode ter outros atributos futuros
    return self
end

function Creature:chooseAction()
    -- IA simples: acao aleatoria entre validas
    local valid = self:getValidActions()
    if #valid == 0 then return nil end
    return valid[math.random(#valid)]
end

-- IA avancada (opcional): poderia ter heuristicas
-- function Creature:chooseActionAdvanced(players)
--     -- atacar jogador com menos vida, etc.
-- end

return Creature
```

---

## 5. Adaptacao das Actions

As actions continuam sendo tabelas externas (padrao strategy/composicao), **nao metodos da classe**. Isso mantem a flexibilidade atual.

### Mudanca na assinatura de `execute`

As actions ja usam `execute(actor, target)`. Nada muda. `actor` e `target` agora sao **instancias** de `Entity`/`Player`/`Creature` em vez de tabelas planas, mas a interface e identica.

### Possiveis melhorias OO nas actions:

- `actor:getValidActions()` — ja e metodo de Entity
- `actor:isAlive()` — ja e metodo de Entity
- `target:takeDamage(damage)` — encapsula `target.health = target.health - damage`
- `actor:heal(amount)` — encapsula logica de cura com cap em `maxHealth`

```lua
-- actions.lua (adaptado para OO)
function actions.createBasicAttack(label, damageMultiplier)
    return {
        description = label or "Atacar",
        targetRequired = true,
        requirement = nil,
        execute = function(actor, target)
            local hitChance = actor.speed / math.max(1, target.speed)
            if math.random() > math.min(hitChance, 1) then
                print(string.format("%s errou!", actor.name))
                return
            end
            local rawDamage = actor.attack - math.random() * target.defense
            local damage = math.max(1, math.ceil(rawDamage))
            target:takeDamage(damage)                    -- <-- metodo OO
            print(string.format("%s causou %d de dano em %s. Vida restante: %s",
                actor.name, damage, target.name, target:getHealthBar()))
        end
    }
end
```

---

## 6. Dados: Instanciacao

### `data/players.lua`

```lua
local Player = require("classes.player")
local actions = require("actions")  -- ou actions.actions

local players = {}

players[#players + 1] = Player.new({
    name = "Violet",
    description = "Uma jovem guerreira determinada a vencer batalhas e salvar seu reino.",
    maxHealth = 10,
    attack = 4,
    defense = 2,
    speed = 2,
    potions = 3,
    actions = {
        actions.createBasicAttack("Atacar com espada"),
        actions.createHeal("Usar poção de cura", 5, 1),
        actions.createDefense("Defender", 2),
    }
})

players[#players + 1] = Player.new({
    name = "August",
    description = "Um jovem guerreiro destemido e focado em ajudar outros guerreiros.",
    maxHealth = 15,
    attack = 6,
    defense = 2,
    speed = 1,
    potions = 3,
    actions = {
        actions.createBasicAttack("Atacar com machado"),
        actions.createHeal("Usar poção de cura", 5, 1),
        actions.createDefense("Defender", 2),
    }
})

return players
```

### `data/creatures.lua`

```lua
local Creature = require("classes.creature")
local actions = require("actions")

local creatures = {}

creatures[#creatures + 1] = Creature.new({
    name = "Dragon",
    description = "Uma criatura poderosa e feroz que cospe fogo.",
    maxHealth = 20,
    attack = 30,
    defense = 20,
    speed = 5,
    actions = {
        actions.createBasicAttack("Ataque de fogo"),
        actions.createWait("Aguardar"),
    }
})

creatures[#creatures + 1] = Creature.new({
    name = "Slime",
    description = "Uma criatura gelatinosa que se move lentamente.",
    maxHealth = 10,
    attack = 8,
    defense = 3,
    speed = 2,
    actions = {
        actions.createBasicAttack("Ataque ácido"),
        actions.createWait("Aguardar"),
    }
})

return creatures
```

---

## 7. Impacto no `main.lua` e `combat.lua`

### Mudancas minimas:

```lua
-- Antes:
chosenAction.execute(chosenPlayer, chosenCreature)

-- Depois (identico! A interface execute(actor, target) nao muda):
chosenAction.execute(chosenPlayer, chosenCreature)
```

### O que passa a ser possivel:

```lua
-- Verificar se criatura esta viva (encapsulado)
if not chosenCreature:isAlive() then
    print("Voce venceu!")
end

-- IA da criatura escolhe acao (metodo da classe)
local creatureAction = chosenCreature:chooseAction()
creatureAction.execute(chosenCreature, chosenPlayer)

-- Mostrar stats formatados
print(chosenPlayer:getStatsDisplay())
print(chosenCreature:getStatsDisplay())
```

---

## 8. Ordem Sugerida de Implementacao

| Passo | Arquivo(s) | Descricao |
|-------|-----------|-----------|
| **1** | `classes/entity.lua` | Criar classe base com atributos e metodos comuns (`new`, `isAlive`, `takeDamage`, `heal`, `getValidActions`, `getHealthBar`, `getStatsDisplay`) |
| **2** | `classes/player.lua` | Criar subclasse `Player` com `potions` e `usePotion()` |
| **3** | `classes/creature.lua` | Criar subclasse `Creature` com `chooseAction()` (IA) |
| **4** | `data/players.lua` | Migrar definicoes de jogadores para usarem `Player.new({...})` |
| **5** | `data/creatures.lua` | Migrar definicoes de criaturas para usarem `Creature.new({...})` |
| **6** | `actions.lua` | Adaptar `execute` das actions para chamar metodos (`target:takeDamage()`, etc.) |
| **7** | `utils.lua` | Adaptar `printCreature` para usar `entity:getStatsDisplay()` |
| **8** | `combat.lua` | Criar modulo de combate (ja planejado no PLANO.md), usando metodos OO |
| **9** | `main.lua` | Atualizar imports e usar metodos OO onde apropriado |
| **10** | Testes | Executar simulacao com cada combinacao jogador-criatura |

---

## 9. Vantagens da Abordagem OO

| Aspecto | Antes (tabelas planas) | Depois (OO) |
|---------|----------------------|-------------|
| **Encapsulamento** | `target.health = target.health - dmg` (direto) | `target:takeDamage(dmg)` (validacao interna) |
| **Reuso** | Atributos repetidos manualmente | Construtor com defaults |
| **Extensibilidade** | Adicionar atributo = editar todas as tabelas | Basta adicionar ao construtor da classe |
| **IA** | Logica espalhada no `main.lua` | `Creature:chooseAction()` encapsulado |
| **Testabilidade** | Dificil testar unidades isoladas | Cada classe pode ser testada isoladamente |
| **Interface consistente** | Cada trecho de codigo acessa atributos de forma diferente | Metodos padronizados (`:isAlive()`, `:getHealthBar()`) |
| **Validacao** | Nenhuma (ex: curar acima do max) | `heal()` impoe cap em `maxHealth` automaticamente |

---

## 10. Riscos e Cuidados

1. **Metatables tem custo**: Cada acesso a metodo via `:` passa pelo `__index`. Para atributos acessados diretamente (`self.health`), nao ha custo adicional. Performance nao e preocupante para um simulador de turnos.

2. **Heranca em Lua e manual**: E facil errar o encadeamento de `__index`. Usar sempre o padrao:
   ```lua
   local Sub = setmetatable({}, { __index = Super })
   Sub.__index = Sub
   ```

3. **Serializacao**: Se no futuro precisar salvar/carregar estado, metatables nao sao serializadas. Precisaria de `Entity:serialize()` e `Entity.deserialize()`.

4. **Nao quebrar a interface das actions**: As actions recebem `actor` e `target` e acessam `.health`, `.attack`, etc. Isso continua funcionando com OO. So mudar para metodos (`:takeDamage()`) se quiser, mas nao e obrigatorio.

5. **Manter arquivos originais intactos**: Os arquivos atuais (`players/players.lua`, `creatures/creatures.lua`, `main.lua`, `actions.lua`, `utils.lua`) nao devem ser alterados durante a migracao. Criar os novos em paralelo.

---

## 11. Exemplo de Uso Final

```lua
-- main.lua (visao final)
local players = require("data.players")
local creatures = require("data.creatures")
local combat = require("combat.combat")
local utils = require("utils")

math.randomseed(os.time())

while true do
    -- Escolher jogador
    local player = combat.selectPlayer(players)
    if not player then break end

    -- Criatura aleatoria
    local creature = creatures[math.random(#creatures)]
    print("Um " .. creature.name .. " apareceu!")
    print(creature:getStatsDisplay())

    -- Loop de batalha
    while player:isAlive() and creature:isAlive() do
        -- Turno do jogador
        combat.playerTurn(player, creature)

        if not creature:isAlive() then
            print("Vitoria! \\o/")
            break
        end

        -- Turno da criatura
        combat.creatureTurn(creature, player)

        if not player:isAlive() then
            print("Derrota... ;-;")
            break
        end
    end
end
```
