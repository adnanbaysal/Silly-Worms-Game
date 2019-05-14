//
//  MenuScene.swift
//  SillyWorms
//
//  Created by Adnan Baysal on 28.04.2019.
//  Copyright © 2019 Adnan Baysal. All rights reserved.
//

import SpriteKit

extension CGRect {
    func aspectRatio() -> CGFloat {
        return self.width / self.height
    }
}

class MenuScene: SKScene {
    
    private var newGameButtonNode: SKButtonNode!
    private var difficultyButtonNode: SKButtonNode!
    private var difficultyLabelNode: SKLabelNode!
    private var gameTitle: SKLabelNode!
    private var userDefaults = UserDefaults.standard
    private var maxScoreLabelNode: SKLabelNode!
    private var recentScoreLabelNode: SKLabelNode!
    private var shareButtonNode: SKButtonNode!
    
    override func didMove(to view: SKView) {
        let center = CGPoint(x: frame.midX, y: frame.midY)
        
        let bgTexture = SKSpriteNode(imageNamed: "brickBig")
        let aspectRatio = bgTexture.frame.aspectRatio()
        bgTexture.size.height = size.height
        bgTexture.size.width = bgTexture.size.height * aspectRatio
        bgTexture.position = center
        bgTexture.zPosition = -1
        addChild(bgTexture)
        
        gameTitle = SKLabelNode(text: "Silly Worms")
        gameTitle.position = center + CGPoint(x: 0, y: size.height * 0.35)
        gameTitle.fontName = "GillSans-Bold"
        gameTitle.fontSize = size.width / 7
        gameTitle.fontColor = .yellow
        gameTitle.zPosition = 1
        addChild(gameTitle)
        
        spawnSillyWorm()
        _ = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(spawnSillyWorm), userInfo: nil, repeats: true)
        
        
        
        newGameButtonNode = SKButtonNode(width: size.width * 0.6, height: size.height/10, cornerRadius: size.height/80,
                                         buttonText: " New Game ", buttonName: "newGameButton", fillColor: GameSettings.buttonFillColor,
                                         strokeColor: .black, lineWidth: 3, fontColor: .white, fontName: "AvenirNext-Bold")
        newGameButtonNode.position = center + CGPoint(x: 0, y: size.height * 0.1)
        newGameButtonNode.zPosition = 1
        addChild(newGameButtonNode)
        
        difficultyButtonNode = SKButtonNode(width: size.width * 0.6, height: size.height/10, cornerRadius: size.height/80,
                                         buttonText: "Difficulty", buttonName: "difficultyButton",
                                         fillColor: GameSettings.buttonFillColor, strokeColor: .black, lineWidth: 3, fontColor: .white,
                                         fontName: "AvenirNext-Bold")
        difficultyButtonNode.position = center + CGPoint(x: 0, y: -size.height * 0.025)
        difficultyButtonNode.zPosition = 1
        addChild(difficultyButtonNode)
        
        difficultyLabelNode = SKLabelNode(text: "Easy")
        difficultyLabelNode.position = center + CGPoint(x: 0, y: -size.height * 0.15)
        difficultyLabelNode.fontSize = size.height / 20
        difficultyLabelNode.fontName = "GillSans-Bold"
        difficultyLabelNode.fontColor = .darkText
        difficultyLabelNode.zPosition = 1
        addChild(difficultyLabelNode)
        
        if userDefaults.bool(forKey: "hard") {
            difficultyLabelNode.text = "Hard"
        } else {
            difficultyLabelNode.text = "Easy"
        }
        
        maxScoreLabelNode = SKLabelNode(text: "Max score: ")
        maxScoreLabelNode.position = center + CGPoint(x: 0, y: -size.height * 0.25)
        maxScoreLabelNode.text = "Max score: \(userDefaults.integer(forKey: "maxscore"))"
        maxScoreLabelNode.fontName = "GillSans-Bold"
        maxScoreLabelNode.fontSize = size.height / 20
        maxScoreLabelNode.zPosition = 1
        addChild(maxScoreLabelNode)
        
