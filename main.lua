Config = {
    Map = nil,
    Items = {
        "voxels.pezh_coin_2",
    }
}

variables = function()
    _TICK = 0
    _COINS = 0
end

Client.OnStart = function()
    variables()
    ui = require("uikit")

    initUi()
    Screen.DidResize()
end

Client.Tick = function(dt)
    _TICK = _TICK + dt
end

Screen.DidResize = function(width, height)
    updateUi()
end

initUi = function()
    hud = {}

    -- BACKGROUND
    hud.Background = ui:createFrame(Color(255, 255, 255))
    hud.Background.object.Color = {gradient="V", from=Color(142, 161, 61), to=Color(178, 214, 133)}

    -- CLICKER
    local shape = Shape(Items.voxels.pezh_coin_2)
    hud.Clicker = ui:createShape(shape)
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
    end

    -- COINS
    hud.Coins = {}
    hud.Coins.Background = ui:createFrame(Color(79, 68, 52, 30))
    hud.Coins.Text = ui:createText("🇵 0", Color(255, 255 , 255)) --🇵 symbol is a coin
end

updateUi = function()
    -- BACKGROUND
    hud.Background.Width, hud.Background.Height = Screen.Width, Screen.Height

    -- CLICKER
    hud.Clicker.pos = Number2(Screen.Width / 2, Screen.Height / 2)
    hud.Clicker.shape.Pivot = Number3(5.5, 5.5, 1)
    hud.Clicker.shape.LocalPosition = Number3(5.5, -5.5, 1)
    local scale = math.min(Screen.Width/2, Screen.Height/2)
    hud.Clicker.Width, hud.Clicker.Height = scale, scale

    -- COINS
    hud.Coins.Text.Text = "🇵 " .. math.floor(_COINS)
    hud.Coins.Text.pos = Number2(Screen.Width / 2 - hud.Coins.Text.Width / 2, Screen.Height - Screen.SafeArea.Top - 5 - hud.Coins.Text.Height)
    hud.Coins.Background.Width = hud.Coins.Text.Width + 6
    hud.Coins.Background.Height = hud.Coins.Text.Height + 6
    hud.Coins.Background.pos = Number2(hud.Coins.Text.pos.X - 3, hud.Coins.Text.pos.Y - 3)
end