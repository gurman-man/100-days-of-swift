//
//  GameViewController.swift
//  Project29
//
//  Created by mac on 16.08.2025.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    var currentGame: GameScene?
    
    // MARK: - IBOutlets (UI)
    @IBOutlet var angleSlider: UISlider!
    @IBOutlet var angleLabel: UILabel!
    
    @IBOutlet var velocitySlider: UISlider!
    @IBOutlet var velocityLabel: UILabel!
    
    @IBOutlet var launchButton: UIButton!
    @IBOutlet var playerNumber: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let skView = self.view as? SKView else { return }
        
        // Створюємо сцену програмно
        let scene = GameScene(size: CGSize(width: 1024, height: 768))
        scene.scaleMode = .aspectFill
        scene.viewController = self    // підключаємо контролер до сцени
        
        // Встановлюємо як поточну гру
        currentGame = scene
        
        // Відображаємо сцену
        skView.presentScene(scene)
        
        // Параметри дебагу (FPS / кількість нод)
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        // Синхронізуємо текст лейблів зі стартовими значеннями слайдерів
        angleChanged(self)
        velocityChanged(self)
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
    
    // оновлюють правильний ярлик з поточним значенням повзунка.
    @IBAction func angleChanged(_ sender: Any) {
        angleLabel.text = "Angle: \(Int(angleSlider.value))°"
    }
    
    // оновлюють правильний ярлик з поточним значенням повзунка.
    @IBAction func velocityChanged(_ sender: Any) {
        velocityLabel.text = "Velocity: \(Int(velocitySlider.value))"
    }
    
    // Запуск банана
    @IBAction func launch(_ sender: Any) {
        // ховаємо UI
        angleSlider.isHidden = true
        angleLabel.isHidden = true
        
        velocitySlider.isHidden = true
        velocityLabel.isHidden = true
        
        launchButton.isHidden = true
        
        // запускаємо постріл у GameScene
        currentGame?.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value))
        
        
    }
    
    
    // Перемикання гравця
    func activatePlayer(number: Int) {
        if number == 1 {
            playerNumber.text = "<<< PLAYER ONE"
        } else {
            playerNumber.text = "PLAYER TWO >>>"
        }
        
        // показуємо елементи управління
        angleSlider.isHidden = false
        angleLabel.isHidden = false
        
        velocitySlider.isHidden = false
        velocityLabel.isHidden = false
        
        launchButton.isHidden = false
    }
}
