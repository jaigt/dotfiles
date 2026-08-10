local colors = require("colors")
local icons = require("icons")
local settings = require("settings")


local WEZTERM = "/Applications/WezTerm.app/Contents/MacOS/wezterm"

local git = sbar.add("item", "git", {
  position = "left",
  icon = {
    string = icons.git,
    font = { family = settings.font, style = "Bold", size = 13.0 },
    color = colors.violet,
    padding_left = 10,
    padding_right = 6,
  },
  label = {
    font = { family = settings.font, style = "SemiBold", size = 12.0 },
    color = colors.fg_dim,
    padding_right = 10,
  },
  drawing = false,
  -- Required: see default.lua.
  updates = "on",
  update_freq = 10,
})

local ROW_ICONS = {
  repo = "repo", upstream = "sync", changes = "diff", ci = "ci", pr = "pr",
}

for _, row in ipairs({ "repo", "upstream", "changes", "ci", "pr" }) do
  sbar.add("item", "git." .. row, {
    position = "popup." .. git.name,
    icon = {
      string = ROW_ICONS[row],
      font = { family = settings.font, style = "Bold", size = 12.0 },
      color = colors.gray,
      padding_left = 14,
      padding_right = 8,
    },
    label = {
      string = "…",
      font = { family = settings.mono, style = "Regular", size = 12.0 },
      color = colors.fg,
      padding_right = 14,
    },
    background = { drawing = false, height = 22 },
  })
end

local current_cwd = nil

local function hide()
  current_cwd = nil
  git:set({ drawing = false, popup = { drawing = false } })
end

local function shquote(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function url_decode(s)
  return (s:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
end

local function pane_cwd(p)
  return url_decode((p.cwd:gsub("^file://[^/]*", "")))
end

-- `cli list` marks one pane per tab active, so list-clients is what names the
-- single focused one. Both fail together while wezterm's mux symlink points at
-- a dead socket, so an empty list-clients is NOT evidence wezterm went away —
-- fall back to the active pane, and if neither answers leave the item alone
-- rather than hide(), which would blink the pill on every tick in the gap.
-- --no-auto-start makes that case fail fast instead of spawning a mux-server.
local CLI = WEZTERM .. " cli --no-auto-start "

local function with_focused_cwd(fn)
  sbar.exec(CLI .. "list-clients --format json", function(clients)
    local focused = type(clients) == "table" and clients[1] and clients[1].focused_pane_id

    sbar.exec(CLI .. "list --format json", function(panes)
      if type(panes) ~= "table" then return end
      local active
      for _, p in ipairs(panes) do
        if p.cwd then
          if p.pane_id == focused then fn(pane_cwd(p)) return end
          if p.is_active and not active then active = p end
        end
      end
      if active then fn(pane_cwd(active)) return end
      hide()
    end)
  end)
end

local function update()
  -- Bundle id, not name: the frontmost process is "wezterm-gui".
  sbar.exec([[sh -c 'lsappinfo info -only bundleid "$(lsappinfo front)" ]]
    .. [[| sed -n "s/.*bundleID=\"\([^\"]*\)\".*/\1/p" | head -1']],
    function(bundle)
      if (bundle or ""):gsub("%s+$", "") ~= "com.github.wez.wezterm" then
        hide()
        return
      end

      with_focused_cwd(function(cwd)
        local q = shquote(cwd)
        -- --no-optional-locks so this never blocks on or writes to a repo the
        -- user is mid-operation in.
        --
        -- No `sh -c` wrapper: sbar.exec is already /bin/sh -c, and double
        -- wrapping re-parses q's quoting — a cwd containing $(...) then runs
        -- as code.
        sbar.exec("cd " .. q .. " 2>/dev/null || exit 0; "
          .. "git --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0; "
          .. "b=$(git --no-optional-locks branch --show-current 2>/dev/null); "
          .. "[ -z \"$b\" ] && b=$(git --no-optional-locks rev-parse --short HEAD 2>/dev/null); "
          .. "echo \"$b\"; "
          .. "git --no-optional-locks status --porcelain 2>/dev/null | wc -l | tr -d \" \"",
          function(out)
            local lines = {}
            for line in (out or ""):gmatch("[^\n]+") do lines[#lines + 1] = line end
            local branch, dirty = lines[1], tonumber(lines[2] or "0") or 0
            if not branch or branch == "" then hide() return end

            current_cwd = cwd
            git:set({
              drawing = true,
              label = { string = dirty > 0 and (branch .. "*") or branch,
                        color = dirty > 0 and colors.yellow or colors.fg_dim },
            })
          end)
      end)
    end)
end

local function fill_popup()
  if not current_cwd then return end
  local q = shquote(current_cwd)
  -- Unwrapped, same reason as update() above.
  sbar.exec("cd " .. q .. " 2>/dev/null || exit 0; "
    .. "basename \"$(git --no-optional-locks rev-parse --show-toplevel 2>/dev/null)\"; "
    .. "git --no-optional-locks rev-list --left-right --count @{upstream}...HEAD 2>/dev/null "
    .. "| awk \"{print \\\"↑\\\"\\$2\\\" ↓\\\"\\$1}\"; "
    .. "echo \"$(git --no-optional-locks diff --cached --numstat 2>/dev/null | wc -l | tr -d \" \") staged\" "
    .. "\"· $(git --no-optional-locks diff --numstat 2>/dev/null | wc -l | tr -d \" \") modified\" "
    .. "\"· $(git --no-optional-locks ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d \" \") new\"",
    function(out)
      local lines = {}
      for line in (out or ""):gmatch("[^\n]+") do lines[#lines + 1] = line end
      sbar.set("git.repo", { label = lines[1] or "—" })
      sbar.set("git.upstream", { label = lines[2] or "no upstream" })
      sbar.set("git.changes", { label = lines[3] or "—" })
    end)

  -- Split from the git block so the local rows fill without waiting on the
  -- network. `gh pr view` exits non-zero with no PR; `gh run list` returns an
  -- empty array — hence the different fallbacks.
  sbar.exec("cd " .. q .. " 2>/dev/null || exit 0; "
    .. "gh repo view --json nameWithOwner >/dev/null 2>&1 "
    .. "|| { echo 'not on GitHub'; echo '—'; exit 0; }; "
    .. [==[gh run list --limit 1 --json status,conclusion,workflowName ]==]
    .. [==[-q '.[0] | if . == null then "no runs" else (.workflowName + " · " + (.conclusion // .status)) end' ]==]
    .. [==[2>/dev/null || echo 'unavailable'; ]==]
    .. [==[gh pr view --json number,state ]==]
    .. [==[-q '"#" + (.number|tostring) + " " + (.state|ascii_downcase)' ]==]
    .. [==[2>/dev/null || echo 'no PR for this branch']==],
    function(out)
      local lines = {}
      for line in (out or ""):gmatch("[^\n]+") do lines[#lines + 1] = line end
      sbar.set("git.ci", { label = lines[1] or "—" })
      sbar.set("git.pr", { label = lines[2] or "—" })
    end)
end

git:subscribe({ "front_app_switched", "routine", "forced" }, update)

git:subscribe("mouse.clicked", function()
  fill_popup()
  git:set({ popup = { drawing = "toggle" } })
end)

git:subscribe("mouse.exited.global", function()
  git:set({ popup = { drawing = false } })
end)

update()

return git
