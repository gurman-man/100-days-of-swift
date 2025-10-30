import UIKit
import PlaygroundSupport

extension UIView {
    /// Анімує масштабування вʼю до майже нульового розміру.
    /// - Використовується для "зникнення" елемента з екрану.
    /// - duration: тривалість анімації в секундах
    func bounceOut(duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform(scaleX:  0.0001, y:  0.0001)
        }
    }
}

extension Int {
    func times(_ clossure: () -> Void) {
        guard self > 0 else { return }
        //  цикл запускається стільки разів, скільки вказано в self (тобто, числі)
        for _ in 0 ..< self {
            clossure()
        }
    }
}


extension Array where Element: Comparable {
    /// Видаляє **перший елемент** масиву, якщо такий існує.
    /// Працює лише якщо елемент підтримує Comparable (наприклад, String, Int, Double)
    mutating func remove(item: Element) {
            // 1. Спробуй знайти індекс першого входження item в масив
        if let index = firstIndex(of: item) {
            // 2. Якщо індекс знайдено — видали елемент за цим індексом
            remove(at: index)
        }
    }
}

let container = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
container.backgroundColor = .white

let testView = UIView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
testView.backgroundColor = .systemRed
container.addSubview(testView)

PlaygroundPage.current.liveView = container

DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    testView.bounceOut(duration: 2)
}

let count = 5
count.times {
    print("Hello")
}

var array = ["hello", "goodbuy", "hello"]
array.remove(item: "hello")
print(array)

