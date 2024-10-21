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
            name = "Easy clicks",
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
        {
            name = "I am rich!",
            description = "Get 2000 coins.",
            check = function()
                if _COINS >= 2000 then
                    return true
                end
                return false
            end,
            reward = "500 🇵",
            get_reward = function(self)
                _COINS = _COINS + 500
                self.unlocked = true
            end,
            unlocked = false,
        },
        {
            name = "Coin industry",
            description = "Upgrade coin factories \nto max level.",
            check = function()
                if _UPGRADES[4].upgraded == _UPGRADES[4].max_upgrades then
                    return true
                end
                return false
            end,
            reward = "5 🛠️",
            get_reward = function(self)
                _COINS_PER_SECOND = _COINS_PER_SECOND + 5
                self.unlocked = true
            end,
            unlocked = false,
        },
        {
            name = "I need more!",
            description = "Get 10000 coins.",
            check = function()
                if _COINS >= 10000 then
                    return true
                end
                return false
            end,
            reward = "5000 🇵",
            get_reward = function(self)
                _COINS = _COINS + 5000
                self.unlocked = true
            end,
            unlocked = false,
        },
        {
            name = "I am farmer?",
            description = "Upgrade media coins \nto max level.",
            check = function()
                if _UPGRADES[6].upgraded == _UPGRADES[6].max_upgrades then
                    return true
                end
                return false
            end,
            reward = "30 🛠️",
            get_reward = function(self)
                _COINS_PER_SECOND = _COINS_PER_SECOND + 30
                self.unlocked = true
            end,
            unlocked = false,
        },
    },

    daily = {
        {
            name = "Good morning!",
            code_reward = math.min(10000, (_COINS_PER_SECOND*10 + _COINS*50)),
            code_check = math.max(1000, (_COINS_PER_SECOND*10 + _COINS*50)),
            description = "Get " .. formatCoins(code_check) .. " coins.",
            reward = formatCoins(code_reward) .. " 🇵",
            check = function()
                if _COINS >= code_check then
                    return true
                end
                return false
            end,
            get_reward = function(self)
                _COINS = _COINS + code_reward
                self.unlocked = true
            end,
            unlocked = false,
        },
        {
            name = "Let's make some robots!",
            code_reward = math.min(1000, (_COINS_PER_SECOND*50)),
            code_check = math.min(1000, (_COINS_PER_SECOND*1.2)),
            description = "Get " .. formatCoins(code_check) .. " coins per second.",
            reward = formatCoins(code_reward) .. " 🛠️",
            check = function()
                if _COINS_PER_SECOND >= code_check then
                    return true
                end
                return false
            end,
            get_reward = function(self)
                _COINS_PER_SECOND = _COINS_PER_SECOND + code_reward
                self.unlocked = true
            end,
            unlocked = false,
        },
    }
}

return quests