junctions = require("./junctions")
-- Station Config
local settings = {}
settings.computerType = "ticketmaster" --Do Not Change

--Station Settings (Change for Each Station) 
--Sould match the route names for every other station
settings.stationID = "Base" --should match the routes on other configs
settings.networkID = "417db330-bc6f-4457-8a59-9baa61e96480" --should match the yard network this is connected to 

settings.screenSide = "top"
settings.modemSide = "right"
settings.cableSide = "back" -- redstone cable
settings.modemChannel = 1 

settings.minTrains = 0 -- the number of trains to always keep in the station.  0 will disable the feature.

-- Route Table (Chnage for each station)
settings.routes = {}
settings.routes["Doofenshmirtz Evil Inc"] = {junctions.villageEntrance, junctions.doofEntrance};
settings.routes["Doof Yard"] = {junctions.doofYardEntrance, hide=true};
settings.routes["Village"] = {junctions.villageEntrance};
settings.routes["Base"] = {junctions.baseEntrance, junctions.yardNorthboundUTurn, junctions.yardSouthboundUTurn}
settings.routes["Main Yard"] = {junctions.yardEntrance, junctions.yardNorthboundUTurn, hide=true};
settings.routes["All (Debug)"] = {junctions.houseEntrance, junctions.houseExitEast, junctions.powerCastleNorth, junctions.powerCastleWest}  
settings.routes["Castle"] = {junctions.yardNorthboundUTurn}
settings.routes["Castle Yard"] = {junctions.yardNorthboundUTurn, hide=true}
settings.routes["Fisherman Village"] = {junctions.yardNorthboundUTurn}
settings.routes["Power Plant"] = {junctions.yardNorthboundUTurn}


settings.buttonColor = colors.blue
settings.buttonClickColor = colors.red

settings.redstone = {
    --input
    lineClear=colors.blue, -- pulse from detector rail. lets the computer know that it is safe to send the next train
    clearPlatform=colors.yellow,  -- will clear a train from the station if full.  used when a train is arriving

    --output
    error=colors.red, -- pulses when an error occurs in the station.  Like a printer is out of paper or ink
    trainLeaving=colors.green, -- pulses when a train is leaving the station
    trainArriving=colors.pink, -- pulses when a train arrives at the station
}

return settings;