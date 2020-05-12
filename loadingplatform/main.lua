--[[
    Loading platform Settings 
    Manages the printing of tickets and informs the ticketmaster or yard computer of train state
]]
local settings = require("./settings");
local printer = peripheral.wrap(station.printerSide);
local station = {} --load from network

--Destination is a string matching the station route
-- Returns true if worked, false if failed
function printTickets(destination)
  --create new page
  local route = station.routes[destination]
  for i,junction in ipairs(route) do
    if not printString(junction) then
      return false
    end
  end
  return true;
end


-- Returns true if worked, false if failed
function printString(string)
  local ready = printer.newPage()
  if ready then
    printer.write(string)
    printer.setPageTitle(string)
    printer.endPage()
  else
    error("Could not create a page. Is there any paper and ink in the printer?")
    return false
  end
  
  print(string)
  return true
end 



function main() 
    --get routes
    local message = {platformName=settings.platformName, priority=settings.priority}
    common.sendMessage("connect", message)

end 

main()
