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
            code_reward = math.min(10000, math.max((_COINS_PER_SECOND * 10 + _COINS * 50), 500)),
            code_check = math.max(1000, (_COINS_PER_SECOND * 10 + _COINS * 50)),
            type = "coins",
            description = "",  -- Placeholder for description; will be set in init function
            reward = "",       -- Placeholder for reward; will be set in init function
            check = function(self)
                return _COINS >= self.code_check
            end,
            get_reward = function(self)
                _COINS = _COINS + self.code_reward
                self.unlocked = true
            end,
            unlocked = false,
        },
        {
            name = "Let's make some robots!",
            code_reward = math.min(1000, math.max((_COINS_PER_SECOND * 50), 10)),
            code_check = math.min(1000, math.max((_COINS_PER_SECOND * 1.2), 5)),
            type = "auto",
            description = "",  -- Placeholder for description; will be set in init function
            reward = "",       -- Placeholder for reward; will be set in init function
            check = function(self)
                return _COINS_PER_SECOND >= self.code_check
            end,
            get_reward = function(self)
                _COINS_PER_SECOND = _COINS_PER_SECOND + self.code_reward
                self.unlocked = true
            end,
            unlocked = false,
        },
    }
}

for _, quest in ipairs(quests.daily) do
    if quest.type == "coins" then
        quest.description = "Get " .. formatCoins(quest.code_check) .. " coins."
    elseif quest.type == "auto" then
        quest.description = "Get " .. formatCoins(quest.code_check) .. " coins per second."
    end
    quest.reward = formatCoins(quest.code_reward) .. " 🇵"
end

return quests