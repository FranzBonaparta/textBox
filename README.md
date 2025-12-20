# textBox

A simple lightweight component to render and edit multi-line text in a flexible way.
The `textBox` automatically adjusts its height to the number of lines, mimicking a **flexBox-style behavior**.
Designed to be modular, easily extendable, and fully integrated with **Löve2D** and **Lua**.

![TurtleTech](https://img.shields.io/badge/TurtleTech-Löve2D-🍕)
![CraftedInLua](https://img.shields.io/badge/Crafted_in-Lua-blue)
![NinjaDev](https://img.shields.io/badge/Ninja_Dev-🐢🍕-purple)

---

## ✨ Features

* [x] Multi-line editable text
* [x] Automatic line wrapping on spaces (wrap-on-word)
* [x] Dynamic height adjustment (like a FlexBox)
* [x] Basic cursor movement and blinking
* [x] Mouse-based positioning of the cursor
* [x] Support for `backspace` and `delete`
* [x] Placeholder text if input is empty
* [x] Lightweight and dependency-free (apart from `classic.lua`)

Coming soon:

* [ ] Hard-wrap on long words (with custom hyphenation logic)
* [ ] Word-aware cursor movement (e.g., ctrl+arrow)
* [ ] Selection / copy-paste support

---

## 📂 Files Overview

* `textBox.lua`: Main component
* `lineManager.lua`: Line-level logic (insertion, deletion, wrapping)
* `main.lua`: Simple usage example with `love.load`, `love.draw`, `love.update`, etc.

---

## ⚡ Quick Usage

```lua
local TextBox = require("textBox")
local textBox = TextBox(50, 50, 300, 30) -- x, y, width, lineHeight

function love.load()
    textBox.focused = true
end

function love.update(dt)
    textBox:update(dt)
end

function love.draw()
    textBox:draw()
end

function love.keypressed(key)
    textBox:keypressed(key)
end

function love.textinput(t)
    local LineManager = require("lineManager")
    LineManager.addToLines(t, textBox)
    textBox:setCanvas()
end

function love.mousepressed(mx, my, button)
    textBox:mousepressed(mx, my, button)
end
```

---

## 🔎 Design Notes

* The text is stored in a `lines` array.
* Each insertion or deletion triggers a check for whether the line needs to wrap.
* Wrapping currently works **only on spaces** (not in the middle of a word).
* Cursor position is tracked with a `line` and `col` index.
* `LineManager` is responsible for splitting/merging lines and adjusting cursor.

Custom hard-wrap (cutting a word) is **not yet implemented** but will use a rule-based hyphenation system (e.g., only inserting a special character like `—`, to allow safe undo).

---

## 🌍 License

**Copyleft © 2025 Franz Bonaparta (aka Jojopov)**
Released under the **GNU GPLv3 or later**.
See [https://www.gnu.org/licenses/](https://www.gnu.org/licenses/) for full terms.

---

## 🚀 Credits & Shoutouts

This project is part of the **TurtleTech** collection:
A suite of small, Lua-based UI and game components built with a hacker/maker mindset.

Feel free to fork, contribute, or repurpose the component in your Löve2D projects.

---

> “Write here… then write your own world.”

---

```
        8
        8  eeeee    e  eeeee eeeee eeeee ee   e
        8e 8  88    8  8  88 8   8 8  88 88   8
        88 8   8    8e 8   8 8eee8 8   8 88  e8
    e   88 8   8 e  88 8   8 88    8   8  8  8
    8eee88 8eee8 8ee88 8eee8 88    8eee8  8ee8
            🐢 TurtleTech · Crafted in Lua 🍕
```

---
