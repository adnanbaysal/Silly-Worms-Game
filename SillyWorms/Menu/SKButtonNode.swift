//
//  SKButtonNode.swift
//  SillyWorms
//
//  Created by Adnan Baysal on 14.05.2019.
//  Copyright © 2019 Adnan Baysal. All rights reserved.
//

import SpriteKit

class SKButtonNode: SKNode {
    private var roundedRectangle: SKShapeNode!
    private var buttonLabelNode: SKLabelNode!
    
    private var textWidthOffset: CGFloat {
        return frame.size.width / 40
    }
    private var textHeightOffset: CGFloat {
        return frame.size.height / 40
    }
    
    var buttonStrokeColor: UIColor = .black {
        didSet {
            roundedRectangle.strokeColor = buttonStrokeColor
        }
    }
    var buttonFillColor: UIColor = .white {
        didSet {
            roundedRectangle.fillColor = buttonFillColor
        }
    }
    var fontColor: UIColor = .black {
        didSet {
            buttonLabelNode.fontColor = fontColor
        }
    }
    var buttonText: String = " " {
        didSet {
            buttonLabelNode.text = buttonText
        }
    }
    
    private func calculateFontSize(width: CGFloat, height: CGFloat) -> CGFloat {
        let availableWidth = width - 2 * textWidthOffset
        let availableHeight = height - 2 * textHeightOffset
        if buttonText.count > 0 {
            return 1.5 * min(availableWidth / CGFloat(buttonText.count), availableHeight)
        } else {
            return 0
        }
    }
    
    init(width: CGFloat, height: CGFloat, cornerRadius: CGFloat, buttonText: String, buttonName: String, fillColor: UIColor,
         strokeColor: UIColor, lineWidth: CGFloat, fontColor: UIColor, fontName: String) {
        super.init()
        self.buttonText = buttonText
//        self.name = buttonName
        self.buttonStrokeColor = strokeColor
        self.buttonFillColor = fillColor
        self.fontColor = fontColor
        
        roundedRectangle = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: cornerRadius)
        roundedRectangle.strokeColor = strokeColor
        roundedRectangle.fillColor = fillColor
        roundedRectangle.lineWidth = lineWidth
        roundedRectangle.zPosition = 0
        roundedRectangle.name = buttonName
        addChild(roundedRectangle)
        
        buttonLabelNode = SKLabelNode(text: buttonText)
        buttonLabelNode.fontColor = fontColor
        buttonLabelNode.text = buttonText
        buttonLabelNode.fontSize = calculateFontSize(width: width, height: height)
        buttonLabelNode.horizontalAlignmentMode = .center
        buttonLabelNode.verticalAlignmentMode = .center
        buttonLabelNode.fontName = fontName
        buttonLabelNode.zPosition = 1
        buttonLabelNode.name = buttonName
        addChild(buttonLabelNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
