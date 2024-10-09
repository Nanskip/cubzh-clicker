Config = {
    Map = nil,
    Items = {
        "voxels.pezh_coin_2",
    }
}

variables = function()
    _TICK = 0
    _TICK_SECOND = 0
    _COINS = 0
    _CLICK_AMOUNT = 1
    _CURRENT_SCREEN = "Coin"
    _DOWNLOAD_COMPLETE = false

    _SELECTED_UPGRADES_PAGE = 0

    _COINS_PER_SECOND = 0
end

Client.OnStart = function()
    variables()
    ui = require("uikit")

    download()
    Screen.DidResize()
    Screen.Orientation = "portrait"
end

Client.Tick = function(dt)
    _TICK = _TICK + dt
    _TICK_SECOND = _TICK_SECOND + dt

    if _DOWNLOAD_COMPLETE then
        hud.Coins.Text.Color = Color(math.floor(lerp(hud.Coins.Text.Color.R, 255, 0.1)), math.floor(lerp(hud.Coins.Text.Color.G, 255, 0.1)), math.floor(lerp(hud.Coins.Text.Color.B, 255, 0.1)))
    end
    if _TICK_SECOND >= 1 then
        _TICK_SECOND = 0
        if updateCoins then
            _COINS = _COINS + _COINS_PER_SECOND
            updateCoins()
        end
    end
end

Screen.DidResize = function(width, height)
    if _DOWNLOAD_COMPLETE then
        updateUi()
    end
end

click = function()
    _COINS = _COINS + _CLICK_AMOUNT

    if not clickSound then
        clickSound = AudioSource("coin_1")
        clickSound.Pitch = 1
        clickSound.Volume = 0.5
    end

    hud.Coins.Text.Color = Color(255, 255, 0)
    clickSound:Play()
    updateCoins()
end

