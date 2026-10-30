-- BlackHoleMax welcome header: approved A/C glyphs with a deep-purple to cyan gradient.
local M = {}

M.art = {
  -- A. Small, one block of four rows (50 columns)
  wide = [==[
 ___ _         _   _  _     _     __  __
| _ ) |__ _ __| |_| || |___| |___|  \/  |__ ___ __
| _ \ / _` / _| / / __ / _ \ / -_) |\/| / _` \ \ /
|___/_\__,_\__|_\_\_||_\___/_\___|_|  |_\__,_/_\_\]==],

  -- C. Stacked, BlackHole above Max (34 columns, eight rows plus a blank line)
  narrow = [==[
 ___ _         _   _  _     _
| _ ) |__ _ __| |_| || |___| |___
| _ \ / _` / _| / / __ / _ \ / -_)
|___/_\__,_\__|_\_\_||_\___/_\___|

 __  __
|  \/  |__ ___ __
| |\/| / _` \ \ /
|_|  |_\__,_/_\_\]==],
}

-- Deep purple -> violet -> cyan.
local STOPS = {
  { 0.00, { 76, 29, 149 } },
  { 0.50, { 124, 58, 237 } },
  { 1.00, { 34, 211, 238 } },
}
local STEPS = 32
local CHUNK = 2
local WIDE_AT = 52
local GROUP = "BlackHoleMax"

local function color_at(t)
  local from, to = STOPS[1], STOPS[#STOPS]
  for i = 1, #STOPS - 1 do
    if t <= STOPS[i + 1][1] then
      from, to = STOPS[i], STOPS[i + 1]
      break
    end
  end
  local span = to[1] - from[1]
  local k = span == 0 and 0 or (t - from[1]) / span
  local function ch(a, b) return math.floor(a + (b - a) * k + 0.5) end
  return string.format("#%02x%02x%02x", ch(from[2][1], to[2][1]), ch(from[2][2], to[2][2]), ch(from[2][3], to[2][3]))
end

function M.highlights()
  for i = 0, STEPS - 1 do
    vim.api.nvim_set_hl(0, ("%s%d"):format(GROUP, i), { fg = color_at(i / (STEPS - 1)) })
  end
end

---@param text string
---@return string[]
local function split(text)
  local lines = vim.split(text, "\n", { plain = true })
  if lines[1] == "" then table.remove(lines, 1) end
  if lines[#lines] == "" then table.remove(lines, #lines) end
  return lines
end

---Build the header as dashboard text segments, one highlight group per chunk.
---@param width integer available window width
---@return snacks.dashboard.Text[]
function M.text(width)
  M.highlights()
  local lines = width >= WIDE_AT and split(M.art.wide) or split(M.art.narrow)
  local text_width = 0
  for _, line in ipairs(lines) do text_width = math.max(text_width, #line) end

  local texts = {}
  for y, line in ipairs(lines) do
    local padded = line .. (" "):rep(text_width - #line)
    for x = 1, text_width, CHUNK do
      local chunk = padded:sub(x, x + CHUNK - 1)
      local pos = (x - 1 + #chunk / 2) / text_width
      texts[#texts + 1] = { chunk, hl = ("%s%d"):format(GROUP, math.min(STEPS - 1, math.floor(pos * (STEPS - 1)))) }
    end
    if y < #lines then texts[#texts + 1] = { "\n" } end
  end
  return texts
end

return M
