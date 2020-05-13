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


function listenForMessages() 
  while true do 
    local event, modemSide, senderChannel, 
    replyChannel, message, senderDistance = os.pullEvent("modem_message")

    if message ~= nil and message.yardID == settings.yardID and message.stationID == settings.stationID then -- this is a message for us 
      print("Directive: " .. message.directive .. " FROM: " .. message.computerType)

      if message.computerType == "ticketmaster" then -- Message from ticket master!
        if message.directive == settings.priority..":connect" then 
          station.routes = message.payload -- save routes
        end -- if (directive)
      end -- if (computer type)

    end -- if
  end -- while
end --listenForMessages


function main() 
    --get routes
    local message = {platformName=settings.platformName, priority=settings.priority}
    common.sendMessage("connect", message)

end --main

parallel.waitForAll(main, listenForMessages)
