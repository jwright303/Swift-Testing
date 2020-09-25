//
//  DriveScene.swift
//  PlaygroundTests
//
//  Created by Jackson Wright on 9/5/20.
//  Copyright © 2020 Jackson Wright. All rights reserved.
//

import GameplayKit
import SpriteKit

class DriveScene: SKScene, SKPhysicsContactDelegate {
    
    //var ground : SKShapeNode = SKShapeNode()
    //var groundNodes : [SKShapeNode] = []
    
    var prevTouchPos : CGPoint = CGPoint(x: 0, y: 0)
    
    var texAtlas = SKTextureAtlas()
    var waitArr : [SKTexture] = []
    var bombArr : [SKTexture] = []
    var shootingArr : [SKTexture] = []
    
    var platsArr : [SKSpriteNode] = []
    var platsDeleted = 0
    var moneyCount = 0
    var addBoostPad = true
    
    var utilArr : [SKSpriteNode] = []
            
    var placeOnSin = (3.14159 * -100)
    
    var leftWheel = SKSpriteNode()
    var rightWheel = SKSpriteNode()
    var baseConnector = SKSpriteNode()
    
    var gunAngle : CGFloat = 0.0
    
    var distanceLabel = SKLabelNode()
    var moneyLabel = SKLabelNode()

    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        spawnPlayerCar()
        newDriveScene()
        createAnimations()
        addControls()
        //spawnBomb()
    }
    
    override func update(_ currentTime: TimeInterval) {
        //Scrolls the screen if the player is on the right most side of the
        if (baseConnector.position.x >= self.frame.width * 1/8) {
            shiftScreenH()
        }
        
        //Scrolls the screen up and down
        if (baseConnector.position.y >= self.frame.height * 3/8) {
            shiftScreenV(falling: false)
        } else if (baseConnector.position.y <= -self.frame.height * 1/8) {
            shiftScreenV(falling: true)
        }
        
        //Check if the first platform is off the screen
        if(platsArr.first != nil) {
            if(platsArr.first!.position.x < -self.frame.width/2 - 200) {
                deletePlatOffscreen()
                platsDeleted += 1
                distanceLabel.text = "\(platsDeleted * 3)m"
            }
        }
        
        //Check if the first Mob/Util is off screen
        if(utilArr.first != nil) {
            if(utilArr.first!.position.x < -self.frame.width/2 - 200) {
                utilArr.first!.removeAllActions()
                utilArr.first!.removeFromParent()
                utilArr.removeFirst()
            }
        }
        
        //Check if player died
        if (baseConnector.position.x < (-self.frame.height/2 - 50)) || (baseConnector.position.y < platsArr.first!.position.y - self.frame.height) {
            reSpawnPlayerMid()
        }
        
        if platsDeleted % 25 == 0 && platsDeleted != 0{
            if (Int.random(in: 1...50) < 25) {
                addBoostPad = true
            }
        }
        if platsDeleted % 55 == 0 && platsDeleted != 0 && self.childNode(withName: "bomb") == nil {
            //spawnBomb()
            if (Int.random(in: 1...50) < 25) {
                spawnBomb()
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA.node
        let secondBody = contact.bodyB.node
        
        if firstBody?.name == "boostPad" || secondBody?.name == "boostPad" {
            if firstBody?.name == "boostPad" {
                let xPulse = cos(firstBody!.zRotation) * 2000
                let yPulse = sin(firstBody!.zRotation) * 2000
                //secondBody?.physicsBody?.
                for _ in 1...10 {
                    secondBody?.physicsBody?.applyImpulse(CGVector(dx: xPulse, dy: yPulse))
                    secondBody?.physicsBody?.applyImpulse(CGVector(dx: xPulse/6, dy: -yPulse/6))
                }
                
            } else {
                let xPulse = cos(secondBody!.zRotation) * 2000
                let yPulse = sin(secondBody!.zRotation) * 2000
                //secondBody?.physicsBody?.
                for _ in 1...10 {
                    firstBody?.physicsBody?.applyImpulse(CGVector(dx: xPulse, dy: yPulse))
                    firstBody?.physicsBody?.applyImpulse(CGVector(dx: xPulse/6, dy: -yPulse/6))
                }
            }
        } else if firstBody?.name == "bomb" || secondBody?.name == "bomb" {
            if let name = firstBody?.name {
                if name.contains("player") {
                    //print("player go boom")
                    let dx = baseConnector.position.x - secondBody!.position.x
                    let dy = baseConnector.position.y - secondBody!.position.y
                    
                    baseConnector.physicsBody!.applyImpulse(CGVector(dx: dx * 5000, dy: dy * 10000))
                    //baseConnector.physicsBody?.joints.removeAll()
                } else {
                    print("player shot bomb")
                }
            }
            if let name2 = secondBody?.name {
                if name2.contains("player") {
                    //print("player go boom boom")
                    let dx = baseConnector.position.x - secondBody!.position.x
                    let dy = baseConnector.position.y - secondBody!.position.y
                    
                    baseConnector.physicsBody!.applyImpulse(CGVector(dx: dx * 500, dy: dy * 1000))
                } else {
                    print("player shot bomb")
                }
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let position = touch!.location(in: self)
        let nodeAtPress = atPoint(position)
        prevTouchPos = position
        
        //print(baseConnector.physicsBody?.velocity.dx)
        
        if nodeAtPress.name == "drive" {
            //nodeAtPress.removeAllActions()
            leftWheel.physicsBody?.applyTorque(-200)
            rightWheel.physicsBody?.applyTorque(-200)
            if (!nodeAtPress.hasActions()) {
                nodeAtPress.run(SKAction.animate(with: [SKTexture(imageNamed: "DrivePressedButton")], timePerFrame: 0.1, resize: false, restore: true))
            }
        } else if nodeAtPress.name == "reverse" {
            //nodeAtPress.removeAllActions()
            leftWheel.physicsBody?.applyTorque(200)
            rightWheel.physicsBody?.applyTorque(200)
            if (!nodeAtPress.hasActions()) {
                nodeAtPress.run(SKAction.animate(with: [SKTexture(imageNamed: "RevrsPressedButton")], timePerFrame: 0.1, resize: false, restore: true))
            }
        } else if nodeAtPress.name == "flip" {
            baseConnector.physicsBody?.applyAngularImpulse(CGFloat(-42))
        } else if nodeAtPress.name == "jump" {
            let xPulse = (-sin(baseConnector.zRotation) * 30000)
            let yPulse = (cos(baseConnector.zRotation) * 30000)
            let waitImage = SKSpriteNode(texture: waitArr[0], size: CGSize(width: 125, height: 125))
            waitImage.position = nodeAtPress.position
            self.addChild(waitImage)
            
            baseConnector.physicsBody?.applyImpulse(CGVector(dx: xPulse, dy: yPulse))
            waitImage.run(SKAction.sequence([
                SKAction.animate(with: waitArr, timePerFrame: 0.5),
                SKAction.removeFromParent()
            ]))
        } else if nodeAtPress.name == "shoot" {
            shootGun()
        } else if (position.x > self.frame.width/2 - 100) && (position.y > -350) {
            let riseORun = (position.y - baseConnector.position.y) / (position.x - baseConnector.position.x)
            gunAngle = atan(riseORun)
            
            let gunAim = SKSpriteNode(texture: SKTexture(imageNamed: "reticle"), size: CGSize(width: 75, height: 75))
            gunAim.alpha = 0.0
            gunAim.position = position
            self.addChild(gunAim)
            
            gunAim.run(SKAction.sequence([
                SKAction.fadeIn(withDuration: 0.2),
                SKAction.wait(forDuration: 0.3),
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.removeFromParent()
            ]))
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let position = touch!.location(in: self)
        let nodeAtPress = atPoint(position)
        
        if nodeAtPress.name == "swipeRot" && atPoint(prevTouchPos).name == "swipeRot" {
            let distance = prevTouchPos.x - position.x
            baseConnector.run(SKAction.rotate(byAngle: distance/25, duration: 0.5))
            baseConnector.physicsBody?.angularVelocity = 0.0
        }
    }
    
    func newPlatSegment() {
        for _ in 1...25 {
            platsFollowSin()
        }
    }
    
    //Spawns the floor for the new scene
    func newDriveScene() {
        moneyLabel = SKLabelNode(fontNamed: "Noteworthy Bold")
        moneyLabel.position = CGPoint(x: (self.frame.width/2 - 50), y: (self.frame.height/2 - 50))
        moneyLabel.text = "$\(moneyCount)"
        self.addChild(moneyLabel)
        
        distanceLabel = SKLabelNode(fontNamed: "Noteworthy Bold")
        distanceLabel.position = CGPoint(x: (-self.frame.width/2 + 25), y: (self.frame.height/2 - 50))
        distanceLabel.text = "\(platsDeleted * 3)m"
        distanceLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        self.addChild(distanceLabel)
        
        newPlatSegment()
    }
    
    //Deletes plats that have gone too far to the left offscreen
    func deletePlatOffscreen() {
        platsArr.first!.removeAllActions()
        platsArr.first!.removeFromParent()
        platsArr.removeFirst()
        if platsArr.count < 20 {
            //platsFollowSin()
            newPlatSegment()
        }
    }
    
    func shiftScreenV(falling: Bool) {
        //Divided by the FPS at accuraetly adjust how much it should move
        var moveThingsBy = -baseConnector.physicsBody!.velocity.dy/60
        if moveThingsBy > 0 {
            moveThingsBy *= -1.0
        }
        if falling {
            moveThingsBy *= -1.0
        }
        
        baseConnector.position.y += moveThingsBy
        leftWheel.position.y += moveThingsBy
        rightWheel.position.y += moveThingsBy
        
        for plat in platsArr {
            plat.position.y += moveThingsBy
        }
        for util in utilArr {
            util.position.y += moveThingsBy
        }
    }
    
    func shiftScreenH() {
        //Divided by the FPS at accuraetly adjust how much it should move
        var moveThingsBy = -baseConnector.physicsBody!.velocity.dx/60
        if moveThingsBy > 0 {
            moveThingsBy *= -1.0
        }
        
        baseConnector.position.x += moveThingsBy
        leftWheel.position.x += moveThingsBy
        rightWheel.position.x += moveThingsBy
        
        for plat in platsArr {
            plat.position.x += moveThingsBy
        }
        for util in utilArr {
            util.position.x += moveThingsBy
        }
    }
    
    func createAnimations() {
        texAtlas = SKTextureAtlas(named: "wait")
        for i in 1...(texAtlas.textureNames.count) {
            let name = "wait_\(i).png"
            waitArr.append(SKTexture(imageNamed: name))
        }
        
        texAtlas = SKTextureAtlas(named: "bomb")
        for i in 1...(texAtlas.textureNames.count) {
            let name = "bomb_\(i).png"
            bombArr.append(SKTexture(imageNamed: name))
        }
        
        texAtlas = SKTextureAtlas(named: "shot")
        for i in 1...(texAtlas.textureNames.count) {
            let name = "shot_\(i).png"
            let texture = SKTexture(imageNamed: name)
            shootingArr.append(texture)
        }
        
        
    }
    
    //Creates all the controls for the game AKA the drive buttons, shooting, jumping, rotating
    func addControls() {
        //add Code that adds all the new controls in
        let rvs = SKSpriteNode(texture: SKTexture(imageNamed: "RevrsUnpressedButton"), size: CGSize(width: 200, height: 300))
        rvs.position.x = -self.frame.width/2 + 120
        rvs.position.y = -self.frame.height/2 + 170
        rvs.name = "reverse"
        self.addChild(rvs)
                
        let drv = SKSpriteNode(texture: SKTexture(imageNamed: "DriveUnpressedButton"), size: CGSize(width: 200, height: 300))
        drv.position.x = rvs.position.x + 210
        drv.position.y = rvs.position.y
        drv.name = "drive"
        self.addChild(drv)
        
        /*
        let rotLft = SKSpriteNode(texture: SKTexture(imageNamed: "RotateLeft"), size: CGSize(width: 200, height: 75))
        rotLft.position.x = rvs.position.x
        rotLft.position.y = rvs.position.y + 200
        rotLft.name = "rotateLeft"
        self.addChild(rotLft)
        
        let rotRht = SKSpriteNode(texture: SKTexture(imageNamed: "RotateRight"), size: CGSize(width: 200, height: 75))
        rotRht.position.x = drv.position.x
        rotRht.position.y = drv.position.y + 200
        rotRht.name = "rotateRight"
        self.addChild(rotRht)
        */
        
        let swipeRot = SKSpriteNode(color: UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 1), size: CGSize(width: 400, height: 75))
        swipeRot.position.x = (drv.position.x + rvs.position.x) / 2
        swipeRot.position.y = drv.position.y + 200
        swipeRot.name = "swipeRot"
        swipeRot.zPosition = 4
        self.addChild(swipeRot)
        
        let jmp = SKSpriteNode(texture: SKTexture(imageNamed: "JumpButton"), size: CGSize(width: 125, height: 125))
        jmp.position.x = self.frame.width/2 - 100
        jmp.position.y = -self.frame.height/2 + 100
        jmp.name = "jump"
        self.addChild(jmp)
        
        let sht = SKSpriteNode(texture: SKTexture(imageNamed: "ShootButton"), size: CGSize(width: 125, height: 125))
        sht.position.x = jmp.position.x - 125
        sht.position.y = jmp.position.y + 125
        sht.name = "shoot"
        self.addChild(sht)
        
    }
    
    func createBoostPad(nodeAt: SKSpriteNode) {
        let dy = 15
        var dx = -13
        var angle = CGFloat(39.0/180 * Double.pi)
        //print("rotation:", nodeAt.zRotation)
        
        if nodeAt.zRotation < 0 {
            dx *= -1
            angle *= -1
        }
        
        let boostPad = SKSpriteNode(color: UIColor(displayP3Red: 0.6, green: 0.8, blue: 1, alpha: 1), size: CGSize(width: 200, height: 25))
        boostPad.position.x = nodeAt.position.x + CGFloat(dx)
        boostPad.position.y = nodeAt.position.y + CGFloat(dy)
        boostPad.zRotation = angle
        boostPad.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 200, height: 25))
        boostPad.physicsBody!.affectedByGravity = false
        boostPad.physicsBody!.isDynamic = false
        boostPad.physicsBody!.friction = 0.0
        boostPad.physicsBody!.categoryBitMask = ContactCategories.DetectNode
        boostPad.physicsBody!.collisionBitMask = 0
        boostPad.physicsBody!.contactTestBitMask = 1
        boostPad.name = "boostPad"
        self.addChild(boostPad)
        utilArr.append(boostPad)
        
    }
    
    func spawnBomb() {
        let newBomb = SKSpriteNode(texture: bombArr[0], size: CGSize(width: 75, height: 75))
        let xDes = self.frame.width/2 + baseConnector.physicsBody!.velocity.dx/5 + CGFloat(Int.random(in: 0...100))
        
        newBomb.physicsBody = SKPhysicsBody(circleOfRadius: 35)
        newBomb.physicsBody!.affectedByGravity = true
        newBomb.physicsBody!.isDynamic = true
        newBomb.physicsBody!.categoryBitMask = ContactCategories.Enemy
        newBomb.physicsBody!.contactTestBitMask = 9
        newBomb.physicsBody!.collisionBitMask = 4
        newBomb.name = "bomb"
        newBomb.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.animate(with: bombArr, timePerFrame: 0.05),
            SKAction.move(by: CGVector(dx: -15, dy: -20), duration: 0.1),
            SKAction.animate(with: bombArr.reversed(), timePerFrame: 0.05),
            SKAction.move(by: CGVector(dx: -15, dy: -20), duration: 0.1)
        ])))
        
        for i in 0...platsArr.count-1 {
            if abs(Int(xDes - platsArr[i].position.x)) < 50 || i == platsArr.count-1 {
                newBomb.zRotation = platsArr[i].zRotation
                newBomb.position = platsArr[i].position
                newBomb.position.y += abs((sin(platsArr[i].zRotation) * 100))
                if newBomb.zRotation < 0 {
                    newBomb.position.x += cos(platsArr[i].zRotation) * 60
                } else {
                    newBomb.position.x -= (cos(platsArr[i].zRotation) * 60)
                }
                break
            }
        }
        
        self.addChild(newBomb)
        utilArr.append(newBomb)
    }
    
    //Spawns the player in the middle of the map if they fall too far below it
    func reSpawnPlayerMid() {
        baseConnector.position = CGPoint(x: 0, y: 350)
        leftWheel.position = CGPoint(x: -20, y: 330)
        rightWheel.position = CGPoint(x: 20, y: 330)
        baseConnector.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        leftWheel.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        rightWheel.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        baseConnector.physicsBody?.applyImpulse(CGVector(dx: 300, dy: 350))
    }
    
    //Creates the players car when the game is created
    func spawnPlayerCar() {
        leftWheel = self.childNode(withName: "playerWL") as! SKSpriteNode
        rightWheel = self.childNode(withName: "playerWR") as! SKSpriteNode
        baseConnector = self.childNode(withName: "player") as! SKSpriteNode
        
        let pinJointLeft = SKPhysicsJointPin.joint(withBodyA: baseConnector.physicsBody!, bodyB: leftWheel.physicsBody!, anchor: CGPoint(x: -20, y: 80))
        let pinJointRight = SKPhysicsJointPin.joint(withBodyA: baseConnector.physicsBody!, bodyB: rightWheel.physicsBody!, anchor: CGPoint(x: 20, y: 80))
            
        scene!.physicsWorld.add(pinJointLeft)
        scene!.physicsWorld.add(pinJointRight)
    }
    
    func shootGun() {
        let bullet = SKSpriteNode(color: UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1), size: CGSize(width: 50, height: 10))
        bullet.position = baseConnector.position
        bullet.zRotation = gunAngle
        bullet.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 10))
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.isDynamic = true
        bullet.physicsBody!.allowsRotation = false
        bullet.physicsBody!.categoryBitMask = ContactCategories.Laser
        bullet.physicsBody!.collisionBitMask = 32
        self.addChild(bullet)
        
        let shootAni = SKSpriteNode(texture: shootingArr[0])
        shootAni.position = baseConnector.position
        shootAni.zRotation = baseConnector.zRotation
        //var shiftX = cos(shootAni.zRotation) * 10
        var shiftY = sin(shootAni.zRotation) * 55
        
        if shootAni.zRotation < 0 {
            shiftY *= -1
        }
    
        //shootAni.position.x += shiftX
        shootAni.position.y += shiftY
        shootAni.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        shootAni.zPosition = 5
        let fixJoint = SKPhysicsJointFixed.joint(withBodyA: baseConnector.physicsBody!, bodyB: shootAni.physicsBody!, anchor: shootAni.position)
        self.addChild(shootAni)
        scene!.physicsWorld.add(fixJoint)
        
        shootAni.run(SKAction.sequence([
            SKAction.animate(with: shootingArr, timePerFrame: 0.2),
            SKAction.removeFromParent()
        ]))
        bullet.physicsBody?.applyImpulse(CGVector(dx: cos(bullet.zRotation) * 30, dy: sin(bullet.zRotation) * 30))
    }
    
    //Function that gets the last platform then checks where it ends
    func getCurEndpoint() -> CGPoint {
        let lastPlat = platsArr.last!
        var endPoint = CGPoint()
        
        endPoint.x = lastPlat.position.x + (cos(lastPlat.zRotation) * lastPlat.size.width/2)
        endPoint.y = lastPlat.position.y + (sin(lastPlat.zRotation) * lastPlat.size.width/2)
        
        return endPoint
    }
    
    //Prints out plats that follow a Sin wave that is specified by the formula y = b sin(ax-h) + k
    //Here the b = 75, a = 0.005, h = 0, k = 0
    //The index is held globally as to where the current x value is as "placeOnSin"
    func platsFollowSin() {
        let ranB = 70.0
        let a = 0.005
        let checkStart = 15
        var checker = 5
        var length : Double
        var newY : Double
        var curX = 0

        //Finds the next point on the Sin Graph that is at least 100 pixles away from the current endpoint
        repeat {
            checker += 5
            curX = checker + checkStart
            newY = ranB * sin(a * Double(placeOnSin + Double(curX)))
            length = sqrt(Double(curX * curX) + (newY * newY))
        } while (Int(length) < 100)
        
        let newRot = atan(newY/Double(curX))
        let degs = newRot/Double.pi * 180.0
        let newPlat = SKSpriteNode(color: UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1), size: CGSize(width: length, height: 25))
        
        placeOnSin += Double(curX)
        
        if platsArr.count == 0 {
            newPlat.position = CGPoint(x: CGFloat((3.14159 * -100) + Double(curX) / 2.0), y: CGFloat(newY/2.0))
        } else {
            let endP = getCurEndpoint()
            newPlat.position = CGPoint(x: endP.x + CGFloat(Double(curX) / 2.0), y: endP.y + CGFloat(newY/2.0))
        }
        
        newPlat.zRotation = CGFloat(newRot)
        newPlat.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: length, height: 25.0))
        newPlat.physicsBody?.affectedByGravity = false
        newPlat.physicsBody?.isDynamic = false
        newPlat.physicsBody?.friction = 1.0
        newPlat.physicsBody?.restitution = 0.1
        newPlat.physicsBody?.angularDamping = 0.3
        newPlat.physicsBody?.categoryBitMask = ContactCategories.Platform
        newPlat.physicsBody?.collisionBitMask = 3      //Makes contact with cats 2, 1
        newPlat.physicsBody?.angularDamping = 0.7
        
        if (abs(Int32(degs)) == 39) && (addBoostPad) {
            createBoostPad(nodeAt: newPlat)
            addBoostPad = false
        }
        
        self.addChild(newPlat)                          //2 is enemy, 1 is player
        platsArr.append(newPlat)
        //newPlat.run(SKAction.repeatForever(SKAction.moveBy(x: -10.0, y: 0.0, duration: 0.1)))
    }
    
    /*
    func newGround(start: CGPoint) {
        let maxY = Int(self.frame.height/2) - 100
        let minY = -maxY
    
        var newLinePoints : [CGPoint] = []
        newLinePoints.append(start)
        for i in 1...2 {
            let yPoint = Int.random(in: minY...maxY)
            let xPoint = Int(start.x) + (i * 250)
            newLinePoints.append(CGPoint(x: xPoint, y: yPoint))
        }
        
        //print(endPointX)
        
        newLinePoints.append(CGPoint(x: Int(start.x + (self.frame.width * CGFloat(groundNodes.count))), y: Int.random(in: minY...maxY)))
        lastNodeY = Float(newLinePoints.last!.y)
        let newGround = SKShapeNode(splinePoints: &newLinePoints, count: newLinePoints.count)
        newGround.lineWidth = 5
        newGround.physicsBody = SKPhysicsBody(edgeChainFrom: newGround.path!)
        newGround.physicsBody?.affectedByGravity = false
        newGround.physicsBody?.isDynamic = false
        newGround.physicsBody?.restitution = 0.5
        newGround.physicsBody?.friction = 1.0
        groundNodes.append(newGround)
        self.addChild(newGround)
        
        //print(newLinePoints.last)
    }
     */
}
