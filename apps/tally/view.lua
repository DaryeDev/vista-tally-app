-- Runs on the glasses. Draws whatever logic.lua passed to vista.render().
local F = require('vista_fonts')
local INK = 0xF4F1EA
local DIM = 0xA8A59D
local FAINT = 0x9A978F
local ACCENT = 0x7CE0B8

local function center(font, text, y, color)
  F.text(font, text, 128 - F.width(font, text) / 2, y, color)
end

local function draw(S)
  S = S or {}
  center(F.label, 'TALLY', 36, ACCENT)
  center(F.display, tostring(S.n or 0), 92, INK)
  center(F.caption, 'of ' .. tostring(S.goal or 10) .. '  -  ' .. tostring(S.msg or ''), 148, DIM)
  center(F.label, 'OK +' .. tostring(S.step or 1) .. '   < -' .. tostring(S.step or 1), 186, FAINT)
end

return { draw = draw }
