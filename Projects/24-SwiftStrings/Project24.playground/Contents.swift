import UIKit

/// 1️⃣    Рядки в Swift потужні, але не завжди інтуїтивні
/// 2️⃣    Розширення (extension) дозволяють зробити роботу з рядками зручнішою
/// 3️⃣    Swift враховує складність мов (наприклад, німецький ß → SS)
/// 4️⃣    contains(where:) + метод об'єкта (input.contains) = синтаксична магія
/// 5️⃣    Swift дозволяє функціям, методам, замиканням бути взаємозамінними, що дає змогу створювати виразний і розширюваний код

let password = "12345"
password.hasPrefix("123")
password.hasSuffix("345")

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
}

extension String {
    var capitalizedFirst: String {
        guard let firstLetter = self.first else { return "" }
        return firstLetter.uppercased() + self.dropFirst()
    }
}

// Зміна регістру рядка
let weather = "it's going to rain"
print(weather.capitalized)

// Методи contains() працюють і для рядків, і для масивів
let input = "Swift is like Objective-C, without the C"
input.contains("Swift")                                 // ✅ true

let languages = ["Python", "Ruby", "Swift"]
languages.contains("Swift")                             // ✅ true

// Рішення через contains(where:):
languages.contains(where: input.contains(_:))           // ✅ true

let label = UILabel()
label.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
label.numberOfLines = 0

// Тут attributes — словник, який описує, як виглядає текст: колір, шрифт, фон тощо. Він застосовується до всього рядка.
let string = "This is a test string"
let attributes: [NSAttributedString.Key: Any] = [
    .foregroundColor: UIColor.white,
    .backgroundColor: UIColor.red,
    .font: UIFont.boldSystemFont(ofSize: 36)
]
let attributedString = NSAttributedString(string: string, attributes: attributes)


// Ти керуєш, на якій ділянці рядка який стиль застосовувати. У прикладі — кожне слово має свій розмір шрифту.
let attributedSecondString = NSMutableAttributedString(string: string)

attributedSecondString.addAttribute(.font, value: UIFont.systemFont(ofSize: 8), range: NSRange(location: 0, length: 4))
attributedSecondString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 5, length: 2))
attributedSecondString.addAttribute(.font, value: UIFont.systemFont(ofSize: 24), range: NSRange(location: 8, length: 1))
attributedSecondString.addAttribute(.font, value: UIFont.systemFont(ofSize: 32), range: NSRange(location: 10, length: 4))
attributedSecondString.addAttribute(.link, value: URL(string: "https://apple.com")!, range: (string as NSString).range(of: "link"))


// MARK: - CHALLENGE PROJECT24 -
extension String {
    func withPrefix(_ prefix: String) -> String {
        // hasPrefix(_:) перевіряє, чи рядок починається з префікса
        return self.hasPrefix(prefix) ? self : prefix + self
    }
}

var word = "pet"
print(word.withPrefix("car"))       //  ДОДАННЯ ПРЕФІКСА


// 🔹 Маємо якийсь рядок: self (бо ми в extension String)
// 🔹 Пробуємо створити Double з цього рядка: Double(self)
// 🔹 Якщо це вдалось — значить, рядок є числом
extension String {
    // ПЕРЕВІРКА ЧИ РЯДОК Є ЧИСЛОМ
    var isNumeric: Bool {
        return Double(self) != nil
    }
}

"123".isNumeric
"String".isNumeric


// components(separatedBy: "\n") — це метод, який розбиває рядок на частини, використовуючи \n як роздільник
extension String {
    var lines: [String] {
        // РОЗБИТТЯ РЯДКА НА ЛІНІЇ
        return self.components(separatedBy: "\n")
    }
}

let text = "this\nis\na\ntest"
print(text.lines)

// string - рядок
// [String] - масив рядків


// Створи розширення для String, яке додає властивість isPalindrome, що повертає true, якщо рядок читається однаково зліва направо і справа наліво (не чутливе до регістру).
extension String {
    var isPalindrome: Bool {
        let lowercased = self.lowercased()              // Перевести рядок у нижній регістр
        let reversed = String(lowercased.reversed())    // Розвернути рядок
        
        if lowercased == reversed {
            return true
        } else {
            return false
        }
    }
}

"racecar".isPalindrome
"RaceCar".isPalindrome
"hello".isPalindrome


// Створи розширення для String, яке додає властивість trimmed, що повертає рядок без пробілів на початку та в кінці.
extension String {
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

let messy = "   Hello, world! \n"
print(messy.trimmed)
