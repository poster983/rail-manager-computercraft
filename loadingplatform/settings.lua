local settings = {}
settings.computerType = "loading_platform" --Do Not Change

settings.priority = 1 --lower numbers get higher priority. also used as an id.  Must not collide with any other platform

settings.platformName = "9 3/4"
settings.printerSide = "top"
settings.cableSide = "back"
settings.modemSide = "left"
settings.modemChannel = 1 

settings.stationID = "base" -- should match the networkid in ticketmaster
settings.yardID = "417db330-bc6f-4457-8a59-9baa61e96480" --should match the yardid this station is connected to 

local 
settings.redstone = {
    --input
    playerPresent=colors.orange --present if true
    trainPresent=colors.black -- in if true

    --output
    sendTrain=colors.blue -- output pulse  

}
return settings