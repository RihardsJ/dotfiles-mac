-- Exercise configuration callbacks without opening or changing terminal panes.
local callbacks, parsed = {}, {}
local calls, performed = {}, nil
local act = setmetatable({}, {
  __index = function(_, name)
    return function(value) return { name = name, value = value } end
  end,
  __call = function(_, value) return value end,
})
local w = {
  action = act, home_dir = '/Users/test',
  nerdfonts = setmetatable({}, { __index = function() return '*' end }),
  mux = { get_active_workspace = function() return 'test' end },
  url = { parse = function() return parsed end },
  config_builder = function() return {} end,
  font = function(...) return {...} end,
  font_with_fallback = function(value) return value end,
  action_callback = function(fn) return fn end,
  on = function(name, fn) callbacks[name] = fn end,
  hostname = function() return 'test-host' end,
  format = function(value) return value end,
  truncate_right = function(value) return value end,
  strftime = function() return '12:00' end,
  battery_info = function() return {} end,
  run_child_process = function(args)
    calls[#calls + 1] = args
    if args[1] == 'file' then return true, 'text/plain' end
    return true, 'main'
  end,
}
utf8 = { char = function() return '*' end }
package.preload.wezterm = function() return w end
local config = dofile(arg[1])
local win = {
  perform_action = function(_, action) performed = action end,
  leader_is_active = function() return false end,
  set_left_status = function() end,
  set_right_status = function(_, parts)
    local text = ''
    for _, part in ipairs(parts) do
      if type(part) == 'table' and part.Text then text = text .. part.Text end
    end
    performed = text
  end,
}
local pane = {
  get_foreground_process_name = function() return nil end,
  is_alt_screen_active = function() return false end,
  send_text = function() error('Must not inject terminal input') end,
}
local checks = 0
local function check(condition, name)
  assert(condition, name)
  checks = checks + 1
  print('PASS ' .. name)
end
for _, key in ipairs(config.keys) do
  if key.key == 'h' and key.mods == 'CTRL' then
    key.action(win, pane)
    check(performed.name == 'ActivatePaneDirection', 'nil process supports pane navigation')
  end
end
parsed = { host = '', file_path = '/tmp/$(touch injected)', fragment = '12' }
pane.get_foreground_process_name = function() return '/bin/zsh' end
callbacks['open-uri'](win, pane, 'file:///tmp/example')
check(performed.name == 'SpawnCommandInNewTab', 'file opens a separate tab')
check(performed.value.args[4] == parsed.file_path, 'shell metacharacters remain literal arguments')
check(performed.value.args[3] == '--', 'editor receives an option separator')
parsed.host = 'remote-host'
performed = nil
check(callbacks['open-uri'](win, pane, 'file://remote-host/tmp/example') == false and not performed,
      'remote file link does not run a local command')
parsed.host = ''
parsed.fragment = '12|shell-command'
check(callbacks['open-uri'](win, pane, 'file:///tmp/example') == false, 'invalid line fragment is rejected')
parsed.fragment = nil
parsed.file_path = '/tmp/line\nbreak'
check(callbacks['open-uri'](win, pane, 'file:///tmp/example') == false, 'control characters are rejected')
parsed.file_path = '/tmp/file'
pane.get_foreground_process_name = function() return nil end
check(callbacks['open-uri'](win, pane, 'file:///tmp/example') == false, 'unknown foreground process receives no input')
local uri = setmetatable({host = 'remote-host'}, {__tostring = function() return 'file://remote-host/var/log/my/project' end})
pane.get_current_working_dir = function() return uri end
calls = {}
callbacks['update-status'](win, pane)
check(#calls == 0, 'remote status avoids local Git queries')
check(performed:find('/var/…/project', 1, true) ~= nil, 'external path retains its root')
callbacks['format-tab-title']({active_pane = { title = 'remote' }, tab_index = 0, tab_title = '', is_active = true})
check(true, 'tab title handles a missing foreground process')
print(checks .. ' checks passed')
