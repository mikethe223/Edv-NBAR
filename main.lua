-- polyfills because lua is missing a lot of features for a programming language

function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

function inRect(x,y,bx,by,bw,bh)
    return x>=bx and x<bx+bw and y>=by and y<by+bh
end

function table.shallow_copy(t)
    local t2 = {}
    for k,v in pairs(t) do
        t2[k] = v
    end
    return t2
end

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- Source - https://stackoverflow.com/a
-- Posted by hookenz, modified by community. See post 'Timeline' for change history
-- Retrieved 2025-11-13, License - CC BY-SA 4.0

function dump(o)
    if type(o) == 'table' then
    local s = '{ '
    for k,v in pairs(o) do
        if type(k) ~= 'number' then
            k = '"'..k..'"'
        end
        s = s .. '['..k..'] = ' .. dump(v) .. ',\n'
    end
    return s .. '} '
    else
        return tostring(o)
    end
end


vernum = "v0.2.4"
font = love.graphics.setNewFont("ShareTechMono-Regular.ttf")
tile = love.graphics.newImage("tile.png")
tilenear = love.graphics.newImage("tile-near.png")

local nodemgr = require("nodes")
local hud = require("hud")
hud.nodemgr = nodemgr
hud.handleNodeModules({"nodedb"})

love.window.setMode(800, 600, {resizable = true, minwidth = 480, minheight = 360})
love.window.setTitle("NBAR - Node-Based Analog Renderer")

