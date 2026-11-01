-- ══════════════════════════════════════════════════════════════════════════════
--  WezTerm — Dream Terminal Configuration
--  Gruvbox Material · Powerline · Smart Splits · Workspaces · Git-aware
-- ══════════════════════════════════════════════════════════════════════════════

local wezterm                                      = require 'wezterm'
local config                                       = wezterm.config_builder()
local act                                          = wezterm.action

-- ── Palette ───────────────────────────────────────────────────────────────────
-- Gruvbox Material (dark, medium) — used everywhere for consistency
local P                                            = {
    bg_hard = '#1d2021',
    bg      = '#282828',
    bg1     = '#3c3836',
    bg2     = '#504945',
    bg3     = '#665c54',
    bg4     = '#7c6f64',
    fg      = '#d4be98',
    fg1     = '#ebdbb2',
    red     = '#ea6962',
    orange  = '#e78a4e',
    yellow  = '#d8a657',
    green   = '#a9b665',
    aqua    = '#89b482',
    blue    = '#7daea3',
    purple  = '#d3869b',
    gray    = '#928374',
}

-- Powerline separators — requires a Nerd Font (JetBrainsMono Nerd Font is set)
local PL_RIGHT                                     = utf8.char(0xe0b0) -- solid  ▶
local PL_LEFT                                      = utf8.char(0xe0b2) -- solid  ◀
local PL_THIN_RIGHT                                = utf8.char(0xe0b1) -- thin   ❯
local PL_THIN_LEFT                                 = utf8.char(0xe0b3) -- thin   ❮

-- ── Leader Key ────────────────────────────────────────────────────────────────
-- Ctrl+A activates the leader. Then press the next key within 1.5 s.
-- Press Ctrl+A twice to send a real Ctrl+A to the running program.
config.leader                                      = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1500 }

-- ── Font ──────────────────────────────────────────────────────────────────────
config.font                                        = wezterm.font_with_fallback {
    { family = 'JetBrainsMono Nerd Font', weight = 'Regular' },
    'Symbols Nerd Font Mono', -- icon fallback
    'Noto Color Emoji',
}
-- Scan installed fonts explicitly when the platform font resolver misses them.
config.font_dirs = { wezterm.home_dir .. '/Library/Fonts' }
config.font_size                                   = 13.0
-- No line_height override — the default (1.0) lets JetBrainsMono render at its
-- natural metrics without clipping ascenders or descenders.
-- Enable programming ligatures (→, ≠, <=, etc.)
config.harfbuzz_features                           = { 'calt=1', 'liga=1', 'clig=1' }

config.font_rules                                  = {
    {
        intensity = 'Bold',
        italic = false,
        font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Bold' }),
    },
    {
        intensity = 'Normal',
        italic = true,
        font = wezterm.font('JetBrainsMono Nerd Font', { style = 'Italic' }),
    },
    {
        intensity = 'Bold',
        italic = true,
        font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Bold', style = 'Italic' }),
    },
}

-- ── Color Scheme & Tab Bar Colors ─────────────────────────────────────────────
config.color_scheme                                = 'Gruvbox Material (Gogh)'

config.colors                                      = {
    -- Make the split line between panes subtle
    split = P.bg2,

    tab_bar = {
        background = P.bg_hard,
        active_tab = {
            bg_color  = P.bg,
            fg_color  = P.fg,
            intensity = 'Bold',
        },
        inactive_tab = {
            bg_color = P.bg_hard,
            fg_color = P.bg3,
        },
        inactive_tab_hover = {
            bg_color = P.bg1,
            fg_color = P.fg,
            italic   = true,
        },
        new_tab = {
            bg_color = P.bg_hard,
            fg_color = P.bg3,
        },
        new_tab_hover = {
            bg_color = P.bg1,
            fg_color = P.fg,
        },
    },
}

-- ── Window ────────────────────────────────────────────────────────────────────
config.window_decorations                          = 'RESIZE' -- no OS titlebar; clean look
config.window_padding                              = {
    left   = '2cell',
    right  = '2cell',
    top    = '0.5cell',
    bottom = '0cell', -- tab bar is at bottom, no extra padding needed
}

-- Dim inactive panes so the active one always stands out
config.inactive_pane_hsb                           = {
    saturation = 0.85,
    brightness = 0.65,
}

