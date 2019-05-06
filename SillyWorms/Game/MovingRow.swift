//
//  MovingRow.swift
//  SillyWorms
//
//  Created by Adnan Baysal on 28.04.2019.
//  Copyright © 2019 Adnan Baysal. All rights reserved.
//

import SpriteKit

class MovingRow: SKSpriteNode {
    
    private var numberOfBlocksInRow: Int = 1
    
    override internal var size: CGSize {
        didSet {
            numberOfBlocksInRow = Int(size.width / lineWidth)
        }
    }
    
    var lineWidth: CGFloat = 1 {
        didSet {
            numberOfBlocksInRow = Int(size.width / lineWidth)
        }
    }
    
    var pathLocations: [Int] = [0] {
        didSet {
            draw()
        }
    }
    
    func draw() {
        self.anchorPoint = CGPoint(x: 0, y: 0)
        for pos in pathLocations {
            let node2draw = drawNode(pos)
            addChild(node2draw)
        }
    }
    
    private func drawNode(_ offset: Int) -> SKSpriteNode {
        let node = SKSpriteNode(imageNamed: GameSettings.pathImage)
        //rect: CGRect(x: 0, y: 0, width: lineWidth, height: size.height))
        node.anchorPoint = CGPoint(x: 0, y: 0)
        node.size.width = lineWidth
        node.size.height = size.height
        node.zPosition = 1
        //node.fillColor = .white
        //node.strokeColor = .white
        node.position.x += CGFloat(offset) * lineWidth
        return node
    }
    
}
