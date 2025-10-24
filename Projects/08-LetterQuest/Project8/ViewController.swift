
//  Project8 chalange
//
//  Created by mac on 09.04.2025.
//

import UIKit

class ViewController: UIViewController {
    var cluesLabel: UILabel!            // Мітка для підказок (1. Ghosts in residence)
    var answersLabel: UILabel!          // Мітка для відповідей (наприклад: 6 letters)
    var currentAnswer: UITextField!     // Поле, куди вводиться поточна відповідь
    var scoreLabel: UILabel!            // Мітка для відображення рахунку гравця
    
    var letterButtons = [UIButton]()    // Масив усіх кнопок із літерами
    var activatedButtons = [UIButton]() // Масив кнопок, які вже були натиснуті
    
    var solutions = [String]()          // Масив правильних відповідей (без '|')
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var level = 1
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        scoreLabel = UILabel()
        // не перетворює автоматично розміри та позицію мітки у frame.
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score 0"
        // додає мітку до ієрархії view'шок (на екрані).
        view.addSubview(scoreLabel)
        
        cluesLabel = UILabel()
        cluesLabel.translatesAutoresizingMaskIntoConstraints = false
        cluesLabel.font = UIFont.systemFont(ofSize: 24)
        cluesLabel.text = "CLUES"
        cluesLabel.numberOfLines = 0
        cluesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view .addSubview(cluesLabel)
        
        answersLabel = UILabel()
        answersLabel.translatesAutoresizingMaskIntoConstraints = false
        answersLabel.font = UIFont.systemFont(ofSize: 24)
        answersLabel.text = "ANSWEARS"
        answersLabel.textAlignment = .right
        answersLabel.numberOfLines = 0
        cluesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(answersLabel)
        
        currentAnswer = UITextField()
        currentAnswer.translatesAutoresizingMaskIntoConstraints = false
        currentAnswer.placeholder = "Tap letters to guess"
        currentAnswer.textAlignment = .center
        currentAnswer.font = UIFont.systemFont(ofSize: 40)
        currentAnswer.isUserInteractionEnabled = false
        view.addSubview(currentAnswer)
        
        let submit = UIButton(type: .system  )
        submit.translatesAutoresizingMaskIntoConstraints = false
        submit.setTitle("SUBMIT", for: .normal)
        submit.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        view.addSubview(submit)
        
        let clear = UIButton(type: .system)
        clear.translatesAutoresizingMaskIntoConstraints = false
        clear.setTitle("CLEAR", for: .normal)
        clear.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        view.addSubview(clear)
        
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        
        
        cluesLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        answersLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        // Цей метод активує Auto Layout обмеження
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0),
            
            // 🔽 Розмістити cluesLabel одразу під scoreLabel (по вертикалі).
            cluesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            
            // ⬅️ Встановити відступ 100 пікселів від лівого краю екрана (з урахуванням layoutMargins).
            cluesLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
            
            // 📏 Задати ширину cluesLabel як 60% від ширини екрана (layoutMargins) мінус 100 пікселів.
            cluesLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -100),
            
            // // 📌 Прив’язує верхній край answersLabel до нижнього краю scoreLabel — тобто розміщується нижче за "Рахунок".
            answersLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            
            // 📌 Прив’язує правий край answersLabel до правого краю вікна (з урахуванням відступів),
            // із відступом 100 пікселів вліво (тому -100).
            answersLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
            
            // 📌 Ширина answersLabel буде 40% від ширини вікна (з урахуванням відступів), і ще мінус 100 пікселів.
            answersLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -100),
            
            // 📌 Висота answersLabel буде така ж, як у cluesLabel — щоб вони виглядали симетрично.
            answersLabel.heightAnchor.constraint(equalTo: cluesLabel.heightAnchor),
            
            currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentAnswer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            currentAnswer.topAnchor.constraint(equalTo: cluesLabel.bottomAnchor, constant: 20),
            
            submit.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor),
            submit.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            submit.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
            submit.heightAnchor.constraint(equalToConstant: 44),
            
            clear.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
            clear.centerYAnchor.constraint(equalTo: submit.centerYAnchor),
            clear.heightAnchor.constraint(equalToConstant: 44),
            
            // вирівняне поле горизонтально по центру
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Існуючі constraints
            buttonsView.widthAnchor.constraint(equalToConstant: 760),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.topAnchor.constraint(equalTo: submit.bottomAnchor, constant: 10),
            buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
        
        let width = 150
        let height = 70
        
        for row in 0..<4 {
            for column in 0..<5 {
                let letterButton = UIButton(type: .system)
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                letterButton.setTitle("WWW", for: .normal)
                letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
                
                let frame = CGRect(x: column * width, y: row * height, width: width, height: height)
                letterButton.frame = frame
                
                buttonsView.addSubview(letterButton)
                letterButtons.append(letterButton)
            }
            
            // Створили “сітку”, яка відображає контури кожної кнопки
            for letterButton in letterButtons {
                letterButton.layer.borderWidth = 1          // тонка лінія
                letterButton.layer.borderColor = UIColor.gray.cgColor
                letterButton.layer.cornerRadius = 5         // заокруглення куточків
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.loadLevel()
        }
    }
    
    @objc func letterTapped(_ sender: UIButton) {
        // Отримує текст з кнопки (наприклад, "HA"), інакше - вихід з фунції
        guard let buttonTitle = sender.titleLabel?.text else { return }
        
        // Додає цей фрагмент до поля відповіді
        currentAnswer.text = currentAnswer.text?.appending(buttonTitle)
        // Зберігає натиснуту кнопку у масив, щоб потім знати, які саме натиснули
        activatedButtons.append(sender)
        sender.isHidden = true
    }
    
    @objc func submitTapped(_ sender: UIButton) {
        // Отримує відповідь користувача.
        guard let answerText = currentAnswer.text else { return }
        
        // Шукає, чи ця відповідь є серед правильних (solutions).
        // Якщо так — отримує її позицію.
            if let solutionPosition = solutions.firstIndex(of: answerText) {
            activatedButtons.removeAll()
            
            // Розбиває текст відповідей по рядках.
            var splitAnswers = answersLabel.text?.components(separatedBy: "\n")
            // Замінює відповідь на правильну в потрібному місці.
            splitAnswers?[solutionPosition] = answerText
            // Об'єднує назад у рядок і показує в answearsLabel.
            answersLabel.text = splitAnswers?.joined(separator: "\n")
            
                currentAnswer.text = ""
                score += 1
                scoreLabel.text = "Score: \(score)"
                
                // Перевірка чи всі кнопки в letterButtons є приховані.
                let allButtonsHiden = letterButtons.allSatisfy { $0.isHidden }
                if  allButtonsHiden {
                    let ac = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: levelUp))
                    present(ac, animated: true)
                }
            } else {
                score -= 1
                scoreLabel.text = "Score: \(score)"
                
                // Показуємо знову всі натиснуті кнопки
                for button in activatedButtons {
                    button.isHidden = false
                }
            
            // Очищаємо масив активованих кнопок
            activatedButtons.removeAll()
            
            // Очищаємо введений текст
            currentAnswer.text = ""
            
            // // Показуємо алерт про помилку
            let alert = UIAlertController(title: "Your word is incorrect.", message: "Don't be upset, try again!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    
    func levelUp(action: UIAlertAction) {
        level += 1
        
        // Очищає список правильних відповідей.
        solutions.removeAll(keepingCapacity: true) //  залишає виділену пам'ять (оптимізація, не створює новий масив).
        
        cluesLabel.text = ""
        answersLabel.text = ""
        currentAnswer.text = ""
        
        loadLevel()
        
        // Показує всі кнопки з літерами заново (бо деякі були сховані після натискань)
        for button in letterButtons {
            button.isHidden = false
        }
        
    }
    
    @objc func clearTapped(_ sender: UIButton) {
        // Очищає поле з відповіддю (прибирає всі букви)
        currentAnswer.text = ""
        
        // Повертає на екран усі натиснуті кнопки.
        for button in activatedButtons {
            button.isHidden = false
        }
        
        // Очищає список натиснутих кнопок.
        activatedButtons.removeAll()
    }
    
    func loadLevel() {
        DispatchQueue.global(qos: .utility).async {
            [weak self] in
            
            guard let self = self else { return }
            
            var clueString = "" // текст усіх підказок
            var solutionsString = "" // текст із кількістю букв для кожної відповіді
            var letterBits = [String]() // шматочки слів (будуть кнопки, які треба натискати)
            
            // Шукаємо файл level*.txt в ресурсах:
            if let levelFileURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") {
                // if let levelContents = try? String(contentsOf: levelFileURL)
                if let levelContents = try? String(contentsOf: levelFileURL, encoding: .utf8) {
                    
                    // Розбиваємо файл на рядки (по \n)
                    var lines = levelContents.components(separatedBy: "\n")
                    lines.shuffle()
                    
                    // Проходимо по кожному рядку + отримуємо номер
                    for (index, line) in lines.enumerated() {
                        let parts = line.components(separatedBy: ": ") // масив parts ["HA|PP|Y", "Feeling good"]
                        
                        // Перевірка, чи масив parts містить мінімум 2 елементи
                        if parts.count == 2 {
                            let answer = parts[0] // answer — це частина з літерами, типу HA|PP|Y
                            let clue = parts[1] // clue — текст підказки, типу "Feeling good"
                            
                            // Додаємо підказку до загального тексту (1. Feeling good)
                            clueString += "\(index + 1). \(clue)\n"
                            
                            // Видаляємо |, отримуємо слово "HAPPY"
                            let solutionWord  = answer.replacingOccurrences(of: "|", with: "")
                            solutionsString += "\(solutionWord.count) letters\n"
                            solutions.append(solutionWord)
                            
                            // Розбиваємо "HA|PP|Y" на шматки ["HA", "PP", "Y"]
                            let bits = answer.components(separatedBy: "|")
                            letterBits += bits
                        } else {
                            print("Warning: Invalid format for line: \(line)")
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                // Додай логування сформованого слова
                let fullWord = letterBits.joined() // Збирає всі частини в одне слово
                print("Full Word: \(fullWord)") // Виводимо сформоване слово
                
                // Показуємо всі підказки в cluesLabel
                self.cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
                // Показуємо кількість букв у кожному слові в answearsLabel
                self.answersLabel.text = solutionsString.trimmingCharacters(in: .whitespacesAndNewlines)
                
                
                
                letterBits.shuffle()
                
                if self.letterButtons.count == letterBits.count {
                    for i in 0..<self.letterButtons.count {
                        self.letterButtons[i].setTitle(letterBits[i], for: .normal)
                    }
                }  else {
                    print("Error: The number of letter buttons doesn't match the number of letter bits.")
                }
            }
        }
    }
}
