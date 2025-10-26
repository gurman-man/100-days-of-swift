//
//  WhackSlot.swift
//  Project14
//
//  Created by mac on 29.05.2025.
//

import UIKit
import SpriteKit

// Цей клас — контейнер для лунки, маски та пінгвіна
class WhackSlot: SKNode {
    var charNode: SKSpriteNode!
    var isVisible = false
    var isHit = false
    
    func configure(at position: CGPoint) {
        self.position = position
        
        // Cтворюємо вузол нори
        let sprite = SKSpriteNode(imageNamed: "whackHole")
        addChild(sprite)
        
        // Створюєм вузол обрізання згідно з формою maskNode
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 15)
        cropNode.zPosition = 1
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")
        
        // Створюєм вузол персонажа, що захований (нижче маски)
        charNode = SKSpriteNode(imageNamed: "penguinGood")
        charNode.position = CGPoint(x: 0, y: -90)
        charNode.name = "character"
        // Додаємо персонажа в cropNode(обрізання)
        cropNode.addChild(charNode)
        
        // а cropNode в слот
        addChild(cropNode)
    }
    
    func show(hideTime: Double) {
        // Не показує нових, якщо вже є показаний пінгвін
        if isVisible { return }
        
        charNode.xScale = 1
        charNode.yScale = 1
        
        if let mud = SKEmitterNode(fileNamed: "mudParticle") {
            mud.position = CGPoint(x: charNode.position.x, y: 20)
            mud.zPosition = -1
            addChild(mud)
            
            // Видалити дим після 1 сек
            let removeAfterDelay = SKAction.sequence([
                SKAction.wait(forDuration: 1.5),
                SKAction.removeFromParent()
            ])
            mud.run(removeAfterDelay)
        }
        
        // Пінгвін "вистрибує" з лунки
        charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
        isVisible = true
        isHit = false
        
        // 1/3 випадків — добрий пінгвін, 2/3 — злий
        if Int.random(in: 0...2) == 0 {
            charNode.texture = SKTexture(imageNamed: "penguinGood")
            charNode.name = "charFriend"
        } else {
            charNode.texture = SKTexture(imageNamed: "penguinEvil")
            charNode.name = "charEnemy"
        }
        
        // Через певний час пінгвін ховається назад
        DispatchQueue.main.asyncAfter(deadline: .now() + (hideTime * 3.5)) {
            [weak self] in
            self?.hide()
        }
    }
    
    // Анімація назад у нору
    func hide() {
        if !isVisible { return }
        
        if let mud = SKEmitterNode(fileNamed: "mudParticle") {
            mud.position = CGPoint(x: charNode.position.x, y: 20)
            mud.zPosition = -1
            addChild(mud)
            
            // Видалити дим після 1 сек
            let removeAfterDelay = SKAction.sequence([
                SKAction.wait(forDuration: 1.5),
                SKAction.removeFromParent()
            ])
            mud.run(removeAfterDelay)
        }
        
        charNode.run(SKAction.moveBy(x: 0, y: -80, duration: 0.05))
        isVisible = false
    }
    
    func hit() {
        isHit = true
        
        let delay = SKAction.wait(forDuration: 0.25)
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
        let notVisible = SKAction.run { [weak self] in self?.isVisible = false }
        let sequence = SKAction.sequence([delay, hide, notVisible])
        charNode.run(sequence)
    }
}
 
