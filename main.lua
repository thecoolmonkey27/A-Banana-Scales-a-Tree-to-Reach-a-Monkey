function love.load()
    -- Vector art
    clickme = love.graphics.newImage('sprites/button.png')
    open = love.graphics.newImage('sprites/open.png')
    closed = love.graphics.newImage('sprites/closed.png')
    shadow = love.graphics.newImage('sprites/shadow.png')
    quit = love.graphics.newImage('sprites/quit.png')
    close = love.graphics.newImage('sprites/close.png')

    -- Window
    love.window.setMode(0, 0, {fullscreentype = 'desktop', fullscreen = 'true'})
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setLineWidth(2.5)
    love.graphics.setBackgroundColor(1/157, 1/205, 1/216)
    font = love.graphics.newFont('Lambda-Regular.ttf', 30)
    love.graphics.setFont(font)
    gamestate = 1
    difficulty = 1
    chance = 20
    monkey = love.graphics.newImage('sprites/monkey.png')
    doMusic = true 
    debug = false
    resetTimer = 0
    resetHeld = false
    timer = 0
    doFullscreen = true

    require 'math'
    require 'libraries/simple-slider'

    -- Camera Setup
    camera = require 'libraries/camera'
     cam = camera()
     cam:zoomTo(4)

    -- Physics Setup
    wf = require 'libraries/windfield'
     world = wf.newWorld()
     world:setGravity(0, 500)
     world:addCollisionClass('static')
     world:addCollisionClass('banana')
     world:addCollisionClass('point', {ignores = {'static', 'banana'}})
     
    -- Banana Setup
    banana = {}
     banana.spawnX = -150
     banana.spawnY = -77
     banana.x = 0
     banana.y = 0
     banana.radius = 10
     banana.power = 0
     banana.shot = false
     banana.sprite = love.graphics.newImage('sprites/banana.png')
     banana.shadow = love.graphics.newImage('sprites/bananaShadow.png')
     o = banana.sprite:getWidth() / 2
     p = banana.sprite:getHeight() / 2
     banana.best = 0
     bananas = {}
     monkeys =  {}
     banana.collider = world:newPolygonCollider({0-o, 9-p, 26-o, 0-p, 26-o, 12-p, 19-o, 21-p, 6-o, 21-p, 0-o, 15-p})
     banana.collider:setRestitution(.3)
     banana.collider:setFriction(3)
     banana.collider:setCollisionClass('banana')
     banana.spritesheet = love.graphics.newImage('sprites/tutorial.png')

    -- Tutorial Setup
    anim8 = require 'libraries/anim8'
    banana.grid = anim8.newGrid(51, 55, banana.spritesheet:getWidth(), banana.spritesheet:getHeight())
    banana.animations = {}
    banana.animations.tutorial = anim8.newAnimation(banana.grid('1-10', 1), .2)
    
    -- Variables Setup
     force = 0
     angle = 0
     held = false
     b = 0
     c = 0

    -- Tiled Setup
    sti = require 'libraries/Simple-Tiled-Implementation-master/sti'
     gameMap = sti('maps/map.lua')
     

     if gameMap.layers['static'] then
        for i, obj in pairs(gameMap.layers['static'].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static')
            wall:setCollisionClass('static')
        end
    end

    cam:lookAt(banana.collider:getX(), banana.collider:getY())

    --sounds
    forest = love.audio.newSource('sounds/forest.mp3', 'stream')
    forest:setVolume(.6)

    music = love.audio.newSource('sounds/music.mp3', 'stream')
    whoosh = love.audio.newSource('sounds/whoosh.mp3', 'static')

    volumeSlider = newSlider(
        love.graphics.getWidth()/2, 
        love.graphics.getHeight()/2 - 115,
        250,
        .5,
        0,
        1,
        function(v) music:setVolume(v) end,
        {knob = 'circle', track = 'line'}
    )
    sfxSlider = newSlider(
        love.graphics.getWidth()/2, 
        love.graphics.getHeight()/2,
        250,
        .5,
        0,
        1,
        function(v) 
            forest:setVolume(v)
            whoosh:setVolume(v)
        end,
        {knob = 'circle', track = 'line'}
    )

    banana.collider:setPosition(banana.spawnX, banana.spawnY)
end

function love.update(dt)
    if not music:isPlaying() then
        music:play()
    end
    if gamestate == 2 then
        banana.animations.tutorial:update(dt)
        timer = timer + dt
        if not forest:isPlaying() then
            forest:play()
        end
        
        cx, cy = cam:position()
        mx, my = cam:mousePosition()
        banana.x, banana.y = banana.collider:getPosition()
        banana.x = math.floor(banana.x)
        banana.y = math.floor(banana.y)
        if held == true then
            force = force + dt
        end
        if resetHeld == true then
            resetTimer = resetTimer + dt
            if resetTimer > 1 then
                banana.collider:setPosition(banana.spawnX, banana.spawnY)
                resetHeld = false
                resetTimer = 0
                timer = 0
            end 
        else
            resetTimer = 0
        end
            
        banana.rotation = banana.collider:getAngle()
        --cam:lookAt(banana.x, banana.y)
        if math.sqrt((cx - banana.x)^2  + (cy - banana.y)^2) > 75 or math.sqrt((cx - banana.x)^2  + (cy - banana.y)^2) < -75 then
            cam:lockPosition(math.floor(banana.x), math.floor(banana.y), cam.smooth.damped(2))
        end
        world:update(dt)
        banana.x, banana.y = banana.collider:getPosition()
        cx, cy = cam:position()
        if -banana.y > banana.best then
            banana.best = -banana.y
        end
    end
    if gamestate == 3 then 
        volumeSlider:update()
        sfxSlider:update()
    end
   
end

function love.draw()
    -- Game Window
    if gamestate >= 2 then
        love.graphics.setColor(1/157, 1/205, 1/216)
        love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)

        cam:attach()
        gameMap:drawTileLayer(gameMap.layers['sky'])
        love.graphics.push()
        love.graphics.setColor(1, 1, 1, .7)
        love.graphics.scale(.5, .5)
        love.graphics.translate(math.floor(cx / 4), math.floor(cy / 4))
        gameMap:drawTileLayer(gameMap.layers['background'])
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.pop()
        gameMap:drawTileLayer(gameMap.layers['cave'])
        gameMap:drawTileLayer(gameMap.layers['vine'])
        gameMap:drawTileLayer(gameMap.layers['Tile Layer 1'])

        love.graphics.setColor(1, 1, 1, .7)
        banana.animations.tutorial:draw(banana.spritesheet, -95, -17 - 55)
        love.graphics.setColor(1, 1, 1, 1)
        
        love.graphics.draw(banana.sprite, banana.x , banana.y , banana.rotation, 1, 1, banana.sprite:getWidth() / 2, banana.sprite:getHeight() / 2)
        love.graphics.setLineWidth(.5)
        if debug == true then 
            world:draw()
        end
        cam:lookAt(math.floor(cx + .5), math.floor(cy + .5))
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
            love.graphics.setLineWidth(4 - force*4)
            love.graphics.line(banana.x, banana.y - 15, banana.x + nw * force * 15, banana.y - 15 + nh * force * 15)
        end
        cam:detach()

        love.graphics.print(tostring(math.floor(-banana.y/10))..'  |  '..tostring(math.floor(banana.best/10)), 50, 50)
        love.graphics.print(tostring(math.floor(timer/60))..' : '..tostring(math.floor(timer-math.floor(timer/60)*60)), 50, 75)
        if debug == true then 
            love.graphics.print('FPS: '..tostring(love.timer.getFPS()), love.graphics.getWidth() - 150, 50)
            love.graphics.print('Force: '..tostring(math.floor(force*100)), love.graphics.getWidth() - 150, 75)
            love.graphics.print('Difficulty: '..tostring(difficulty), love.graphics.getWidth() - 150, 100)
            love.graphics.print(tostring(resetHeld), love.graphics.getWidth() - 150, 125)
            love.graphics.print(tostring(doMusic), love.graphics.getWidth() - 150, 150)
        end
    end

    -- Main Menu
    if gamestate == 1 then
        love.graphics.push()
        love.graphics.setColor(170/255, 68/255, 0, 1)
        love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1 ,1)
        love.graphics.pop()

        if math.random(1,math.floor(chance)) == 1 then
            spawnBanana()
            chance = chance - .01
            if chance <1 then
                chance = 1
            end
        end
        love.graphics.setColor(1, 1, 1, .4)
        for k,v in ipairs(bananas) do
            love.graphics.draw(banana.shadow, bananas[k].x + 40, bananas[k].y + 40, bananas[k].r, 5, 5, banana.sprite:getWidth()/2, banana.sprite:getHeight()/2)
            bananas[k].y = bananas[k].y + 500*love.timer.getDelta()
            bananas[k].r = bananas[k].r + bananas[k].d*3*love.timer.getDelta()
        end
        love.graphics.setColor(1, 1, 1, 1)
        for k,v in ipairs(bananas) do
            love.graphics.draw(banana.sprite, bananas[k].x, bananas[k].y, bananas[k].r, 5, 5, banana.sprite:getWidth()/2, banana.sprite:getHeight()/2)
            bananas[k].y = bananas[k].y + 500*love.timer.getDelta()
            bananas[k].r = bananas[k].r + bananas[k].d*3*love.timer.getDelta()
        end
        for k,v in ipairs(monkeys) do
            love.graphics.draw(monkey, monkeys[k].x, monkeys[k].y, monkeys[k].r, .5, .5, monkey:getWidth()/2, monkey:getHeight()/2)
            monkeys[k].y = monkeys[k].y + 2000*love.timer.getDelta()
            monkeys[k].r = monkeys[k].r + 9*love.timer.getDelta()
        end
        love.graphics.draw(clickme, love.graphics.getWidth()/2 - clickme:getWidth()/6, love.graphics.getHeight()/2-clickme:getHeight()/6-55, 0, .3)
        love.graphics.print('Normal', love.graphics.getWidth()/2 - 50, love.graphics.getHeight()/2 - 80)
        love.graphics.draw(clickme, love.graphics.getWidth()/2 - clickme:getWidth()/6, love.graphics.getHeight()/2-clickme:getHeight()/6+55, 0, .3)
        love.graphics.print('Assist', love.graphics.getWidth()/2 - 48, love.graphics.getHeight()/2 + 30)

        love.graphics.draw(close, 30, 30, 0, .1, .1)
    end

    -- Pause Menu
    if gamestate == 3 then
        love.graphics.setColor(1, 1, 1, .7)
        love.graphics.draw(shadow, love.graphics.getWidth()/2, love.graphics.getHeight()/2, 0, 1, 1, shadow:getWidth()/2, shadow:getHeight()/2)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print('Paused', love.graphics.getWidth()/2 - 40, love.graphics.getHeight()/2 - 400)

        love.graphics.print('Music', love.graphics.getWidth()/2 - 35, love.graphics.getHeight()/2 - 195)
        volumeSlider:draw()

        love.graphics.print('SFX', love.graphics.getWidth()/2 - 35, love.graphics.getHeight()/2 - 80)
        sfxSlider:draw()

        love.graphics.print('Fullscreen', love.graphics.getWidth()/2 - 90, love.graphics.getHeight()/2 + 75)
        if doFullscreen then
            love.graphics.draw(closed, love.graphics.getWidth()/2 + 50, love.graphics.getHeight()/2 + 70, 0, 1, 1)
        else
            love.graphics.draw(open, love.graphics.getWidth()/2 + 50, love.graphics.getHeight()/2 + 70, 0, 1, 1)
        end

        love.graphics.draw(quit, love.graphics.getWidth()/2 - quit:getWidth()/4, love.graphics.getHeight()/2 + 300, 0, 1/2, 1/2)
        love.graphics.print('Menu', love.graphics.getWidth()/2 - 30, love.graphics.getHeight()/2 + 315)

        love.graphics.draw(quit, love.graphics.getWidth()/2 - quit:getWidth()/4, love.graphics.getHeight()/2 + 400, 0, 1/2, 1/2)
        love.graphics.print('Reset', love.graphics.getWidth()/2 - 35, love.graphics.getHeight()/2 + 415)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if gamestate == 2 then
        if button == 1 then
            force = 0
            held = true
        end
    end
    if gamestate == 1 then
        if x > love.graphics.getWidth()/2 - clickme:getWidth()/6 and x < love.graphics.getWidth()/2 - clickme:getWidth()/6 + clickme:getWidth()/3 then 
            if y > love.graphics.getHeight()/2-clickme:getHeight()/6-55 and y < love.graphics.getHeight()/2-clickme:getHeight()/6-55 + clickme:getHeight()/3 then
                difficulty = 1
                gamestate = 2
                timer = 0
            end 
        end
        if x > love.graphics.getWidth()/2 - clickme:getWidth()/6 and x < love.graphics.getWidth()/2 - clickme:getWidth()/6 + clickme:getWidth()/3 then 
            if y > love.graphics.getHeight()/2-clickme:getHeight()/6+55 and y < love.graphics.getHeight()/2-clickme:getHeight()/6+55 + clickme:getHeight()/3 then
                difficulty = 2
                gamestate = 2
                timer = 0
            end 
        end
        if checkButtonPress(30, 30, x, y, close:getWidth()/10, close:getHeight()/10) then 
            love.event.quit()
        end
    end
    if gamestate == 3 then
        if checkButtonPress(love.graphics.getWidth()/2 + 50, love.graphics.getHeight()/2 + 70, x, y, open:getWidth(), open:getHeight()) then
            if doFullscreen then
                doFullscreen = false
                love.window.setMode(0, 0, {fullscreen = false, resizable = true, borderless = false})
            else 
                doFullscreen = true
                love.window.setMode(0, 0, {fullscreentype = 'desktop', fullscreen = true})
            end
        end
        if checkButtonPress(love.graphics.getWidth()/2 - quit:getWidth()/4, love.graphics.getHeight()/2 + 300, x, y, quit:getWidth()/2, quit:getHeight()/2) then
            gamestate = 1
        end
        if checkButtonPress(love.graphics.getWidth()/2 - quit:getWidth()/4, love.graphics.getHeight()/2 + 400, x, y, quit:getWidth()/2, quit:getHeight()/2) then
            timer = 0
            banana.held = false
            banana.collider:setLinearVelocity(0, 0)
            banana.collider:setPosition(banana.spawnX, banana.spawnY)
            banana.collider:setLinearVelocity(0, 0)
            banana.collider:setAngle(0)
            reset = true
        end
    end 