local hoverPadding=8
function renderHover(hover,mx,my)
    local txtWidth, wrappedText = font:getWrap(hover,200)
    love.graphics.setColor(0.992156863,0.823529412,0.0509803922)
    love.graphics.rectangle("fill",mx,my,txtWidth+hoverPadding*2,font:getHeight(hover)*(#wrappedText)+hoverPadding*2,5,5,5)
    love.graphics.setColor(0,0,0)
    love.graphics.print(table.concat(wrappedText,"\n"),mx+hoverPadding,my+hoverPadding)
end

mouseDownBef = false
dragStartX=0
dragStartY=0
draggingNode=nil
nodeToDrag=nil
draggingConnector=nil
connectorToDrag=nil

function handleDrag()
    local mx,my = love.mouse.getPosition()
    width, height = love.graphics.getDimensions()
    if hud.touching(mx,my,width,height) then
        return nil
    end
    if not mouseDownBef then -- started dragging
        local hoveringConnector,hoveredConnectorIDX,isOutputConnector,connectorNode = nodemgr.findHoveredNodebit(mx, my)
        if hoveringConnector~=nil then
            -- dragging connector
            draggingConnector=true
            connectorToDrag={hoveringConnector,hoveredConnectorIDX,isOutputConnector,connectorNode}
        else
            draggingConnector=false
            local hoveringNode = nodemgr.hoveringNode()
            if hoveringNode~=nil then
                -- dragging node
                draggingNode=true
                dragStartX=mx-hoveringNode.x
                dragStartY=my-hoveringNode.y
                nodeToDrag=hoveringNode
            else
                -- dragging canvas
                draggingNode=false
                dragStartX=mx-nodemgr.offsetX
                dragStartY=my-nodemgr.offsetY
            end
        end
    else -- currently dragging
        if draggingConnector then
            local hoveringConnector,hoveredConnectorIDX,isOutputConnector,connectorNode = unpack(connectorToDrag)
            -- print(hoveringConnector,hoveredConnectorIDX,isOutputConnector,connectorNode)
            local cx, cy = nodemgr.getConnectorCenterPosition(connectorNode,hoveredConnectorIDX,isOutputConnector)
            love.graphics.line(cx, cy, mx, my)
        else
            if(draggingNode) then
                nodeToDrag.x=mx-dragStartX
                nodeToDrag.y=my-dragStartY
            else
                nodemgr.offsetX=mx-dragStartX
                nodemgr.offsetY=my-dragStartY
            end
        end
    end
end

function handleConnectorSet(startConnector,startConnectorIDX,isStartOutput,startNode,endConnector,endConnectorIDX,isEndOutput,endNode)
    table.insert(nodemgr.nodeConnections,
        {["output"]={startConnector,startConnectorIDX,isStartOutput,startNode},
        ["input"]={endConnector,endConnectorIDX,isEndOutput,endNode}}
    )
end

function testConnectorSet(startConnector,startConnectorIDX,isStartOutput,startNode,endConnector,endConnectorIDX,isEndOutput,endNode)
    return {["output"]={startConnector,startConnectorIDX,isStartOutput,startNode},["input"]={endConnector,endConnectorIDX,isEndOutput,endNode}}
end

function handleDragEnd()
    local mx,my = love.mouse.getPosition()
    if draggingConnector then
        local startConnector,startConnectorIDX,isStartOutput,startNode = unpack(connectorToDrag)
        local endConnector,endConnectorIDX,isEndOutput,endNode = nodemgr.findHoveredNodebit(mx, my)
        if endConnector==nil then
            return nil
        end
        if isStartOutput==isEndOutput then
            if isStartOutput then
                print("You cannot connect outputs to other outputs.")
            else
                print("You cannot connect inputs to other inputs.")
            end
        else
            if isStartOutput then
                handleConnectorSet(endConnector,endConnectorIDX,isEndOutput,endNode,startConnector,startConnectorIDX,isStartOutput,startNode)
            else
                handleConnectorSet(startConnector,startConnectorIDX,isStartOutput,startNode,endConnector,endConnectorIDX,isEndOutput,endNode)
            end
        end
    end
end

function handleClick()
    local mx,my = love.mouse.getPosition()
    width, height = love.graphics.getDimensions()

    if hud.touching(mx,my,width,height) then
        hud.handleClick(mx,my,width,height)
    end
end

function drawConnectorHover(mx,my)
    local hoveringConnector,hoveredConnectorIDX,isOutputConnector,connectorNode = nodemgr.findHoveredNodebit(mx, my)
    -- print(hoveringConnector,hoveredConnectorIDX,isOutputConnector,connectorNode)
    if hoveringConnector then
        local bbox = nodemgr.makeIOBbox(connectorNode,connectorNode:getBboxRect(),hoveredConnectorIDX,isOutputConnector)
        love.graphics.setColor(1,1,1,0.4)
        love.graphics.rectangle("fill",bbox[1],bbox[2],bbox[3],bbox[4],3,3,3)
    end
end

function drawConnectors()
    for i,value in ipairs(nodemgr.nodeConnections) do
        local ox, oy = nodemgr.getConnectorCenterPosition(value.output[4],value.output[2],value.output[3])
        local ix, iy = nodemgr.getConnectorCenterPosition(value.input[4],value.input[2],value.input[3])
        love.graphics.line(ox, oy, ix, iy)
    end
end

function love.draw()
    local mx,my = love.mouse.getPosition()
    width, height = love.graphics.getDimensions()

    love.graphics.clear(0.211764706,0.2,0.223529412)
    love.graphics.clear(0.211764706,0.2,0.223529412)
    for y = -64, height+64, 64 do
        for x = -64, width+64, 64 do
            love.graphics.draw(tile, x+(nodemgr.offsetX/1.6 % 64), y+(nodemgr.offsetY/1.6 % 64))
        end
    end

	for y = -80, height+80, 80 do
        for x = -80, width+80, 80 do
            love.graphics.draw(tilenear, x+(nodemgr.offsetX/1.2 % 80), y+(nodemgr.offsetY/1.2 % 80))
        end
    end

    nodemgr.drawNodes()

    -- connectors
    drawConnectors()

    -- dragging
    local mouseDown = love.mouse.isDown(1)
    if(mouseDown) then
        if(not mouseDownBef) then 
            handleClick()
        end
        handleDrag()
    elseif mouseDownBef then
        handleDragEnd()
    end
    mouseDownBef=mouseDown

    hud.render(width,height)

    -- connector hover
    drawConnectorHover(mx,my)

    -- hover message
    local hoverMsg=nodemgr.getHoverMessage(mx,my)
    if hoverMsg~=nil then
        renderHover("[i] "..hoverMsg,mx,my)
    end

    -- debug
    love.graphics.print(dump(nodemgr.nodeConnections), 5+nodemgr.offsetX, 5+nodemgr.offsetY)
    love.graphics.print(dump(nodeList), 500+nodemgr.offsetX, 5+nodemgr.offsetY)

    -- NBAR text
    love.graphics.setColor(0.9,0.9,0.9,1)
    love.graphics.print('NBAR - Node-Based Analog Renderer '..vernum, 5, height-20)
end

function love.keypressed(key,scancode,isrepeat)
    if key=="space" then
        nodemgr.configureHoveredNode()
    end
    if key=="backspace" or key=="delete" then
        nodemgr.removeHoveredNode()
    end
end
