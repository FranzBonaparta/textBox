local LineManager = {}
local font = love.graphics.newFont("NotoSans-Regular.ttf", 14)

function LineManager.addToLines(t, box)
  if not box.focused then return end

  local text = box.lines[box.cursor.line]
  local before = text:sub(1, box.cursor.col - 1)
  local after = text:sub(box.cursor.col)
  --reconstruct current line
  local newLine = before .. t .. after
  --update the buffer
  box.lines[box.cursor.line] = newLine
  local didWrap=LineManager.didLineWrap(box)
  if didWrap then
    local canWrap,pos=LineManager.spaceBreakWrap(box)
    if canWrap then
      --reset cursor's position on the new line
      box.cursor.line=box.cursor.line+1
      box.cursor.col=pos
    end
  end
  --update cursor's position after capture
  box.cursor.col = box.cursor.col + 1
end

local function deleteChar(box, offset)
  local lineIndex = box.cursor.line
  if offset == -1 and lineIndex == 1 and box.cursor.col == 1 then
    return
  end
  --determine our text
  local actualLine = box.lines[lineIndex]
  local startText, endText =
      box.cursor.col - 1 + offset, box.cursor.col + 1 + offset
  --delete previous caracter, before cursor's position
  local newText = actualLine:sub(1, math.max(0, startText)) .. actualLine:sub(endText)
  --save the new text
  box.lines[lineIndex] = newText
  --debugText(newText)
  box.cursor.col = math.max(1, box.cursor.col + offset)
end
function LineManager.deletePreviousChar(box)
  local offset = -1
  deleteChar(box, offset)
end

function LineManager.deleteNextChar(box)
  local offset = 0
  deleteChar(box, offset)
end

--just to know if a line may wrap
function LineManager.didLineWrap(box, lineIndex)
  lineIndex = lineIndex or box.cursor.line
  return font:getWidth(box.lines[lineIndex]) >= box.w
end

function LineManager.spaceBreakWrap(box, lineIndex)
  lineIndex = lineIndex or box.cursor.line
  local canWrap = false
  local text = box.lines[lineIndex]
  --looking for the last space caracter
  local reverse = text:reverse()
  local spaceIndex = reverse:find("%s")

  while spaceIndex do
    --now check if the space is not too close for width line's limit
    spaceIndex=#text-spaceIndex+1
    print(spaceIndex)
    local movedText = text:sub(spaceIndex)
    local newText = text:sub(1, spaceIndex-1)
    print(movedText)
    canWrap = font:getWidth(newText) < box.w
    if canWrap then
      box.lines[lineIndex] = newText
      if not box.lines[lineIndex+1]then
        box.lines[lineIndex+1]=""
      end
      box.lines[lineIndex + 1] = movedText .. box.lines[lineIndex + 1]
      return true,#movedText
    end
    reverse=newText:reverse()
    spaceIndex=reverse:find("%s")
  end
  --exit if there is no space
   if not spaceIndex then
    return false,0
  end
end

return LineManager

--[[local function debugText(t)
  local pText = ""
  for i = 1, #t do
    pText = pText .. "[" .. t:sub(i, i) .. "]"
    if i < #t then
      pText = pText .. ","
    end
  end
  print(pText)
end]]
