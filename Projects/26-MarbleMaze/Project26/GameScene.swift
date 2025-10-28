//
//  GameScene.swift
//  Project26
//
//  Created by mac on 27.07.2025.
//

import SpriteKit
import CoreMotion

//  Унікальні біти для кожного типу об'єкта, з яким можливі зіткнення
enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
    case teleport = 32
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: SKSpriteNode!
    var motionManager: CMMotionManager!     // Це штука, яка слухає, як ти нахиляєш телефон
    var lastTouchPosition: CGPoint?         // Зберігає точку, де ти останній раз торкався екрану
    var isGameOver = false
    var justTeleported = false
    
    var levels = Levels()
    let maxLevel = 3
    var currentLevel = 1
    
    // Labels
    var scoreLabel: SKLabelNode!
    var currentLevelLabel: SKLabelNode!
    var nextLevelLabel: SKLabelNode!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    
    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        setupBackground()
        setupLabels()
        setupPhysics()
        setupMotion()
        
        score = UserDefaults.standard.integer(forKey: "score")
        currentLevel = UserDefaults.standard.integer(forKey: "currentLevel")
        if currentLevel == 0 { currentLevel = 1 } // якщо ще не збережено
        loadLevel()
        createPlayer()
    }
    
    func setupBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
    }
    
    func setupLabels() {
        scoreLabel = createLabel(text: "Score: 0", position: CGPoint(x: 16, y: 16), alignment: .left)
        addChild(scoreLabel)
        
        currentLevelLabel = createLabel(text: "Level: \(currentLevel)", position: CGPoint(x: 512, y: 720))
        addChild(currentLevelLabel)
        
        nextLevelLabel = createLabel(text: "", position: CGPoint(x: 512, y: 680))
        addChild(nextLevelLabel)
    }
    
    func createLabel(text: String, position: CGPoint, alignment: SKLabelHorizontalAlignmentMode = .center) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = text
        label.fontSize = 32
        label.horizontalAlignmentMode = alignment
        label.position = position
        label.zPosition = 2
        return label
    }
    
    func setupPhysics() {
        physicsWorld.gravity =  .zero
        physicsWorld.contactDelegate = self     // Це каже SpriteKit: «коли щось зіткнеться — скажи мені, я розберусь»
    }
    
    func setupMotion() {
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
    }
    
    
    // MARK: - Level Loading
    //  Цей метод завантажує файл рівня з диска
    func loadLevel() {
        
        // Шукаємо наш рівень у системі
        guard let levelURL = Bundle.main.url(forResource: "level\(currentLevel)", withExtension: "txt") else {
            fatalError("Could not find level\(currentLevel).txt in the app bundle.")
        }
        
        // Зчитує його вміст як рядки
        guard let levelString = try? String(contentsOf: levelURL, encoding: .utf8) else {
            fatalError("Could not find level1.txt in the app bundle.")
            // .utf8 — це найпоширеніше кодування тексту, і 99% ймовірності, що твій .txt збережений саме в цьому форматі.
        }
        
        let lines = levelString.components(separatedBy: "\n")
        
        // Ти перевертаєш масив .reversed() бо SpriteKit малює сцену знизу вгору (а ти хочеш, щоб верхня лінія в тексті була верхом екрану).
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
                
                if let node = createObjects(for: letter, at: position) {
                    addChild(node)
                }
            }
        }
        
        currentLevelLabel.text = "Level: \(currentLevel)"
    }
    
    
    // MARK: - Object Creation
    // Створення перешкод, зірок та кубку
    func createObjects(for letter: Character, at position: CGPoint) -> SKNode? {
        switch letter {
        case "x":
            // load wall
            let node = SKSpriteNode(imageNamed: "block")
            node.position = position
            node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
            node.physicsBody?.isDynamic = false
            
            node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue    // ? rawValue
            return node
            
        case "v": return createVortex(at: position)
        case "s": return createStar(at: position)
        case "t": return createTeleport(at: position)
        case "f": return createFinish(at: position)
        case " ": return nil
        default: fatalError("Unknown level letter: \(letter)")
        }
    }
    
    func createVortex(at position: CGPoint) -> SKNode {
        let node = SKSpriteNode(imageNamed: "vortex")
        node.name = "vortex"
        node.position = position
        
        //  щоб кожен вихор обертався навколо себе протягом усього часу гри
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
        
        // означає, що ми хочемо отримувати повідомлення, коли ці два елементи стикаються
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        // Не взаємодіє фізично
        node.physicsBody?.collisionBitMask = 0
        return node
    }
    
    func createStar(at position: CGPoint) -> SKNode {
        let node = SKSpriteNode(imageNamed: "star")
        node.name = "star"
        node.position = position
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        return node
    }
    
    func createTeleport(at position: CGPoint) -> SKNode {
        let node = SKSpriteNode(imageNamed: "teleport")
        node.name = "teleport"
        node.position = position
        
        node.color = .cyan
        node.colorBlendFactor = 0.6
        
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.teleport.rawValue
        // означає, що ми хочемо отримувати повідомлення, коли ці два елементи стикаються
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        // Не взаємодіє фізично
        node.physicsBody?.collisionBitMask = 0
        return node
    }
    
    func createFinish(at position: CGPoint) -> SKNode {
        let node = SKSpriteNode(imageNamed: "finish")
        node.name = "finish"
        node.position = position
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        return node
    }
    
    
    // MARK: - Player
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 96, y: 672)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.zPosition = 1
        
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5
        
        //  Маски зіткнень
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue   |
            CollisionTypes.vortex.rawValue |
            CollisionTypes.finish.rawValue |
            CollisionTypes.teleport.rawValue
        
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        
        addChild(player)
    }
    
    
    // MARK: - Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { lastTouchPosition = touches.first?.location(in: self) }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) { lastTouchPosition = touches.first?.location(in: self) }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { lastTouchPosition = nil }
    
    
    // MARK: - Update Loop
    //  Рух гравця
    override func update(_ currentTime: TimeInterval) {
        guard isGameOver == false else { return }
    //  "якщо ми в симуляторі — використовуй дотик"
    #if targetEnvironment(simulator)
        if let currentTouch = lastTouchPosition {
            //  Це створює ефект гравітації в напрямку до торкання гравцем
            let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
            // Гравітація спрямована в бік дотику
            // Поділення на 100 — це просто для зменшення сили, щоб не летіло занадто швидко
            physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
        }
    #else
        // На реальному пристрої
        // Безпечно розгортає додаткові дані акселерометра, оскільки їх може не бути доступних
        if let accelerometerData = motionManager.accelerometerData {
            // Змінює гравітацію нашого ігрового світу так, що вона відображає дані акселерометра
            // Ти множиш на 60 — щоб рух був чутливішим
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -60, dy: accelerometerData.acceleration.x * 60)
        }
    #endif
    }
    
    
    // MARK: - Collisions
    //  Метод автоматично викликається коли гравець щось торкнувся.
    func didBegin(_ contact: SKPhysicsContact) {
        //  перевіряємо, об'єкт взагалі існує
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        // перевіряємо: хто з об’єктів був гравцем, а хто – ні
        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }
    
    
    // Обробляє результат: втягування у вихор, збір зірок, перехід до фінішу
    func playerCollided(with node: SKNode) {
        switch node.name {
        case "vortex": handleVortexCollision(node)
        case "star": handleStarCollision(node)
        case "teleport": handleTeleportCollision(node)
        case "finish": handleFinishCollision(node)
        default: break
        }
    }
    
    
    // MARK: - Collision Handlers
    // Обробка вихору
    private func handleVortexCollision(_ node: SKNode) {
        player.physicsBody?.isDynamic = false
        isGameOver = true
        score -= 1
        
        let sequence = SKAction.sequence([
            .move(to: node.position, duration: 0.25),
            .scale(to: 0.0001, duration: 0.25),
            .removeFromParent()
        ])
        
        player.run(sequence) { [weak self] in
            self?.createPlayer()
            self?.isGameOver = false
        }
    }
    
    
    // 🌟 Збір зірки
    private func handleStarCollision(_ node: SKNode) {
        node.removeFromParent()
        score += 1
    }
    
    
    // Обробка телепорту
    private func handleTeleportCollision(_ node: SKNode) {
        // 1. Знаходимо всі інші телепорти
        let otherTeleports = children.filter {
            $0.name == "teleport" && $0 != node
        }
        
        guard let destination = otherTeleports.first else { return }
        guard !justTeleported else { return }
        
        justTeleported = true
        // 2. Вимикаємо фізику на час переміщення
        player.physicsBody?.isDynamic = false
        
        // 3. Створюємо анімацію телепорту
        let teleportSequence = SKAction.sequence([
            .scale(to: 0.1, duration: 0.2),
            .move(to: destination.position, duration: 0),
            .scale(to: 1.0, duration: 0.2)
        ])
        
        // 4. Виконуємо анімацію та повертаємо фізику
        player.run(teleportSequence) { [weak self] in
            self?.player.physicsBody?.isDynamic = true
            self?.player.physicsBody?.applyImpulse(CGVector(dx: 5, dy: 0))  // Додаємо поштовх, щоб вибити з зони телепорту
            
            // Дозволити новий телепорт через 0.5 с
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.justTeleported = false
            }
        }
    }
    
    // 🎉 Фініш — завершення рівня
    private func handleFinishCollision(_ node: SKNode){
        node.removeFromParent()
        showConfetti()
        showLevelCompleteLabel()
        
        if currentLevel < maxLevel {
            nextLevelLabel.text = "Next Level: \(currentLevel + 1)"
        } else {
            nextLevelLabel.text = "All levels complete!"
        }

        let wait = SKAction.wait(forDuration: 3)
        let cleanup = SKAction.run { [weak self] in
            self?.childNode(withName: "confetti")?.removeFromParent()
            self?.childNode(withName: "levelCompleteLabel")?.removeFromParent()
        }

        let next = SKAction.run { [weak self] in self?.advanceToNextLevel() }
        run(.sequence([wait, cleanup, next]))
    }


    // MARK: - Level Progression
    func advanceToNextLevel() {
        if currentLevel < maxLevel {
            currentLevel += 1
            score += 10
            UserDefaults.standard.set(score, forKey: "score")
            UserDefaults.standard.set(currentLevel, forKey: "currentLevel")
        } else {
            currentLevel = 1
            score = 0
            UserDefaults.standard.set(score, forKey: "score")
            UserDefaults.standard.set(currentLevel, forKey: "currentLevel")
        }

        if let newScene = GameScene(fileNamed: "GameScene") {
            newScene.scaleMode = .aspectFill
            newScene.currentLevel = currentLevel
            view?.presentScene(newScene, transition: .crossFade(withDuration: 1))
        }
    }
    
    // Налаштування нового Рівня
    func setupNextLevel() {
        removeAllChildren()
        setupBackground()
        setupLabels()
        setupPhysics()
        setupMotion()
        loadLevel()
        createPlayer()
    }
    
    
    // MARK: - UI Helpers
    // 🧨 Конфетті
    private func showConfetti() {
        guard let confetti = SKEmitterNode(fileNamed: "confetti") else { return }
        confetti.position = CGPoint(x: 512, y: 384)
        confetti.zPosition = 50
        confetti.name = "confetti"
        
        // Розкидає частинки по всій ширині екрана
        confetti.particlePositionRange = CGVector(dx: frame.width, dy: frame.height)
        addChild(confetti)
        
        confetti.run(SKAction.sequence([
            .wait(forDuration: 5),
            .removeFromParent()
        ]))
    }

    
    // 🪧 Напис “Level Complete!”
    private func showLevelCompleteLabel() {
        let label = SKLabelNode(text: "Level \(currentLevel) Complete!")
        label.fontSize = 48
        label.fontName = "AmericanTypewriter-Bold"
        label.fontColor = .yellow
        label.position = CGPoint(x: 512, y: 384)
        label.zPosition = 100
        label.alpha = 0
        label.name = "levelCompleteLabel"
        addChild(label)

        let appear = SKAction.group([
            .fadeIn(withDuration: 0.3),
            .scale(to: 1.2, duration: 0.3)
        ])
        label.run(appear)
    }
}