-- ── Tab Bar ───────────────────────────────────────────────────────────────────
config.enable_tab_bar                              = true
config.use_fancy_tab_bar                           = false -- retro/powerline mode
config.tab_bar_at_bottom                           = true
config.hide_tab_bar_if_only_one_tab                = false -- always show for status bar
config.tab_max_width                               = 40
config.show_new_tab_button_in_tab_bar              = true
config.status_update_interval                      = 1000 -- ms; drives update-status

-- ── Performance & Rendering ───────────────────────────────────────────────────
config.max_fps                                     = 144
config.animation_fps                               = 60
config.front_end                                   = 'WebGpu' -- best quality; fall back to OpenGL if issues
config.custom_block_glyphs                         = true     -- pixel-perfect box-drawing chars

-- ── Cursor ────────────────────────────────────────────────────────────────────
config.default_cursor_style                        = 'BlinkingBar'
config.cursor_blink_rate                           = 500
config.cursor_blink_ease_in                        = 'EaseIn'
config.cursor_blink_ease_out                       = 'EaseOut'

-- ── Behaviour ─────────────────────────────────────────────────────────────────
config.scrollback_lines                            = 10000
config.enable_scroll_bar                           = false
config.pane_focus_follows_mouse                    = false
config.hide_mouse_cursor_when_typing               = true
config.audible_bell                                = 'Disabled'
config.visual_bell                                 = { fade_in_duration_ms = 0, fade_out_duration_ms = 0 }
-- No "are you sure?" for shells or common tools
config.skip_close_confirmation_for_processes_named = {
    'bash', 'zsh', 'fish', 'sh', 'nu',
}
config.exit_behavior                               = 'CloseOnCleanExit'
config.adjust_window_size_when_changing_font_size  = false
config.unicode_version                             = 15
config.use_cap_height_to_scale_fallback_fonts      = true -- fixes mixed-font sizing

-- Extended keyboard protocol — allows more key combos in Neovim etc.
config.enable_kitty_keyboard                       = true

-- Quick-select patterns — extends the default URL/path set
config.quick_select_patterns                       = {
    '[0-9a-f]{7,40}',                                                -- git SHA (short or full)
    'sha256:[0-9a-f]{64}',                                           -- docker image digest
    '[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}(?::[0-9]+)?', -- IP[:port]
}

-- ── Session Persistence ───────────────────────────────────────────────────────
config.unix_domains                                = { { name = 'unix' } }

-- ══════════════════════════════════════════════════════════════════════════════
--  SMART SPLITS  (Ctrl+H/J/K/L  move · Alt+H/J/K/L  resize)
--
--  Move  (Ctrl)  — forwarded to Neovim so smart-splits.nvim can navigate
--                  Neovim splits AND jump to a WezTerm pane at the edge.
--  Resize (Alt)  — handled only by WezTerm; never sent to Neovim so there
--                  is no conflict with aerial's <A-j>/<A-k> bindings.
--
--  Neovim side: lua/plugins/smart-splits.lua in your Neovim config.
-- ══════════════════════════════════════════════════════════════════════════════

local function is_vim(pane)
    local name = (pane:get_foreground_process_name() or ''):match('[^/\\]+$')
    return name == 'nvim' or name == 'vim'
end

local nav = { h = 'Left', j = 'Down', k = 'Up', l = 'Right' }

local function smart_nav(kind, key)
    if kind == 'resize' then
        -- Resize is always handled by WezTerm — never forwarded to Neovim.
        -- This avoids conflicting with aerial's <A-j>/<A-k> inside Neovim.
        return {
            key    = key,
            mods   = 'ALT',
            action = act.AdjustPaneSize { nav[key], 3 },
        }
    end
    -- Move: forward to Neovim when active; otherwise move between WezTerm panes.
    return {
        key    = key,
        mods   = 'CTRL',
        action = wezterm.action_callback(function(win, pane)
            if is_vim(pane) then
                win:perform_action(act.SendKey { key = key, mods = 'CTRL' }, pane)
            else
                win:perform_action(act.ActivatePaneDirection(nav[key]), pane)
            end
        end),
    }
end

