function love.load()
    love.window.setMode(0, 0, {fullscreentype = 'desktop', fullscreen = 'true'})
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setLineWidth(2.5)

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
     world:setQueryDebugDrawing(true)
     

    banana = {}
     banana.x = 0
     banana.y = 0
     banana.radius = 10
     banana.power = 0
     banana.shot = false
     banana.sprite = love.graphics.newImage('sprites/banana.png')
     o = banana.sprite:getWidth() / 2
     p = banana.sprite:getHeight() / 2
     
     banana.collider = world:newPolygonCollider({0-o, 9-p, 26-o, 0-p, 26-o, 12-p, 19-o, 21-p, 6-o, 21-p, 0-o, 15-p})
     banana.collider:setRestitution(.3)
     banana.collider:setFriction(3)
     
     banana.collider:setCollisionClass('banana')
     banana.collider:setAngle(math.pi / 2)
     
     
     force = 0
     angle = 0
     held = false
     b = 0
     c = 0
    

    sti = require 'libraries/Simple-Tiled-Implementation-master/sti'
     gameMap = sti('maps/untitled.lua')

     if gameMap.layers['static'] then
        for i, obj in pairs(gameMap.layers['static'].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static')
            wall:setCollisionClass('static')
        end
    end

    banana.collider:applyLinearImpulse(0, -100)
    
end

function love.update(dt)
    banana.x, banana.y = banana.collider:getPosition()
    force = force + dt
    banana.rotation = banana.collider:getAngle()
    --cam:lookAt(banana.x, banana.y)
    cam:lockPosition(banana.x, banana.y, cam.smooth.damped(2))
    world:update(dt)
    banana.x, banana.y = banana.collider:getPosition()
end

function love.draw()
    cam:attach()
        love.graphics.draw(banana.sprite, banana.x , banana.y , banana.rotation, 1, 1, banana.sprite:getWidth() / 2, banana.sprite:getHeight() / 2)
        love.graphics.setLineWidth(.5)
        world:draw()
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

    love.graphics.print(tostring(force))
end

function love.mousepressed(x, y, button, istouch, presses)
    force = 0
    held = true
end

function love.mousereleased(x, y, button, istouch, presses)
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
