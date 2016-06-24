//
//  GameScene.swift
//  HoppyBunny
//
//  Created by Norma Tu on 6/23/16.
//  Copyright (c) 2016 MakeSchool Summer Academy. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var hero: SKSpriteNode!
    var scrollLayer: SKNode!
    var sinceTouch : CFTimeInterval = 0
    var spawnTimer: CFTimeInterval = 0
    var obstacleLayer: SKNode!
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS */
    let scrollSpeed: CGFloat = 160
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        hero = self.childNodeWithName("//hero") as! SKSpriteNode
        
        /* Set reference to scroll layer node */
        scrollLayer = self.childNodeWithName("scrollLayer")
        
        /* Set reference to obstacle layer node */
        obstacleLayer = self.childNodeWithName("obstacleLayer")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        /* Apply vertical impulse */
        hero.physicsBody?.applyImpulse(CGVectorMake(0, 300))
        
        /* Apply subtle rotation */
        hero.physicsBody?.applyAngularImpulse(1)
        
        /* Reset touch timer */
        sinceTouch = 0
        
        /* Play SFX */
        let flapSFX = SKAction.playSoundFileNamed("sfx_flap", waitForCompletion: false)
        self.runAction(flapSFX)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        /* Grab current velocity */
        let velocityY = hero.physicsBody?.velocity.dy ?? 0
        let velocityX = hero.physicsBody?.velocity.dx ?? 0
        
        /* Check and cap vertical velocity */
        if velocityY > 400 {
            hero.physicsBody?.velocity.dy = 400
        }
        
        // Fixes velocity in X so bunny doesn't roll offscreen. (stays in same xPos)
        if velocityX != 0 {
            hero.physicsBody?.velocity.dx = 0
        }
        
        /* Apply falling rotation */
        if sinceTouch > 0.1 {
            let impulse = -20000 * fixedDelta
            hero.physicsBody?.applyAngularImpulse(CGFloat(impulse))
        }
        
        /* Clamp rotation */
        hero.zRotation.clamp(CGFloat(-20).degreesToRadians(),CGFloat(30).degreesToRadians())
        hero.physicsBody?.angularVelocity.clamp(-2, 2)
        
        /* Update last touch timer */
        sinceTouch+=fixedDelta
        
        /* Process world scrolling */
        scrollWorld()
        
        /* Process obstacles */
        updateObstacles()
        
        //Tracks time: every 1.5 seconds an obstacle is spawned at random yPos
        spawnTimer+=fixedDelta
    }
    
    func scrollWorld() {
        /* Scroll World */
        scrollLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through scroll layer nodes */
        for ground in scrollLayer.children as! [SKSpriteNode] {
            
            /* Get ground node position, convert node position to scene space */
            let groundPosition = scrollLayer.convertPoint(ground.position, toNode: self)
            
            /* Check if ground sprite has left the scene */
            if groundPosition.x <= -ground.size.width / 2 {
                
                /* Reposition ground sprite to the second starting position */
                let newPosition = CGPointMake( (self.size.width / 2) + ground.size.width, groundPosition.y)
                
                /* Convert new node position back to scroll layer space */
                ground.position = self.convertPoint(newPosition, toNode: scrollLayer)
            }
        }
    }
    
    func updateObstacles() {
        /* Update Obstacles */
        
        obstacleLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through obstacle layer nodes */
        for obstacle in obstacleLayer.children as! [SKReferenceNode] {
            
            /* Get obstacle node position, convert node position to scene space */
            let obstaclePosition = obstacleLayer.convertPoint(obstacle.position, toNode: self)
            
            /* Check if obstacle has left the scene */
            if obstaclePosition.x <= 0 {
                
                /* Remove obstacle node from obstacle layer */
                obstacle.removeFromParent()
            }
            
        }
        
        /* Time to add a new obstacle? */
        if spawnTimer >= 1.5 {
            
            /* Create a new obstacle reference object using our obstacle resource */
            let resourcePath = NSBundle.mainBundle().pathForResource("Obstacle", ofType: "sks")
            let newObstacle = SKReferenceNode (URL: NSURL (fileURLWithPath: resourcePath!))
            obstacleLayer.addChild(newObstacle)
            
            /* Generate new obstacle position, start just outside screen and with a random y value */
            let randomPosition = CGPointMake(352, CGFloat.random(min: 234, max: 382))
            
            /* Convert new node position back to obstacle layer space */
            newObstacle.position = self.convertPoint(randomPosition, toNode: obstacleLayer)
            
            // Reset spawn timer
            spawnTimer = 0
        }
        
    }
}