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
        -- si pas focus, on affiche le curseur fixe ou pas du tout
        self.cursorVisible = false
        self.cursorTimer = 0
    end
end

function TextBox:draw()
    love.graphics.setFont(font)

    -- fond
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    -- bord
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

    -- texte
    love.graphics.print(self.text, self.x + self.padding, self.y + self.padding)

    -- curseur à la fin
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

function TextBox:mousepressed(mx, my, button)
    if button ~= 1 then return end

    self.focused =
        mx >= self.x and mx <= self.x + self.w and
        my >= self.y and my <= self.y + self.h
end

function TextBox:textinput(t)
    if not self.focused then return end
    -- ici on part du principe : ASCII basique, on ajoute à la fin
    local before = self.text:sub(1, self.cursor.col - 1)
    local after  = self.text:sub(self.cursor.col)

    self.text = before .. t .. after
    self.cursor.col = self.cursor.col + 1
end

function TextBox:keypressed(key)
    if not self.focused then return end

    if key == "backspace" then
         if self.cursor.col > 1 then
            -- supprime le char juste avant le curseur
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

    -- FLECHE DROITE
    if key == "right" then
        self.cursor.col = math.min(#self.text + 1, self.cursor.col + 1)
        return
    end

end

return TextBox