-- ══════════════════════════════════════════════════════════════════════════════
--  KEY BINDINGS
-- ══════════════════════════════════════════════════════════════════════════════

config.keys = {

    -- ── Escape hatch ────────────────────────────────────────────────────────────
    -- Ctrl+A, Ctrl+A → send real Ctrl+A (go to start-of-line, etc.)
    { key = 'a',     mods = 'LEADER|CTRL', action = act.SendKey { key = 'a', mods = 'CTRL' } },

    -- ── Pane management ─────────────────────────────────────────────────────────
    { key = '\\',    mods = 'LEADER',      action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = '-',     mods = 'LEADER',      action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = 'x',     mods = 'LEADER',      action = act.CloseCurrentPane { confirm = true } },
    { key = 'z',     mods = 'LEADER',      action = act.TogglePaneZoomState },
    { key = 'o',     mods = 'LEADER',      action = act.RotatePanes 'Clockwise' },
    { key = 'Space', mods = 'LEADER',      action = act.PaneSelect { mode = 'SwapWithActive' } },
    -- Visual pane picker with labels (like tmux display-panes)
    { key = 'q',     mods = 'LEADER',      action = act.PaneSelect },

    -- ── Tab management ──────────────────────────────────────────────────────────
    { key = 'c',     mods = 'LEADER',      action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 'n',     mods = 'LEADER',      action = act.ActivateTabRelative(1) },
    { key = 'p',     mods = 'LEADER',      action = act.ActivateTabRelative(-1) },
    { key = '1',     mods = 'LEADER',      action = act.ActivateTab(0) },
    { key = '2',     mods = 'LEADER',      action = act.ActivateTab(1) },
    { key = '3',     mods = 'LEADER',      action = act.ActivateTab(2) },
    { key = '4',     mods = 'LEADER',      action = act.ActivateTab(3) },
    { key = '5',     mods = 'LEADER',      action = act.ActivateTab(4) },
    { key = '6',     mods = 'LEADER',      action = act.ActivateTab(5) },
    { key = '7',     mods = 'LEADER',      action = act.ActivateTab(6) },
    { key = '8',     mods = 'LEADER',      action = act.ActivateTab(7) },
    { key = '9',     mods = 'LEADER',      action = act.ActivateTab(8) },
    { key = '&',     mods = 'LEADER',      action = act.CloseCurrentTab { confirm = true } },
    { key = 'f',     mods = 'LEADER',      action = act.ShowTabNavigator },
    -- Rename the current tab
    {
        key = 'T',
        mods = 'LEADER',
        action = act.PromptInputLine {
            description = 'Rename tab',
            action = wezterm.action_callback(function(win, _, line)
                if line then win:active_tab():set_title(line) end
            end),
        },
    },

    -- ── Workspace management ────────────────────────────────────────────────────
    { key = 's', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'WORKSPACES' } },
    { key = '[', mods = 'LEADER', action = act.SwitchWorkspaceRelative(-1) },
    { key = ']', mods = 'LEADER', action = act.SwitchWorkspaceRelative(1) },
    {
        key = 'w',
        mods = 'LEADER',
        action = act.PromptInputLine {
            description = 'New workspace name',
            action = wezterm.action_callback(function(win, pane, line)
                if line then win:perform_action(act.SwitchToWorkspace { name = line }, pane) end
            end),
        },
    },
    {
        key = '$',
        mods = 'LEADER',
        action = act.PromptInputLine {
            description = 'Rename workspace',
            action = wezterm.action_callback(function(_, _, line)
                if line then
                    wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
                end
            end),
        },
    },

    -- ── Session persistence ──────────────────────────────────────────────────────
    { key = 'A',       mods = 'LEADER|SHIFT', action = act.AttachDomain 'unix' },
    { key = 'D',       mods = 'LEADER|SHIFT', action = act.DetachDomain { DomainName = 'unix' } },

    -- ── Launcher / fuzzy everything ──────────────────────────────────────────────
    { key = 'l',       mods = 'LEADER',       action = act.ShowLauncherArgs { flags = 'FUZZY|TABS|WORKSPACES' } },

    -- ── Utility ──────────────────────────────────────────────────────────────────
    -- Quick-select: grab anything visible on screen (URLs, SHAs, IPs…)
    { key = 'u',       mods = 'LEADER',       action = act.QuickSelect },
    -- Copy mode (vi-like selection without mouse)
    { key = '[',       mods = 'CTRL|SHIFT',   action = act.ActivateCopyMode },
    -- Command palette
    { key = 'phys:F1', mods = 'NONE',         action = act.ActivateCommandPalette },
    -- Font size
    { key = '=',       mods = 'CTRL',         action = act.IncreaseFontSize },
    { key = '-',       mods = 'CTRL',         action = act.DecreaseFontSize },
    { key = '0',       mods = 'CTRL',         action = act.ResetFontSize },
    -- Toggle background opacity (great for focus / distraction-free mode)
    {
        key = 'b',
        mods = 'LEADER',
        action = wezterm.action_callback(function(window)
            local overrides = window:get_config_overrides() or {}
            if overrides.window_background_opacity then
                overrides.window_background_opacity = nil
            else
                overrides.window_background_opacity = 0.88
            end
            window:set_config_overrides(overrides)
        end),
    },

    -- ── Smart splits: navigate ────────────────────────────────────────────────
    smart_nav('move', 'h'),
    smart_nav('move', 'j'),
    smart_nav('move', 'k'),
    smart_nav('move', 'l'),
    -- ── Smart splits: resize ─────────────────────────────────────────────────
    smart_nav('resize', 'h'),
    smart_nav('resize', 'j'),
    smart_nav('resize', 'k'),
    smart_nav('resize', 'l'),
}

