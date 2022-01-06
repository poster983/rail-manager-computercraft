local settings = {}
settings.computerType = "loading_platform" --Do Not Change

settings.priority = 1 --lower numbers get higher priority. also used as an id.  Must not collide with any other platform

settings.platformName = "9 3/4"

--Will print all the debug messages
settings.verbose = false 

settings.printerSide = "left"
settings.cableSide = "back" -- redstone cable
settings.modemSide = "top"
settings.modemChannel = 1 

settings.stationID = "Base" -- should match the networkid in ticketmaster
settings.networkID = "417db330-bc6f-4457-8a59-9baa61e96480" --should match the yardid this station is connected to 

settings.autogo = false -- will not wait for 'trainReady' to pulse.  will be set to true if connected to a yardmaster

settings.printDelay = 0.3 -- how much time it takes in seconds for a ticket to be transfered from the printer to the cart



settings.redstone = {
    --input
    trainReady=colors.orange, -- on if train is ready to go.  should pulse. may not be used if used in a yard or if autogo is set to false
    trainPresent=colors.black, -- in if true

    --output
    sendTrain=colors.lime, -- output pulse  

}
return settings