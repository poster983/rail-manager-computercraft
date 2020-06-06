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


station.buttonColor = colors.blue
station.buttonClickColor = colors.red

station.redstone = {
    --input
    lineClear=colors.blue, -- pulse from detector rail. lets the computer know that it is safe to send the next train

    --output
    error=colors.red, -- pulses when an error occurs in the station.  Like a printer is out of paper or ink
    trainLeaving=colors.green, -- pulses when a train is leaving the station
    trainArriving=colors.black, -- pulses when a train arrives at the station
}

return station;