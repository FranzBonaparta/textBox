local LineManager = {}
local function debugText(t)
  local pText = ""
  for i = 1, #t do
    pText = pText .. "[" .. t:sub(i, i) .. "]"
    if i < #t then
      pText = pText .. ","
    end
  end
  print(pText)
end

function LineManager.addToLines(t, box)
  if not box.focused then return end

  local text = box.lines[box.cursor.line]
  local before = text:sub(1, box.cursor.col - 1)
  local after = text:sub(box.cursor.col)
  --reconstruct current line
  local newLine = before .. t .. after
  --update the buffer
  box.lines[box.cursor.line] = newLine
  --update cursor's position
  box.cursor.col = box.cursor.col + 1
end

function LineManager.deleteNearestChar(box)
  local lineIndex = box.cursor.line
  if lineIndex == 1 and box.cursor.col == 1 then
    return
  end
  --determine our text
  local actualLine = box.lines[lineIndex]
  local startText, endText =
      box.cursor.col - 2, box.cursor.col
  --delete previous caracter, before cursor's position
  local newText = actualLine:sub(1, math.max(0, startText)) .. actualLine:sub(endText)
  debugText(newText)
  --save the new text
  box.lines[lineIndex] = newText
  --change cursor's position
  box.cursor.col = math.max(1, box.cursor.col - 1)
end

return LineManager
