local LineManager = {}
local font = love.graphics.newFont("NotoSans-Regular.ttf", 14)

function LineManager.addToLines(t, box)
  if not box.focused then return end

  local text = box.lines[box.cursor.line].content
  local before = text:sub(1, box.cursor.col - 1)
  local after = text:sub(box.cursor.col)
  --reconstruct current line
  local newLine = before .. t .. after
  --update the buffer
  box.lines[box.cursor.line] = {content=newLine,jump=false}
  local didWrap = LineManager.didLineWrap(box)
  if didWrap then
    local canWrap, pos = LineManager.spaceBreakWrap(box)
    local remain = 0
    if not canWrap then
      --make hardWrap
      remain = LineManager.makeHardWrap(box)
    end
    --reset cursor's position on the new line

    if remain == 0 then
      box.cursor.col = pos
      box.cursor.line = box.cursor.line + 1
    else
      if box.cursor.col >= remain then
        box.cursor.line = box.cursor.line + 1
        box.cursor.col = box.cursor.col - remain
      end
    end
  end
  --update cursor's position after capture
  box.cursor.col = box.cursor.col + 1
end

local function deleteChar(box, offset, lineIndex, col)
  col = col or box.cursor.col
  lineIndex = lineIndex or box.cursor.line
  if offset == -1 and lineIndex == 1 and col == 1 then
    return
  end
  --[[
  IMPORTANT:
  don't forget to stop the cascade when you encountered a line where
  box.lines[x].jump=true
  So: the delete MUST stop when you encountered a jump line!
  ]]

  --determine our text
  local actualLine = box.lines[lineIndex].content
  local startText, endText =
      col - 1 + offset, col + 1 + offset
  --delete previous caracter, before cursor's position
  local newText = actualLine:sub(1, math.max(1, startText)) .. actualLine:sub(endText)
  --save the new text
  box.lines[lineIndex].content = newText
  --debugText(newText)
  print(box.cursor.col, box.cursor.line)
end
function LineManager.deletePreviousChar(box)
  local offset = -1
  deleteChar(box, offset)
  box.cursor.col = math.max(1, box.cursor.col + offset)
  LineManager.cleanLines(box, box.cursor.line + 1)
end

function LineManager.deleteNextChar(box)
  local offset = 0
  deleteChar(box, offset)
  box.cursor.col = math.max(1, box.cursor.col + offset)
  LineManager.cleanLines(box, box.cursor.line + 1)
end
--function to propagate the delete on following lines
function LineManager.cleanLines(box, startLine)
  local i = startLine
  while i <= #box.lines do
    local currentLine = box.lines[i].content
    local previousLine = box.lines[i - 1].content

    if not currentLine or not previousLine then break end

    -- Try moving one or more characters if possible
    local charMoved = false
    while #currentLine > 0 do
      local firstChar = currentLine:sub(1, 1)
      local testLine = previousLine .. firstChar
      if font:getWidth(testLine) < box.w then
        --valid, then we add the  char
        previousLine = testLine
        currentLine = currentLine:sub(2)
        charMoved = true
      else
        -- stop if we exceed the width
        break
      end
    end
    if not charMoved then
      local canWrap, _ = LineManager.spaceBreakWrap(box, i)
      if not canWrap then
        --make hardWrap
        LineManager.makeHardWrap(box, i)
      end
    end
    box.lines[i - 1].content = previousLine
    box.lines[i].content = currentLine

    -- If the current line is empty, we delete it
    if #box.lines[i].content == 0 then
      table.remove(box.lines, i)
    else
      i = i + 1
    end
  end

  -- reposition the cursor properly
  local curLine = box.cursor.line
  if curLine > #box.lines then
    box.cursor.line = #box.lines
    box.cursor.col = #box.lines[#box.lines].content + 1
  end
end

--make a jump line and shift existing ones
function LineManager.insertLine(box)
  local nextLine = box.cursor.line + 1
  local oldText = ""
  if box.lines[nextLine] then
    --shift next lines
    for i = #box.lines, nextLine, 1 do
      oldText = box.lines[i].content
      local j=box.lines[i + 1].jump or false
      box.lines[i + 1] = {content=oldText,jump=j}
    end
  end
  local newText = box.lines[box.cursor.line].content:sub(box.cursor.col)
  oldText = box.lines[box.cursor.line].content:sub(1, box.cursor.col - 1)
  box.lines[box.cursor.line] = {content=oldText,jump=true}
  box.lines[nextLine] = {content=newText,jump=false}
  --actualize cursor's position
  box.cursor.line = box.cursor.line + 1
  box.cursor.col = #newText + 1
end

-- try to detect if the cursor is on first's char position
function LineManager.isFirstChar(box)
  if box.cursor.col ~= 1 then
    return false
  end
  print("first")
  if box.lines[box.cursor.line - 1] then
    box.cursor.line = box.cursor.line - 1
    box.cursor.col = #box.lines[box.cursor.line] + 1
    return true, box.cursor.line + 1
  end
end

--just to know if a line may wrap
function LineManager.didLineWrap(box, lineIndex)
  lineIndex = lineIndex or box.cursor.line
  return font:getWidth(box.lines[lineIndex].content) >= box.w
end

function LineManager.spaceBreakWrap(box, lineIndex)
  lineIndex = lineIndex or box.cursor.line
  local canWrap = false
  local text = box.lines[lineIndex].content
  --looking for the last space caracter
  local reverse = text:reverse()
  local spaceIndex = reverse:find("%s")

  while spaceIndex do
    --now check if the space is not too close for width line's limit
    spaceIndex = #text - spaceIndex + 1
    print(spaceIndex)
    local movedText = text:sub(spaceIndex)
    local newText = text:sub(1, spaceIndex - 1)
    print(movedText)
    canWrap = font:getWidth(newText) < box.w
    if canWrap then
      box.lines[lineIndex].content = newText
      if not box.lines[lineIndex + 1] then
        box.lines[lineIndex + 1] = {content="",jump=false}
      end
      box.lines[lineIndex + 1] = {content=movedText .. box.lines[lineIndex + 1].content,jump=false}
      return true, #movedText
    end
    reverse = newText:reverse()
    spaceIndex = reverse:find("%s")
  end
  --exit if there is no space
  if not spaceIndex then
    return false, 0
  end
end

function LineManager.makeHardWrap(box, lineIndex)
  lineIndex = lineIndex or box.cursor.line

  --if no space we cut the word
  local cutchar = box.lines[lineIndex].content:sub(#box.lines[lineIndex].content)
  local remain = box.lines[lineIndex].content:sub(1, #box.lines[lineIndex].content - 1)
  local length = font:getWidth(remain) - 1
  while length >= box.w do
    cutchar = remain:sub(#remain) .. cutchar
    remain = remain:sub(1, #remain - 1)
    length = font:getWidth(remain)
  end
  box.lines[lineIndex].content = remain
  box.lines[lineIndex + 1] = {content=cutchar .. (box.lines[lineIndex + 1] or ""),jump=false}
  return #remain
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
