local quests = {
    regular = {
        {
            name = "First steps",
            description = "Click coin 10 times",
            check = function()
                if _COINS >= 10 then
                    return true
                end
                return false
            end,
            reward = "100 coins",
            get_reward = function(self)
                _COINS = _COINS + 100
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
            reward = "100 coins",
            get_reward = function(self)
                _COINS = _COINS + 100
                self.unlocked = true
            end,
            unlocked = false,
        },
    }
}

return quests