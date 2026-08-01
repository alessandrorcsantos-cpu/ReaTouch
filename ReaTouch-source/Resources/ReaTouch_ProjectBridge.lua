-- ReaTouch bridge for REAPER. Run this once and leave it running while performing live.
local separator = "\t"
local home = os.getenv("HOME")
local directory = home .. "/Library/Application Support/ReaTouch"
os.execute('mkdir -p "' .. directory .. '"')
local projectsFile = directory .. "/open_projects.tsv"
local commandFile = directory .. "/command.txt"
local lastSnapshot = ""

local function safe(value)
  return (value or ""):gsub("[\t\r\n]", " ")
end

local function projects()
  local rows, index = {}, 0
  while true do
    local project, filename = reaper.EnumProjects(index, "")
    if not project then break end
    local _, name = reaper.GetProjectName(project, "", 512)
    if name == "" then name = filename ~= "" and filename:match("([^/]+)%.rpp$") or "Projeto sem nome" end
    rows[#rows + 1] = safe(tostring(project)) .. separator .. safe(name) .. separator .. safe(filename)
    index = index + 1
  end
  return table.concat(rows, "\n") .. (#rows > 0 and "\n" or "")
end

local function publish()
  local snapshot = projects()
  if snapshot == lastSnapshot then return end
  local file = io.open(projectsFile, "w")
  if file then file:write(snapshot); file:close() end
  lastSnapshot = snapshot
end

local function consumeCommand()
  local file = io.open(commandFile, "r")
  if not file then return end
  local command = file:read("*l")
  file:close()
  os.remove(commandFile)
  local target = command and command:match("^SELECT\t(.+)$")
  if not target then return end
  local index = 0
  while true do
    local project, filename = reaper.EnumProjects(index, "")
    if not project then break end
    if tostring(project) == target then reaper.SelectProjectInstance(project); return end
    index = index + 1
  end
end

local function loop()
  consumeCommand()
  publish()
  reaper.defer(loop)
end

loop()
