-- Scratchpad: one short note, edited on the phone (HTML page) and shown on the
-- glasses. The page talks to this file only through Vista.post({op = ...}).
--   glasses: OK cycles the colour, up/down switch the text size.

local MAX = 280
local SIZES = { 'small', 'large' }
local COLORS = { 'cream', 'mint', 'amber' }

local note = { text = '', size = 'small', color = 'cream' }

local function has(list, v)
  for _, x in ipairs(list) do
    if x == v then return true end
  end
  return false
end

local function save()
  vista.kv.set('note', note)
end

local function publish()
  vista.render({
    text = note.text,
    size = note.size,
    color = note.color,
    len = string.len(note.text),   -- '#' on strings is not available here
    max = MAX,
  })
end

vista.on('start', function()
  local saved = vista.kv.get('note')
  if type(saved) == 'table' then
    if type(saved.text) == 'string' then note.text = saved.text end
    if has(SIZES, saved.size) then note.size = saved.size end
    if has(COLORS, saved.color) then note.color = saved.color end
  end
  publish()
end)

vista.on('foreground', publish)

vista.on('input', function(key)
  if key == 'ok' then
    for i, c in ipairs(COLORS) do
      if c == note.color then
        note.color = COLORS[i % #COLORS + 1]
        break
      end
    end
  elseif key == 'up' or key == 'down' then
    note.size = note.size == 'small' and 'large' or 'small'
  else
    return
  end
  save(); publish()
end)

-- The page is untrusted input: check everything before using it.
vista.on('phone', function(cmd)
  if cmd.op ~= 'set' then return end
  if type(cmd.text) == 'string' then
    note.text = string.sub(cmd.text, 1, MAX)
  end
  if has(SIZES, cmd.size) then note.size = cmd.size end
  if has(COLORS, cmd.color) then note.color = cmd.color end
  save(); publish()
  vista.toast('Note sent')
end)
