//
//  GameViewController.swift
//  Project20
//
//  Created by mac on 23.06.2025.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Слухає потрясіння пристрою (shake gesture)
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        
        // Перевіряє, чи view є SKView (а не звичайний UIView).
        guard let skView = view as? SKView else { return }
        
        // Перевіряє, чи scene — це саме твоя GameScene.
        guard let gameScene = skView.scene as? GameScene else { return }
        
        // викликає вибухи
        gameScene.explodeFireworks()
    }
}
