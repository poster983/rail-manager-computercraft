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
    trainReady=colors.orange, -- on if train is ready to go.  should pulse. may not be used if used in a yard or if autogo is set to false
    trainPresent=colors.black, -- in if true

    --output
    sendTrain=colors.blue, -- output pulse  

}
return settings