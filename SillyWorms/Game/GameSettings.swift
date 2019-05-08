//
//  GameSettings.swift
//  SillyWorms
//
//  Created by Adnan Baysal on 5.05.2019.
//  Copyright © 2019 Adnan Baysal. All rights reserved.
//

import UIKit

struct GameSettings {
    
    static let pauseButtonHeight: CGFloat = 30
    static let numberOfRowsInMovingRow: Int = 4
    static let gemSpawnYIndex: Int = 11
    static let gemFillColor = UIColor.green
    static let gemStrokeColor = UIColor.white
    static let wormPhysicsCategory: UInt32 = 0x1
    static let gemPhysicsCategory: UInt32 = 0x2
    static let blinkRepetition = 3
    static let numberOfRows: Int = 3
    static let numberOfColumns: Int = 12
    static let level1BlinkDuration: TimeInterval = 6
    static let level1MoveDuration: TimeInterval = 2
    static let level1SpawnTime: TimeInterval = 16
    static let bornAreaColor = UIColor(red: 0.8, green: 0.5, blue: 0.5, alpha: 1.0)
    static let scoreLabelOffset = CGPoint(x: 10, y: 10)
    static let backgroundColor = UIColor.black 
    static let levelLabelOffset = CGPoint(x: 5, y: 10)
    static let fillBarColor = UIColor(red: 0.5, green: 0.8, blue: 0.5, alpha: 1.0)
    static let sillyWormImageNames: [String] = [
        "sillywormblue",
        "sillywormbw",
        "sillywormgray",
        "sillywormgreen",
        "sillywormorange",
        "sillywormpink",
        "sillywormpurple",
        "sillywormred",
        "sillywormtan",
        "sillywormyellow"
    ]
    static let rowImages: [String] = ["brickDark", "brickLight", "brickDark"]
    static let pathImage = "soil"
    
    static func timeAt(level: Int, initial time: TimeInterval) -> TimeInterval {
        return time / sqrt(TimeInterval(level))
    }
}