initUi = function()
    hud = {}
    -- COLORS
    hud.Colors = {

    }

    -- BACKGROUND
    hud.Background = ui:createFrame(Color(255, 255, 255))
    hud.Background.object.Color = {gradient="V", from=Color(142, 161, 61), to=Color(178, 214, 133)}

    -- CLICKER
    coin_shape = Shape(Items.voxels.pezh_coin_2)
    hud.Clicker = ui:createShape(coin_shape)
    hud.Clicker.shape.Tick = function(s)
        s.rot = Rotation(-0.2*math.sin(_TICK+0.3)*0.5, math.pi+(0.3*math.sin(_TICK)*0.6), math.sin(_TICK+0.3)*0.05)
        s.Rotation:Slerp(s.Rotation, s.rot, 0.1)
    end
    hud.Clicker.onPress = function()
        hud.Clicker.shape.Rotation = Rotation(
            hud.Clicker.shape.Rotation.X+math.random(-10, 10)*0.005,
            hud.Clicker.shape.Rotation.Y+math.random(-10, 10)*0.005,
            hud.Clicker.shape.Rotation.Z+math.random(-10, 10)*0.005
        )

        click()
    end

    -- UPGRADES
    hud.Upgrades = {}
    hud.Upgrades.Buttons = {}
    hud.Upgrades.Background = ui:createFrame(Color(79, 68, 52, 50))
    for i=1, #_UPGRADES do
        if _UPGRADES[i].upgraded == nil then
            _UPGRADES[i].upgraded = 0
        end
        hud.Upgrades.Buttons[i] = ui:createButton("")
        hud.Upgrades.Buttons[i].onRelease = function(self)
            if _UPGRADES[i].cost <= _COINS then
                _COINS = _COINS - _UPGRADES[i].cost
                updateCoins()

                if _UPGRADES[i].type == "coins_per_click" then
                    if _UPGRADES[i].action == "+" then
                        _CLICK_AMOUNT = _CLICK_AMOUNT + _UPGRADES[i].value
                    end
                elseif _UPGRADES[i].type == "coins_per_seconds" then
                    if _UPGRADES[i].action == "+" then
                        _COINS_PER_SECOND = _COINS_PER_SECOND + _UPGRADES[i].value
                    end
                end

                if _UPGRADES[i].cost_action == "+" then
                    _UPGRADES[i].cost = _UPGRADES[i].cost + _UPGRADES[i].cost_value
                elseif _UPGRADES[i].cost_action == "*" then
                    _UPGRADES[i].cost = math.floor(_UPGRADES[i].cost * _UPGRADES[i].cost_value)
                end

                _UPGRADES[i].upgraded = _UPGRADES[i].upgraded + 1

                if _UPGRADES[i].upgraded >= _UPGRADES[i].max_upgrades then
                    self:disable()
                end

                purchase_sound:Play()
            end

            updateUi()
        end
        hud.Upgrades.Buttons[i].pos = Number2(0, 0)
        hud.Upgrades.Buttons[i].Width, hud.Upgrades.Buttons[i].Height = 0, 0

        hud.Upgrades.Buttons[i].image = ui:createFrame(Color(255, 255, 255))
        hud.Upgrades.Buttons[i].image:setImage(images[_UPGRADES[i].image])
        hud.Upgrades.Buttons[i].image.object.Color.A = 254
        hud.Upgrades.Buttons[i].image.pos = Number2(0, 0)
        hud.Upgrades.Buttons[i].image.Width, hud.Upgrades.Buttons[i].image.Height = 0, 0

        hud.Upgrades.Buttons[i].name = ui:createText(_UPGRADES[i].name, Color(0, 0, 0))
        hud.Upgrades.Buttons[i].name.pos = Number2(0, 0)
        hud.Upgrades.Buttons[i].name.object.Scale = 1

        hud.Upgrades.Buttons[i].description = ui:createText(_UPGRADES[i].description, Color(0, 0, 0))
        hud.Upgrades.Buttons[i].description.pos = Number2(0, 0)
        hud.Upgrades.Buttons[i].description.object.Scale = 0.8

        hud.Upgrades.Buttons[i].cost = ui:createText("Cost: " .. _UPGRADES[i].cost, Color(0, 0, 0))
        hud.Upgrades.Buttons[i].cost.pos = Number2(0, 0)
    end

    -- QUESTS
    hud.Quests = {}
    hud.Quests.Buttons = {}
    for i=1, #_QUESTS.regular do
        hud.Quests.Buttons[i] = ui:createButton("")
        hud.Quests.Buttons[i].onRelease = function(self)
            if _QUESTS.regular[i].check() then
                _QUESTS.regular[i]:get_reward()
                self:disable()

                quest_complete_sound:Play()
            end
            updateUi()
        end
        hud.Quests.Buttons[i].pos = Number2(0, 0)
        hud.Quests.Buttons[i].Width, hud.Quests.Buttons[i].Height = 0, 0

        hud.Quests.Buttons[i].name = ui:createText(_QUESTS.regular[i].name, Color(0, 0, 0))
        hud.Quests.Buttons[i].name.pos = Number2(0, 0)
        hud.Quests.Buttons[i].name.object.Scale = 1

        hud.Quests.Buttons[i].description = ui:createText(_QUESTS.regular[i].description, Color(0, 0, 0))
        hud.Quests.Buttons[i].description.pos = Number2(0, 0)
        hud.Quests.Buttons[i].description.object.Scale = 0.8

        hud.Quests.Buttons[i].reward = ui:createText(_QUESTS.regular[i].reward, Color(0, 0, 0))
        hud.Quests.Buttons[i].reward.pos = Number2(0, 0)
    end

    -- COINS
    hud.Coins = {}
    hud.Coins.Background = ui:createFrame(Color(79, 68, 52, 80))
    hud.Coins.Text = ui:createText("🇵 0", Color(255, 255 , 255)) --🇵 symbol is a coin
    hud.Coins.Text.object.Scale = 2

    -- DOWN BUTTONS
    hud.DownButtons = {}

    hud.DownButtons.Upgrades = ui:createButton("Upgrades")
    hud.DownButtons.Upgrades.onRelease = function()
        _CURRENT_SCREEN = "Upgrades"
        button_click_sound:Play()

        updateUi()
    end
    hud.DownButtons.Coin = ui:createButton("Coin")
    hud.DownButtons.Coin.onRelease = function()
        _CURRENT_SCREEN = "Coin"
        button_click_sound:Play()
        
        updateUi()
    end
    hud.DownButtons.Quests = ui:createButton("Quests")
    hud.DownButtons.Quests.onRelease = function()
        _CURRENT_SCREEN = "Quests"
        button_click_sound:Play()
        
        updateUi()
    end
