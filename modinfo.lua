name = "seriously, go to bed"
description = [[
makes sleeping a cozier, more practical part of camp life.

all sleep gear uses siesta-level hunger drain with reduced recovery. tent, siesta, and camper's tent have infinite uses. rolls keep configurable durability, and tent and siesta can be shared.
]]

author = "nroj95"
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
