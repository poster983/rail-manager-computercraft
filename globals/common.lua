local settings = require("./settings");
local common = {}

common.getTableKeys = function(tab)
    local keyset = {}
    for k,v in pairs(tab) do
      keyset[#keyset + 1] = k
    end
    return keyset
  end


common.sendMessage = function(directive, payload) 
  local message = {}

  message.yardID = settings.yardID
  message.stationID = settings.stationID
  message.computerType = settings.computerType
  message.directive = directive
  message.payload = payload

  peripheral.wrap(settings.modemSide).transmit(settings.modemChannel, settings.modemChannel, message)
end --function

--Event passthrough is called if an event is recieved and it is not for this timer Passes an event array to the function
common.wait = function(time, eventPassthrough)
  local timer = os.startTimer(time)
  
  while true do
    local event = {os.pullEvent()}
    
    if (event[1] == "timer" and event[2] == timer) then
      break
    else
      eventPassthrough(event) -- a custom function in which you would deal with received events
    end --if else
  end -- while


end --function 

common.printTable = function(o)
  if type(o) == 'table' then
    local s = '{ '
    for k,v in pairs(o) do
       if type(k) ~= 'number' then k = '"'..k..'"' end
       s = s .. '['..k..'] = ' .. dump(v) .. ','
    end
    return s .. '} '
 else
    return tostring(o)
 end
end

  
return common;