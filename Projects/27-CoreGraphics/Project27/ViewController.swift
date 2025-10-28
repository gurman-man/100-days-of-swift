//
//  ViewController.swift
//  Project27
//
//  Created by mac on 04.08.2025.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var imageView: UIImageView!
    
    // MARK: - Properties
    var currentDrawtype = 0
    private let canvasSize = CGSize(width: 512, height: 512)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        drawRectangle()
    }
    
    // MARK: - Actions
    // Це функція кнопки. Кожне натискання — показує новий малюнок.
    @IBAction func redrawTapped(_ sender: Any) {
        currentDrawtype += 1
        
        if currentDrawtype > 7 {
            currentDrawtype = 0
        }
        
        switch currentDrawtype {
        case 0: drawRectangle()
        case 1: drawCircle()
        case 2: drawCheckerboard()
        case 3: drawRotatedSquares()
        case 4: drawLines()
        case 5: drawImagesAndText()
        case 6: drawStarEmoji()
        case 7: drawTWIN()
        default: break
        }
    }
}

// MARK: - Drawing Methods

// MARK: Rectangle
private extension ViewController {
    func drawRectangle() {
        // "рендер-блок", у якому ти описуєш, що саме малювати:
        // Все, що намалюється в цьому блоці, буде записано в об'єкт UIImage, який повертає метод image(...).
        imageView.image = renderImage { ctx in
            let rectangle = CGRect(origin: .zero, size: canvasSize)
            
            ctx.setFillColor(UIColor.red.cgColor)
            // встановлює колір заливки нашої фігури,
            
            ctx.setStrokeColor(UIColor.black.cgColor)
            // встановлює колір обведення нашої фігури,
            
            ctx.setLineWidth(10)
            // регулює ширину лінії, яка буде використовуватися для обведення,
            
            ctx.addRect(rectangle)
            // додає прямокутний контур до CGRect,
            
            ctx.drawPath(using: .fillStroke)
            //  малює поточний контур фігури
        }
    }
    
    // MARK: Circle
    func drawCircle() {
        imageView.image = renderImage { ctx in
            let rectangle = CGRect(origin: .zero, size: canvasSize).insetBy(dx: 5, dy: 5)
            // зменшуємо прямокутник з усіх сторін на 5 — щоб обводка не вийшла за межі
            
            ctx.setFillColor(UIColor.red.cgColor)
            ctx.setStrokeColor(UIColor.black.cgColor)
            ctx.setLineWidth(10)
            ctx.addEllipse(in: rectangle)  // додає контур еліпса до прямокутника
            ctx.drawPath(using: .fillStroke)  //  малює поточний контур нашої фігури
        }
    }
    
    // MARK: Checkerboard
    func  drawCheckerboard() {
        imageView.image = renderImage { ctx in
            ctx.setFillColor(UIColor.black.cgColor)
            
            for row in 0 ..< 8 {
                for col in 0 ..< 8  {
                    // Цикл малює лише половину клітинок (парні позиції) чорним кольором
                    if (row + col) % 2 == 0 {
                        let square = CGRect(x: col * 64, y: row * 64, width: 64, height: 64)
                        ctx.fill(square)
                    }
                }
            }
        }
    }
    
    // MARK: Rotated Squares
    func  drawRotatedSquares() {
        imageView.image = renderImage { ctx in
            ctx.translateBy(x: 256, y: 256)
            // Тепер усе малювання буде відбуватись відносно центру, а не від кута (0,0)
            
            let rotations = 16
            let amount  = Double.pi / Double(rotations) // кут обертання - 11.25°
            
            for _ in 0 ..< rotations {
                ctx.rotate(by: CGFloat(amount))   // не повертає саму фігуру, а всю систему координат
                ctx.addRect(CGRect(x: -128, y: -128, width: 256, height: 256))
            }
            
            ctx.setStrokeColor(UIColor.black.cgColor)
            ctx.strokePath()
            //  Малюємо квадрат, повертаємо координати, знову малюємо. І так 16 разів — отримуємо фігуру як з калейдоскопа.
        }
    }
    
    // MARK: Lines Spiral
    func  drawLines() {
        imageView.image = renderImage { ctx in
            ctx.translateBy(x: 256, y: 256)
            // Тепер усе малювання буде відбуватись відносно центру, а не від кута (0,0)
            // Навіщо? Щоб малювати з центру, а не з верхнього лівого кута.
            
            var first = true
            var length: CGFloat = 256
            
            for _ in 0 ..< 256 {
                ctx.rotate(by: .pi / 2)
                // Повертає систему координат на 90° проти годинникової стрілки
                
                if first {
                    ctx.move(to: CGPoint(x: length, y: 50))
                    first = false
                } else {
                    ctx.addLine(to: CGPoint(x: length, y: 50))
                    // Малює лінію до нової точки
                }
                
                length *= 0.99
                // Кожна нова лінія трохи коротша, ніж попередня
                // 📍 Всі точки ліній розташовані на горизонтальній лінії y = 50 — але через обертання координат ці лінії кожного разу змінюють напрямок (вліво, вниз, вправо, вгору тощо).
            }
            ctx.setStrokeColor(UIColor.black.cgColor)
            ctx.strokePath()                          //  малює побудовані лінії
        }
    }
    
    // MARK: Image + Text
    func  drawImagesAndText() {
        // 1. Cиворили полотно
        imageView.image = renderImage { ctx in
            // 2. Визначили стиль абзацу
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            // 3. Створили словник атрибутів, що містить цей стиль абзацу, а також шрифт.
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36),
                .paragraphStyle: paragraphStyle
            ]
            
