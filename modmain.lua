local TUNING = GLOBAL.TUNING
local ACTIONS = GLOBAL.ACTIONS

-- keep the balance expressed relative to dst's native one-second sleep tick.
local hunger_per_tick = TUNING.SLEEP_HUNGER_PER_TICK / 3

local straw_health_per_tick = 0
local straw_sanity_per_tick = TUNING.SLEEP_SANITY_PER_TICK / 3

local fur_health_per_tick = TUNING.SLEEP_HEALTH_PER_TICK / 3
local fur_sanity_per_tick = TUNING.SLEEP_SANITY_PER_TICK / 2

local tent_health_per_tick = TUNING.SLEEP_HEALTH_PER_TICK * 2 / 3
local tent_sanity_per_tick = TUNING.SLEEP_SANITY_PER_TICK / 2

local siesta_health_per_tick = TUNING.SLEEP_HEALTH_PER_TICK * 2 / 3
local siesta_sanity_per_tick = TUNING.SLEEP_SANITY_PER_TICK * 2 / 3

local straw_roll_uses = GetModConfigData("straw_roll_uses")
local fur_roll_uses = GetModConfigData("fur_roll_uses")


-- configure a portable roll with ordinary dst finite-use behaviour.
-- a value of 0 means infinite uses while retaining the component.
local function configure_roll_uses(inst, uses)
    if inst.components.stackable ~= nil then
        inst:RemoveComponent("stackable")
    end

    if inst.components.finiteuses == nil then
        inst:AddComponent("finiteuses")
    end

    local finiteuses = inst.components.finiteuses

    finiteuses:SetConsumption(ACTIONS.SLEEPIN, 1)

    if uses == 0 then
        finiteuses:SetMaxUses(1)
        finiteuses:SetUses(1)

        -- keep finiteuses present for vanilla/component compatibility.
        finiteuses.Use = function()
        end
    else
        finiteuses:SetMaxUses(uses)
        finiteuses:SetUses(uses)
    end
end


-- built tents remain normal finite-use entities internally, but sleeping
-- no longer consumes a use. hammering, burning, and other behaviour remain.
local function make_sleep_structure_infinite(inst)
    local finiteuses = inst.components.finiteuses
    if finiteuses == nil then
        return
    end

    finiteuses.Use = function()
    end
end


local function configure_straw_roll(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    configure_roll_uses(inst, straw_roll_uses)

    local sleepingbag = inst.components.sleepingbag
    sleepingbag.healthsleep = false
    sleepingbag.health_tick = straw_health_per_tick
    sleepingbag.sanity_tick = straw_sanity_per_tick
    sleepingbag.hunger_tick = hunger_per_tick
end


local function configure_fur_roll(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    configure_roll_uses(inst, fur_roll_uses)

    local sleepingbag = inst.components.sleepingbag
    sleepingbag.health_tick = fur_health_per_tick
    sleepingbag.sanity_tick = fur_sanity_per_tick
    sleepingbag.hunger_tick = hunger_per_tick
end


local function configure_tent(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    make_sleep_structure_infinite(inst)

    local sleepingbag = inst.components.sleepingbag
    sleepingbag.health_tick = tent_health_per_tick
    sleepingbag.sanity_tick = tent_sanity_per_tick
    sleepingbag.hunger_tick = hunger_per_tick
end


local function configure_siesta(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    make_sleep_structure_infinite(inst)

    local sleepingbag = inst.components.sleepingbag
    sleepingbag.health_tick = siesta_health_per_tick
    sleepingbag.sanity_tick = siesta_sanity_per_tick
    sleepingbag.hunger_tick = hunger_per_tick
end


local function configure_walter_tent(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    make_sleep_structure_infinite(inst)

    local sleepingbag = inst.components.sleepingbag
    sleepingbag.health_tick = tent_health_per_tick
    sleepingbag.sanity_tick = tent_sanity_per_tick
    sleepingbag.hunger_tick = hunger_per_tick
end


local function configure_walter(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    local sleepingbaguser = inst.components.sleepingbaguser
    if sleepingbaguser == nil then
        return
    end

    -- replace walter's vanilla 50% sleep hunger perk with 2x sleep sanity.
    sleepingbaguser:SetHungerBonusMult(1)
    sleepingbaguser:SetSanityBonusMult(2)
end


AddPrefabPostInit("bedroll_straw", configure_straw_roll)
AddPrefabPostInit("bedroll_furry", configure_fur_roll)

AddPrefabPostInit("tent", configure_tent)
AddPrefabPostInit("siestahut", configure_siesta)
AddPrefabPostInit("portabletent", configure_walter_tent)

AddPrefabPostInit("walter", configure_walter)
