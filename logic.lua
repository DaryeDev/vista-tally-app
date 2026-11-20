-- Tally: a counter with a daily goal.
--   glasses: OK adds, left undoes
--   phone:   the buttons in phone.ui.json send {op = ...} events
-- State lives in vista.kv, so it survives closing the app.

local n, goal, step, notify_on = 0, 10, 1, true
local log = {}

local function load()
  n = vista.kv.get('n') or 0
  goal = vista.kv.get('goal') or 10
  step = vista.kv.get('step') or 1
  local nf = vista.kv.get('notify')
  if nf ~= nil then notify_on = nf end
  log = vista.kv.get('log') or {}
end

local function save()
  vista.kv.set('n', n)
  vista.kv.set('goal', goal)
  vista.kv.set('step', step)
  vista.kv.set('notify', notify_on)
  vista.kv.set('log', log)
end

local function note(text)
  table.insert(log, 1, text)
  while #log > 5 do table.remove(log) end
end

local function message()
  if n >= goal then return 'Goal reached' end
  return (goal - n) .. ' to go'
end

local function publish()
  vista.render({
    n = n,
    goal = goal,
    step = tostring(step),   -- the Segmented widget compares strings
    notify = notify_on,
    msg = message(),
    log = log,
    hasLog = #log > 0,
  })
end

local function add(by)
  local before = n
  n = n + by
  if n < 0 then n = 0 end
  if n == before then return end
  note((by > 0 and '+' or '') .. by .. '  ->  ' .. n)
  if before < goal and n >= goal and notify_on then
    -- PermissionDenied is raised if the user revoked "notify"; ignore it.
    pcall(vista.notify, { title = 'Tally', body = 'You reached ' .. goal .. '.' })
  end
  save()
  publish()
end

vista.on('start', function() load(); publish() end)
vista.on('foreground', publish)

vista.on('input', function(key)
  if key == 'ok' then
    add(step)
  elseif key == 'left' then
    add(-step)
  end
end)

-- Events from phone.ui.json widgets.
vista.on('phone', function(cmd)
  if cmd.op == 'add' then
    add(step)
  elseif cmd.op == 'undo' then
    add(-step)
  elseif cmd.op == 'step' then
    step = tonumber(cmd.value) or 1
    save(); publish()
  elseif cmd.op == 'goal' then
    goal = tonumber(cmd.value) or goal
    save(); publish()
  elseif cmd.op == 'notify' then
    notify_on = cmd.value == true
    save(); publish()
  end
end)
