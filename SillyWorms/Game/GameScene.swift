//
//  GameScene.swift
//  SillyWorms
//
//  Created by Adnan Baysal on 28.04.2019.
//  Copyright © 2019 Adnan Baysal. All rights reserved.
//

import SpriteKit
import UIKit

extension CGPoint {
    // component-wise addition
    static func +(_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var scoreLabel: SKLabelNode!
    var score: Int = 0
    {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    private var levelLabel: SKLabelNode!
    var level: Int = 1
    {
        didSet {
            levelLabel.text = "Level: \(level)"
        }
    }
    
    private let userDefaults = UserDefaults.standard
    
    private var pausedLabel: SKLabelNode!
    private var pauseButtonNode: SKSpriteNode!
    private var gem: Gem!
    private var isGameOver = false
    private var sillyWormWidth: CGFloat = 0
    private var sillyWorms = [SillyWorm]()
    private var movingRows = [MovingRow]()
    private var lineWidth: CGFloat!
    private var rowHeight: CGFloat!
    private var bottomOffsetHeight: CGFloat!
    private var topOffsetHeight: CGFloat!
    private var finishLine: [Bool]!
    private var numberOfFinishedWorms: Int = 0
    private var pathLocationArrays: [[Int]] = [[0, 2, 7],[0, 3, 6],[0, 4, 8]] { // this is predefined, do not change
        didSet {
            layoutMovingRows()
        }
    }
    
    override func didMove(to view: SKView){
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        prepareScene()
        layoutSubviews()
        generateSillyWorms()
    }
    
    private let scaleDown = SKAction.scale(to: 0.9, duration: 0.75)
    private let scaleUp = SKAction.scale(to: 1.0, duration: 0.75)
    private var heartBeatSequence: SKAction!
    
    private func prepareScene() {
        backgroundColor = GameSettings.backgroundColor
        bottomOffsetHeight = (self.size.height - self.size.width) / 2 
        topOffsetHeight = bottomOffsetHeight
        rowHeight = self.size.width / CGFloat(GameSettings.numberOfRows)
        lineWidth = self.size.width / CGFloat(GameSettings.numberOfColumns)
        sillyWormWidth = lineWidth
        finishLine = Array(repeating: false, count: GameSettings.numberOfColumns)
        numberOfFinishedWorms = 0
        heartBeatSequence = SKAction.sequence([scaleDown, scaleUp])
    }
    
    private func layoutSubviews() {
        layoutTopBars()
        layoutBottomBars()
        layoutMovingRows()
    }
    
    private func layoutTopBars() {
        addScoreLabel()
        addLevelLabel()
        score = 0
        level = userDefaults.bool(forKey: "hard") ? 2 : 1
        let bornArea = SKSpriteNode(color: GameSettings.bornAreaColor,
                                    size: CGSize(width: self.size.width, height: lineWidth))
        bornArea.anchorPoint = CGPoint(x: 0, y: 0)
        bornArea.position = self.position
        bornArea.position.y = (self.size.height + self.size.width) / 2
        addChild(bornArea)
    }
    
    private func addScoreLabel() {
        scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontName = "GillSans-Bold"
        scoreLabel.fontSize = size.width / 20
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = position + GameSettings.scoreLabelOffset
        scoreLabel.position.y += bottomOffsetHeight + CGFloat(GameSettings.numberOfRows) * rowHeight + sillyWormWidth
        addChild(scoreLabel)
    }
    
    private func addLevelLabel() {
        levelLabel = SKLabelNode(text: "Level: \(level)")
        levelLabel.fontName = "GillSans-Bold"
        levelLabel.fontSize = size.width / 20
        levelLabel.fontColor = .white
        levelLabel.horizontalAlignmentMode = .right
        levelLabel.position = CGPoint(x: size.width * 0.95, y: position.y) + GameSettings.levelLabelOffset
        levelLabel.position.y += bottomOffsetHeight + CGFloat(GameSettings.numberOfRows) * rowHeight + sillyWormWidth
        addChild(levelLabel)
    }
    
    private func layoutBottomBars() {
        let fillBar = SKSpriteNode(color: GameSettings.fillBarColor,
                                   size: CGSize(width: self.size.width, height: lineWidth))
        fillBar.anchorPoint = CGPoint(x: 0, y: 0)
        fillBar.position = self.position
        fillBar.position.y = (self.size.height - self.size.width) / 2 - lineWidth
        fillBar.zPosition = 0
        addChild(fillBar)
        
        pauseButtonNode = SKSpriteNode(imageNamed: "pauseButton")
        pauseButtonNode.position = CGPoint(x: frame.midX, y: frame.minY + GameSettings.pauseButtonHeight)
        let aspectRatio = pauseButtonNode.frame.aspectRatio()
        pauseButtonNode.size.width = size.width / 4
        pauseButtonNode.size.height = pauseButtonNode.size.width / aspectRatio
        pauseButtonNode.name = "pauseButton"
        pauseButtonNode.zPosition = 2
        addChild(pauseButtonNode)
    }
    
    private func layoutMovingRows() {
        self.removeChildren(in: movingRows)
        movingRows = [MovingRow]()
        for i in 0..<GameSettings.numberOfRows {
            let movingRow = genMovingRow(yPosition: bottomOffsetHeight + CGFloat(i) * rowHeight,
                                         height: rowHeight,
                                         image: GameSettings.rowImages[i],
                                         pathLocations: pathLocationArrays[i])
            movingRows.append(movingRow)
            self.addChild(movingRow)
        }
    }
    
    private func genMovingRow(yPosition: CGFloat, height: CGFloat, image: String, pathLocations: [Int]) -> MovingRow {
        let movingRow = MovingRow(imageNamed: image)
        movingRow.position = self.position
        movingRow.position.y = yPosition
        movingRow.size = self.size
        movingRow.size.height = height
        movingRow.lineWidth = lineWidth
        movingRow.pathLocations = pathLocations
        movingRow.zPosition = 0
        return movingRow
    }
    
    private func generateSillyWorms() {
        if sillyWorms.count < GameSettings.numberOfColumns && !isGameOver {
            spawnSillyWorm()
            run(.wait(forDuration: (GameSettings.timeAt(level: level, initial: GameSettings.level1SpawnTime)) ) ) {
                self.generateSillyWorms()
            }
        }
    }
    
    private func spawnSillyWorm() {
        let randSWImageNameIndex = arc4random_uniform(UInt32(GameSettings.sillyWormImageNames.count))
        let sillyWorm = SillyWorm(imageNamed: GameSettings.sillyWormImageNames[Int(randSWImageNameIndex)])
        sillyWorm.size = CGSize(width: sillyWormWidth, height: sillyWormWidth)
        sillyWorm.anchorPoint = CGPoint(x: 0, y: 0)
        sillyWorm.position = self.position
        sillyWorm.position.y = bottomOffsetHeight + CGFloat(GameSettings.numberOfRows) * rowHeight + lineWidth
        sillyWorm.endHeight = (self.size.height - self.size.width) / 2 - lineWidth
        sillyWorm.wormHeight = lineWidth
        let randSpeedFactor = 0.8 + TimeInterval(arc4random_uniform(4)) / 10
        sillyWorm.blinkDuration = GameSettings.timeAt(level: level, initial: GameSettings.level1BlinkDuration) * randSpeedFactor
        sillyWorm.moveDuration = GameSettings.timeAt(level: level, initial: GameSettings.level1MoveDuration) * randSpeedFactor
        sillyWorm.zPosition = 2
        sillyWorm.xIndex = Int(arc4random_uniform(UInt32(GameSettings.numberOfColumns)))
        sillyWorm.yIndex = GameSettings.numberOfColumns + 1
        
        sillyWorm.addObserver(self, forKeyPath: "yIndex", options: .new, context: nil)
        
        addChild(sillyWorm)
        sillyWorms.append(sillyWorm)
        sillyWorm.bornAndMove()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let sillyWorm = object as! SillyWorm? {
            if sillyWorm.yIndex == 0 {
                if finishLine[sillyWorm.xIndex] {
                    gameOver()
                } else {
                    run(SKAction.playSoundFileNamed("bling.wav", waitForCompletion: false))
                    finishLine[sillyWorm.xIndex] = true
                    numberOfFinishedWorms += 1
                    score += level
                    if numberOfFinishedWorms == GameSettings.numberOfColumns {
                        levelWon()
                    }
                }
            } else if sillyWorm.yIndex == GameSettings.gemSpawnYIndex {
                spawnGem()
            } else {
                let rowIndex = yIndex2rowIndex(sillyWorm.yIndex)
                if !pathLocationArrays[rowIndex].contains(sillyWorm.xIndex) {
                    gameOver()
                }
            }
        }
    }
    
    private func spawnGem() {
        gem = Gem(color: .clear, size: CGSize(width: sillyWormWidth, height: sillyWormWidth))
        gem.wormWidth = sillyWormWidth
        gem.endHeight = (self.size.height - self.size.width) / 2 - lineWidth
        gem.gemRadius = sillyWormWidth / 2
        var randX = arc4random_uniform(UInt32(GameSettings.numberOfColumns))
        while !pathLocationArrays[1].contains(Int(randX)) {
            randX = (randX + 1) % UInt32(GameSettings.numberOfColumns)
        }
        let randY = arc4random_uniform(UInt32(GameSettings.numberOfRowsInMovingRow))
        gem.xIndex = Int(randX)
        gem.yIndex = Int(randY) + GameSettings.numberOfRowsInMovingRow + 1
        let totalGemTime = GameSettings.timeAt(level: level, initial: GameSettings.level1MoveDuration) * TimeInterval(8 - randY)
        gem.blinkDuration = 2 * GameSettings.timeAt(level: level, initial: GameSettings.level1MoveDuration)
        gem.waitDuration = totalGemTime - gem.blinkDuration
        addChild(gem)
        gem.bornBlinkAndDie()
    }
    
    private func gameOver() {
        isGameOver = true
        for sillyWorm in sillyWorms { sillyWorm.isPaused = true }
        for movingRow in movingRows { movingRow.isPaused = true }
        if gem != nil { gem.isPaused = true }
        let redifyScreen = SKSpriteNode(color: UIColor(red: 1, green: 0, blue: 0, alpha: 0.3), size: size)
        redifyScreen.anchorPoint = CGPoint(x: 0, y: 0)
        redifyScreen.position = position
        redifyScreen.zPosition = 2
        run(.fadeAlpha(to: 0.5, duration: 0.1)) {
            self.addChild(redifyScreen)
            redifyScreen.run(.fadeAlpha(to: 1, duration: 0.5)) {
                redifyScreen.run(SKAction.playSoundFileNamed("game_over.wav", waitForCompletion: true))
                self.heartBeat(message: "Game Over!", count: 2)
                {
                    self.userDefaults.set(self.score, forKey: "recentscore")
                    if self.score > self.userDefaults.integer(forKey: "maxscore") {
                        self.userDefaults.set(self.score, forKey: "maxscore")
                    }
                    let transition = SKTransition.flipVertical(withDuration: 0.5)
                    let menuScene = MenuScene(size: self.size)
                    self.view?.presentScene(menuScene, transition: transition)
                }
            }
        }
    }
    
    private var heartBeatLabel: SKLabelNode!
    private func heartBeat(message text: String, count: Int, completion: @escaping () -> Void) {
        heartBeatLabel = SKLabelNode(text: text)
        heartBeatLabel.fontSize = size.height / 15
        heartBeatLabel.fontName = "Bold"
        heartBeatLabel.fontColor = .red
        heartBeatLabel.position.x = self.frame.midX
        heartBeatLabel.position.y = self.frame.midY
        heartBeatLabel.zPosition = 3
        self.addChild(heartBeatLabel)
        heartBeatLabel.run(.repeat(heartBeatSequence, count: count), completion: completion)
    }
    
    private func levelWon() {
        deleteSillyWormsOneByOne(0)
    }
    
    private func deleteSillyWormsOneByOne(_ index: Int) {
        if index < numberOfFinishedWorms {
            run(.wait(forDuration: 0.2)) {
                self.run(SKAction.playSoundFileNamed("bling.wav", waitForCompletion: false))
                self.score += self.level
                self.sillyWorms[index].removeFromParent()
                self.deleteSillyWormsOneByOne(index + 1)
            }
        } else {
            sillyWorms = []
            finishLine = Array(repeating: false, count: GameSettings.numberOfColumns)
            numberOfFinishedWorms = 0
            run(.wait(forDuration: 1)) {
                self.heartBeat(message: "Level completed!", count: 3) {
                    self.heartBeatLabel.removeFromParent()
                    self.level += 1
                    self.generateSillyWorms()
                }
            }
        }
    }
    
    private func yIndex2rowIndex(_ yIndex: Int) -> Int {
        return Int((yIndex - 1) / GameSettings.numberOfRowsInMovingRow)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isGameOver {
            if let touchLocation = touches.first?.location(in: self) {
                if nodes(at: touchLocation).first?.name == "pauseButton" {
                    if isPaused {
                        for sillyWorm in sillyWorms { sillyWorm.isHidden = false }
                        if gem != nil { gem.isHidden = false }
                        self.isPaused = false
                        var pausedLabelChildren = [SKNode]()
                        for child in self.children {
                            if child.name == "pausedLabel" {
                                pausedLabelChildren.append(child)
                            }
                        }
                        for child in pausedLabelChildren {
                            child.removeFromParent() // to handle enter from bacground while paused
                        }
                        run(.fadeAlpha(to: 1.0, duration: 0.1))
                        run(.playSoundFileNamed("bip", waitForCompletion: false))
                    } else {
                        for sillyWorm in sillyWorms { sillyWorm.isHidden = true }
                        if gem != nil { gem.isHidden = true }
                        run(.playSoundFileNamed("bip", waitForCompletion: false))
                        run(.fadeAlpha(to: 0.5, duration: 0.1)) {
                            self.pausedLabel = SKLabelNode(text: "Game Paused")
                            self.pausedLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                            self.pausedLabel.fontSize = self.size.height / 20
                            self.pausedLabel.fontColor = .red
                            self.pausedLabel.fontName = "GillSans-Bold"
                            self.pausedLabel.zPosition = 1
                            self.pausedLabel.name = "pausedLabel"
                            self.addChild(self.pausedLabel)
                            self.isPaused = true
                        }
                    }
                } else if touchLocation.y >= bottomOffsetHeight && touchLocation.y < bottomOffsetHeight + self.size.width {
                    if !isPaused {
                        let moveAmount = touchLocation.x < self.frame.midX ? -1 : 1
                        let moveIndex = Int((touchLocation.y - bottomOffsetHeight) / rowHeight)
                        let numCol = GameSettings.numberOfColumns
                        let numRow = GameSettings.numberOfRowsInMovingRow
                        pathLocationArrays[moveIndex] = pathLocationArrays[moveIndex].map {
                            ($0 + moveAmount + GameSettings.numberOfColumns) % GameSettings.numberOfColumns
                        }
                        for sillyWorm in sillyWorms {
                            if ((numRow * moveIndex + 1 )...(numRow * moveIndex + numRow)).contains(sillyWorm.yIndex) {
                                sillyWorm.xIndex = (sillyWorm.xIndex + moveAmount + numCol) % numCol
                            }
                        }
                        if moveIndex==1 && gem != nil {
                            gem.xIndex = (gem.xIndex + moveAmount + numCol) % numCol
                        }
                    }
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node != nil && contact.bodyB.node != nil {
            if contact.bodyA.categoryBitMask == GameSettings.wormPhysicsCategory &&
                contact.bodyB.categoryBitMask == GameSettings.gemPhysicsCategory {
                run(SKAction.playSoundFileNamed("bling.wav", waitForCompletion: false))
                contact.bodyB.node?.removeFromParent()
                score += level
            } else if contact.bodyA.categoryBitMask == GameSettings.gemPhysicsCategory &&
                contact.bodyB.categoryBitMask == GameSettings.wormPhysicsCategory {
                run(SKAction.playSoundFileNamed("bling.wav", waitForCompletion: false))
                contact.bodyA.node?.removeFromParent()
                score += level
            }
        }
    }
}
