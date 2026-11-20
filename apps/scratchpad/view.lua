-- Glasses view: the note, word-wrapped and centred, as much as fits.
local F = require('vista_fonts')
local INK = { cream = 0xF4F1EA, mint = 0x7CE0B8, amber = 0xFFB86B }
local DIM = 0xA8A59D
local ACCENT = 0xFFB86B

local W = 184   -- text column width inside the round display

local function wrap(font, text, maxw)
  local lines = {}
  for para in (text .. '\n'):gmatch('(.-)\n') do
    local line = ''
    for word in para:gmatch('%S+') do
      local try = line == '' and word or (line .. ' ' .. word)
      if F.width(font, try) <= maxw or line == '' then
        line = try
      else
        lines[#lines + 1] = line
        line = word
      end
    end
    lines[#lines + 1] = line
  end
  return lines
end

local function center(font, str, y, color)
  F.text(font, str, 128 - F.width(font, str) / 2, y, color)
end

local function draw(S)
  S = S or {}
  center(F.label, 'SCRATCHPAD', 30, ACCENT)
  local text = tostring(S.text or '')
  if text == '' then
    center(F.title, 'Nothing yet', 104, INK.cream)
    center(F.caption, 'Write a note on the phone', 128, DIM)
    return
  end
  local large = S.size == 'large'
  local font = large and F.title or F.body
  local step = large and 22 or 17
  local rows = large and 5 or 7
  local color = INK[S.color] or INK.cream
  local lines = wrap(font, text, W)
  local shown = math.min(#lines, rows)
  local y = 128 - (shown * step) / 2 + 2
  for i = 1, shown do
    local s = lines[i]
    if i == shown and #lines > rows then s = s .. '...' end
    center(font, s, y + (i - 1) * step, color)
  end
  center(F.label, 'OK color  up size', 210, DIM)
end

return { draw = draw }
