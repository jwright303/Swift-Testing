//
//  ShopScene.swift
//  PlaygroundTests
//
//  Created by Jackson Wright on 9/5/20.
//  Copyright © 2020 Jackson Wright. All rights reserved.
//

import SpriteKit
import GameplayKit

class ShopScene: SKScene {

    override func didMove(to view: SKView) {
        createScene()
    }
    
    func createScene() {
        let topLabelHeight = ((self.frame.height/2) - (self.frame.height/6))
        let shopLabel = SKLabelNode(text: "Shop")
        shopLabel.fontSize = 55
        shopLabel.fontName = "Bold"
        shopLabel.fontColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1)
        shopLabel.position = CGPoint(x: 0.0, y: topLabelHeight)
        self.addChild(shopLabel)
        
        let itemBubble = SKShapeNode(rect: CGRect(x: 0, y: 50, width: 100, height: 100), cornerRadius: 25)
        itemBubble.fillColor = UIColor(displayP3Red: 0.451, green: 0.631, blue: 0.812, alpha: 1)
        self.addChild(itemBubble)
        
    }
}
