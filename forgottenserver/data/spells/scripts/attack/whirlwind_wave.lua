-- Define animation delay in milliseconds
local animationDelay = 200
-- Initialize table for combat areas
local combat = {}

-- Frames (1 = Area, 2 = Player, 3 = Player + Self Damaging)
local area = {}

-- Generate random combat area configurations
for i = 1,25 do
    local row = {
        {0, 0, 0, math.random(0,1), 0, 0, 0},
        {0, 0, math.random(0,1), math.random(0,1), math.random(0,1), 0, 0},
        {0, math.random(0,1), math.random(0,1), math.random(0,1), math.random(0,1), math.random(0,1), 0},
        {math.random(0,1), math.random(0,1), math.random(0,1), 2, math.random(0,1), math.random(0,1), math.random(0,1)},
        {0, math.random(0,1), math.random(0,1), math.random(0,1), math.random(0,1), math.random(0,1), 0},
        {0, 0, math.random(0,1), math.random(0,1), math.random(0,1), 0, 0},
        {0, 0, 0, math.random(0,1), 0, 0, 0}
    }
    area[i] = row
end

-- Initialize combat objects and set parameters
for i = 1, #area do
    combat[i] = Combat()
    combat[i]:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
    combat[i]:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ICETORNADO)
end

-- Set combat area for each combat object
for x, _ in ipairs(area) do
    combat[x]:setArea(createCombatArea(area[x]))
end

-- Execute combat action
function executeCombat(p, i)
    if not p.player then
        return false
    end
    if not p.player:isPlayer() then
        return false
    end
    p.combat[i]:execute(p.player, p.var)
end

-- Cast Spell
function onCastSpell(player, var)
    -- Create a table with player, var, and combat objects
    local p = {player = player, var = var, combat = combat}

    -- Damage formula
    local level = player:getLevel()
    local maglevel = player:getMagicLevel()
    local min = (level / 5) + (maglevel * 1.4) + 8
    local max = (level / 5) + (maglevel * 2.2) + 14

    -- Set combat formula and execute for each combat object
    for i = 1, #area do
        combat[i]:setFormula(COMBAT_FORMULA_LEVELMAGIC, 0, -min, 0, -max)
        -- Execute immediately for the first area, otherwise schedule execution with delay
        if i == 1 then
            combat[i]:execute(player, var)
        else
            addEvent(executeCombat, (animationDelay * i) - animationDelay, p, i)
        end
    end

    return true
end