end 

updateUi = function()
    -- BACKGROUND
    hud.Background.Width, hud.Background.Height = Screen.Width, Screen.Height

    -- CLICKER
    if _CURRENT_SCREEN == "Coin" then
        hud.Clicker.pos = Number2(Screen.Width / 2, Screen.Height / 2)
        hud.Clicker.shape.Pivot = Number3(5.5, 5.5, 1)
        hud.Clicker.shape.LocalPosition = Number3(5.5, -5.5, 1)
        local scale = math.min(Screen.Width/2, Screen.Height/2)
        hud.Clicker.Width, hud.Clicker.Height = scale, scale
    else
        hud.Clicker.pos = Number2(-1000, -1000)
        hud.Clicker.Width, hud.Clicker.Height = 0, 0
    end

    -- COINS
    function updateCoins()
        hud.Coins.Text.Text = "🇵 " .. math.floor(_COINS)
        hud.Coins.Text.pos = Number2(Screen.Width / 2 - hud.Coins.Text.Width / 2, Screen.Height - Screen.SafeArea.Top - 5 - hud.Coins.Text.Height)
        hud.Coins.Background.Width = hud.Coins.Text.Width + 6
        hud.Coins.Background.Height = hud.Coins.Text.Height + 6
        hud.Coins.Background.pos = Number2(hud.Coins.Text.pos.X - 3, hud.Coins.Text.pos.Y - 3)
    end

    updateCoins()

    -- DOWN BUTTONS

    hud.DownButtons.Upgrades.pos = Number2(0, 0)
    hud.DownButtons.Upgrades.Width, hud.DownButtons.Upgrades.Height = Screen.Width / 3, Screen.Height / 10
    hud.DownButtons.Coin.pos = Number2(Screen.Width / 3, 0)
    hud.DownButtons.Coin.Width, hud.DownButtons.Coin.Height = Screen.Width / 3, Screen.Height / 10
    hud.DownButtons.Quests.pos = Number2(Screen.Width / 3 * 2, 0)
    hud.DownButtons.Quests.Width, hud.DownButtons.Quests.Height = Screen.Width / 3, Screen.Height / 10

    -- UPGRADES
    if _CURRENT_SCREEN == "Upgrades" then
        for i=(_SELECTED_UPGRADES_PAGE*6)+1, (_SELECTED_UPGRADES_PAGE+1)*6 do
            if _UPGRADES[i] == nil then
                break
            end
            hud.Upgrades.Buttons[i].name.Text = _UPGRADES[i].name
            hud.Upgrades.Buttons[i].cost.Text = "Cost: " .. _UPGRADES[i].cost
            if _UPGRADES[i].upgraded >= _UPGRADES[i].max_upgrades then
                hud.Upgrades.Buttons[i].name.Text = _UPGRADES[i].name .. " (MAX)"
                hud.Upgrades.Buttons[i].cost.Text = "✅"
            end
            hud.Upgrades.Buttons[i].description.Text = _UPGRADES[i].description

            hud.Upgrades.Buttons[i].Width, hud.Upgrades.Buttons[i].Height = Screen.Width - 10, Screen.Height / 10
            hud.Upgrades.Buttons[i].pos = Number2(5, Screen.Height - Screen.SafeArea.Top - 5 - hud.Upgrades.Buttons[i].Height - i * (hud.Upgrades.Buttons[i].Height+2))

            hud.Upgrades.Buttons[i].image.Width, hud.Upgrades.Buttons[i].image.Height = hud.Upgrades.Buttons[i].Height - 10, hud.Upgrades.Buttons[i].Height - 10
            hud.Upgrades.Buttons[i].image.pos = Number2(hud.Upgrades.Buttons[i].pos.X + 5, hud.Upgrades.Buttons[i].pos.Y + hud.Upgrades.Buttons[i].Height - hud.Upgrades.Buttons[i].image.Height - 5)

            hud.Upgrades.Buttons[i].name.pos = Number2(hud.Upgrades.Buttons[i].pos.X + 10 + hud.Upgrades.Buttons[i].image.Width, hud.Upgrades.Buttons[i].pos.Y + hud.Upgrades.Buttons[i].Height - hud.Upgrades.Buttons[i].name.Height - 5)
            hud.Upgrades.Buttons[i].description.pos = Number2(hud.Upgrades.Buttons[i].pos.X + 10 + hud.Upgrades.Buttons[i].image.Width, hud.Upgrades.Buttons[i].pos.Y + hud.Upgrades.Buttons[i].Height - hud.Upgrades.Buttons[i].description.Height - hud.Upgrades.Buttons[i].name.Height)
            hud.Upgrades.Buttons[i].cost.pos = Number2(hud.Upgrades.Buttons[i].pos.X + hud.Upgrades.Buttons[i].Width - hud.Upgrades.Buttons[i].cost.Width - 10, hud.Upgrades.Buttons[i].pos.Y + hud.Upgrades.Buttons[i].Height - hud.Upgrades.Buttons[i].cost.Height)

            hud.Upgrades.Buttons[i]:setColor(Color(181, 196, 157))
            hud.Upgrades.Buttons[i]:setColorDisabled(Color(216, 222, 104))

            if _UPGRADES[i].cost > _COINS then
                hud.Upgrades.Buttons[i]:setColor(Color(181, 196, 157))
                hud.Upgrades.Buttons[i]:setColorDisabled(Color(216, 222, 104))
            else
                hud.Upgrades.Buttons[i]:setColor(Color(123, 224, 147))
                hud.Upgrades.Buttons[i]:setColorDisabled(Color(216, 222, 104))
            end
        end
    else
        for i=1, #_UPGRADES do
            hud.Upgrades.Buttons[i].Width, hud.Upgrades.Buttons[i].Height = 0, 0
            hud.Upgrades.Buttons[i].pos = Number2(-1000, -1000)
            hud.Upgrades.Buttons[i].image.pos = Number2(-1000, -1000)
            hud.Upgrades.Buttons[i].name.pos = Number2(-1000, -1000)
            hud.Upgrades.Buttons[i].description.pos = Number2(-1000, -1000)
            hud.Upgrades.Buttons[i].cost.pos = Number2(-1000, -1000)
        end
    end

    -- QUESTS
    if _CURRENT_SCREEN == "Quests" then
        for i=1, #_QUESTS.regular do
            hud.Quests.Buttons[i].Width, hud.Quests.Buttons[i].Height = Screen.Width - 10, Screen.Height / 10
            hud.Quests.Buttons[i].pos = Number2(5, Screen.Height - Screen.SafeArea.Top - 5 - hud.Quests.Buttons[i].Height - i * (hud.Quests.Buttons[i].Height+2))

            hud.Quests.Buttons[i].name.Text = _QUESTS.regular[i].name
            hud.Quests.Buttons[i].description.Text = _QUESTS.regular[i].description

            if _QUESTS.regular[i].check() then
                if _QUESTS.regular[i].unlocked == false then
                    hud.Quests.Buttons[i]:setColor(Color(123, 224, 147))
                else
                    hud.Quests.Buttons[i].reward.Text = "✅"
                    hud.Quests.Buttons[i]:setColor(Color(216, 222, 104))
                    hud.Quests.Buttons[i]:setColorDisabled(Color(216, 222, 104))
                end
            else
                hud.Quests.Buttons[i]:setColor(Color(181, 196, 157))
            end
            
            hud.Quests.Buttons[i].name.pos = Number2(hud.Quests.Buttons[i].pos.X + 10, hud.Quests.Buttons[i].pos.Y + hud.Quests.Buttons[i].Height - hud.Quests.Buttons[i].name.Height - 5)
            hud.Quests.Buttons[i].reward.pos = Number2(hud.Quests.Buttons[i].pos.X + hud.Quests.Buttons[i].Width - hud.Quests.Buttons[i].reward.Width - 10, hud.Quests.Buttons[i].pos.Y + hud.Quests.Buttons[i].Height - hud.Quests.Buttons[i].reward.Height)
            hud.Quests.Buttons[i].description.pos = Number2(hud.Quests.Buttons[i].pos.X + 10, hud.Quests.Buttons[i].pos.Y + hud.Quests.Buttons[i].Height - hud.Quests.Buttons[i].description.Height - hud.Quests.Buttons[i].name.Height)
        end
    else
        for i=1, #_QUESTS.regular do
            hud.Quests.Buttons[i].Width, hud.Quests.Buttons[i].Height = 0, 0
            hud.Quests.Buttons[i].pos = Number2(-1000, -1000)
            hud.Quests.Buttons[i].name.pos = Number2(-1000, -1000)
            hud.Quests.Buttons[i].description.pos = Number2(-1000, -1000)
            hud.Quests.Buttons[i].reward.pos = Number2(-1000, -1000)
        end
    end
