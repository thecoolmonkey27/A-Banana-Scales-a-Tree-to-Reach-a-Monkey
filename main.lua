function love.load()
    love.window.setMode(0, 0, {fullscreentype = 'desktop', fullscreen = 'true'})
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setLineWidth(2.5)
    love.graphics.setBackgroundColor(1/157, 1/205, 1/216)
    font = love.graphics.newFont('Lambda-Regular.ttf', 30)
    love.graphics.setFont(font)

    require 'math'

    camera = require 'libraries/camera'
     cam = camera()
     cam:zoomTo(4)

    wf = require 'libraries/windfield'
     world = wf.newWorld()
     world:setGravity(0, 500)
     world:addCollisionClass('static')
     world:addCollisionClass('banana')
     world:addCollisionClass('point', {ignores = {'static', 'banana'}})
     
    banana = {}
     banana.x = 0
     banana.y = 0
     banana.radius = 10
     banana.power = 0
     banana.shot = false
     banana.sprite = love.graphics.newImage('sprites/banana.png')
     o = banana.sprite:getWidth() / 2
     p = banana.sprite:getHeight() / 2
     banana.best = 0
     
     banana.collider = world:newPolygonCollider({0-o, 9-p, 26-o, 0-p, 26-o, 12-p, 19-o, 21-p, 6-o, 21-p, 0-o, 15-p})
     banana.collider:setRestitution(.3)
     banana.collider:setFriction(3)
     
     banana.collider:setCollisionClass('banana')
     banana.collider:setAngle(math.pi / 2)
     banana.collider:setPosition(-12, -5)
     
     joystick = nil
     force = 0
     angle = 0
     held = false
     b = 0
     c = 0

    sti = require 'libraries/Simple-Tiled-Implementation-master/sti'
     gameMap = sti('maps/map.lua')
     

     if gameMap.layers['static'] then
        for i, obj in pairs(gameMap.layers['static'].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static')
            wall:setCollisionClass('static')
        end
    end

    banana.collider:applyLinearImpulse(0, -100)
    
    cam:lookAt(banana.collider:getX(), banana.collider:getY())
end

function love.update(dt)
    cx, cy = cam:position()
    mx, my = cam:mousePosition()
    banana.x, banana.y = banana.collider:getPosition()
    banana.x = math.floor(banana.x)
    banana.y = math.floor(banana.y)
    force = force + dt
    banana.rotation = banana.collider:getAngle()
    --cam:lookAt(banana.x, banana.y)
    cam:lockPosition(math.floor(banana.x), math.floor(banana.y), cam.smooth.damped(2))
    world:update(dt)
    banana.x, banana.y = banana.collider:getPosition()

    if -banana.y > banana.best then
        banana.best = -banana.y
    end
end

function love.draw()
    love.graphics.setColor(1/157, 1/205, 1/216)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)
    cam:attach()
        gameMap:drawTileLayer(gameMap.layers['sky'])
        love.graphics.push()
        love.graphics.setColor(1, 1, 1, .7)
        love.graphics.scale(.5, .5)
        love.graphics.translate(math.floor(banana.x / 4), math.floor(cy))
        gameMap:drawTileLayer(gameMap.layers['background'])
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.pop()
        gameMap:drawTileLayer(gameMap.layers['cave'])
        gameMap:drawTileLayer(gameMap.layers['vine'])
        gameMap:drawTileLayer(gameMap.layers['Tile Layer 1'])
        love.graphics.draw(banana.sprite, banana.x , banana.y , banana.rotation, 1, 1, banana.sprite:getWidth() / 2, banana.sprite:getHeight() / 2)
        love.graphics.setLineWidth(.5)
        
        if held == true then
            
            mx, my = cam:mousePosition()
            w = mx - banana.x 
            h = my - banana.y
            hyp = math.sqrt(w*w + h*h)
            nw = w / hyp 
            nh = h / hyp
            if force > .8 then
                force = .8
            end
            love.graphics.setLineWidth(2.5)
            love.graphics.line(banana.x, banana.y - 15, banana.x + nw * force * 15, banana.y - 15 + nh * force * 15)
        end
    cam:detach()

    love.graphics.print(tostring(math.floor(-banana.y/10))..'  |  '..tostring(math.floor(banana.best/10)), 50, 50)
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        force = 0
        held = true
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if button == 1 then
        mx, my = cam:mousePosition()
        w = mx - banana.x 
        h = my - banana.y
        hyp = math.sqrt(w*w + h*h)
        nw = w / hyp 
        nh = h / hyp
        if force > .8 then
        force = .8
        end
        if #world:queryRectangleArea(banana.x - 15, banana.y, 30, 15) > 1 then  
        banana.collider:applyLinearImpulse(nw * force * 400, nh * force * 400)
        held = false
        end
    end
end
