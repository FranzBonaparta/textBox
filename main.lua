-- main.lua - entry point of your Love2D project
local TextBox = require("textBox")
local textBox = TextBox(10, 10, 200)
-- Function called only once at the beginning
function love.load()
    -- Initialization of resources (images, sounds, variables)
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1) -- dark grey background
end

-- Function called at each frame, it updates the logic of the game
function love.update(dt)
    -- dt = delta time = time since last frame
    -- Used for fluid movements
end

-- Function called after each update to draw on screen
function love.draw()
    -- Everything that needs to be displayed passes here
    love.graphics.setColor(1, 1, 1) -- blanc
    textBox:draw()
end

-- Function called at each touch
function love.keypressed(key)
    -- Example: exit the game with Escape
    if key == "escape" then
        love.event.quit()
    else
        textBox:keypressed(key)
    end
end

function love.textinput(t) textBox:setText(t) end
