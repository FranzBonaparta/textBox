local Object = require("libs.classic")
local TextBox = Object:extend()
local defaultFont = love.graphics.newFont("NotoSans-Regular.ttf",14)
local twemoji=love.graphics.newFont("openmojiblack.ttf",14)
local notoEmoji=love.graphics.newFont("NotoEmoji-VariableFont_wght.ttf",22)
local utf8 = require("utf8")

function TextBox:new(x, y, w)
    self.x = x
    self.y = y
    self.width = w
    self.height = 0
    self.text = ""
    self.canvas = nil
    love.graphics.setFont(notoEmoji)
    self:setCanvas()
end

function TextBox:setCanvas()
    local _, wrappedtext = notoEmoji:getWrap(self.text, self.width)
    local height = notoEmoji:getHeight()
    self.height = height * #wrappedtext
    self.canvas = love.graphics.newCanvas(self.width, self.height)
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(self.text, 0, 0, self.width, "left")
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
end

function TextBox:setText(t)
    self.text = self.text == "" and t or (self.text .. t)
    self:setCanvas()
end

function TextBox:back()
    local len = utf8.len(self.text)
    if not len or len <= 0 then return end

    local byteStart = utf8.offset(self.text, len)  -- start of last character
    self.text = self.text:sub(1, byteStart - 1)
    self:setCanvas()
end

function TextBox:delete()
    self.text = ""
    self:setCanvas()
end

function TextBox:draw()
    if self.canvas then love.graphics.draw(self.canvas, self.x, self.y) end

end

function TextBox:keypressed(key)
    local keys = {"return", "backspace", "delete"}
    local actions = {
        function() self:setText("\n") end, function() self:back() end,
        function() self:delete() end
    }
    for i, k in ipairs(keys) do if key == k then actions[i]() end end
end

return TextBox