end

download = function()
    downloaded = 0
    need_downloads = 2
    -- download upgrades
    HTTP:Get("https://raw.githubusercontent.com/Nanskip/cubzh-clicker/refs/heads/main/pezh/upgrades.lua", function(response)
        if response.StatusCode == 200 then
            local data = response.Body
            _UPGRADES = load(data:ToString(), nil, "bt", _ENV)()

            downloaded = downloaded + 1
            checkload()
        else
            print("Error downloading upgrades.lua: " .. response.StatusCode)
        end
    end)
    HTTP:Get("https://raw.githubusercontent.com/Nanskip/cubzh-clicker/refs/heads/main/pezh/quests.lua", function(response)
        if response.StatusCode == 200 then
            local data = response.Body
            _QUESTS = load(data:ToString(), nil, "bt", _ENV)()

            downloaded = downloaded + 1
            checkload()
        else
            print("Error downloading upgrades.lua: " .. response.StatusCode)
        end
    end)

    images = {}
    images_downloading = {
        pezh_cpc_1 = "pezh/images/cpc_1.png",
        pezh_cpc_2 = "pezh/images/cpc_2.png",
        pezh_cps_1 = "pezh/images/cps_1.png",
        pezh_cps_2 = "pezh/images/cps_2.png",
    }
    images_need_download = 2
    images_downloaded = 0

    for k, v in pairs(images_downloading) do
        HTTP:Get("https://raw.githubusercontent.com/Nanskip/cubzh-clicker/refs/heads/main/" .. v, function(response)
            if response.StatusCode == 200 then
                local data = response.Body
                images[k] = data
                images_downloaded = images_downloaded + 1
                checkload()
            else
                print("Error downloading image: " .. v .. " " .. response.StatusCode)
            end
        end)
    end

    sounds = {}
    sounds_downloading = {
        purchase = "pezh/sounds/purchase.mp3",
        quest_complete = "pezh/sounds/quest_complete.mp3",
    }
    sounds_need_download = 2
    sounds_downloaded = 0

    for k, v in pairs(sounds_downloading) do
        HTTP:Get("https://raw.githubusercontent.com/Nanskip/cubzh-clicker/refs/heads/main/" .. v, function(response)
            if response.StatusCode == 200 then
                local data = response.Body
                sounds[k] = data
                sounds_downloaded = sounds_downloaded + 1
                checkload()
            else
                print("Error downloading sound: " .. v .. " " .. response.StatusCode)
            end
        end)
    end
end

function checkload()
    if images_downloaded < images_need_download then
        return
    end
    if sounds_downloaded < sounds_need_download then
        return
    end
    if downloaded < need_downloads then
        return
    end
    if not _DOWNLOAD_COMPLETE then
        _DOWNLOAD_COMPLETE = true
        initUi()
        updateUi()
    end

    purchase_sound = AudioSource("")
    purchase_sound.Sound = sounds.purchase
    purchase_sound.Pitch = 1
    purchase_sound.Volume = 0.8

    quest_complete_sound = AudioSource("")
    quest_complete_sound.Sound = sounds.quest_complete
    quest_complete_sound.Pitch = 1
    quest_complete_sound.Volume = 0.8

    button_click_sound = AudioSource("button_5")
    button_click_sound.Pitch = 1
    button_click_sound.Volume = 0.8
end

Client.DirectionalPad = nil
Client.AnalogPad = nil

function lerp(a, b, t)
    return a * (1-t) + b * t
end