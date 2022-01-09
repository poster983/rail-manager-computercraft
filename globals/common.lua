local settings = require("./settings");
local common = {}

common.getTableKeys = function(tab)
    local keyset = {}
    for k,v in pairs(tab) do
      keyset[#keyset + 1] = k
    end
    return keyset
  end


common.sendMessage = function(directive, payload, to) 
  local message = {}

  message.networkID = settings.networkID
  message.stationID = settings.stationID
  message.computerType = settings.computerType
  message.directive = directive
  message.payload = payload
  message.to = to

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


common.pulse = function(color, eventPassthrough, time)
  if time == nil then 
    time = 0.5
  end
  redstone.setBundledOutput(settings.cableSide, colors.combine(redstone.getBundledOutput(settings.cableSide), color))
  common.wait(time, eventPassthrough)
  redstone.setBundledOutput(settings.cableSide, colors.subtract(redstone.getBundledOutput(settings.cableSide), color))

end --end pulse


common.tprint = function(tbl, indent)
  if tbl == nil then 
    print("NIL TABLE")
    return 
  end
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      common.tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))      
    else
      print(formatting .. v)
    end
  end
end -- tprint



common.debug = function(message)
  if settings.verbose ~= nil and settings.verbose == true then 
    print(message)
  end
end -- debug
  
return common;