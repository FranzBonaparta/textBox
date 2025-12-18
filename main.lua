--[[
	    8
	    8  eeeee    e  eeeee eeeee eeeee ee   e
	    8e 8  88    8  8  88 8   8 8  88 88   8
	    88 8   8    8e 8   8 8eee8 8   8 88  e8
	e   88 8   8 e  88 8   8 88    8   8  8  8
	8eee88 8eee8 8ee88 8eee8 88    8eee8  8ee8
	        🐢 TurtleTech · Crafted in Lua 🍕

  Project : ko
  Copyleft (ɔ) 2025 Jojopov (Franz Bonaparta)
  License : GNU GPLv3 or later
  https://www.gnu.org/licenses/
]]
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
-- See <https://www.gnu.org/licenses/>.

local TextBox = require("textBox")
local textBox = TextBox(50, 50, 300, 30)
local LineManager = require("lineManager")

-- Function called only once at the beginning
function love.load()
    -- Initialization of resources (images, sounds, variables)
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1) -- dark grey background
    textBox.focused = true
end

-- Function called at each frame, it updates the logic of the game
function love.update(dt)
    -- dt = delta time = time since last frame
    -- Used for fluid movements
    textBox:update(dt)
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

function love.mousepressed(mx, my, button)
    textBox:mousepressed(mx, my, button)
end

function love.textinput(t)
    LineManager.addToLines(t, textBox)
    textBox:setCanvas()
end
