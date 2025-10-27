//
//  GameScene.swift
//  Project20
//
//  Created by mac on 23.06.2025.
//

import SpriteKit

class GameScene: SKScene {
    var gameTimer: Timer?
    var fireworks = [SKNode]()
    
    var scoreLabel: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    
    // прапорець очікування завершення гри
    var isGameOverPending = false
    
    var launchesCount = 0
    var maxLaunches = 20
    
    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)   // рівно по центру розміщено
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 40
        scoreLabel.verticalAlignmentMode = .bottom
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 10, y: 10)
        scoreLabel.zPosition = 1
        addChild(scoreLabel)
        
        
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
    
    
    func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        // Створюється порожній контейнер SKNode, який буде містити феєрверк (ракету).
        // Це дозволяє додавати до нього інші елементи (напр., вогні, частинки, ефекти) і рухати всі разом.
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1   // повне змішування (100% кольору, 0% оригінальної текстури)
        firework.name = "firework"
        node.addChild(firework)         // Ми додаємо ракету (firework) як дочірній елемент до контейнера (node), щоб потім рухати весь феєрверк як одне ціле.
        
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .cyan
        case 1:
            firework.color = .green
        default:
            firework.color = .red
        }
        
        // Створюємо порожній шлях (path) — це набір ліній або кривих, по яких буде рухатися феєрверк
        let path = UIBezierPath()
        path.move(to: .zero)    //  початкова точка шляху
        path.addLine(to: CGPoint(x: xMovement, y: 1000))    // Це означає, що феєрверк буде рухатися вгору на                                                     1000 пікселів, і при цьому ще трохи вліво або вправо (залежно від xMovement).
        
        // Рухайся по цьому шляху, враховуючи зміщення (asOffset: true) і обертайся по напряму руху (orientToPath: true)"
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(move)
        
        // Створили частинки за ракетою, щоб вона виглядала так, ніби запалений феєрверк
        let emitter = SKEmitterNode(fileNamed: "fuse")!
        emitter.position = CGPoint(x: 0, y: -22)
        node.addChild(emitter)
        
        
        fireworks.append(node)  // Зберегли феєрверк у масив для подальшої взаємодії.
        addChild(node)          // Додали феєрверк до сцени
    }
    
    
    // Ця функція викликається таймером і кожного разу запускає п’ять феєрверків у одному з кількох варіантів запуску — або вертикально вгору, або віялом
    @objc func launchFireworks() {
        let movementAmount: CGFloat = 1800  // наскільки далеко феєрверк буде рухатись по горизонталі
        
        switch Int.random(in: 0...3) {
        case 0:
            // fire five, straight up (прямо вгору)
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)
        case 1:
            // fire five, in a fan (віялом)
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)
        case 2:
            // fire five, from the left to the right
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)
        case 3:
            // fire five, from the right to the left
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)
            
        default:
            break
        }
        launchesCount += 1
        
        if launchesCount >= maxLaunches {
            gameTimer?.invalidate()
            isGameOverPending = true
        }
    }
    
    
    // Метод, що виділяє феєрверки одним натисканням або свайпом, але лише одного кольору одночасно
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }     // Перевіряємо, чи був хоча б один дотик
        
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)      // масив усіх вузлів, які знаходяться в цій точці
        
        // Ми перебираємо всі знайдені вузли, і якщо це SKSpriteNode з ім’ям "firework", тоді працюємо з ним
        for case let node as SKSpriteNode in nodesAtPoint {
            guard node.name == "firework" else { continue }
            
            // Перебираємо всі феєрверки, які вже є на сцені.
            for parent in fireworks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue }
                
                // Якщо феєрверк уже виділений - знімаємо вибір
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            // Виділення обраного феєрверку
            node.name = "selected"
            node.colorBlendFactor = 0
        }
    }
    
    
    // Обробник дотику - коли він торкається
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    // Обробник дотику - коли він проводить пальцем по екрану
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    
    // створює вибух там, де був феєрверк, а потім видаляє феєрверк зі сцени гри
    func explode(firework: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitter.position = firework.position
            addChild(emitter)
            
            // Дії: зачекати 1 секунду → видалити з батьківського вузла
            emitter.run(showRemoveAfterDelay(1))
        }
        
        firework.removeFromParent()
    }
    
    
    // Очищає сцену від феєрверків, які вже "вилетіли за межі" екрану
    override func update(_ currentTime: TimeInterval) {
        for(index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                fireworks.remove(at: index)     // Видаляємо феєрверк із масиву fireworks, щоб більше не                                      взаємодіяти з ним.
                firework.removeFromParent()     // Видаляємо візуально з екрану
            }
        }
        
        // Коли гра завершилась і всі феєрверки зникли — показати Game Over
        if isGameOverPending && fireworks.isEmpty {
            isGameOverPending = false
            showGameOver()
        }
    }
    
    
    func explodeFireworks() {
        var numExploded = 0
        
        // Перебирає всі феєрверки в масиві fireworks в зворотному порядку.
        for(index, fireworkContainer) in fireworks.enumerated().reversed() {
            //  Дістаємо з кожного його першу дитину – спрайт ракети та зберігаємо спрайт у змінну  firework, інакше  переходимо до наступного елемента
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }
            
            if firework.name == "selected" {
                // destroy this firework!
                explode(firework: fireworkContainer)    // вибухає
                fireworks.remove(at: index)             // Видаляє феєрверк із масиву
                numExploded += 1                        // Збільшує лічильник
            }
        }
        
        switch numExploded {
        case 0:
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }
    

    func showGameOver() {
        gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 100
        gameOverLabel.verticalAlignmentMode = .center
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverLabel.position = CGPoint(x: 512, y: 384)
        gameOverLabel.zPosition = 1
        addChild(gameOverLabel)
        
        gameOverLabel.run(showFadeInOutActions(waitBeforeFadeOut: 1, fadeDuration: 2))
    }
    
    
    // метод, який повертатиме готову анімацію
    func showFadeInOutActions(
        waitBeforeFadeOut: TimeInterval = 1,
        fadeDuration: TimeInterval = 1
    ) -> SKAction {
        let fadeIn = SKAction.fadeIn(withDuration: fadeDuration)
        let wait = SKAction.wait(forDuration: waitBeforeFadeOut)
        let fadeOut = SKAction.fadeOut(withDuration: fadeDuration)
        let remove = SKAction.removeFromParent()
        return SKAction.sequence([fadeIn, wait, fadeOut, remove])
    }

    
    
    func showRemoveAfterDelay(_ delay: TimeInterval) -> SKAction {
        let wait = SKAction.wait(forDuration: delay)
        let remove = SKAction.removeFromParent()
        return SKAction.sequence([wait, remove])
    }

}
