junctions = require("./junctions")
-- Station Config
local station = {}
station.computerType = "ticketmaster" --Do Not Change

--Station Settings (Change for Each Station) 
--Sould match the route names for every other station
station.stationID = "base" --should match the routes on other configs
station.yardID = "417db330-bc6f-4457-8a59-9baa61e96480" --should match the yard this is connected to 

station.trainCount = 3
station.screenSide = "top"
station.modemSide = "right"
station.modemChannel = 1 --THere should be one yard per channell
-- Route Table (Chnage for each station)

station.routes["Doof"] = {junctions.villageEntrance, junctions.doofEntrance};
station.routes["Village"] = {junctions.villageEntrance};
station.routes["All"] = {junctions.villageEntrance, junctions.doofEntrance, junctions.hubEntrance, junctions.villageWestboundUTurn};

return station;