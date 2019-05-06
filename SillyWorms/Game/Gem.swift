//
//  Gem.swift
//  SillyWorms
//
//  Created by Adnan Baysal on 5.05.2019.
//  Copyright © 2019 Adnan Baysal. All rights reserved.
//

import SpriteKit

class Gem: SKSpriteNode {
    
    private var fadeOut: SKAction!
    private var fadeIn: SKAction!
    private var blinkSequence: SKAction!
    
    var wormWidth: CGFloat = 1
    var endHeight: CGFloat = 1
    var gemRadius: CGFloat = 1
    var waitDuration: TimeInterval = 1
    var blinkDuration: TimeInterval = 1
    
    var xIndex: Int = 0 {
        didSet {
            self.position.x = CGFloat(xIndex) * wormWidth + wormWidth / 2
        }
    }
    var yIndex: Int = 0 {
        didSet {
            self.position.y = endHeight + CGFloat(yIndex) * wormWidth + wormWidth / 2
        }
    }
    
    func bornBlinkAndDie() {
        zPosition = 2
        let shape = SKShapeNode(circleOfRadius: gemRadius)
        shape.fillColor = GameSettings.gemFillColor
        shape.strokeColor = GameSettings.gemStrokeColor
        addChild(shape)
        let sigleBlinkDuration = blinkDuration / (2 * TimeInterval(GameSettings.blinkRepetition))
        fadeOut = SKAction.fadeAlpha(to: 0, duration: sigleBlinkDuration)
        fadeIn = SKAction.fadeAlpha(to: 1, duration: sigleBlinkDuration)
        blinkSequence = SKAction.sequence([fadeOut, fadeIn])
        physicsBody = SKPhysicsBody(circleOfRadius: gemRadius)
        physicsBody?.categoryBitMask = GameSettings.gemPhysicsCategory
        physicsBody?.contactTestBitMask = GameSettings.wormPhysicsCategory
        physicsBody?.collisionBitMask = 0
        run(.wait(forDuration: waitDuration)){
            self.blink()
        }
    }
    
    private func blink() {
        run(SKAction.repeat(blinkSequence, count: GameSettings.blinkRepetition)) {
            self.removeFromParent()
        }
    }
    
}
