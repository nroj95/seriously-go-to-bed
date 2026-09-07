name = "seriously, go to bed"
description = [[
sleep should be a normal part of camp life, not an expensive emergency heal.

all supported sleeping gear uses the vanilla siesta lean-to hunger drain, about one-third of the normal sleep hunger rate. recovery is deliberately toned down: straw gives no health, fur about one-third, and tents and siesta about two-thirds. sanity recovery is generally around half of vanilla.

the idea is simple: sleeping should be worth doing to pass the night, while food, healing, and sanity management still matter.

proper tents no longer wear out from sleeping, while portable rolls keep configurable durability. full-sized tents can also be shared.

features:
- siesta-level hunger drain across sleeping equipment
- deliberately reduced health and sanity recovery
- configurable straw roll and fur roll durability
- infinite tent, siesta lean-to, and camper's tent uses
- shared tent and siesta sleeping
- walter gets double sleep sanity recovery
]]

author = "nroj"
version = "0.2.0"

api_version = 10
dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false

client_only_mod = false
all_clients_require_mod = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

server_filter_tags = {
    "sleep",
    "tent",
}

local capacity_options = {
    { description = "1", data = 1 },
    { description = "2", data = 2 },
    { description = "3", data = 3 },
    { description = "4", data = 4 },
    { description = "10", data = 10 },
    { description = "Unlimited", data = 0 },
}

configuration_options = {
    {
        name = "tent_capacity",
        label = "Tent capacity",
        hover = "Maximum players who can sleep in one Tent at a time.",
        options = capacity_options,
        default = 3,
    },
    {
        name = "siesta_capacity",
        label = "Siesta Lean-to capacity",
        hover = "Maximum players who can sleep in one Siesta Lean-to at a time.",
        options = capacity_options,
        default = 3,
    },
    {
        name = "straw_roll_uses",
        label = "Straw Roll uses",
        hover = "Number of sleeps before a Straw Roll wears out.",
        options = {
            { description = "2", data = 2 },
            { description = "3", data = 3 },
            { description = "4", data = 4 },
            { description = "10", data = 10 },
            { description = "Infinite", data = 0 },
        },
        default = 3,
    },
    {
        name = "fur_roll_uses",
        label = "Fur Roll uses",
        hover = "Number of sleeps before a Fur Roll wears out.",
        options = {
            { description = "3", data = 3 },
            { description = "10", data = 10 },
            { description = "15", data = 15 },
            { description = "30", data = 30 },
            { description = "Infinite", data = 0 },
        },
        default = 15,
    },
}
