Config = {
    Map = nil,
    Items = {
        "voxels.pezh_coin_2",
    }
}

variables = function()
    _TICK = 0
    _COINS = 0
    _CLICK_AMOUNT = 1
    _CURRENT_SCREEN = "Coin"
    _DOWNLOAD_COMPLETE = false
end

Client.OnStart = function()
    variables()
    ui = require("uikit")

    download()
    Screen.DidResize()
end

Client.Tick = function(dt)
    _TICK = _TICK + dt

    if _DOWNLOAD_COMPLETE
        hud.Coins.Text.Color = Color(math.floor(lerp(hud.Coins.Text.Color.R, 255, 0.1)), math.floor(lerp(hud.Coins.Text.Color.G, 255, 0.1)), math.floor(lerp(hud.Coins.Text.Color.B, 255, 0.1)))
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
        hud.Upgrades.Buttons[i] = ui:createButton(_UPGRADES[i].name)
        hud.Upgrades.Buttons[i].onRelease = function()
            if _UPGRADES[i].type == "coins_per_click" then
                if _UPGRADES[i].action == "+" then
                    _CLICK_AMOUNT = _CLICK_AMOUNT + _UPGRADES[i].value
                end
            end

            if _UPGRADES[i].cost_action == "+" then
                _CLICK_AMOUNT = _CLICK_AMOUNT + _UPGRADES[i].cost_value
            end

            updateUi()
        end
        hud.Upgrades.Buttons[i].pos = Number2(0, 0)
        hud.Upgrades.Buttons[i].Width, hud.Upgrades.Buttons[i].Height = 0, 0
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

        updateUi()
    end
    hud.DownButtons.Coin = ui:createButton("Coin")
    hud.DownButtons.Coin.onRelease = function()
        _CURRENT_SCREEN = "Coin"

        updateUi()
    end
    hud.DownButtons.Quests = ui:createButton("Quests")
    hud.DownButtons.Quests.onRelease = function()
        _CURRENT_SCREEN = "Quests"

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
    for i=1, #_UPGRADES do
        hud.Upgrades.Buttons[i].Width, hud.Upgrades.Buttons[i].Height = Screen.Width - 10, Screen.Height / 10
        hud.Upgrades.Buttons[i].pos = Number2(5, Screen.Height - Screen.SafeArea.Top - 5 - hud.Upgrades.Buttons[i].Height - i * hud.Upgrades.Buttons[i].Height)
    end
end

download = function()
    local downloaded = 0
    local need_downloads = 1
    -- download upgrades
    HTTP:Get("https://raw.githubusercontent.com/Nanskip/cubzh-clicker/main/pezh/upgrades.lua", function(response)
        if response.StatusCode ~= 200 then
            local data = response.Body
            _UPGRADES = load(data)()

            downloaded = downloaded + 1
            if downloaded >= need_downloads then
                    _DOWNLOAD_COMPLETE = true
                initUi()
            end
        else
            print("Error downloading upgrades.lua: " .. response.StatusCode)
        end
    end)
end

function lerp(a, b, t)
    return a * (1-t) + b * t
end