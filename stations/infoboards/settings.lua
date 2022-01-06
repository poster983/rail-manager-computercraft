local settings = {}
settings.computerType = "infoboard" --Do Not Change

--Station Settings (Change for Each Station) 
--Sould match the route names for every other station
settings.stationID = "Base" --should match the routes on other configs
settings.networkID = "417db330-bc6f-4457-8a59-9baa61e96480" --should match the yard this is connected to 

--Will print all the debug messages
settings.verbose = false 

settings.screenScale = 0.9
settings.screenSide = "top"
settings.modemSide = "right"
settings.modemChannel = 1 --THere should be one yard per channell


settings.bgColor = colors.black


return settings;