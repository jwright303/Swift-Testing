//
//  GameScene.swift
//  PlaygroundTests
//
//  Created by Jackson Wright on 8/31/20.
//  Copyright © 2020 Jackson Wright. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        createButtons()
 
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let position = touch.location(in: self)
        //let nodeTouched = nodes(at: position)
        let frontNode = atPoint(position).name
        //let bottomNodeCenter = (-(self.frame.height/2.0) + (self.frame.height/6.0))
        
        /*
        if (position.x > -150 && position.x < 150) {
            //print(position.x)
            if (position.y > (bottomNodeCenter - 50) && position.y < (bottomNodeCenter + 50)) {
                print("press shop button")
            } else if (position.y > (bottomNodeCenter + 110) && position.y < (bottomNodeCenter + 210)) {
                print("press boss button")
            } else if (position.y > (bottomNodeCenter + 270) && position.y < (bottomNodeCenter + 370)) {
                print("press charge button")
                let newScene = PlayScene(fileNamed: "PlayScene")
                newScene?.scaleMode = .aspectFill
                scene?.view?.presentScene(newScene!)
            }
        }
        */
        if frontNode != nil {
            if (frontNode == "shopLabel" || frontNode == "shopButton") {
                print("press shop button")
                let newScene = ShopScene(fileNamed: "ShopScene")
                newScene?.scaleMode = .aspectFill
                scene?.view?.presentScene(newScene!)
            } else if (frontNode == "bossLabel" || frontNode == "bossButton") {
                print("press boss button")
                let newScene = DriveScene(fileNamed: "DriveScene")
                newScene?.scaleMode = .aspectFill
                scene?.view?.presentScene(newScene!)
            } else if (frontNode == "chargeLabel" || frontNode == "chargeButton") {
                print("press charge button")
                let newScene = PlayScene(fileNamed: "PlayScene")
                newScene?.scaleMode = .aspectFill
                scene?.view?.presentScene(newScene!)
            } else if (-1 == 2) {
                let newScene = DriveScene(fileNamed: "DriveScene")
                newScene?.scaleMode = .aspectFill
                scene?.view?.presentScene(newScene!)
            }
        }
    }
    
    func createLabels(shopPos : CGPoint, bossPos : CGPoint, chargePos : CGPoint) {
        let shopLabel = SKLabelNode(text: "Shop")
        let bossLabel = SKLabelNode(text: "Boss")
        let chargeLabel = SKLabelNode(text: "Charge")
        shopLabel.name = "shopLabel"
        bossLabel.name = "bossLabel"
        chargeLabel.name = "chargeLabel"
        
        shopLabel.fontColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 1)
        bossLabel.fontColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 1)
        chargeLabel.fontColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 1)
        
        shopLabel.fontSize = 60
        bossLabel.fontSize = 60
        chargeLabel.fontSize = 60
        shopLabel.fontName = "Bold"
        bossLabel.fontName = "Bold"
        chargeLabel.fontName = "Bold"
        
        shopLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode(rawValue: 1)!
        bossLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode(rawValue: 1)!
        chargeLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode(rawValue: 1)!
        
        self.addChild(shopLabel)
        self.addChild(bossLabel)
        self.addChild(chargeLabel)
        
        shopLabel.position = shopPos
        bossLabel.position = bossPos
        chargeLabel.position = chargePos
    }
    
    func createButtons() {
        let chargeButton = SKSpriteNode(color: UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1), size: CGSize(width: 300, height: 100))
        chargeButton.name = "chargeButton"
        let bossButton = SKSpriteNode(color: UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1), size: CGSize(width: 300, height: 100))
        bossButton.name = "bossButton"
        let shopButton = SKSpriteNode(color: UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1), size: CGSize(width: 300, height: 100))
        shopButton.name = "shopButton"
    
        shopButton.position = CGPoint(x: 0, y: (-(self.frame.height/2) + (self.frame.height/6)))
        bossButton.position = CGPoint(x: 0, y: (shopButton.position.y + 160))
        chargeButton.position = CGPoint(x: 0, y: (bossButton.position.y + 160))
                
        self.addChild(chargeButton)
        self.addChild(bossButton)
        self.addChild(shopButton)
        createLabels(shopPos: shopButton.position, bossPos: bossButton.position, chargePos: chargeButton.position)
    }
}
