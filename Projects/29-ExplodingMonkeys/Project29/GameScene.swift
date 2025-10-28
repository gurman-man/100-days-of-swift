//
//  GameScene.swift
//
//  Challenge_29

import SpriteKit

// MARK: - Collision Types
/// Бітові маски для системи фізики.
enum CollisionTypes: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
}


// MARK: - Game Scene
class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Scene state
    var buildings = [BuildingNode]()                // Масив згенерованих будівель
    weak var viewController: GameViewController?    // Посилання на контролер для керування UI
    var currentPlayer = 1                           // 1 — хід першого гравця, 2 — другого
    var isGameOver = false
    
    
    // MARK: - Nodes
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var windLabel: SKLabelNode!
    
    // Environment
    var windValue: Double = 0.0                     // змінна для сили вітру
    
    // Score
    var player1Score = 0 {
        didSet {
            updateScoreLabel()
            if player1Score == 3 {
                endGame(winner: "Player 1")
            }
        }
    }
    
    var player2Score = 0 {
        didSet {
            updateScoreLabel()
            if player2Score == 3 {
                endGame(winner: "Player 2")
            }
        }
    }
    
    
    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        setupScene()
    }
    
    
    // MARK: - Setup
    private func setupScene() {
        // Нічне небо (темно-синій відтінок)
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        // hue — тон, saturation — насиченість, brightness — яскравість, alpha — прозорість
        
        physicsWorld.contactDelegate = self // Підписуємося на події зіткнень ДО створення тіл
        
        windValue = Double.random(in: -3.00...3.00)
        physicsWorld.gravity = CGVector(dx: windValue, dy: -9.8)
        
        createBuildings()
        createPlayers()
        createLabels()
        updateWindLabel()
    }
    
    
    // MARK: - World generation
    /// Генерує ряд будівель різної ширини та висоти, що заповнюють ширину сцени.
    func createBuildings() {
        var currentX: CGFloat = -15     // Починаємо трохи за лівою межею сцени, щоб не було прогалин
        
        while currentX < 1024 {         // генеруємо будівлі, поки не заповнимо ширину сцени
            let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))
            
            currentX += size.width + 2  // Невеликий зазор між будівлями
            
            // Створюємо спрайт-будівлю з плейсхолдерним кольором (фактура накладеться далі)
            let building = BuildingNode(color: .red, size: size)
            
            // Центр будівлі в середині, тому ставимо базуючись на половині ширини/висоти
            building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)
            
            building.setup()            // Малюємо фасад та надаємо фізику за контуром текстури
            
            addChild(building)
            buildings.append(building)
        }
    }
    
    
    // MARK: - Player Setup
    /// Розміщує двох гравців на другій та передостанній будівлях і налаштовує їхню фізику.
    private func createPlayers() {
        player1 = createPlayer(named: "player1", on: buildings[1])
        player2 = createPlayer(named: "player2", on: buildings[buildings.count - 2])
    }
    
    private func createPlayer(named name: String, on building: BuildingNode) -> SKSpriteNode {
        let player = SKSpriteNode(imageNamed: "player")
        player.name = name
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.isDynamic = false                                    // стоїть, не падає
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue    // стикається з бананом
        player.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue  // відслідковує удар бананом
        
        player.position = CGPoint(
            x: building.position.x,
            y: building.position.y + (building.size.height + player.size.height) / 2
        )
        
        addChild(player)
        return player
    }
    
    
    // MARK: - Labels
    private func createLabels() {
        func makeLabel(text: String, y: CGFloat) -> SKLabelNode {
            let label = SKLabelNode(fontNamed: "Courier")
            label.text = text
            label.horizontalAlignmentMode = .right
            label.verticalAlignmentMode = .top
            label.fontSize = 18
            label.zPosition = 100
            label.position = CGPoint(x: 1014, y: y)
            addChild(label)
            return label
        }
        scoreLabel = makeLabel(text: "P1: 0   P2: 0", y: 748)
        windLabel = makeLabel(text: "Wind: \(String(format: "%.1f", windValue))", y: 700)
    }
    
    
    // MARK: - Launching
    
    /// Перетворення градусів у радіани
    func deg2rad(degrees: Int) -> Double {
        return Double(degrees) * .pi / 180
    }
    
    
    func launch(angle: Int, velocity: Int) {
        // 1. З'ясуйте, як важко кинути банан.
        let speed = Double(velocity) / 10
        
        // 2) Кут у радіанах
        let radians = deg2rad(degrees: angle)
        
        // 3) Якщо попередній банан ще живий — прибираємо його
        banana?.removeFromParent()
        
        // 4) Створюємо новий банан з круглим тілом
        banana = SKSpriteNode(imageNamed: "banana")
        guard let banana = banana else { return }
        
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody?.categoryBitMask = CollisionTypes.banana.rawValue
        banana.physicsBody?.collisionBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody?.contactTestBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody?.usesPreciseCollisionDetection = true
        addChild(banana)
        
        // 5) Позиціонування, анімація руки та імпульс залежно від гравця
        if currentPlayer == 1 {
            // Трохи лівіше та вище від гравця 1; обертання проти годинникової
            banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            banana.physicsBody?.angularVelocity = -20 // швидкість обертання
            
            // Анімуємо кидок гравця 1
            animateThrow(for: player1)
            
            // Змусьте банан рухатися в правильному напрямку.
            let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        } else {
            banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
            banana.physicsBody?.angularVelocity = 20
            
            // Анімуємо кидок гравця 2
            animateThrow(for: player2)
            
            let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        }
    }
    
    
    // Анімуємо гравця, який підкидає руку вгору, а потім знову кладе її вниз
    private func animateThrow(for player: SKSpriteNode) {
        let name = player.name ?? ""
        let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "\(name)Throw"))
        let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
        let pause = SKAction.wait(forDuration: 0.15)
        let seq = SKAction.sequence([raiseArm, pause, lowerArm])
        player.run(seq)
    }
    
    
    // MARK: - Contacts & collisions
    func didBegin(_ contact: SKPhysicsContact) {
        // SpriteKit гарантує лише наявність двох тіл; впорядкуємо їх за маскою, щоб спростити умови
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // Банан врізається в будівлю — «вирізаємо» дірку і передаємо хід
        guard let firstNode = firstBody.node else { return }
        guard let secondNode = secondBody.node else { return }
        
        // Влучання по гравцю завершує раунд і перезавантажує сцену
        if firstNode.name == "banana" && secondNode.name == "building" {
            bananaHit(building: secondNode, atPoint: contact.contactPoint)
        }
        
        if firstNode.name == "banana" && secondNode.name == "player1" {
            destroy(player: player1)
            player2Score += 1
        }
        
        if firstNode.name == "banana" && secondNode.name == "player2" {
            destroy(player: player2)
            player1Score += 1
        }
        scoreLabel?.text = "P1: \(player1Score)   P2: \(player2Score)"
    }
    
    
    // MARK: - Destroy
    /// Ефект вибуху, видалення гравця, підготовка нової сцени та передача ходу.
    func destroy(player: SKSpriteNode) {
        if let explosion = SKEmitterNode(fileNamed: "hitPlayer") {
            explosion.position = player.position
            addChild(explosion)
        }
        
        player.removeFromParent()
        banana.removeFromParent()
        
        // Через 2 секунди плавно відкриваємо нову сцену і передаємо хід іншому гравцю
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.restartScene()
        }
    }
    
    
    private func restartScene() {
        let newGame = GameScene(size: size)
        newGame.viewController = viewController
        newGame.currentPlayer = (currentPlayer == 1) ? 2 : 1
        newGame.player1Score = player1Score
        newGame.player2Score = player2Score
        
        viewController?.currentGame = newGame
        let transition = SKTransition.crossFade(withDuration: 1.5)  // метод виконує зміну сцени з ефектом
        view?.presentScene(newGame, transition: transition)
        
        // 🔥 після завантаження сцени — онови UI
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak newGame] in
            newGame?.viewController?.activatePlayer(number: newGame?.currentPlayer ?? 1)
        }
    }
    
    
    /// Обробка попадання банана в будівлю: «вирізаємо» дірку у текстурі та змінюємо гравця.
    func bananaHit(building: SKNode, atPoint contactPoint: CGPoint) {
        guard let building = building as? BuildingNode else { return }
        
        // Перетворюємо глобальну точку зіткнення у локальні координати будівлі
        let buildingLocation = convert(contactPoint, to: building)
        building.hit(at: buildingLocation)
        
        if let exposion = SKEmitterNode(fileNamed: "hitBuilding") {
            exposion.position = contactPoint
            addChild(exposion)
        }
        banana.removeFromParent()
        banana = nil
        changePlayer()
    }
    
    
    // MARK: - Player Switching
    func changePlayer() {
        currentPlayer = (currentPlayer == 1) ? 2 : 1
        viewController?.activatePlayer(number: currentPlayer)
    }
    
    
    // MARK: - Frame updates
    /// Якщо банан «вилетів» далеко за межі екрану — прибираємо його та передаємо хід
    override func update(_ currentTime: TimeInterval) {
        guard banana != nil else { return }
        
        if abs(banana.position.y) > 1000 {
            banana.removeFromParent()
            banana = nil
            changePlayer()
        }
    }
    
    
    // MARK: - Labels Update
    private func updateScoreLabel() {
        scoreLabel?.text = "P1: \(player1Score)   P2: \(player2Score)"
    }
    
    
    // Оновлення напрямку вітру
    private func updateWindLabel() {
        let wind = String(format: "%.1f", windValue)
        windLabel?.text = (-0.2...0.2).contains(windValue)
        ? "Wind: Calm \(wind)"
        : "Wind: \(windValue > 0 ? "-> RIGHT" : "<- LEFT") \(wind)"
    }
    
    
    // MARK: - Game Over
    private func endGame(winner: String) {
        guard !isGameOver else { return } // щоб не дублювалось
        isGameOver = true
        showOverlay(with: winner)
    }
    
    
    private func showOverlay(with winner: String) {
        // 🔥 Створюємо прозорий чорний фон на весь екран
        let overlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.6),
                                   size: self.size)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 100
        overlay.alpha = 0 // спочатку невидимий
        addChild(overlay)
        
        // Плавна поява фону
        overlay.run(.fadeIn(withDuration: 0.5))
        
        // 🔥 Текст переможця
        let label = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        label.text = "\(winner) wins!"
        label.fontSize = 60
        label.fontColor = .systemOrange
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.zPosition = 200
        label.alpha = 0 // спочатку теж невидимий
        
        overlay.addChild(label)
        
        // Анімація для тексту
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let pulse = SKAction.repeatForever(.sequence([
            .scale(to: 1.2, duration: 0.5),
            .scale(to: 1.0, duration: 0.5)
        ]))
        
        label.run(.sequence([.wait(forDuration: 0.5), fadeIn, .run { label.run(pulse) }]))
        
        // Через 2 секунди прибираємо анімацію і стартуємо нову гру
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.resetGame()
        }
    }
    
    
    private func resetGame() {
        let newGame = GameScene(size: size)
        newGame.viewController = viewController
        newGame.player1Score = 0
        newGame.player2Score = 0
        newGame.currentPlayer = 1  // нова гра завжди починає з першого гравця
        viewController?.currentGame = newGame
        view?.presentScene(newGame, transition: .fade(withDuration: 0.5))
        
        // 🔥 відновлюємо UI після перезапуску
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak newGame] in
            newGame?.viewController?.activatePlayer(number: 1)
        }
    }
}