end
function love.mousereleased(x, y, button, istouch, presses)
    if gamestate == 2 then
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
                whoosh:play()
            banana.collider:applyLinearImpulse(nw * force * 400, nh * force * 400)
            held = false
            end
        end
    end
    if reset == true then
        gamestate = 2
    end
end

function love.keypressed(key, scancode, isrepeat)
    if gamestate == 2 then
        if key == 'f3' then 
            if debug == false then
                debug = true
            else
                debug = false 
            end
        end
    end
    if key == 'escape' then
        if gamestate > 1 and gamestate ~= 3 then
            gamestate = 3
            held = false
        elseif gamestate == 3 then
            gamestate = 2
        end
    end
end

function spawnBanana()
    b = {}
    m = {}
    bananas[#bananas+1] = b 
    bananas[#bananas].x = math.random(-20, love.graphics.getWidth() + 20)
    bananas[#bananas].y = -50
    bananas[#bananas].r = math.random(1, 10)
    if math.random(1, 3) == 1 then
        bananas[#bananas].d = -1
    else
        bananas[#bananas].d = 1
    end
    if math.random(1, 2000) == 1 then
        monkeys[#monkeys+1] = m
        monkeys[#monkeys].x = math.random(-20, love.graphics.getWidth() + 20)
        monkeys[#monkeys].y = - 50
        monkeys[#monkeys].r = math.random(1, 10)
    end
end

function newButton(x, y, boolean)
    
end

function checkButtonPress(buttonX, buttonY, mouseX, mouseY, w, h)
    if mouseX > buttonX and mouseX < buttonX + w then
        if mouseY > buttonY and mouseY < buttonY + h then
            return true 
        end 
    end 
end