-- Config
local loadPreMain = false -- change this if you want to load the pre-main branch on your next autorun

-- Runtime
shared.isLoadingPreMainBranch = loadPreMain

local branch = "main"
if shared.isLoadingPreMainBranch == true then
    branch = "pre-main"
end

local domain = "https://raw.githubusercontent.com/mt7k/shiny-succostash/refs/heads/".. branch.. "/"

set_require_domain(domain)
require("deadline_monster_server_autorun.luau")