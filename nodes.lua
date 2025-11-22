local nodemgr = {}

-- Node inputs
nodemgr.ioElem={
["digital"] = {0},
["analog"] = {1,0},
["audioleft"] = {1,1},
["audioright"] = {1,2},
["avideo"] = {1,3},
["dynval"] = {2}
}

-- Node "class"
nodemgr.nodeClass = {
["id"] = "default",
["title"] = "Unknown element",
["shortTitle"] = "[title]",
["about"] = nil,
["inputs"] = {},
["outputs"] = {},
["numberInputs"] = {},
["run"] = function(selfvar,numberInputs,inputStreams,outputStreams)
    print("Node setup for "+selfvar["id"]+" has not added a run function.")
end
}

-- Node connections
nodemgr.nodeConnections = {
}

-- Node I/O rendering
function renderIO(type,x,y)
    --print(type,x,y)
    function circle(r,g,b)
        love.graphics.setColor(r,g,b)
        love.graphics.circle("fill",x,y,6.5)
    end

    if(type==nodemgr.ioElem.digital) then
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("fill",x-4,y-6,8,12,2,2,3)
    elseif(type==nodemgr.ioElem.analog)     then
        love.graphics.setColor(1,0.8,0.4)
        love.graphics.rectangle("fill",x-4,y-6,8,12,2,2,3)
    elseif(type==nodemgr.ioElem.audioleft)  then
        love.graphics.setColor(1,0.4,0.8)
        love.graphics.rectangle("fill",x-4,y-6,8,12,2,2,3)
    elseif(type==nodemgr.ioElem.audioright) then
        love.graphics.setColor(0.4,1,0.8)
        love.graphics.rectangle("fill",x-4,y-6,8,12,2,2,3)
    elseif(type==nodemgr.ioElem.avideo)     then 
        love.graphics.setColor(1,0.4,0.4)
        love.graphics.rectangle("fill",x-4,y-6,8,12,2,2,3)
    end
end

