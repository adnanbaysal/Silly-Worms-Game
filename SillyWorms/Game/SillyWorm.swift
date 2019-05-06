//
//  SillyWorm.swift
//  SillyWorms
//
//  Created by Adnan Baysal on 1.05.2019.
//  Copyright © 2019 Adnan Baysal. All rights reserved.
//

import SpriteKit

class SillyWorm: SKSpriteNode {
    
    private var fadeOut: SKAction!
    private var fadeIn: SKAction!
    private var blinkSequence: SKAction!
    
    var endHeight: CGFloat = 0
    var wormHeight: CGFloat = 0
    var blinkDuration: TimeInterval = 1
    var moveDuration: TimeInterval = 1
    
    var xIndex: Int = 0 {
        didSet {
            self.position.x = CGFloat(xIndex) * wormHeight
        }
    }
    @objc dynamic var yIndex: Int = 0 {
        didSet {
            self.position.y = endHeight + CGFloat(yIndex) * wormHeight
        }
    }
    
    func bornAndMove() {
        let sigleBlinkDuration = blinkDuration / (2 * TimeInterval(GameSettings.blinkRepetition))
        fadeOut = SKAction.fadeAlpha(to: 0, duration: sigleBlinkDuration)
        fadeIn = SKAction.fadeAlpha(to: 1, duration: sigleBlinkDuration)
        blinkSequence = SKAction.sequence([fadeOut, fadeIn])
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = GameSettings.wormPhysicsCategory
        physicsBody?.contactTestBitMask = GameSettings.gemPhysicsCategory
        physicsBody?.collisionBitMask = 0
        blink()
    }
    
    private func blink() {
        run(SKAction.repeat(blinkSequence, count: GameSettings.blinkRepetition)) {
            self.moveDown()
        }
    }
    
    private func moveDown() {
        if yIndex > 0 {
            yIndex -= 1
            size.height += wormHeight
            run(.resize(toHeight: wormHeight, duration: moveDuration)) {
                self.moveDown()
            }
        }
    }
    
    func moveLeft() {
        if xIndex > 0 {
            xIndex -= 1
            size.height += wormHeight/2
            run(.resize(toHeight: self.size.height - wormHeight/2, duration: moveDuration)) {
                self.moveLeft()
            }
        } else {
            removeFromParent()
        }
    }
        
}
