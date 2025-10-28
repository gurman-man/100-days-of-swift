//
//  BuildingNode.swift
//  Project29
//
//  Created by mac on 16.08.2025.
//

import UIKit
import SpriteKit

class BuildingNode: SKSpriteNode {
    var currentImage:  UIImage! // Поточна згенерована текстура (потрібна для «вирізання» дірок)
    
    
    /// Базова ініціалізація будівлі: задаємо імʼя, малюємо текстуру та конфігуруємо фізику
    func setup() {
        name = "building"
        
        currentImage = drawBuilding(size: size)
        texture = SKTexture(image: currentImage)
        
        configurePhysics()  // налаштовуємо фізику (колізії, взаємодії).
    }
    
    
    // Налаштує фізику на піксель для поточної текстури спрайта
    func configurePhysics() {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        // створює фізичне тіло по формі текстури (піксельна фізика).
        
        physicsBody?.isDynamic = false
        // будівля нерухома, вона не падає
        
        physicsBody?.categoryBitMask = CollisionTypes.building.rawValue
        // каже, що це будівля
        
        physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        //  каже, з чим ми хочемо відслідковувати зіткнення
    }
    
    
    // Створення будівлі
    func drawBuilding(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let img = renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            // Випадковий колір будівлі
            let color: UIColor
            
            switch Int.random(in: 0...2) {
            case 0:
                color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
                // синій
                
            case 1:
                color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
                // червоний
                
            default:
                color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
                // сірий
            }
            
            color.setFill()
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fill)
            
            
            // Вікна: частина «увімкнена» (жовта), частина «вимкнена» (темна)
            let lightOnColor = UIColor(hue: 0.19, saturation: 0.67, brightness: 0.99, alpha: 1)
            let lightOffColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)
            
            // цикл з кроком 40, щоб рівномірно розставляти вікна
            // По кожному рядку і колонці малюється віконце (15×20)
            // Bool.random() → випадково вирішує, чи світло увімкнене (жовте), чи вимкнене (сіре)
            for row in stride(from: 10, to: Int(size.height - 10), by: 40) {
                for col in stride(from: 10, to: Int(size.width - 10), by: 40) {
                    // для випадкового генерування значень
                    if Bool.random() {
                        lightOnColor.setFill()
                    } else {
                        lightOffColor.setFill()
                    }
                    
                    ctx.cgContext.fill(CGRect(x: col, y: row, width: 15, height: 20))
                }
            }
        }
        
        return img
    }
    
    
    /// «Пробиває» дірку у фасаді в місці попадання банана і оновлює фізику під нову форму
    func hit(at point: CGPoint) {
        // SpriteKit має центр (0,0) у центрі спрайта, CoreGraphics — у нижньому лівому куті.
        // Переводимо координату контакту у систему CoreGraphics для рендеру маски.
        let convertedPoint = CGPoint(x: point.x + size.width / 2, y: abs(point.y) - size.height / 2)
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            currentImage.draw(at: .zero)
            
            // Дірка радіусом 32pt навколо точки удару; режим .clear «вирізає» прозорість
            ctx.cgContext.addEllipse(in: CGRect(x: convertedPoint.x - 32, y: convertedPoint.y - 32, width: 64, height: 64))
            ctx.cgContext.setBlendMode(.clear)
            ctx.cgContext.drawPath(using: .fill)
        }
        
        texture = SKTexture(image: img)
        currentImage = img
        
        configurePhysics()  // Оновлюємо фізичне тіло під новий контур
    }
    
    
}
