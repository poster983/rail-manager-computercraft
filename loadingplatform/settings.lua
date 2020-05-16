local settings = {}
settings.computerType = "loading_platform" --Do Not Change

settings.priority = 1 --lower numbers get higher priority. also used as an id.  Must not collide with any other platform

settings.platformName = "9 3/4"
settings.printerSide = "left"
settings.cableSide = "back"
settings.modemSide = "top"
settings.modemChannel = 1 

settings.stationID = "base" -- should match the networkid in ticketmaster
settings.yardID = "417db330-bc6f-4457-8a59-9baa61e96480" --should match the yardid this station is connected to 


settings.redstone = {
    --input
    trainPresent=colors.black, -- in if true

    --output
    sendTrain=colors.orange, -- output pulse  

}
return settings