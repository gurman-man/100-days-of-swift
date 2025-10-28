//
//  GameScene.swift
//  Project23
//
//  Created by mac on 11.07.2025.
//
import AVFoundation
import SpriteKit

// MARK: - Enums -
enum ForceBomb {
    case never, always, random
}

enum SequenceType: CaseIterable {
    case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain
}

class GameScene: SKScene {
    // MARK: - 🧩 Properties
    var gameOverTitle: SKLabelNode!
    var gameScore: SKLabelNode!
    var newGame: SKLabelNode!
    
    var score = 0 {
        didSet {
            gameScore.text = "Score \(score)"
        }
    }
    
    var livesImages = [SKSpriteNode]()
    var lives = 3
    var isGameEnded = false
    
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    
    var activeSlicePoints = [CGPoint]()
    var isSwooshSoundActive = false
    var activateEnemies = [SKSpriteNode]()
    var bombSoundEffect: AVAudioPlayer?  // Програвач звуку "запалювання бомби"
    
    var popupTime = 0.9                 // час очікування між знищенням останнього ворога та створенням нового
    var sequence = [SequenceType]()     // масив зчислення, який визначає, яких ворогів створювати
    var sequencePosition = 0            // місце, де ми зараз знаходимося у грі
    var chainDelay = 3.0                // час очікування перед створенням нового ворога, якщо тип послідовності має значення .chain або .fastChain.
    var nextSequenceQueued = true       //  щоб ми знали, коли всі вороги знищені і можна створювати нових.
    
    var enemyCallCount = 0              // лічильник - скільки ворогів було створено
    var goldenEnemyIsActive = false     // прапорець, лише для одного золотого пінгвіна
        
    // Константи для створення ворога
        
    /// Радіус фізичного тіла ворога (використовується для зіткнень та руху)
    let enemyRadius: CGFloat = 64

    /// Мінімальна кутова швидкість обертання ворога (обертається проти годинникової стрілки)
    let enemyMinAngularVelocity: CGFloat = -3

    /// Максимальна кутова швидкість обертання ворога (обертається за годинниковою стрілкою)
    let enemyMaxAngularVelocity: CGFloat = 3

    /// Мінімальна початкова X-позиція ворога на екрані (лівий край)
    let enemyMinXPosition = 64

    /// Максимальна початкова X-позиція ворога на екрані (правий край)
    let enemyMaxXPosition = 960

    /// Початкова Y-позиція ворога (нижче за екран — щоб підлітав знизу)
    let enemyStartYPosition = -128

    /// Мінімальна вертикальна швидкість ворога (Y) — як повільно підлітає вгору
    let enemyMinYVelocity = 24

    /// Максимальна вертикальна швидкість ворога (Y) — як швидко підлітає вгору
    let enemyMaxYVelocity = 32

    /// Горизонтальна швидкість ворогів, які зʼявляються зліва (рухаються вправо)
    let leftXVelocityRange = 8...15

    /// Горизонтальна швидкість ворогів, які зʼявляються ближче до центру ліворуч (повільніше вправо)
    let centerXVelocityRange = 3...5

    /// Горизонтальна швидкість ворогів, які зʼявляються ближче до центру праворуч (повільніше вліво)
    let centerRightXVelocityRange = -5 ... -3

    /// Горизонтальна швидкість ворогів, які зʼявляються праворуч (швидко летять вліво)
    let rightXVelocityRange = -15 ... -8


    // MARK: - 🎬 Scene Lifecycle
    override func didMove(to view: SKView) {
        isGameEnded = false   // скидаємо прапорець при старті сцени
        isUserInteractionEnabled = true
        
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)  // Гравітація направлена вниз
        physicsWorld.speed = 0.85   //  сповільнює фізичну симуляцію
        
        createScore()
        createLives()
        createSlices()
        
        sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]
        
        for _ in 0...1000 {
            if let nextSequence = SequenceType.allCases.randomElement() {
                sequence.append(nextSequence)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.tossEnemies()
        }
    }
    
    // MARK: - 🧱 UI Elements Setup
    func createScore() {
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 46
        addChild(gameScore)
        
        gameScore.position = CGPoint(x: 8, y: 8)
        score = 0
    }
    
    func createLives() {
        for i in 0 ..< 3 {
            let spiteNode = SKSpriteNode(imageNamed: "sliceLife")
            spiteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
            addChild(spiteNode)
            livesImages.append(spiteNode)
        }
    }
    
    func createSlices() {
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 3
        
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9
        
        activeSliceFG.strokeColor = .white
        activeSliceFG.lineWidth = 5
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }
    
    
    // MARK: - 🖐 Touch Handling
    
    // touchesBegan спрацьовує, коли користувач починає торкатись екрану
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        activeSlicePoints.removeAll(keepingCapacity: true)  // — очищаємо масив точок попереднього жесту
        
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        // Скасовуємо всі дії (анімації згасання), якщо юзер знову доторкнувся.
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        
        // Повністю показуємо лінії (alpha = 1), якщо вони були затемнені.
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
    }
    
    // Викликається щоразу, коли палець рухається по екрану
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isGameEnded == false else { return }
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice() // для оновлення траєкторії лінії розрізу
        
        //  Якщо звук "свушу" зараз не грає
        if !isSwooshSoundActive {
            playSwooshSound()
        }
        
        //  отримуємо усі ноди в точці, куди перемістився палець користувача
        let nodesAtPoint = nodes(at: location)
        
        // Цикл перебирає тільки об'єкти типу SKSpriteNode, ігноруючи інші типи нод
        for case let node as SKSpriteNode in nodesAtPoint {
            if node.name == "enemy" {
                // знищення пінгвіна
                
                if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
                    emitter.position = node.position
                    addChild(emitter)
                }
                
                node.name = ""
                node.physicsBody?.isDynamic = false                         // щоб тіло не падало
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])             // виконує одночасно
                
                let seq = SKAction.sequence([group, .removeFromParent()])   // виконує по черзі
                node.run(seq)
                
                score += 1
                
                
                if let index = activateEnemies.firstIndex(of: node) {
                    activateEnemies.remove(at: index)
                }
                
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            } else if node.name == "goldEnemy" {
                // знищення ЗОЛОТОГО пінгвіна
                
                if let emitter = SKEmitterNode(fileNamed: "sliceHitGold") {
                    emitter.position = node.position
                    addChild(emitter)
                }
                
                node.name = ""
                node.physicsBody?.isDynamic = false
                // швидко "спалахує" (збільшується),
                // Потім плавно зникає — виглядає яскраво та преміально
                let scaleUp = SKAction.scale(to: 1.3, duration: 0.05)
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let shrinkAndFade = SKAction.group([scaleOut, fadeOut])
                let seq = SKAction.sequence([scaleUp, shrinkAndFade, .removeFromParent()])
                node.run(seq)
                
                score += 5
                
                if let index = activateEnemies.firstIndex(of: node) {
                    activateEnemies.remove(at: index)
                }
                
                // Скидає прапорець, коли золотого пінгвіна знищено
                goldenEnemyIsActive = false
                
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                
            } else if node.name == "bomb" {
                // знищення бомби
                // Бомба — це вкладений спрайт, тож потрібно обробити контейнер
                guard let bombContainer = node.parent as? SKSpriteNode else { continue }
            
                if let emitter = SKEmitterNode(fileNamed: "sliceHitBomb") {
                    emitter.position = bombContainer.position
                    addChild(emitter)
                }
                
                node.name = ""
                bombContainer.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                let seq = SKAction.sequence([group, .removeFromParent()])
                bombContainer.run(seq)
                
                if let index = activateEnemies.firstIndex(of: bombContainer) {
                    activateEnemies.remove(at: index)
                }
                
                run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                endGame(triggeredByBomb: true)
            }
        }
    }
    
    // Коли палець піднято з екрана, виконуємо анімацію згасання (fade out) ліній
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Якщо натиснули на "New Game" після програшу
        if isGameEnded, let newGame = newGame, newGame.contains(location) {
            startNewGame()
        }
    }
    
    // MARK: - ✏️ Slice Drawing
    
    // Метод, який візуалізує рух пальця користувача у вигляді красивої лінії
    func redrawActiveSlice() {
        
        //  1. Якщо занадто мало точок — не малювати лінію:
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        
        //  2. Обмеження кількості точок:
        //  Щоб лінія не була нескінченною (і не знижувала продуктивність), зберігаємо лише останні 12 точок.
        if activeSlicePoints.count > 12 {
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
        }
        
        //  3. Побудова шляху:
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        
        //  4. Додаємо лінії між усіма точками:
        for i in 1 ..< activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        //   5. Присвоюємо побудований шлях двом лініям:
        activeSliceBG.path = path.cgPath    //  товстий жовтий слід
        activeSliceFG.path = path.cgPath    // тонкий білий
    }
    
    
    func playSwooshSound() {
        // Встановлюємо прапорець, що звук уже активний — це не дозволяє відтворювати багато звуків одночасно при швидкому русі.
        isSwooshSoundActive = true
        
        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"
        
        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true) // waitForCompletion: true -  звук має догратися до кінця перед скиданням прапорця
        
        // Запуск дії та скидання прапорця після завершення:
        run(swooshSound) { [weak self] in
            self?.isSwooshSoundActive = false
        }
    }
    
    
    // MARK: - 💣 Enemy Creation
    // Метод створює або пінгвіна, або бомбу, з випадковими параметрами руху
    func createEnemy(forceBomb: ForceBomb = .random) {
        enemyCallCount += 1
        
        let enemy: SKSpriteNode
        var enemyType = Int.random(in: 0...9)
        
        if forceBomb == .never {
            enemyType = 1                   // гарантовано пінгвін
        } else if forceBomb == .always {
            enemyType = 0                   // гарантовано бомба
        }
        
        // 💡 додай умову: якщо вже є золотий або ще не час — не створюй нового
        let shouldCreateGold = (enemyCallCount % 10 == 0 && goldenEnemyIsActive == false)
        
        if shouldCreateGold {
            // Ствлрення золотого пінгвіна
            enemy = SKSpriteNode(imageNamed: "penguin")
            enemy.color = .yellow
            enemy.colorBlendFactor = 1
            run(SKAction.playSoundFileNamed("goldSound.mp3", waitForCompletion: false))
            enemy.name = "goldEnemy"
            goldenEnemyIsActive = true
            
        } else if enemyType == 0 {
            //  Створення бомби
            enemy = SKSpriteNode()
            enemy.zPosition = 1             // Щоб не перекривався іншими спрайтами
            enemy.name = "bombContainer"
            
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"         // Дитина-картинка — сама бомба
            enemy.addChild(bombImage)
            
            //  Запуск звуку запалювання бомби
            if bombSoundEffect != nil {
                bombSoundEffect?.stop()
                bombSoundEffect = nil
            }
            
            if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
                if let sound = try? AVAudioPlayer(contentsOf: path) {
                    bombSoundEffect = sound
                    sound.play()            // Запускаємо новий звук
                }
            }
            
            //  Додати ефект іскор
            if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                emitter.position = CGPoint(x: 76, y: 64)
                enemy.addChild(emitter)
            }
        } else {
            // 🐧 Якщо не бомба — створюється пінгвін:
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemy"
        }
        
        //  🎲 Положення та фізика
        //  Задали ворогу випадкове положення біля нижнього краю екрана
        let randomPosition = CGPoint(x: Int.random(in: enemyMinXPosition...enemyMaxXPosition), y: enemyStartYPosition)
        enemy.position = randomPosition
        
        //  Створили випадкову кутову швидкість, яка є тим, як швидко щось має обертатися
        let randomAngularVelocity = CGFloat.random(in: enemyMinAngularVelocity...enemyMaxAngularVelocity)
        let randomXVelocity: Int
        
        //  Створили випадкову швидкість X (як далеко рухатися горизонтально), яка враховує позицію ворога
        if randomPosition.x < 256 {
            randomXVelocity = Int.random(in: leftXVelocityRange)
        } else if randomPosition.x < 512 {
            randomXVelocity = Int.random(in: centerXVelocityRange)
        } else if randomPosition.x < 768 {
            randomXVelocity = Int.random(in: centerRightXVelocityRange)
        } else {
            randomXVelocity = Int.random(in: rightXVelocityRange)
        }
        
        //  Створіть випадкову Y-швидкість лише для того, щоб речі літали з різною швидкістю
        // let randomYVelocity = Int.random(in: enemyMinYVelocity...enemyMaxYVelocity)
        let randomYVelocity = enemy.name == "goldEnemy" ? Int.random(in: 28...36) : Int.random(in: enemyMinYVelocity...enemyMaxYVelocity)

        
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemyRadius)
        enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * 40, dy: randomYVelocity * 40)
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask = 0     // не буде взаємодіяти з іншими фізичними тілами, тільки з гравітацією
        
        addChild(enemy)
        activateEnemies.append(enemy)
    }
    
    
    // Метод відповідає за викидання ворогів (пінгвінів або бомб) на екран
    func tossEnemies() {
        guard isGameEnded == false else { return }
        
        popupTime *= 0.991              // інтервал між викидами зменшується
        chainDelay *= 0.991             // затримка між ворогами в атаках теж скорочується
        physicsWorld.speed *= 1.02      // фізика гри пришвидшується на 2%
        
        let sequenceType = sequence[sequencePosition]
        //  Визначаємо, який тип послідовності ворогів використовувати.
        
        switch sequenceType {
        case .oneNoBomb:                        // один ворог, гарантовано не бомба
            createEnemy(forceBomb: .never)
            
        case .one:                              // один ворог, може бути бомбою або пінгвіном
            createEnemy()
        case .twoWithOneBomb:                   // два вороги — один з них обов’язково бомба
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)
        case .two:
            createEnemy()
            createEnemy()
        case .three:
            createEnemy()
            createEnemy()
            createEnemy()
        case .four:
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()
            
        case .chain:            // один ворог за іншим з невеликим інтервалом між запуском
            createEnemy()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 2)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 3)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 4)) { [weak self] in self?.createEnemy() }
        case .fastChain:        // вороги запускаються майже без пауз, дуже динамічно
            createEnemy()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 2)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 3)) { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 4)) { [weak self] in self?.createEnemy() }
        }
        sequencePosition += 1           // Переходимо до наступної послідовності
        nextSequenceQueued = false      // Встановлюємо, що нова хвиля ще не запланована
    }
    
    
    // MARK: - ❤️ Lives & Score
    func subtractLife() {
        lives -= 1
        
        run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
        
        var life: SKSpriteNode
        
        if lives == 2 {
            life = livesImages[0]
        } else if lives == 1 {
            life = livesImages[1]
        } else {
            life = livesImages[2]
            endGame(triggeredByBomb: false)
        }
        
        life.texture = SKTexture(imageNamed: "sliceLifeGone")
        life.xScale = 1.3
        life.yScale = 1.3
        life.run(SKAction.scale(to: 1, duration: 0.1))
    }
    
    // MARK: - 💥 Game Over & Restart
    func endGame(triggeredByBomb: Bool) {
        guard isGameEnded == false else { return }
        
        for enemy in activateEnemies {
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let shrink = SKAction.scale(to: 0.001, duration: 0.3)
            let group = SKAction.group([fadeOut, shrink])
            let sequence = SKAction.sequence([group, .removeFromParent()])
            enemy.run(sequence)
        }
        gameScore.isHidden = true
        activateEnemies.removeAll()
        isGameEnded = true
        
        physicsWorld.speed = 0
        
        bombSoundEffect?.stop()
        bombSoundEffect = nil
        
        
        // Відображення зниклих життів
        if triggeredByBomb {
            livesImages[0].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[1].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[2].texture = SKTexture(imageNamed: "sliceLifeGone")
        }
        showGameOverScreen()
    }
    
    
    func showGameOverScreen() {
        let centerX = size.width / 2
        let centerY = size.height / 2

        // Заголовок: GAME OVER
        gameOverTitle = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        gameOverTitle.text = "GAME OVER"
        gameOverTitle.fontSize = 80
        gameOverTitle.position = CGPoint(x: centerX, y: centerY + 20)
        gameOverTitle.horizontalAlignmentMode = .center
        gameOverTitle.verticalAlignmentMode = .center
        gameOverTitle.zPosition = 10
        gameOverTitle.alpha = 0
        addChild(gameOverTitle)

        // Кнопка New Game
        newGame = SKLabelNode(fontNamed: "Chalkduster")
        newGame.text = " >< New Game >< "
        newGame.fontSize = 40
        newGame.position = CGPoint(x: centerX, y: centerY - 50)
        newGame.horizontalAlignmentMode = .center
        newGame.verticalAlignmentMode = .center
        newGame.zPosition = 10
        newGame.name = "newGame"
        
        // Кольори і стилі
        newGame.fontColor = UIColor.systemYellow
        newGame.alpha = 0
        newGame.setScale(0.8)
        
        newGame.setScale(1)
        addChild(newGame)

        // Анімація для всіх лейблів
        let fadeIn = SKAction.fadeIn(withDuration: 1)
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        let group = SKAction.group([fadeIn, scaleSequence])

        gameOverTitle.run(group)
        newGame.run(group)
    }
    
    
    // Метод для початку нової гри
    func startNewGame() {
        // Зникнення ворогів із fade out
        for enemy in activateEnemies {
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let shrink = SKAction.scale(to: 0.001, duration: 0.3)
            let group = SKAction.group([fadeOut, shrink])
            let sequence = SKAction.sequence([group, .removeFromParent()])
            enemy.run(sequence)
        }
        gameScore.isHidden = false
        activateEnemies.removeAll()
        
        // Зникнення "Game Over", "Your Score", і "New Game"
        gameOverTitle?.removeFromParent()
        newGame?.removeFromParent()
        
        // Скидання значень
        score = 0
        lives = 3
        livesImages.forEach { $0.texture = SKTexture(imageNamed: "sliceLife") }
        
        enemyCallCount = 0
            goldenEnemyIsActive = false
            sequencePosition = 0
            popupTime = 0.9
            chainDelay = 3.0
            nextSequenceQueued = true
            isGameEnded = false
            isUserInteractionEnabled = true
            physicsWorld.speed = 0.85

            sequence.removeAll()
            sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]
            for _ in 0...1000 {
                if let nextSequence = SequenceType.allCases.randomElement() {
                    sequence.append(nextSequence)
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.tossEnemies()
            }
    }

    
    // MARK: - 🔄 Game Loop
    // Метод cлідкує за звуком бомби
    override func update(_ currentTime: TimeInterval) {
        if activateEnemies.count > 0 {
                var nodesToRemove: [Int] = []

                for (index, node) in activateEnemies.enumerated() {
                    if node.position.y < -140 {
                        node.removeAllActions()

                        if node.name == "enemy" {
                            node.name = ""
                            subtractLife()
                            node.removeFromParent()
                            nodesToRemove.append(index)

                        } else if node.name == "bombContainer" {
                            node.name = ""
                            node.removeFromParent()
                            nodesToRemove.append(index)
                        }
                    }
                }
            // видаляємо після циклу, щоб не порушити індекси
             for index in nodesToRemove.sorted(by: >) {
                 if index < activateEnemies.count {
                     activateEnemies.remove(at: index)
                 }
             }
            
        } else {
            if !nextSequenceQueued && !isGameEnded {
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [weak self] in
                    self?.tossEnemies()
                }
                
                nextSequenceQueued = true
            }
        }
        
        // перевірка активних бомб
        var bombCount = 0
        for node in activateEnemies {
            if node.name == "bombContainer" {
                bombCount += 1                  // Якщо хоча б 1 бомба активна — прапорець
                break
            }
        }
        
        if bombCount == 0 {
            bombSoundEffect?.stop()              // Якщо всі бомби зникли — зупиняємо звук
            bombSoundEffect = nil
        }
    }
}