        recentScoreLabelNode = SKLabelNode(text: "Recent score: ")
        recentScoreLabelNode.position = center + CGPoint(x: 0, y: -size.height * 0.30)
        recentScoreLabelNode.text = "Recent score: \(userDefaults.integer(forKey: "recentscore"))"
        recentScoreLabelNode.fontSize = size.height / 20
        recentScoreLabelNode.fontName = "GillSans-Bold"
        recentScoreLabelNode.zPosition = 1
        addChild(recentScoreLabelNode)
        
        
        shareButtonNode = SKButtonNode(width: size.width * 0.6, height: size.height/10, cornerRadius: size.height/80,
                                       buttonText: "  Share   ", buttonName: "shareButton", fillColor: .clear,
                                       strokeColor: .clear, lineWidth: 3, fontColor: .cyan, fontName: "AvenirNext-Bold")
        shareButtonNode.position = center + CGPoint(x: 0, y: -size.height * 0.40)
        shareButtonNode.zPosition = 1
        addChild(shareButtonNode)
    }
    
    @objc private func spawnSillyWorm() {
        let center = CGPoint(x: frame.midX, y: frame.midY)
        
        let randWormIndex = Int(arc4random_uniform(UInt32(GameSettings.sillyWormImageNames.count)))
        let sillyWorm = SillyWorm(imageNamed: GameSettings.sillyWormImageNames[randWormIndex])
        
        sillyWorm.size = CGSize(width: size.width / CGFloat(GameSettings.numberOfColumns),
                                height: 2 * size.width / CGFloat(GameSettings.numberOfColumns))
        sillyWorm.zRotation = 3 * CGFloat.pi / 2
        sillyWorm.position = center + CGPoint(x: -size.width / 2, y: size.height * 0.225)
        sillyWorm.wormHeight = size.width / CGFloat(GameSettings.numberOfColumns)
        sillyWorm.moveDuration = 0.5 + TimeInterval(arc4random_uniform(10)) / 10
        sillyWorm.zPosition = 1
        sillyWorm.xIndex = GameSettings.numberOfColumns + 1
        let randWaitDuration = TimeInterval(arc4random_uniform(100)) / 50
        run(.wait(forDuration: randWaitDuration)) {
            self.addChild(sillyWorm)
            sillyWorm.moveLeft()
        }
    }
    
    private func changeDifficulty() {
        run(SKAction.playSoundFileNamed("bip.wav", waitForCompletion: false))
        if difficultyLabelNode.text == "Easy" {
            difficultyLabelNode.text = "Hard"
            userDefaults.set(true, forKey: "hard")
        } else {
            difficultyLabelNode.text = "Easy"
            userDefaults.set(false, forKey: "hard")
        }
        userDefaults.synchronize()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let nodesArray = nodes(at: location)
            if nodesArray.first?.name == "newGameButton" {
                run(SKAction.playSoundFileNamed("opening.wav", waitForCompletion: true))
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                let gameScene = GameScene(size: self.size)
                self.view?.presentScene(gameScene, transition: transition)
            }
            else if nodesArray.first?.name == "difficultyButton" {
                changeDifficulty()
            }
            else if nodesArray.first?.name == "shareButton" {
                let image = self.takeScreenshot()!
                let message = "My best score in Silly Worms :)"
                let activityVC = UIActivityViewController(activityItems: [message, image], applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = self.view
                self.view?.window?.rootViewController!.present(activityVC, animated: true, completion: nil)
            }
        }
    }
    
    private func takeScreenshot() -> UIImage? {
        let snapshotView = view!.snapshotView(afterScreenUpdates: true)!
        let bounds = UIScreen.main.bounds
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        snapshotView.drawHierarchy(in: bounds, afterScreenUpdates: true)
        let screenshotImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return screenshotImage;
    }
    
}
