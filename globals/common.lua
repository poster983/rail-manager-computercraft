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

  
return common;