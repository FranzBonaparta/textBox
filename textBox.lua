local Object = require("libs.classic")
local TextBox = Object:extend()

local font = love.graphics.newFont("NotoSans-Regular.ttf", 14)

function TextBox:new(x, y, w, h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h

    self.text = ""
    self.focused = false

    self.cursor={col=1,line=1}
    self.cursorVisible = true
    self.cursorTimer = 0

    self.padding = 4
end

function TextBox:update(dt)
    if self.focused then
        self.cursorTimer = self.cursorTimer + dt
        if self.cursorTimer >= 0.5 then
            self.cursorTimer = 0
            self.cursorVisible = not self.cursorVisible
        end
    else
        -- If there is no focus, the cursor is displayed as fixed or not at all.
        self.cursorVisible = false
        self.cursorTimer = 0
    end
end

function TextBox:draw()
    love.graphics.setFont(font)

    -- background
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    -- border
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

    -- text
    love.graphics.print(self.text, self.x + self.padding, self.y + self.padding)

    -- cursor to the end
    if self.focused and self.cursorVisible then
        local before=self.text:sub(1,self.cursor.col-1)or ""
        local textWidth = font:getWidth(before)
        local lineHeight = font:getHeight()

        local cx = self.x + self.padding + textWidth
        local cy = self.y + self.padding

        love.graphics.line(
            cx, cy,
            cx, cy + lineHeight
        )
    end
end
function TextBox:getCharIndexFromPixel(mx)
    local x=mx- (self.x+self.padding)
    if x < 0 then return 1 end
    local acc = 0
     for i = 1, #self.text do
        local ch = self.text:sub(i, i)
        local w = font:getWidth(ch)
        if acc + w >= x then
            return i
        end
        acc = acc + w
    end

    -- clic after the end 
    return #self.text + 1
    
end
function TextBox:mousepressed(mx, my, button)
    if button ~= 1 then return end

    self.focused =
        mx >= self.x and mx <= self.x + self.w and
        my >= self.y and my <= self.y + self.h
        if self.focused then
            local x=self:getCharIndexFromPixel(mx)
            self.cursor.col=x
        end
end

function TextBox:textinput(t)
    if not self.focused then return end
    -- Here we start from the principle: basic ASCII, we add at the end
    local before = self.text:sub(1, self.cursor.col - 1)
    local after  = self.text:sub(self.cursor.col)

    self.text = before .. t .. after
    self.cursor.col = self.cursor.col + 1
end

function TextBox:keypressed(key)
    if not self.focused then return end

    if key == "backspace" then
         if self.cursor.col > 1 then
            -- deletes the character just before the cursor
            local before = self.text:sub(1, self.cursor.col - 2)
            local after  = self.text:sub(self.cursor.col)

            self.text = before .. after
            self.cursor.col = self.cursor.col - 1
        end
        return
    end
    if key == "left" then
        self.cursor.col = math.max(1, self.cursor.col - 1)
        return
    end

    if key == "right" then
        self.cursor.col = math.min(#self.text + 1, self.cursor.col + 1)
        return
    end

end

return TextBox
