function love.load()
    love.window.setMode(0, 0, {fullscreentype = 'desktop', fullscreen = 'true'})
    love.graphics.setDefaultFilter('nearest', 'nearest')

    require 'math'

    camera = require 'libraries/camera'
     cam = camera()
     cam:zoomTo(4)

    wf = require 'libraries/windfield'
     world = wf.newWorld()
     world:setGravity(0, 0)
     world:addCollisionClass('static')
     world:addCollisionClass('banana')
     world:setQueryDebugDrawing(true)
     

    banana = {}
     banana.x = 0
     banana.y = 0
     banana.radius = 10
     banana.held = false
     banana.shot = false
     banana.sprite = love.graphics.newImage('sprites/banana.png')
     banana.collider = world:newPolygonCollider({0, 14, 26, 5, 26, 17, 19, 26, 6, 26, 0, 20})
     banana.collider:setRestitution(.3)
     banana.collider:setLinearDamping(3)
     banana.collider:setFixedRotation(true)
     force = 50
     angle = 0
     b = 0
     c = 0
     
     banana.collider:setCollisionClass('banana')
    
    

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
    mx, my = cam:mousePosition()
    if love.mouse.isDown(1) then
         angle = normalize(mx - banana.x, my - banana.y)
         b = math.sin(angle) * force
         c = math.cos(angle) * force
         if mx < banana.x then
            c = -c
         end
         if my < banana.y then
            b = -b
         end
        banana.collider:applyLinearImpulse(c, b)

        cool = math.sqrt(b*b + c*c)
    end

    banana.rotation = banana.collider:getAngle()
    cam:lookAt(banana.x, banana.y)
    world:update(dt)
    banana.x, banana.y = banana.collider:getPosition()
end

function love.draw()
    cam:attach()
        love.graphics.draw(banana.sprite, banana.x - 1, banana.y - 2, banana.rotation)
        world:draw()
    cam:detach()

    
    love.graphics.print(tostring(math.floor(b + .5)))
    love.graphics.print(tostring(math.floor(c + .5)), 50, 0)
end

function love.mousepressed(x, y, button, istouch, presses)
    
end

function normalize(x, y)
    return math.tan(y/x)
end

