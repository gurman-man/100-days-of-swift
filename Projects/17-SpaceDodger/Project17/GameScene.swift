//
//  GameScene.swift
//  Project17
//
//  Created by mac on 10.06.2025.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var healthLabel: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    var restartLabel: SKLabelNode!
    
    var health = 4
    var isGameOver = false
    var isTouching = false
    var countEnemy = 0
    var enemySpeedUpStep = 0.1
    var possibleEnemies = ["ball", "hammer", "tv"]
    
    // Таймер, який регулярно викликає функцію для створення ворогів (createEnemy)
    var gameTimer: Timer?
    //  Використовується для контролю частоти оновлення рахунку у
    var lastScoreUpdateTime: TimeInterval = 0
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        starfield = SKEmitterNode(fileNamed: "starfield")!
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10) // одразу з’являється багато зірок
        addChild(starfield)
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        
        player.physicsBody?.angularVelocity = 0
        player.physicsBody?.angularDamping = 0
        
        //  створює фізичне тіло, тобто додає йому форму для взаємодії з іншими об'єктами
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        
        player.physicsBody?.categoryBitMask = 2  // для гравця
        player.physicsBody?.contactTestBitMask = 1 // вороги мають 1, дивись далі
        
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 36)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        healthLabel = SKLabelNode(fontNamed: "Chalkduster")
        healthLabel.name = "healthLabel"
        healthLabel.position = CGPoint(x: 900, y: 36)
        healthLabel.horizontalAlignmentMode = .right
        healthLabel.zPosition = 1
        addChild(healthLabel)
        
        updateHealthLabel()
        score = 0
        
        physicsWorld.gravity = .zero // відсутність гравітації
        physicsWorld.contactDelegate = self
        
        // Запускає таймер, який кожні 1 секунди створює нового ворога
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    
    // MARK: - Enemy
    // Метод, який створює нового ворога:
    @objc func createEnemy() {
        guard !isGameOver else { return }
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        //  З’являється справа, на випадковій висоті
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        
        sprite.physicsBody?.categoryBitMask = 1 // вороги
        sprite.physicsBody?.contactTestBitMask = 2 // щоб виявити зіткнення з гравцем
        
        //  Рухається вліво зі швидкістю -500
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        
        // додає певне обертання спрайта
        sprite.physicsBody?.angularVelocity = 5
        
        // Не гальмує з часом — завжди рухається з тією ж швидкістю
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        
        countEnemy += 1
        
        if countEnemy % 20 == 0 {
            // Зупиняє попередній таймер
            gameTimer?.invalidate()
            let newInterval = max(0.2, 1 - enemySpeedUpStep)
            gameTimer = Timer.scheduledTimer(timeInterval: newInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
            enemySpeedUpStep += 0.1
        }
    }
    
    
    //  Викликається один раз у кожному кадрі і дозволяє нам вносити зміни у гру
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
            
            if !isGameOver {
                if currentTime - lastScoreUpdateTime > 0.5 {
                    score += 1
                    lastScoreUpdateTime = currentTime
                }
            }
        }
    }
    
    
    // MARK: - Touches
    // Коли гравець доторкається екрану, ми ставимо прапорець
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = true
        if isGameOver {
            if let touch = touches.first {
                let location = touch.location(in: self)
                let tappedNodes = nodes(at: location)
                
                for node in tappedNodes {
                    if node.name == "restartLabel" {
                        restartGame()
                    }
                }
            }
        } else {
            isTouching = true
        }
    }
    
    // Гравець веде палець по екрану (touchesMoved)
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if location.y < 100 { location.y = 100 }
        if location.y > 668 { location.y = 668 }
        
        player.position = location
    }
    
    // Коли палець підняли (touchesEnded) — ми говоримо - не рухай його!
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false
    }
    
    
    // MARK: - Physics
    // Коли ракета стикається з ворогом:
    func didBegin(_ contact: SKPhysicsContact) {
        if isGameOver { return }
        
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        // Перевірка, чи гравець та ворог зіткнулися
        if (bodyA.categoryBitMask == 2 && bodyB.categoryBitMask == 1) ||
            (bodyA.categoryBitMask == 1 && bodyB.categoryBitMask == 2) {
            
            // Запобігаємо повторним втратам HP поки діє невразливість
            guard player.alpha == 1 else { return }
            
            // Тимчасова "невразливість"
            player.alpha = 0.4
            let invincible = SKAction.sequence([
                SKAction.wait(forDuration: 0.8),
                SKAction.fadeAlpha(to: 1, duration: 0.3)
            ])
            player.run(invincible)
            
            health -= 1
            updateHealthLabel()
            
            if health <= 0 {
                let explosion = SKEmitterNode(fileNamed: "explosion")!
                explosion.position = player.position
                addChild(explosion)
                
                player.removeFromParent()
                isGameOver = true
                gameTimer?.invalidate() // ⬅️ Зупиняємо створення нових ворогів
                
                // Плавна поява Game Over
                run(SKAction.sequence([
                    SKAction.wait(forDuration: 0.5),
                    SKAction.run { self.showGameOver() }
                ]))
                
                remove(object: explosion)
            }
        }
    }
    
    
    // MARK: - Helpers
    func updateHealthLabel() {
        if let healthLabel = childNode(withName: "healthLabel") as? SKLabelNode {
            let safeHealth = max(0, health)
            let hearts = safeHealth > 0 ? String(repeating: "❤️", count: safeHealth) : "💀"
            healthLabel.text = "HP: \(hearts)"
        }
    }
    
    func remove(object: SKNode) {
        let wait = SKAction.wait(forDuration: 1)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([wait, remove])
        
        object.run(sequence)
    }
    
    func restartGame() {
        // Прибираємо всі поточні елементи
        removeAllChildren()
        removeAllActions()
        
        // Скидаємо стани
        isGameOver = false
        health = 3
        score = 0
        countEnemy = 0
        enemySpeedUpStep = 0.1
        
        // Перезапускаємо сцену з плавним переходом
        let newScene = GameScene(size: size)
        newScene.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration: 1)
        view?.presentScene(newScene, transition: transition)
    }
    
    func showGameOver() {
        // Затемнення фону
        let overlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.5), size: self.size)
        overlay.position = CGPoint(x: frame.midX, y: frame.midY)
        overlay.zPosition = 9
        overlay.alpha = 0
        addChild(overlay)
        
        overlay.run(SKAction.fadeIn(withDuration: 1.0))
        
        // Створюємо надпис
        gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 60
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY + 50)
        gameOverLabel.zPosition = 10
        gameOverLabel.name = "gameOverLabel"
        addChild(gameOverLabel)
        
        let fadeIn = SKAction.fadeIn(withDuration: 1)
        let appear = SKAction.sequence([fadeIn])
        gameOverLabel.run(appear)
        
        // Створюємо кнопку Restart
        restartLabel = SKLabelNode(fontNamed: "Chalkduster")
        restartLabel.text = "Tap to Restart"
        restartLabel.fontSize = 40
        restartLabel.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        restartLabel.zPosition = 10
        restartLabel.name = "restartLabel"
        addChild(restartLabel)
        
        // Плавна поява після Game Over
        let scaleUp = SKAction.scale(to: 1, duration: 0.6)
        let scaleDown = SKAction.scale(to: 0.5, duration: 0.2)
        let appear2 = SKAction.sequence([scaleUp, scaleDown, scaleUp])
        restartLabel.run(appear2)
    }
}