-- ══════════════════════════════════════════════════════════════════════════════
--  MOUSE BINDINGS
-- ══════════════════════════════════════════════════════════════════════════════

config.mouse_bindings = {
    -- Right-click: copy selection if active, paste if not
    {
        event  = { Down = { streak = 1, button = 'Right' } },
        mods   = 'NONE',
        action = wezterm.action_callback(function(window, pane)
            local has_selection = window:get_selection_text_for_pane(pane) ~= ''
            if has_selection then
                window:perform_action(act.CopyTo 'ClipboardAndPrimarySelection', pane)
                window:perform_action(act.ClearSelection, pane)
            else
                window:perform_action(act { PasteFrom = 'Clipboard' }, pane)
            end
        end),
    },
    -- Left-click: complete selection / navigate to file or folder (via open-uri)
    {
        event  = { Up = { streak = 1, button = 'Left' } },
        mods   = 'NONE',
        action = act.CompleteSelection 'ClipboardAndPrimarySelection',
    },
    -- Ctrl+click: open link in browser
    {
        event  = { Up = { streak = 1, button = 'Left' } },
        mods   = 'CTRL',
        action = act.OpenLinkAtMouseCursor,
    },
}

-- ══════════════════════════════════════════════════════════════════════════════
--  STATUS BAR  (Powerline segments)
--
--  LEFT:  [ leader/mode pill ] [ workspace ]
--  RIGHT: [ cwd  git-branch ] [ battery ] [  time ]
-- ══════════════════════════════════════════════════════════════════════════════

-- Git branch with a 10-second cache so we don't shell-out every second
local _git_cache = {}
local function git_branch(cwd)
    local now = os.time()
    local cached = _git_cache[cwd]
    if cached and (now - cached.ts) < 10 then return cached.branch end
    local ok, out = wezterm.run_child_process {
        'git', '-C', cwd, 'branch', '--show-current',
    }
    local branch = nil
    if ok then
        branch = out:gsub('%s+', '')
        if branch == '' then branch = nil end
    end
    _git_cache[cwd] = { branch = branch, ts = now }
    return branch
end

