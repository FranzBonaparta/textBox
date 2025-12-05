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
    self.focused=false
    self.cursorPos = #self.text + 1
    self.font=font or defaultFont
    love.graphics.setFont(self.font)
     self.cursorBlinkTime = 0 -- Timer used for blinking effect
    self.cursorVisible = true -- Whether the cursor is currently visible
    self.placeholder = "Write here"
    self.cursorState = "arrow"
    self:setCanvas()
end

function TextBox:setCanvas()
    local _, wrappedtext = self.font:getWrap(self.text, self.width)
    local height = self.font:getHeight()
    self.height = height * #wrappedtext
    self.canvas = love.graphics.newCanvas(self.width, self.height)
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
        local paddingX = 4
    if #self.text > 0 then
        love.graphics.setColor(0, 0, 0)
    
    love.graphics.printf(self.text, paddingX, 0, self.width, "left")
    else
        -- placeholder
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.printf(self.placeholder, paddingX, 0, self.width, "left")
    end
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
end

function TextBox:setText(t)
        if not self.focused then return end
       -- self.text = self.text == "" and t or (self.text .. t)
 local before = self.text:sub(1, self.cursorPos - 1)
    local after = self.text:sub(self.cursorPos)
    local potentialText = before .. t .. after
    -- Only allow insertion if it doesn't exceed the field's visual width
    if self.font:getWidth(self.text) < self.width and self.focused then
                self.text = potentialText
        self.cursorPos = self.cursorPos + utf8.len(self.text)
    end
    --self.text = self.text == "" and t or (self.text .. t)
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
if self.focused and self.cursorVisible then
        local textBeforeCursor = self.text:sub(1, self.cursorPos - 1)
        local paddingX = 4
        local cursorX = self.x + self.font:getWidth(textBeforeCursor) + paddingX
        love.graphics.setColor(0, 0, 0)
        love.graphics.setLineWidth(1)
        love.graphics.line(cursorX, self.y, cursorX, self.y + self.height)
        love.graphics.setColor(1, 1, 1)
    end
end
function TextBox:mousepressed(mx,my,button)
        if button == 1 and not self.focused then
        self.focused = mx >= self.x and mx <= self.x + self.width and my >=
                           self.y and my <= self.y + self.height
        -- desactivate if click outside
    elseif button == 1 and self.focused then
        self.focused = (mx < self.x or mx > self.x + self.width) and
                           (my < self.y or my > self.y + self.height)
    end
end

function TextBox:keypressed(key)
    if not self.focused then return end
    local keys = {"return", "backspace", "delete"}
    local actions = {
        function() self:setText("\n") end, function() self:back() end,
        function() self:delete() end
    }
    for i, k in ipairs(keys) do if key == k then actions[i]() end end
end
function TextBox:update(dt)
     if self.focused then
        self.cursorBlinkTime = self.cursorBlinkTime + dt
        if self.cursorBlinkTime > 0.5 then
            self.cursorBlinkTime = 0
            self.cursorVisible = not self.cursorVisible -- Toggle cursor visibility
        end
    end
    -- change mouse cursor when hover the field
    local mouseX, mouseY = love.mouse.getPosition()
    local newCursor = (mouseX > self.x and mouseX < self.x + self.width and
                          mouseY > self.y) and "ibeam" or "arrow"
    if self.cursorState ~= newCursor then
        love.mouse.setCursor(love.mouse.getSystemCursor(newCursor))
        self.cursorState = newCursor
    end
end
return TextBox
