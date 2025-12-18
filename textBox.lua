local Object = require("libs.classic")
local TextBox = Object:extend()
local font = love.graphics.newFont("NotoSans-Regular.ttf", 14)
local LineManager=require("lineManager")

function TextBox:new(x, y, w, lh)
    self.x = x
    self.y = y
    self.w = w
    self.lineHeight = lh

    self.lines = { "" }
    self.focused = false

    self.cursor = { col = 1, line = 1 }
    self.cursorVisible = true
    self.cursorTimer = 0

    self.padding = 4
    self.canvas = love.graphics.newCanvas(self.w, self.lineHeight)
    self:setCanvas()
end

function TextBox:setCanvas()
    local canvasHeight = self.padding * 2 + self.lineHeight * #self.lines
    self.canvas = love.graphics.newCanvas(self.w, canvasHeight)
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()
    love.graphics.setFont(font)

    -- background
    love.graphics.setColor(1, 1, 1)

    love.graphics.rectangle("fill", 0, 0, self.w, canvasHeight)
    --print(#self.lines, self.lineHeight * #self.lines)
    -- border

    if #self.lines>=1 and #self.lines[1] > 0 then
        love.graphics.setColor(0, 0, 0)
    else
        love.graphics.setColor(0, 0, 0, 0.4)
    end

    --love.graphics.rectangle("line", 0, 0, self.w, self.lineHeight*#self.lines)

    -- text
    if #self.lines == 1 and self.lines[1] == "" then
        love.graphics.print("Write here", self.padding, self.padding)
    else
        for i, line in ipairs(self.lines) do
            love.graphics.print(line, self.padding, self.padding + ((i - 1) * self.lineHeight))
        end
    end
    love.graphics.setCanvas()
end

function TextBox:draw()
    love.graphics.draw(self.canvas, self.x, self.y)
    -- cursor to the end
    if self.focused and self.cursorVisible then
        love.graphics.setColor(0, 0, 0)
        local before = self.lines[self.cursor.line]:sub(1, self.cursor.col - 1) or ""
        local textWidth = font:getWidth(before)
        -- cursor height is depending of the font's height
        local height = self.lineHeight
        --calculate the position of the cursor
        local cx = self.x + self.padding + textWidth
        local cy = self.y + ((self.cursor.line - 1) * self.lineHeight) + self.padding
        --drawing the cursor
        love.graphics.line(
            cx, cy,
            cx, (cy + height - self.padding)
        )
    end
end

function TextBox:getCharIndexFromPixel(mx, my)
    local y = math.max(math.floor((my - self.y - self.padding) / self.lineHeight) + 1, 1)
    local line = self.lines[y]
    local x = mx - (self.x + self.padding)
    if x < 0 then return 1, y end

    if not line then
        local lastLine = self.lines[#self.lines]
        return #lastLine + 1, #self.lines
    end

    local acc = 0
    for i = 1, #line do
        local ch = line:sub(i, i)
        local w = font:getWidth(ch)
        if acc + w >= x then
            return i, y
        end
        acc = acc + w
    end

    -- clic after the end
    return #line + 1, y
end

function TextBox:mousepressed(mx, my, button)
    if button ~= 1 then return end

    self.focused =
        mx >= self.x and mx <= self.x + self.w and
        my >= self.y and my <= self.y + (self.lineHeight * #self.lines)
    if self.focused then
        local x, y = self:getCharIndexFromPixel(mx, my)
        self.cursor.col = x
        self.cursor.line = y
        self:setCanvas()
    else
        return
    end
end

function TextBox:keypressed(key)
    if not self.focused then return end
    local currentLine = self.lines[self.cursor.line]
    if key == "backspace" then

        LineManager.deletePreviousChar(self)
        self:setCanvas()
        return
    end
        if key == "left" then
        self.cursor.col = math.max(1, self.cursor.col - 1)
        return
    end

    if key == "right" then
        self.cursor.col = math.min(#currentLine + 1, self.cursor.col + 1)
        return
    end
    if key == "up" then
        if self.lines[self.cursor.line - 1] then
            self.cursor.line = self.cursor.line - 1
            currentLine = self.lines[self.cursor.line]
            self.cursor.col = #currentLine >= self.cursor.col and self.cursor.col or #currentLine + 1
            return
        end
    end
    if key == "down" then
        if self.lines[self.cursor.line + 1] then
            self.cursor.line = self.cursor.line + 1
            currentLine = self.lines[self.cursor.line]
            self.cursor.col = #currentLine >= self.cursor.col and self.cursor.col or #currentLine + 1
            return
        end
    end
end

function TextBox:update(dt)
    if self.focused then
        local keys={"left","right","up","down","delete","backspace"}
        self.cursorTimer = self.cursorTimer + dt
        if self.cursorTimer >= 0.5 then
--[[            for _, key in ipairs(keys) do
                if love.keyboard.isDown(key) then
                   self:keypressed(key) 
                end
            end]]
            self.cursorTimer = 0
            self.cursorVisible = not self.cursorVisible
        end
    else
        -- If there is no focus, the cursor is displayed as fixed or not at all.
        self.cursorVisible = false
        self.cursorTimer = 0
    end
end
return TextBox