-- Compact path: ~/a/b/very-long/dir → ~/a/b/…/dir  (max 3 trailing parts)
local function short_path(full)
    if not full or full == '' then return '' end
    local home = wezterm.home_dir
    if full == home then return '~' end
    if full:sub(1, #home + 1) == home .. '/' then
        full = '~' .. full:sub(#home + 1)
    end
    -- collect path segments
    local parts = {}
    for p in full:gmatch '[^/]+' do table.insert(parts, p) end
    if #parts <= 3 then return full end
    local prefix = full:sub(1, 2) == '~/' and '~/' or '/'
    local first = prefix == '~/' and 2 or 1
    return prefix .. parts[first] .. '/…/' .. parts[#parts]
end

wezterm.on('update-status', function(window, pane)
    -- ── Left status ─────────────────────────────────────────────────────────────
    local left = {}

    if window:leader_is_active() then
        -- Bright yellow pill when LEADER is held
        table.insert(left, { Background = { Color = P.yellow } })
        table.insert(left, { Foreground = { Color = P.bg_hard } })
        table.insert(left, { Attribute = { Intensity = 'Bold' } })
        table.insert(left, { Text = '  LEADER ' })
        table.insert(left, { Background = { Color = P.bg1 } })
        table.insert(left, { Foreground = { Color = P.yellow } })
    else
        -- Quiet blue WezTerm icon when idle
        table.insert(left, { Background = { Color = P.blue } })
        table.insert(left, { Foreground = { Color = P.bg_hard } })
        table.insert(left, { Attribute = { Intensity = 'Bold' } })
        table.insert(left, { Text = '  ' })
        table.insert(left, { Background = { Color = P.bg1 } })
        table.insert(left, { Foreground = { Color = P.blue } })
    end
    table.insert(left, { Text = PL_RIGHT })

    -- Workspace name
    local ws = wezterm.mux.get_active_workspace()
    table.insert(left, { Background = { Color = P.bg1 } })
    table.insert(left, { Foreground = { Color = P.fg } })
    table.insert(left, { Attribute = { Intensity = 'Bold' } })
    table.insert(left, { Text = '  ' .. ws .. ' ' })
    table.insert(left, { Background = { Color = P.bg_hard } })
    table.insert(left, { Foreground = { Color = P.bg1 } })
    table.insert(left, { Text = PL_RIGHT })
    table.insert(left, 'ResetAttributes')

    window:set_left_status(wezterm.format(left))

    -- ── Right status ────────────────────────────────────────────────────────────
    local right     = {}

    -- Resolve cwd
    local cwd_uri   = pane:get_current_working_dir()
    local full_path = ''
    local cwd_label = ''
    if cwd_uri then
        -- tostring() yields "file:///path" or "file://hostname/path"; strip the prefix.
        full_path = tostring(cwd_uri):gsub('^file://[^/]*', '')
        -- Decode percent-encoded characters (e.g. %20 → space)
        full_path = full_path:gsub('%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
        cwd_label = short_path(full_path)
    end

    -- Git branch (cached)
    local host = cwd_uri and cwd_uri.host or ''
    local local_host = host == '' or host == 'localhost' or host == wezterm.hostname()
    local branch = local_host and full_path ~= '' and git_branch(full_path) or nil

    -- ── Segment: cwd + git ──────────────────────────────────────────────────────
    table.insert(right, { Background = { Color = P.bg_hard } })
    table.insert(right, { Foreground = { Color = P.bg1 } })
    table.insert(right, { Text = PL_LEFT })
    table.insert(right, { Background = { Color = P.bg1 } })
    table.insert(right, { Foreground = { Color = P.blue } })
    table.insert(right, { Text = '  ' .. cwd_label })
    if branch then
        table.insert(right, { Foreground = { Color = P.bg3 } })
        table.insert(right, { Text = '  ' .. PL_THIN_LEFT .. ' ' })
        table.insert(right, { Foreground = { Color = P.green } })
        table.insert(right, { Text = ' ' .. branch })
    end
    table.insert(right, { Text = ' ' })

    -- ── Segment: battery (only if battery info is available) ────────────────────
    local bats = wezterm.battery_info()
    local prev_bg = P.bg1
    if #bats > 0 then
        local b   = bats[1]
        local pct = math.floor(b.state_of_charge * 100)
        local icon
        if b.state == 'Charging' then
            icon = wezterm.nerdfonts.md_battery_charging
        elseif pct > 80 then
            icon = wezterm.nerdfonts.md_battery
        elseif pct > 60 then
            icon = wezterm.nerdfonts.md_battery_80
        elseif pct > 40 then
            icon = wezterm.nerdfonts.md_battery_60
        elseif pct > 20 then
            icon = wezterm.nerdfonts.md_battery_40
        else
            icon = wezterm.nerdfonts.md_battery_20
        end
        local bat_fg = pct <= 20 and P.red or P.green
        table.insert(right, { Background = { Color = P.bg1 } })
        table.insert(right, { Foreground = { Color = P.bg2 } })
        table.insert(right, { Text = PL_LEFT })
        table.insert(right, { Background = { Color = P.bg2 } })
        table.insert(right, { Foreground = { Color = bat_fg } })
        table.insert(right, { Text = ' ' .. icon .. '  ' .. pct .. '% ' })
        prev_bg = P.bg2
    end

    -- ── Segment: clock ──────────────────────────────────────────────────────────
    table.insert(right, { Background = { Color = prev_bg } })
    table.insert(right, { Foreground = { Color = P.purple } })
    table.insert(right, { Text = PL_LEFT })
    table.insert(right, { Background = { Color = P.purple } })
    table.insert(right, { Foreground = { Color = P.bg_hard } })
    table.insert(right, { Attribute = { Intensity = 'Bold' } })
    table.insert(right, { Text = '  ' .. wezterm.strftime '%H:%M' .. ' ' })
    table.insert(right, 'ResetAttributes')

    window:set_right_status(wezterm.format(right))
end)

-- ══════════════════════════════════════════════════════════════════════════════
--  TAB TITLE  (Powerline pills with process icons)
-- ══════════════════════════════════════════════════════════════════════════════

-- Map process basename → Nerd Font icon
local process_icons = {
    nvim    = wezterm.nerdfonts.custom_vim,
    vim     = wezterm.nerdfonts.custom_vim,
    zsh     = wezterm.nerdfonts.dev_terminal,
    fish    = wezterm.nerdfonts.dev_terminal,
    bash    = wezterm.nerdfonts.dev_terminal,
    sh      = wezterm.nerdfonts.dev_terminal,
    node    = wezterm.nerdfonts.dev_nodejs_small,
    python  = wezterm.nerdfonts.dev_python,
    python3 = wezterm.nerdfonts.dev_python,
    ruby    = wezterm.nerdfonts.dev_ruby,
    cargo   = wezterm.nerdfonts.dev_rust,
    rustc   = wezterm.nerdfonts.dev_rust,
    go      = wezterm.nerdfonts.dev_go,
    docker  = wezterm.nerdfonts.dev_docker,
    git     = wezterm.nerdfonts.dev_git,
    lazygit = wezterm.nerdfonts.dev_git,
    ssh     = wezterm.nerdfonts.md_server_network,
    htop    = wezterm.nerdfonts.md_chart_areaspline,
    btop    = wezterm.nerdfonts.md_chart_areaspline,
    top     = wezterm.nerdfonts.md_chart_areaspline,
    make    = wezterm.nerdfonts.seti_makefile,
    psql    = wezterm.nerdfonts.dev_postgresql,
    mysql   = wezterm.nerdfonts.dev_mysql,
}

local function tab_icon(pane)
    local name = ((pane.foreground_process_name or ''):match '([^/\\]+)$') or ''
    return process_icons[name] or wezterm.nerdfonts.fa_terminal
end

wezterm.on('format-tab-title', function(tab, _, _, _, hover, _)
    local pane   = tab.active_pane
    local icon   = tab_icon(pane)
    local idx    = tostring(tab.tab_index + 1)
    local title  = tab.tab_title ~= '' and tab.tab_title or pane.title
    title        = wezterm.truncate_right(title, 28)

    local zoom   = pane.is_zoomed and '  ' or ''
    local unseen = pane.has_unseen_output and ' ●' or ''

    if tab.is_active then
        -- Active tab: single pill — dim number, yellow icon, bold title
        return {
            { Background = { Color = P.bg_hard } },
            { Foreground = { Color = P.bg1 } },
            { Text = PL_LEFT },
            { Background = { Color = P.bg1 } },
            { Foreground = { Color = P.bg4 } },           -- subtle dim number
            { Text = ' ' .. idx .. ' ' },
            { Foreground = { Color = P.yellow } },         -- icon accent
            { Text = icon },
            { Foreground = { Color = P.fg1 } },
            { Attribute = { Intensity = 'Bold' } },
            { Text = '  ' .. title .. zoom .. unseen .. ' ' },
            { Background = { Color = P.bg_hard } },
            { Foreground = { Color = P.bg1 } },
            { Text = PL_RIGHT },
            'ResetAttributes',
        }
    end

    -- Inactive tab: flat, muted — number barely visible, icon+title dim
    local bg     = hover and P.bg1 or P.bg_hard
    local fg     = hover and P.fg  or P.bg3
    local num_fg = hover and P.bg4 or P.bg2
    return {
        { Background = { Color = bg } },
        { Foreground = { Color = num_fg } },
        { Text = ' ' .. idx .. ' ' },
        { Foreground = { Color = fg } },
        { Text = icon .. '  ' .. title .. unseen .. ' ' },
        'ResetAttributes',
    }
end)

-- ══════════════════════════════════════════════════════════════════════════════
--  EVENTS
-- ══════════════════════════════════════════════════════════════════════════════

-- Maximize window on startup
wezterm.on('gui-startup', function(cmd)
    local _, _, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

-- Toast notification on config reload
wezterm.on('window-config-reloaded', function(window, _)
    window:toast_notification('WezTerm', 'Configuration reloaded', nil, 2000)
end)

-- Augment the command palette with common actions
wezterm.on('augment-command-palette', function(window, pane)
    return {
        {
            brief  = 'Rename tab',
            icon   = 'md_rename_box',
            action = act.PromptInputLine {
                description = 'New tab name',
                action = wezterm.action_callback(function(win, _, line)
                    if line then win:active_tab():set_title(line) end
                end),
            },
        },
        {
            brief  = 'New workspace',
            icon   = 'md_tab_plus',
            action = act.PromptInputLine {
                description = 'New workspace name',
                action = wezterm.action_callback(function(win, p, line)
                    if line then win:perform_action(act.SwitchToWorkspace { name = line }, p) end
                end),
            },
        },
        {
            brief  = 'Toggle opacity',
            icon   = 'md_opacity',
            action = wezterm.action_callback(function(win)
                local overrides = win:get_config_overrides() or {}
                if overrides.window_background_opacity then
                    overrides.window_background_opacity = nil
                else
                    overrides.window_background_opacity = 0.88
                end
                win:set_config_overrides(overrides)
            end),
        },
    }
end)

-- ══════════════════════════════════════════════════════════════════════════════
--  HYPERLINKS / OPEN-URI
--  Ctrl+click on a file:// URI → open in nvim (or cd into directory)
-- ══════════════════════════════════════════════════════════════════════════════

local function is_shell(proc)
    local name = (proc or ''):match '[^/\\]+$' or ''
    for _, s in ipairs { 'bash', 'zsh', 'fish', 'sh', 'ksh', 'dash' } do
        if name == s then return true end
    end
    return false
end

wezterm.on('open-uri', function(window, pane, uri)
    -- http/https: return nothing → WezTerm uses the OS default browser (xdg-open).
    -- No browser is hardcoded here; change your system default instead.
    if uri:find '^https?:' then return end

    local editor = 'nvim'
    if uri:find '^file:' ~= 1 or pane:is_alt_screen_active() then return end

    local url = wezterm.url.parse(uri)
    -- Only handle links to files on this host.
    local host = url.host or ''
    if host ~= '' and host ~= 'localhost' and host ~= wezterm.hostname() then
        return false
    end
    if not url.file_path or url.file_path:find('[%c]') then return false end
    if url.fragment and not url.fragment:match('^%d+$') then return false end

    if is_shell(pane:get_foreground_process_name()) then
        local ok, stdout = wezterm.run_child_process {
            'file', '--brief', '--mime-type', url.file_path,
        }
        if not ok then return end
        if stdout:find 'directory' then
            window:perform_action(act.SpawnCommandInNewTab {
                cwd = url.file_path, domain = 'CurrentPaneDomain',
            }, pane)
            return false
        end
        if stdout:find 'text' then
            local args = { editor, '--', url.file_path }
            if url.fragment then args = { editor, '+' .. url.fragment, '--', url.file_path } end
            window:perform_action(act.SpawnCommandInNewTab {
                args = args, domain = 'CurrentPaneDomain',
            }, pane)
            return false
        end
    else
        -- Leave remote panes and running applications untouched.
        return false
    end
end)

-- ══════════════════════════════════════════════════════════════════════════════
return config
