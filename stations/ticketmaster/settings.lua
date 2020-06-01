junctions = require("./junctions")
-- Station Config
local station = {}
station.computerType = "ticketmaster" --Do Not Change

--Station Settings (Change for Each Station) 
--Sould match the route names for every other station
station.stationID = "base" --should match the routes on other configs
station.yardID = "417db330-bc6f-4457-8a59-9baa61e96480" --should match the yard network this is connected to 

station.screenSide = "top"
station.modemSide = "right"
station.cableSide = "back" -- redstone cable
station.modemChannel = 1 
-- Route Table (Chnage for each station)
station.routes = {}
station.routes["Doof"] = {junctions.villageEntrance, junctions.doofEntrance};
station.routes["Village"] = {junctions.villageEntrance};
station.routes["Hub Base"] = {junctions.baseEntrance, junctions.yardNorthboundUTurn, junctions.yardSouthboundUTurn}
station.routes["Yard"] = {junctions.yardEntrance, junctions.yardNorthboundUTurn};
station.routes["All (Debug)"] = {junctions.baseEntrance, junctions.yardNorthboundUTurn, junctions.yardSouthboundUTurn,junctions.villageEntrance,junctions.doofEntrance, junctions.villageWestboundUTurn, junctions.yardEntrance}

station.autogo = false -- will not wait for 'trainReady' to pulse from the loading platform 

station.buttonColor = colors.blue
station.buttonClickColor = colors.red

station.redstone = {
    --input
    lineClear=colors.blue -- pulse from detector rail. lets the computer know that it is safe to send the next train

}

return station;