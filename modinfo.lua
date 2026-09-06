name = "chill sleep (dev)"
description = [[
rebalances sleeping into a cheaper, gentler way to pass the night.

current development features:
- reduced sleep health and sanity recovery
- siesta-level hunger drain across sleeping equipment
- configurable straw roll and fur roll durability
- infinite tent, siesta lean-to, and camper's tent uses
- walter trades his sleep hunger bonus for double sleep sanity recovery

shared tent and siesta sleeping is planned for the next development phase.
]]

author = "nroj"
version = "0.1.0-dev"

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

configuration_options = {
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
