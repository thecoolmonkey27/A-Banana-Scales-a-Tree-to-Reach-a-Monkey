function love.load()
    love.window.setMode(0, 0, {fullscreentype = 'desktop', fullscreen = 'true'})
    love.graphics.setDefaultFilter('nearest', 'nearest')

    require 'math'

    camera = require 'libraries/camera'
     cam = camera()
     cam:zoomTo(4)

    wf = require 'libraries/windfield'
     world = wf.newWorld()
     world:setGravity(0, 500)
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
     
     force = 300
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

end

function love.mousepressed(x, y, button, istouch, presses)
    mx, my = cam:mousePosition()
    w = mx - banana.x 
    h = my - banana.y
    hyp = math.sqrt(w*w + h*h)
    nw = w / hyp 
    nh = h / hyp
    banana.collider:applyLinearImpulse(nw * force, nh * force)
end

function normalize(x, y)
    return math.tan(y/x)
end

