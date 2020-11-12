-- REQUIRES https://github.com/Siarko/ButtonApi
-- WGET it from: https://raw.githubusercontent.com/Siarko/ButtonApi/master/button
local settings = require("./settings")
local common = require("./common")
os.loadAPI("button")

local screen = {}

screen.currentPage = 0

screen.buttons = {} 



local monitor = peripheral.wrap( settings.screenSide )
monitor.setTextScale(0.9)
button.setMonitor(monitor)
--get screen size
local w, h = monitor.getSize()

--removes routes that have the hide=true property 
function filterRoutes() 
  local out = {}
  for k, v in pairs(settings.routes) do
    --add to new table if it should not be hidden
    if v["hide"] ~= true then
      out[k] = v
    end
  end
  return out
end

local routes = filterRoutes()
local gRouteKeys = common.getTableKeys(routes);
local numOfRoutes = table.getn(gRouteKeys);


--Pagenation 
local pagenationHeight = 5
local pagenationStartY = h - pagenationHeight
local pagenationButtonWidth = 10

--Pagenation buttons
local nextButton = button.create("Next")
nextButton.onClickReturn({type="command", value="next"})
nextButton.setColor(settings.buttonClickColor)
nextButton.setBlinkColor(settings.buttonColor)
nextButton.setPos(w-pagenationButtonWidth, pagenationStartY+1)
nextButton.setSize(pagenationButtonWidth, pagenationHeight)

local previousButton = button.create("Previous")
previousButton.onClickReturn({type="command", value="previous"})
previousButton.setBlinkColor(settings.buttonColor)
previousButton.setColor(settings.buttonClickColor)
previousButton.setPos(2, pagenationStartY+1)
previousButton.setSize(pagenationButtonWidth, pagenationHeight)

filledBox(1,pagenationStartY,w,h, colors.white)





--build the buttons 
screen.buildButtons = function(page)
  
  if page == nil then 
    page = screen.currentPage
  end -- if

  local conWidth = w
  local conHeight = h-pagenationHeight

  --Clear background
  filledBox(1,1,conWidth,conHeight, colors.black)


  --set pagenation button status
  if (page+1 * settings.maxButtonsPerPage) < numOfRoutes then 
    nextButton.setActive(true)
  else 
    nextButton.setActive(false)
  end

  if (page - 1) >= 0 then 
    previousButton.setActive(true)
  else 
    previousButton.setActive(false)
  end

  -- build page
  local pageRoutes = {}

  local startIndex = (page * settings.maxButtonsPerPage)+1
  local p = 1
  for k, v in pairs(routes) do
    if ((startIndex + settings.maxButtonsPerPage) > p) and ( p >= startIndex) then 
      pageRoutes[k] = v
    end -- if

    p=p+1
  end -- for
  

  local routeKeys = common.getTableKeys(pageRoutes);
  

  local numOfColumns = settings.numOfButtonColumns
  local numOfRows = table.getn(routeKeys)/numOfColumns;
  

  local buttons = {}
  local buttonPadding = 2;
  local buttonWidth = (conWidth/numOfColumns);
  -- find how many rows there will be
  --number of routes (MOD) number of columns
  if numOfRows % numOfColumns ~= 0 then
    numOfRows = math.ceil(numOfRows)
  end

  local buttonHeight = conHeight/numOfRows

  print(buttonWidth, buttonHeight)
  local x=0 --col
  local y=0 --row
  for k, v in pairs(pageRoutes) do
    local bx = buttonPadding --button x 
    local by = buttonPadding --button y
    --find the coords of the button
    --find by 
    by = by + (y*buttonHeight)
    bx = bx + (x*buttonWidth);
    --bx
    if x == numOfColumns-1 then -- last col
      
      x = 0;
      y = y+1;
    else 
      x = x + 1;
    end --if
    
    --add button
    --t:add(k, nil, bx, by, bx+buttonWidth-buttonPadding, by+buttonHeight-buttonPadding, colors.red, colors.lime)
    local but = button.create(k)
    but.setPos(bx,by)
    but.setColor(settings.buttonColor)
    but.setBlinkColor(settings.buttonClickColor)
    but.setSize(buttonWidth-buttonPadding,buttonHeight-buttonPadding)
    but.onClickReturn({type="destination", value=k})
    --add to array
    buttons[#buttons+1] = but;
    print(k .. ": x: ".. bx .. " y: " .. by)
  end --for
  --add pagenation
  buttons[#buttons+1] = nextButton;
  buttons[#buttons+1] = previousButton;
  return buttons;
end --function




screen.build = function()
  local bttn = screen.buildButtons()
  --buildPagenation()
  return bttn
end -- function


screen.page = {}
screen.page.next = function() 
  if (screen.currentPage+1 * settings.maxButtonsPerPage) <= numOfRoutes then 
    screen.currentPage = screen.currentPage +1
  end -- if

  return screen.build()
end -- function 

screen.page.prev = function() 
  if (screen.currentPage - 1) >= 0 then 
    screen.currentPage = screen.currentPage-1
    
  end -- if
  return screen.build()
end -- function 

--Full screen alert with text 
screen.alert = function(text, textColor, bgColor, clearColor, time) 


end -- function alert 

--show current jobs
screen.printJobCount = function(count)
  --clear the text area
    filledBox((w/2)-8, h-1, (w/2)+8, h-1, colors.white)
    monitor.setCursorPos((w/2)-8,h-1)
    monitor.clearLine()
    if count == 1 then -- singular 
        monitor.write(count .. " Train incoming")
    end 
    if count > 1 then --plural 
        monitor.write(count .. " Trains incoming")
    end 
end --printJobCount


function filledBox(startX, startY, endX, endY, color)
  local oldterm = term.redirect( monitor )
  paintutils.drawFilledBox(1,1,conWidth,conHeight, colors.black)
  term.redirect(oldterm)
end --function

return screen;