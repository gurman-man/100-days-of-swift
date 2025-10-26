//
//  GameScene.swift
//  Project14
//
//  Created by mac on 29.05.2025.
//

import SpriteKit


class GameScene: SKScene {
    // Масив лунок, звідки з’являються пінгвіни
    var slots = [WhackSlot]()
    var gameScore: SKLabelNode!
    
    // Час, через який щось з’являється
    var popupTime = 0.85
    var numRounds = 0
    
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        // Додає фонове зображення
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        // Виводить очки у нижньому лівому куті
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        // Розміщує 4 ряди лунок у шаховому порядку
        for i in 0..<5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 410)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 320)) }
        for i in 0..<5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 230)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 140)) }
        
        // Затримка 1 секунда перед тим, як вперше показати пінгвіна
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.createEnemy()
        }
    }
    
    // Створює лунку, додає її до сцени і записує в масив slots
    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        
        slots.append(slot)
    }
    
    
    // Метод обробляє дотик гравця до екрану в грі
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        // Дізнаємося, які ноди (спрайти) були під місцем дотику
        let tappedNodes = nodes(at: location)
        
        // Обробка кожного об’єкта
        for node in tappedNodes {
            // Кожен пінгвін — це дитина charNode, який є у WhackSlot
            // Ми намагаємося піднятися вгору до батьківського елементу та знайти WhackSlot
            // Якщо це не WhackSlot — переходимо до наступного node
            guard let whackSlot = node.parent?.parent as? WhackSlot else {
                continue }
            
            // Якщо слот неактивний або вже вдарений, нічого не робимо.
            if !whackSlot.isVisible { continue }
            if whackSlot.isHit { continue }
            
            // Позначаємо слот як вдарений, щоб він більше не реагував.
            whackSlot.hit()
            
            //  Перевірка, кого вдарили: друга чи ворога
            if node.name == "charFriend" {
                // Не потрібно вдаряти цього пінгвіна
                score -= 5
                run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion:false))
                
            } else if node.name == "charEnemy" {
                // Слід вдарити пінгвіна
                
                whackSlot.charNode.xScale = 0.85
                whackSlot.charNode.yScale = 0.85
                
                score += 1
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            }
            
            if let smoke = SKEmitterNode(fileNamed: "SmokeParticle") {
                
                smoke.position = whackSlot.charNode.position
                smoke.zPosition = 1
                whackSlot.addChild(smoke)

                // Видалити дим після 1 сек
                let removeAfterDelay = SKAction.sequence([
                    SKAction.wait(forDuration: 1.5),
                    SKAction.removeFromParent()
                ])
                smoke.run(removeAfterDelay)
            }
        }
    }
    
    // Цей метод керує появою пінгвінів
    func createEnemy() {
        numRounds += 1
        
        // Гра закінчуєтся після 30 раундів
        if numRounds >= 20 {
            gameScore.removeFromParent()
            // – приховує всіх пінгвінів
            for slot in slots {
                slot.hide()
            }
            
            // Cтворює зображення Game Over
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 512, y: 384)
            gameOver.zPosition = 1
            // початково невидиме
            gameOver.alpha = 0
            
            let finalScore = SKLabelNode(fontNamed: "Chalkduster")
            finalScore.text = "Your final score: \(score)"
            finalScore.fontSize = 48
            finalScore.horizontalAlignmentMode = .center
            finalScore.position = CGPoint(x: 512, y: 300)
            finalScore.zPosition = 1
            
            // Створення анімації
            let fadeIn = SKAction.fadeIn(withDuration: 2)
            let wait = SKAction.wait(forDuration: 3)
            let fadeOut = SKAction.fadeOut(withDuration: 1)
            //  повністю видаляється зі сцени.
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([fadeIn, wait, fadeOut, remove])
            
            gameOver.run(sequence)
            finalScore.run(sequence)
            
            addChild(gameOver)
            addChild(finalScore)
            
            run(SKAction.playSoundFileNamed("game-over-arcade-6435", waitForCompletion: true))
            run(SKAction.playSoundFileNamed("Game-Over", waitForCompletion: false))
            // Зупиняє метод createEnemy()
            return
        }
        // Зменшує час показу кожного наступного пінгвіна — гра ускладнюється
        popupTime *= 0.991
        
        // Перетасуйємо лунки
        slots.shuffle()
        // Показує першого пінгвіна
        slots[0].show(hideTime: popupTime)
         
        // Іноді показуються додаткові пінгвіни — додає випадковості
        if Int.random(in: 0...12) > 4 { slots[1].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 8 { slots[2].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 10 { slots[3].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 11 { slots[4].show(hideTime: popupTime) }
        
        // Генерується випадкова затримка перед наступною появою ворогів
        // popupTime — це тривалість, на яку персонаж показується на екрані
        // minDelay і maxDelay визначають діапазон затримки (щоб не було одноманітно)
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2
        let delay = Double.random(in: minDelay...maxDelay)
        
        // Циклічний виклик — запускає появу пінгвінів знову після випадкової затримки
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.createEnemy()
        }
    }
}
 
