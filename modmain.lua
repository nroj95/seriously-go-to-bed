local TUNING = GLOBAL.TUNING
local ACTIONS = GLOBAL.ACTIONS

local setmetatable = GLOBAL.setmetatable
local pairs = GLOBAL.pairs
local ipairs = GLOBAL.ipairs
local next = GLOBAL.next

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

local tent_capacity = GetModConfigData("tent_capacity") or 3
local siesta_capacity = GetModConfigData("siesta_capacity") or 3


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


local function set_sleep_healing(sleeper, enabled)
    if sleeper.player_classified ~= nil then
        sleeper.player_classified.issleephealing:set(enabled)
    end
end


local function configure_shared_sleep(inst, capacity)
    if capacity == 1 then
        return
    end

    local sleepingbag = inst.components.sleepingbag
    if sleepingbag == nil then
        return
    end

    local original_onsleep = sleepingbag.onsleep
    local original_onwake = sleepingbag.onwake

    local shared = {
        capacity = capacity,
        sleepers = {},
        visual_owner = nil,
        waking_all = false,
    }

    inst.chill_sleep_shared = shared

    local wake_sleeper
    local wake_all

    local function sleeper_count()
        local count = 0

        for _ in pairs(shared.sleepers) do
            count = count + 1
        end

        return count
    end

    local function first_sleeper()
        for sleeper in pairs(shared.sleepers) do
            return sleeper
        end
    end

    local function is_full()
        return shared.capacity > 0
            and sleeper_count() >= shared.capacity
    end

    local function update_capacity_tag()
        if is_full() then
            inst:AddTag("hassleeper")
        else
            inst:RemoveTag("hassleeper")
        end
    end

    local function make_proxy(sleeper)
        local proxy = {
            prefab = inst.prefab,
            components = {},
        }

        local proxy_sleepingbag = {}

        setmetatable(proxy_sleepingbag, {
            __index = function(_, key)
                if key == "temperaturetickfn" then
                    if sleepingbag.temperaturetickfn == nil then
                        return nil
                    end

                    return function(_, player)
                        sleepingbag.temperaturetickfn(inst, player)
                    end
                end

                return sleepingbag[key]
            end,
        })

        proxy_sleepingbag.DoWakeUp = function(_, nostatechange)
            wake_sleeper(sleeper, nostatechange)
        end

        proxy.components.sleepingbag = proxy_sleepingbag

        return proxy
    end

    local function set_visual_owner(sleeper)
        shared.visual_owner = sleeper
        sleepingbag.sleeper = sleeper
    end

    local function clear_visual_owner()
        shared.visual_owner = nil
        sleepingbag.sleeper = nil
    end

    wake_sleeper = function(sleeper, nostatechange)
        local record = shared.sleepers[sleeper]
        if record == nil then
            return
        end

        if record.onremove ~= nil then
            sleeper:RemoveEventCallback("onremove", record.onremove)
        end

        if sleeper.sleepingbag == record.proxy then
            sleeper.sleepingbag = nil
        end

        if sleeper.components.sleepingbaguser ~= nil then
            sleeper.components.sleepingbaguser:DoWakeUp(nostatechange)
        end

        set_sleep_healing(sleeper, false)

        shared.sleepers[sleeper] = nil

        if shared.waking_all then
            return
        end

        if shared.visual_owner == sleeper then
            if original_onwake ~= nil then
                original_onwake(inst, sleeper, nostatechange)
            end

            clear_visual_owner()

            local replacement = first_sleeper()

            if replacement ~= nil then
                set_visual_owner(replacement)

                if original_onsleep ~= nil then
                    original_onsleep(inst, replacement)
                end
            end
        end

        update_capacity_tag()
    end

    wake_all = function(nostatechange)
        if shared.waking_all then
            return
        end

        local sleepers = {}
        local visual_owner = shared.visual_owner

        for sleeper in pairs(shared.sleepers) do
            sleepers[#sleepers + 1] = sleeper
        end

        shared.waking_all = true

        for _, sleeper in ipairs(sleepers) do
            wake_sleeper(sleeper, nostatechange)
        end

        shared.waking_all = false

        if visual_owner ~= nil and original_onwake ~= nil then
            original_onwake(inst, visual_owner, nostatechange)
        end

        clear_visual_owner()
        update_capacity_tag()
    end

    sleepingbag.DoSleep = function(_, doer)
        if doer == nil
            or doer.sleepingbag ~= nil
            or doer.components.sleepingbaguser == nil
            or shared.sleepers[doer] ~= nil
            or is_full() then
            return
        end

        local proxy = make_proxy(doer)

        local record = {
            proxy = proxy,
        }

        record.onremove = function()
            wake_sleeper(doer, true)
        end

        shared.sleepers[doer] = record

        doer.sleepingbag = proxy
        doer.components.sleepingbaguser:DoSleep(proxy)

        doer:ListenForEvent("onremove", record.onremove)

        if shared.visual_owner == nil then
            set_visual_owner(doer)

            if original_onsleep ~= nil then
                original_onsleep(inst, doer)
            end
        else
            set_sleep_healing(doer, sleepingbag.healthsleep)
        end

        update_capacity_tag()
    end

    sleepingbag.DoWakeUp = function(_, nostatechange)
        wake_all(nostatechange)
    end

    sleepingbag.InUse = function()
        return next(shared.sleepers) ~= nil
    end

    sleepingbag.OnRemoveFromEntity = function()
        wake_all(true)
    end

    sleepingbag.OnRemoveEntity = sleepingbag.OnRemoveFromEntity
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

    configure_shared_sleep(inst, tent_capacity)
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

    configure_shared_sleep(inst, siesta_capacity)
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
