//
//  PlayScene.swift
//  PlaygroundTests
//
//  Created by Jackson Wright on 9/5/20.
//  Copyright © 2020 Jackson Wright. All rights reserved.
//

import SpriteKit
import GameplayKit

struct ContactCategories {
    static let Player : UInt32 = 0x1 << 0
    static let Enemy : UInt32 = 0x1 << 1
    static let Platform : UInt32 = 0x1 << 2
    static let Laser : UInt32 = 0x1 << 3
    static let DetectNode : UInt32 = 0x1 << 4
    static let Nothing : UInt32 = 0x1 << 9
    
}

class PlayScene: SKScene, SKPhysicsContactDelegate {

    var laserTimer : Timer?
        
        
    var leftWheel = SKSpriteNode()
    var rightWheel = SKSpriteNode()
    var baseConnector = SKSpriteNode()
    var floor = SKSpriteNode()
        
    var playerLifeBar = SKSpriteNode()
    var coinsLabel = SKLabelNode()
    
    var laserBlasting = false
    var enemyAlive = false
    var enemyLives = 3
    var playerLives = 3
    
    var coinCount = 0
    var coinsCollected = 0
    
    override func didMove(to view: SKView) {
        //Sets up the world for detecting contacts
        physicsWorld.contactDelegate = self
        
        //Adds the Charge Counter
        let chargeSymbol = SKSpriteNode(texture: SKTexture(imageNamed: "Charge"), size: CGSize(width: 40, height: 60))
        chargeSymbol.position = CGPoint(x: 0, y: ((self.frame.height/2) - 80))
        coinsLabel = SKLabelNode(text: String(coinsCollected))
        coinsLabel.fontColor = UIColor(displayP3Red: 0.596, green: 0.596, blue: 0.616, alpha: 1)
        coinsLabel.fontName = "Noteworthy Bold"
        coinsLabel.fontSize = 42.0
        coinsLabel.position = CGPoint(x: 0, y: (chargeSymbol.position.y - 80))
        
        self.addChild(chargeSymbol)
        self.addChild(coinsLabel)
        
        //Creates the pinjoints for the car
        initializeUserCar()
            
        //Makes the border something that makes contact with the player
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.restitution = 0.5
        border.friction = 1
        border.linearDamping = 0.1
        border.angularDamping = 0.1
        self.physicsBody = border
            
        //Start Timer that blasts Laser
        laserTimer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(fireLaser), userInfo: nil, repeats: true)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let position = touch!.location(in: view)
        var objectRotation : CGFloat
        var xPulse : CGFloat
        var yPulse : CGFloat
 
        //print(position?.x)
        //print("base speed", baseConnector.physicsBody?.velocity.dy)
        
        if position.x < self.frame.width/8 {
            leftWheel.physicsBody?.applyTorque(CGFloat(1000))
            rightWheel.physicsBody?.applyTorque(CGFloat(1000))
            if (Int((baseConnector.physicsBody?.velocity.dx)!) == 0) && (Int(baseConnector.position.x) != 0) {
                baseConnector.physicsBody?.applyAngularImpulse(CGFloat(6))
            }
        } else if position.x < self.frame.width/4 {
            leftWheel.physicsBody?.applyTorque(CGFloat(-1000))
            rightWheel.physicsBody?.applyTorque(CGFloat(-1000))
            if (Int((baseConnector.physicsBody?.velocity.dx)!) == 0) && (Int(baseConnector.position.x) != 0) {
                baseConnector.physicsBody?.applyAngularImpulse(CGFloat(-6))
            }
        } else {
            objectRotation = baseConnector.zRotation
            xPulse = (-sin(objectRotation) * 4000)
            yPulse = (cos(objectRotation) * 4000)
            baseConnector.physicsBody?.applyImpulse(CGVector(dx: xPulse, dy: yPulse))
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA.node
        let secondBody = contact.bodyB.node
        
        if (firstBody?.name == "laserBlast" && secondBody?.name == "enemyBody") || (firstBody?.name == "enemyBody" && secondBody?.name == "laserBlast") {
            print("kill enemy")
            //enemyLifeBar.size.width -= self.frame.width/8
        } else if (firstBody?.name == "laserBlast" && secondBody?.name == "base") || (firstBody?.name == "base" && secondBody?.name == "laserBlast") {
            print("kill player")
            //playerLifeBar.size.width -= self.frame.width/8
        } else if (firstBody?.name == "coin" || secondBody?.name == "coin") {
            coinsCollected += 100
            coinsLabel.text = String(coinsCollected)
            coinCount -= 1
            if firstBody?.name == "coin" {
                firstBody?.removeFromParent()
            } else {
                secondBody?.removeFromParent()
            }
        }
    }
    
