
local upgrades = {
    {
        name = "Coins per click",
        description = "Adds +1 coins per click",
        cost = 100,
        image = "pezh_cpc_1",
        type = "coins_per_click",
        action = "+",
        value = 1,
        cost_action = "*",
        cost_value = 1.5,
    },
    {
        name = "Coins per second",
        description = "Adds +1 coins per second",
        cost = 200,
        image = "pezh_cps_1",
        type = "coins_per_seconds",
        action = "+",
        value = 1,
        cost_action = "*",
        cost_value = 2,
    },
}

return upgrades