            // 4. Обернули цей словник атрибутів і рядок у екземпляр NSAttributedString
            let string = """
                The best-laid schemes 0'
                \nmice an' men gang aft agley
                """
            let attributedString = NSAttributedString(string: string, attributes:  attributes)
            
            // 5. Завантажили зображення з проєкту та намалюйте його до контексту
            attributedString.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)
            
            // 6. Оновили вигляд зображення з готовим результатом
            let mouse = UIImage(named: "mouse")
            mouse?.draw(at: CGPoint(x: 300, y: 150))
        }
    }
    
    // MARK: Star Emoji
    func drawStarEmoji() {
        
        imageView.image = renderImage { ctx in
            ctx.translateBy(x: 256, y: 256)
            
            // Тінь для зірки
            ctx.setShadow(offset: CGSize(width: 5, height: 5), blur: 8, color: UIColor.black.withAlphaComponent(0.4).cgColor)
            
            
            // --- Градієнтний фон ---
            let colors = [UIColor.systemMint.withAlphaComponent(0.5).cgColor, UIColor.white.cgColor] as CFArray
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let locations: [CGFloat] = [0.0, 1.0]
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
                let startPoint = CGPoint(x: -256, y: -256)
                let endPoint = CGPoint(x: -256, y: 256)
                ctx.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
            }
            
            // Star points
            let starPoints: [CGPoint] = [
                CGPoint(x: 200.00, y: 0.00),      // 1. Зовнішня
                CGPoint(x: 64.72, y: 58.78),      // 2. Внутрішня
                CGPoint(x: 61.80, y: 190.21),     // 3. Зовнішня
                CGPoint(x: -24.72, y: 76.36),     // 4. Внутрішня
                CGPoint(x: -161.80, y: 118.57),   // 5. Зовнішня
                CGPoint(x: -80.00, y: 0.00),      // 6. Внутрішня
                CGPoint(x: -161.80, y: -118.57),  // 7. Зовнішня
                CGPoint(x: -24.72, y: -76.36),    // 8. Внутрішня
                CGPoint(x: 61.80, y: -190.21),    // 9. Зовнішня
                CGPoint(x: 64.72, y: -58.78)      // 10. Внутрішня
            ]
            
            ctx.move(to: starPoints[0])
            for point in starPoints.dropFirst() {
                ctx.addLine(to: point)
            }
            ctx.closePath()
            ctx.setFillColor(UIColor.systemMint.cgColor)
            ctx.setStrokeColor(UIColor.systemGray6.cgColor)
            ctx.setLineWidth(7)
            ctx.drawPath(using: .fillStroke)  //  одночасно заливає та обводить шлях
            
            // --- Рамка навколо полотна ---
            let borderRect = CGRect(x: -256, y: -256, width: 512, height: 512)
            ctx.setStrokeColor(UIColor.systemTeal.withAlphaComponent(0.6).cgColor)
            ctx.setLineWidth(8)
            ctx.stroke(borderRect)
        }
    }
    
    // MARK: TWIN Word
    func drawTWIN() {
        imageView.image = renderImage { ctx in
            
            // Фон
            ctx.setFillColor(UIColor.black.cgColor)
            ctx.fill(CGRect(x: 0, y: 0, width: 512, height: 512))
            
            // Стиль
            ctx.setStrokeColor(UIColor.systemIndigo.cgColor)
            ctx.setLineWidth(12)
            ctx.setLineCap(.round)       // як закінчуються лінії (гостро, кругло)
            ctx.setLineJoin(.round)      // як з’єднуються кути (гострі, закруглені)
            
            // Зміщуємо систему координат у центр полотна
            ctx.translateBy(x: canvasSize.width / 2, y: canvasSize.height / 2)
            // Зміщуємо вліво і вниз, щоб текст розташувався точно по центру
            ctx.translateBy(x: -180, y: -55)
            
            // T
            ctx.move(to: CGPoint(x: 0, y: 0))
            ctx.addLine(to: CGPoint(x: 80, y: 0))
            ctx.move(to: CGPoint(x: 40, y: 0))
            ctx.addLine(to: CGPoint(x: 40, y: 100))
            
            // W
            ctx.move(to: CGPoint(x: 110, y: 0))
            ctx.addLine(to: CGPoint(x: 130, y: 100))
            ctx.addLine(to: CGPoint(x: 150, y: 40))
            ctx.addLine(to: CGPoint(x: 170, y: 100))
            ctx.addLine(to: CGPoint(x: 190, y: 0))
            
            // I
            ctx.move(to: CGPoint(x: 230, y: 0))
            ctx.addLine(to: CGPoint(x: 230, y: 100))
            
            // N
            ctx.move(to: CGPoint(x: 270, y: 0))
            ctx.addLine(to: CGPoint(x: 270, y: 100))
            ctx.move(to: CGPoint(x: 320, y: 100))
            ctx.addLine(to: CGPoint(x: 270, y: 0))
            ctx.move(to: CGPoint(x: 320, y: 100))
            ctx.addLine(to: CGPoint(x: 320, y: 0))
            
            ctx.strokePath()
        }
    }
    
    // MARK: Helper
    func renderImage(_ drawing: (CGContext) -> Void) -> UIImage {
        //  Створили "полотно", на якому ти малюєш
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        return renderer.image { drawing($0.cgContext) }
    }
}