    func initializeUserCar() {
        leftWheel = self.childNode(withName: "leftWheel") as! SKSpriteNode
        rightWheel = self.childNode(withName: "rightWheel") as! SKSpriteNode
        baseConnector = self.childNode(withName: "base") as! SKSpriteNode
        floor = self.childNode(withName: "floor") as! SKSpriteNode
        //enemyLifeBar = self.childNode(withName: "enemyLifeBar") as! SKSpriteNode
        //playerLifeBar = self.childNode(withName: "playerLifeBar") as! SKSpriteNode
        //coinsLabel = self.childNode(withName: "coinsCollected") as! SKLabelNode
        
        
        let pinJointLeft = SKPhysicsJointPin.joint(withBodyA: baseConnector.physicsBody!, bodyB: leftWheel.physicsBody!, anchor: CGPoint(x: -22, y: -180))
        let pinJointRight = SKPhysicsJointPin.joint(withBodyA: baseConnector.physicsBody!, bodyB: rightWheel.physicsBody!, anchor: CGPoint(x: 22, y: -180))
            
        scene!.physicsWorld.add(pinJointLeft)
        scene!.physicsWorld.add(pinJointRight)
    }
        
    func laserPatternA() {
        let leftLaser = SKEmitterNode(fileNamed: "MyParticle")
        let rightLaser = SKEmitterNode(fileNamed: "MyParticle")
        leftLaser!.position = CGPoint(x: -250, y: 200)
        rightLaser!.position = CGPoint(x: 250, y: 200)
        self.addChild(leftLaser!)
        self.addChild(rightLaser!)
        
        let leftLaserNode = SKSpriteNode(color: UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1), size: CGSize(width: 70, height: 1000))
        let rightLaserNode = SKSpriteNode(color: UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1), size: CGSize(width: 70, height: 1000))
        
        leftLaserNode.name = "laserBlast"
        leftLaserNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 70, height: 1000))
        leftLaserNode.physicsBody?.affectedByGravity = false
        leftLaserNode.physicsBody?.isDynamic = false
        leftLaserNode.physicsBody?.categoryBitMask = ContactCategories.Laser
        leftLaserNode.physicsBody?.collisionBitMask = 0
        leftLaserNode.physicsBody?.contactTestBitMask = 3
        leftLaserNode.position = CGPoint(x: -250, y: 50)
        self.addChild(leftLaserNode)
        
        rightLaserNode.name = "laserBlast"
        rightLaserNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 70, height: 1000))
        rightLaserNode.physicsBody?.affectedByGravity = false
        rightLaserNode.physicsBody?.isDynamic = false
        rightLaserNode.physicsBody?.categoryBitMask = ContactCategories.Laser
        rightLaserNode.physicsBody?.collisionBitMask = 0
        rightLaserNode.physicsBody?.contactTestBitMask = 3
        rightLaserNode.position = CGPoint(x: 250, y: 50)
        self.addChild(rightLaserNode)
        
        leftLaserNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 5.0),
            SKAction.removeFromParent()
        ]))
        
        leftLaser!.run(SKAction.sequence([
            SKAction.wait(forDuration: 5.0),
            SKAction.removeFromParent()
        ]))
        
        rightLaserNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 5.0),
            SKAction.removeFromParent()
        ]))
        
        rightLaser!.run(SKAction.sequence([
            SKAction.wait(forDuration: 5.0),
            SKAction.removeFromParent()
        ]))
    }
        
    func laserPatternB() {
        let laser = SKEmitterNode(fileNamed: "MyParticle")
        laser!.position = CGPoint(x: 0, y: 200)
        self.addChild(laser!)
        let laserNode = SKSpriteNode(color: UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1), size: CGSize(width: 80, height: 1000))
        laserNode.name = "laserBlast"
        laserNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 80, height: 1000))
        laserNode.physicsBody?.affectedByGravity = false
        laserNode.physicsBody?.isDynamic = false
        laserNode.physicsBody?.categoryBitMask = ContactCategories.Laser
        laserNode.physicsBody?.collisionBitMask = 0
        laserNode.physicsBody?.contactTestBitMask = 3
        laserNode.position = CGPoint(x: 0, y: 200)
        self.addChild(laserNode)
        
        laser?.run(SKAction.sequence([
            SKAction.wait(forDuration: 5.0),
            SKAction.removeFromParent()
        ]))
        
        laserNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 5.0),
            SKAction.removeFromParent()
        ]))
    }
        
    @objc func fireLaser() {
        let ranNumber = Int.random(in: 1...3)
        if ranNumber == 1 {
            laserPatternA()
        } else {
            laserPatternB()
        }
        
        if coinCount <= 1 {
            createCoins()
        }
    }
    
    func middleCoins() {
        for i in 1...2 {
            let coin = SKSpriteNode(texture: SKTexture(imageNamed: "chargeCoin"), size: CGSize(width: 40, height: 40))
            coin.color = UIColor(red: 0, green: 102, blue: 255, alpha: 1)
            coin.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(15))
            coin.physicsBody?.affectedByGravity = false
            coin.physicsBody?.isDynamic = false
            coin.physicsBody?.categoryBitMask = ContactCategories.Laser
            coin.physicsBody?.collisionBitMask = 0
            coin.physicsBody?.contactTestBitMask = 1
            coin.name = "coin"
            if i == 1 {
                coin.position = CGPoint(x: 0, y: 400)
            } else {
                coin.position = CGPoint(x: 0, y: 100)
            }
            self.addChild(coin)
        }
        coinCount += 2
    }
    
    func sideCoins() {
        for i in 1...2 {
            let coin = SKSpriteNode(texture: SKTexture(imageNamed: "chargeCoin"), size: CGSize(width: 40, height: 40))
            coin.color = UIColor(red: 0, green: 102, blue: 255, alpha: 1)
            coin.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(15))
            coin.physicsBody?.affectedByGravity = false
            coin.physicsBody?.isDynamic = false
            coin.physicsBody?.categoryBitMask = ContactCategories.Laser
            coin.physicsBody?.collisionBitMask = 0
            coin.physicsBody?.contactTestBitMask = 1
            coin.name = "coin"
            if i == 1 {
                coin.position = CGPoint(x: -320, y: 325)
            } else {
                coin.position = CGPoint(x: 320, y: 325)
            }
            self.addChild(coin)
        }
        coinCount += 2
        
    }
    
    func createCoins() {
        if coinCount == 1 {
            if Int(self.childNode(withName: "coin")!.position.x) == 0 {
                sideCoins()
            } else {
                middleCoins()
            }
        } else {
            middleCoins()
            sideCoins()
        }
    }
        
    //Funtion that creates the wheels and the base of the car then joins them together at a pin joint
    //Joints have to be added to the physics world
    //Also makes the car drive automatically when it is spawned
    func createCar() {
        enemyAlive = true
        let eLeftWheel = SKSpriteNode(texture: SKTexture(imageNamed: "enemyWheel"), size: CGSize(width: 50, height: 50))
        eLeftWheel.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        eLeftWheel.physicsBody!.affectedByGravity = true
        eLeftWheel.physicsBody!.isDynamic = true
        eLeftWheel.physicsBody!.allowsRotation = true
        eLeftWheel.position = CGPoint(x: -30, y: 560)
        eLeftWheel.physicsBody?.categoryBitMask = ContactCategories.Enemy
        eLeftWheel.physicsBody?.collisionBitMask = 5
        eLeftWheel.physicsBody?.contactTestBitMask = 0
        
        let eRightWheel = SKSpriteNode(texture: SKTexture(imageNamed: "enemyWheel"), size: CGSize(width: 50, height: 50))
        eRightWheel.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        eRightWheel.physicsBody!.affectedByGravity = true
        eRightWheel.physicsBody!.isDynamic = true
        eRightWheel.physicsBody!.allowsRotation = true
        eRightWheel.position = CGPoint(x: 30, y: 560)
        eRightWheel.physicsBody?.categoryBitMask = ContactCategories.Enemy
        eRightWheel.physicsBody?.collisionBitMask = 5
        eRightWheel.physicsBody?.contactTestBitMask = 0
        
        let eBase = SKSpriteNode(texture: SKTexture(imageNamed: "enemyCar"), size: CGSize(width: 60, height: 50))
        eBase.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 60, height: 50))
        eBase.physicsBody!.affectedByGravity = true
        eBase.physicsBody!.isDynamic = true
        eBase.physicsBody!.allowsRotation = true
        eBase.position = CGPoint(x: 0, y: 585)
        eBase.physicsBody?.categoryBitMask = ContactCategories.Enemy
        eBase.physicsBody?.collisionBitMask = 5
        eBase.physicsBody?.contactTestBitMask = 0
        eBase.name = "enemyBody"
        
        let pinJointLeft = SKPhysicsJointPin.joint(withBodyA: eBase.physicsBody!, bodyB: eLeftWheel.physicsBody!, anchor: CGPoint(x: -30, y: 560))
        let pinJointRight = SKPhysicsJointPin.joint(withBodyA: eBase.physicsBody!, bodyB: eRightWheel.physicsBody!, anchor: CGPoint(x: 30, y: 560))
        
        self.addChild(eLeftWheel)
        self.addChild(eRightWheel)
        self.addChild(eBase)
        
        scene!.physicsWorld.add(pinJointLeft)
        scene!.physicsWorld.add(pinJointRight)
        
        eLeftWheel.physicsBody?.applyTorque(CGFloat(5000))
    }
        
    func blastLaser() {
        let laser = SKEmitterNode(fileNamed: "MyParticle")
        laser!.position = CGPoint(x: 0, y: 50)
        self.addChild(laser!)
        let laserNode = SKSpriteNode(color: UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1), size: CGSize(width: 100, height: 1000))
        laserNode.position = CGPoint(x: 0, y: 50)
        self.addChild(laserNode)
    }
        
    
    
}
