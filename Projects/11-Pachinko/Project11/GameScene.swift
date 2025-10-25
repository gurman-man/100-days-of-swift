//
//  GameScene.swift
//  Project11
//
//  Created by mac on 05.05.2025.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel: SKLabelNode!
    var alertLabel: SKLabelNode!
    var ballsLabel: SKLabelNode!
    
    var ballColors: [String] = ["ballBlue", "ballGreen", "ballRed", "ballGrey", "ballYellow", "ballPurple", "ballCyan"]
    
    var ballsLeft = 5 {
        didSet {
            ballsLabel.text = "Balls: \(ballsLeft)"
        }
    }
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    //  Створення кнопки вгорі ліворуч
    var editLabel: SKLabelNode!
    
    //  логічна змінна, яка визначає, що робити при дотику: створювати м’яч чи прямокутник
    var editingMode: Bool = false {
        // автоматично змінює текст кнопки при перемиканні режиму
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        ballsLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballsLabel.text = "Balls: 5"
        ballsLabel.horizontalAlignmentMode = .right
        ballsLabel.position = CGPoint(x: 980, y: 650)
        addChild(ballsLabel)
        
        // Це створює невидимий контур по краях екрану, щоб м’ячі не вилітали за межі
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        // Встановлює, що контакти (зіткнення тіл) на сцені будуть оброблятись саме тут
        physicsWorld.contactDelegate = self

        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
    }
    
    
    //  Додавання м’яча при торканні екрану
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
    
        
        // Шукає всі об’єкти, на які натиснули.
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        
        // Якщо торкнулись "Edit", перемикає режим редагування.
        if objects.contains(editLabel) {
            // метод, який автоматично перемикає значення bool
            editingMode.toggle()
        } else {
            if editingMode {
                // Це створює випадкову кольорову коробку, яка не падає
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                let box  = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location
                
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                box.name = "box"
                addChild(box)
            } else {
                //  Створення м’яча (режим гри)
                if  ballsLeft > 0 {
                    // Випадковий колір кулі при кожному дотику
                    let ball = SKSpriteNode(imageNamed: ballColors.randomElement() ?? "ballRed")
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                    // коефіцієнт пружності
                    ball.physicsBody?.restitution = 0.4
                    
                    // "Зроби так, щоб я отримував повідомлення (contactTest) про усі фізичні зіткнення, які можливі для цього м’яча (тобто ті, що вже визначені в collisionBitMask).
                    //
                    // Але якщо collisionBitMask з якоїсь причини дорівнює nil, то встанови 0 — тобто нічого не повідомляй."
                    
                    ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                    ball.position = location
                    ball.position.y = 700
                    ball.name = "ball"
                    addChild(ball)
                    
                } else {
                    // ❗️Сповіщення про відсутність куль
                    alertLabel = SKLabelNode(fontNamed: "Chalkduster")
                    alertLabel.text = "No more balls"
                    alertLabel.horizontalAlignmentMode = .center
                    alertLabel.position = CGPoint(x: 500, y: 400)
                    
                    let wait = SKAction.wait(forDuration: 2)
                    let fade = SKAction.fadeOut(withDuration: 1)
                    let remove = SKAction.removeFromParent()
                    let sequence = SKAction.sequence([wait, fade, remove])
                    alertLabel.run(sequence)
                    
                    addChild(alertLabel)
                }
            }
        }
    }
    
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    
    // Ця функція створює "смуги" внизу екрану
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            // - Ім’я слоту — `"good"`, щоб пізніше знати, що це добрий слот
            slotBase.name = "good"
        } else {
            slotBase =  SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        // Розміщуєм слоти в заданій позиції на сцені
        slotBase.position = position
        slotGlow.position = position
        
        // - Створює **фізичне тіло** у вигляді прямокутника, щоб воно могла зіштовхуватись з м’ячем
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        
        addChild(slotBase)
        addChild(slotGlow)
        
        // Обертає об'єкт **на 180°** (π радіан) **за 10 секунд**
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        // Змушує це обертання **повторюватися
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    
    // Ця функція перевіряє, з чим саме зіштовхнувся м’яч:
    func collision(between ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
            ballsLeft += 1
            
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
            ballsLeft -= 1
            
        // Коробки з іменем "box" знищуються при торканні
        } else if object.name == "box" {
            destroy(box: object)
        }
    }
    
    
    //  Видаляє м’яч зі сцени
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        ball.removeFromParent()
    }
    
    // Видаляє коробку зі сцени
    func destroy(box: SKNode) {
        box.removeFromParent()
    }
    
    
    // Функція, яка викликається автоматично, коли об'єкти стикаються
    func didBegin(_ contact: SKPhysicsContact) {
        // Бере два об'єкти, що зіштовхнулись
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        // Визначає, хто з них є м’ячем (name == "ball")
        // Передає об’єкти у collision(between:object:)
        if nodeA.name == "ball" {
            collision(between: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collision(between: nodeB, object: nodeA)
        }
    }
}
