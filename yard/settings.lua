junctions = require("./junctions")
-- yard Config
local yard = {}
--Station Settings (Change for Each Station) 
--Sould match the route names for every other station
yard.name = "Hub"
yard.printerSide = "right"
yard.trainCount = 3

-- Route Table (Chnage for each station)
yard.routes = {
  doof={junctions.villageEntrance, junctions.doofEntrance},
  village={junctions.villageEntrance},
  all={junctions.villageEntrance, junctions.doofEntrance, junctions.hubEntrance, junctions.villageWestboundUTurn}
}

return yard;