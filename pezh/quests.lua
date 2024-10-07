local quests = {
    regular = {
        {
            name = "First steps",
            description = "Get 10 coins.",
            check = function()
                if _COINS >= 10 then
                    return true
                end
                return false
            end,
            reward = "50 🇵",
            get_reward = function(self)
                _COINS = _COINS + 50
                self.unlocked = true
            end,
            unlocked = false,
        },
        {
            name = "Automatization",
            description = "Upgrade coins per seconds.",
            check = function()
                if _COINS_PER_SECOND > 0 then
                    return true
                end
                return false
            end,
            reward = "20 🇵",
            get_reward = function(self)
                _COINS = _COINS + 20
                self.unlocked = true
            end,
            unlocked = false,
        },
        {
            name = "Professional clicker",
            description = "Get 300 coins.",
            check = function()
                if _COINS >= 300 then
                    return true
                end
                return false
            end,
            reward = "200 🇵",
            get_reward = function(self)
                _COINS = _COINS + 200
                self.unlocked = true
            end,
            unlocked = false,
        },
        {
            name = "Fully robotic",
            description = "Upgrade coins per seconds \nto max level.",
            check = function()
                if _UPGRADES[2].upgraded == _UPGRADES[2].max_upgrades then
                    return true
                end
                return false
            end,
            reward = "300 🇵",
            get_reward = function(self)
                _COINS = _COINS + 300
                self.unlocked = true
            end,
            unlocked = false,
        },
    }
}

return quests