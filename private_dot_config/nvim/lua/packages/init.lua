local config_dir = vim.fn.stdpath 'config'
local pkg_dir = config_dir .. '/lua/packages'

local paths = vim.fn.globpath(pkg_dir, '*.lua', false, true)
local names = {}
for _, path in ipairs(paths) do
  local name = vim.fn.fnamemodify(path, ':t:r')
  if name ~= 'init' then
    table.insert(names, name)
  end
end

local specs = {}
for _, name in ipairs(names) do
  local ok, spec = pcall(require, 'packages.' .. name)
  if ok and type(spec) == 'table' then
    spec._name = name
    table.insert(specs, spec)
  elseif not ok then
    vim.notify('packages.' .. name .. ': ' .. tostring(spec), vim.log.levels.ERROR)
  end
end

table.sort(specs, function(a, b)
  local pa, pb = a.priority or 0, b.priority or 0
  if pa ~= pb then
    return pa > pb
  end
  return a._name < b._name
end)

local all_plugins = {}
for _, spec in ipairs(specs) do
  for _, plugin in ipairs(spec.plugins or {}) do
    table.insert(all_plugins, plugin)
  end
end

vim.pack.add(all_plugins)

for _, spec in ipairs(specs) do
  if type(spec.setup) == 'function' then
    local ok, err = pcall(spec.setup)
    if not ok then
      vim.notify('packages.' .. spec._name .. ' setup: ' .. tostring(err), vim.log.levels.ERROR)
    end
  end
end

-- vim: ts=2 sts=2 sw=2 et