-- Node on-screen "class"
local nodeRenderPadding = 4
local nodeIOElemHeight = 16
nodemgr.screenNodeClass = {
["x"] = 0,
["y"] = 0,
["getWrappedText"] = function(selfvar)
    local txtWidth, wrappedtext = font:getWrap( selfvar.node.title, 140 )
    return txtWidth, table.concat(wrappedtext,"\n"), #wrappedtext
end,
["getBboxRect"] = function(selfvar)
    -- bounding box, returns {x,y,width,height}
    local txtWidth, txt, txtLines = selfvar:getWrappedText()
    -- local txtWidth =font:getWidth(txt)
    local txtHeight=font:getHeight(txt)*txtLines
    -- print(txtWidth, txtHeight)

    local rectWidth = txtWidth;
    local rectHeight = math.max(txtHeight,math.max(#selfvar.node.inputs,#selfvar.node.outputs)*nodeIOElemHeight);

    return {selfvar.x+nodemgr.offsetX,selfvar.y+nodemgr.offsetY,rectWidth+nodeRenderPadding*2,rectHeight+nodeRenderPadding*2}
end,
["getBbox"] = function(selfvar)
    -- bounding box, returns {left,top,right,bottom}
    local rect = selfvar:getBboxRect()
    return {rect[1],rect[2],rect[1]+rect[3],rect[2]+rect[4]}
end,
["isHovered"] = function(selfvar,mx,my)
    local bbox = selfvar:getBbox()
    return mx>=bbox[1] and mx<=bbox[3] and my>=bbox[2] and my<=bbox[4]
end,
["render"] = function(selfvar)
    local wTextWidth, wrappedText, wrappedTextLines = selfvar:getWrappedText()

    local rectBox = selfvar:getBboxRect()

    for i, input in ipairs(selfvar.node.inputs) do
        local ioX = rectBox[1]
        local ioY = rectBox[2]+(i-0.5)*nodeIOElemHeight+nodeRenderPadding
        renderIO(input,ioX,ioY)
    end

    for i, input in ipairs(selfvar.node.outputs) do
        local ioX = rectBox[1]+rectBox[3]
        local ioY = rectBox[2]+(i-0.5)*nodeIOElemHeight+nodeRenderPadding
        renderIO(input,ioX,ioY)
    end

    love.graphics.setColor(0.7,0.7,0.7)
    love.graphics.rectangle("line",rectBox[1],rectBox[2],rectBox[3],rectBox[4],5,5,5)
    love.graphics.setColor(selfvar.node.color)
    love.graphics.rectangle("fill",rectBox[1],rectBox[2],rectBox[3],rectBox[4],5,5,5)

    love.graphics.setColor(1.0,1.0,1.0)
    love.graphics.print(wrappedText,rectBox[1]+nodeRenderPadding,rectBox[2]+nodeRenderPadding)
end
}

-- node list and rendering
nodeList={}
nodemgr.offsetX=0
nodemgr.offsetY=0

function nodemgr.drawNodes()
    for i, scrnode in ipairs(nodeList) do
        scrnode:render()
    end
end

function nodemgr.getHoverMessage(mx,my)
    local hover=nil
    for i, scrnode in ipairs(nodeList) do
        if(scrnode:isHovered(mx,my)) then
            hover=scrnode.node.about
        end
    end
    return hover
end

-- adding a node
function nodemgr.addNodeToScreen(node)
    local scrnode = table.shallow_copy(nodemgr.screenNodeClass)
    scrnode.node=node
    scrnode.x=math.random(10,200)-nodemgr.offsetX
    scrnode.y=math.random(10,200)-nodemgr.offsetY
    table.insert(nodeList,scrnode)
end

-- getting the node that is getting hovered
function nodemgr.hoveringNode()
    local mx,my = love.mouse.getPosition()
    for i, scrnode in ipairs(nodeList) do
        if(scrnode:isHovered(mx,my)) then
            return scrnode
        end
    end
    return nil
end

-- configuring currently hovered node
function nodemgr.configureHoveredNode()
    local hovered = nodemgr.hoveringNode()
    if not hovered then
        print("You're not hovering on a node.")
        return
    end
    
    if hovered.node.configure then
        hovered.node.configure(hovered)
    else
        print("This node does not have a configure function.")
    end
end

-- removing currently hovered node
function nodemgr.removeHoveredNode()
    local hovered = nodemgr.hoveringNode()
    if not hovered then
        print("You're not hovering on a node.")
        return
    end

    idx = indexOf(nodeList,hovered)
    table.remove(nodeList,idx) -- and then another table remove that gets rid of its connections
    -- table.remove(nodeConnections,???)
end

function nodemgr.makeIOBbox(scrnode,nodebbox,idx,isOutput)
    local x=nodebbox[1]+nodebbox[3]*(isOutput and 1 or 0)
    local y=nodebbox[2]+(idx-0.5)*nodeIOElemHeight+nodeRenderPadding
    return {x-nodeIOElemHeight/2,y-nodeIOElemHeight/2,nodeIOElemHeight,nodeIOElemHeight}
end

function nodemgr.getConnectorCenterPosition(scrnode,idx,isOutput)
    local bbox = nodemgr.makeIOBbox(scrnode,scrnode:getBboxRect(),idx,isOutput)
    return bbox[1]+bbox[3]/2,bbox[2]+bbox[4]/2
end

-- get currently hovered node IO
function nodemgr.findHoveredNodebitFromNode(scrnode,mx,my)
    -- nodemgr.hoveringNode() probably won't work in this specific case because node IO doesn't cound as part of the node
    -- returns: nodebit, nodebit index, boolean that is true if nodebit is output
    local nodebbox = scrnode:getBboxRect()

    for i,val in ipairs(scrnode.node.inputs) do
        local bbox = nodemgr.makeIOBbox(scrnode,nodebbox,i,false)
        if inRect(mx,my,bbox[1],bbox[2],bbox[3],bbox[4]) then
            return val,i,false
        end
    end

    for i,val in ipairs(scrnode.node.outputs) do
        local bbox = nodemgr.makeIOBbox(scrnode,nodebbox,i,true)
        if inRect(mx,my,bbox[1],bbox[2],bbox[3],bbox[4]) then
            return val,i,true
        end
    end
    -- todo: get it workin
end

function nodemgr.findHoveredNodebit(mx,my)
    for i, scrnode in ipairs(nodeList) do
        local bbox = scrnode:getBbox()
        if mx>=bbox[1]-nodeIOElemHeight/2 and mx<=bbox[3]+nodeIOElemHeight/2 and my>=bbox[2] and my<=bbox[4] then
            local val,i,out = nodemgr.findHoveredNodebitFromNode(scrnode,mx,my)
            return val,i,out,scrnode
        end
    end
end

return nodemgr
