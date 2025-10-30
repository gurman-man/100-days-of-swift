//
//  ViewController.swift
//  Consolidation4_Hangman_game
//
//  Created by mac on 24.04.2025.
//

import UIKit

class ViewController: UIViewController {
    
    private var nameGameLabel: UILabel!     // назва гри
    private var scoreLabel: UILabel!        // рахунок
    private var wrongAnswersCount: Int = 0
    private var hintLabel: UILabel!         // підказка
    private var guessWordLabel: UILabel!    // слово _ _ _ _
    private var wrongLabel: UILabel!        // неправильна буква
    var humanImage: UIImageView!            // малюнок чоловічка
    
    // Це порожній UIView, в який ми засунемо всі кнопки
    var buttonsContainer = UIView()
    var letterButtons = [UIButton]()        // Масив кнопок - букв
    
    var nextLevelButton: UIButton!
    var menuButton: UIButton!
    
    var usedLetters = Set<String> ()         // Масив кнопок, які вже були натиснуті
    var wrongLetters = Set<String> ()
    
    var wordToGuess = "FORD"
    var wordsLevel = ["AUDI", "CITROEN", "HONDA", "TOYOTA", "MAZDA", "FERARRI"]
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score \(score)"
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        // Налаштовуємо лейбли
        nameGameLabel = createLabel(text: "HANGMAN", fontSize: 30)
        
        scoreLabel = createLabel(text: "Score 0", fontSize: 20)
        scoreLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        hintLabel = createLabel(text: "Hint: Car Brand ", fontSize: 20)
        hintLabel.font = UIFont.italicSystemFont(ofSize: 20)
        hintLabel.textColor = .purple
        
        guessWordLabel = createLabel(text: "_ _ _ _", fontSize: 25)
        guessWordLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 32, weight: .medium)
        guessWordLabel.textAlignment = .center
        
        wrongLabel = createLabel(text: "Wrong: \(wrongLetters.joined(separator: ", "))", fontSize: 20)
        
        // Створюєм кнопку - next level
        nextLevelButton = UIButton(type: .system)
        nextLevelButton.translatesAutoresizingMaskIntoConstraints = false
        nextLevelButton.setTitle("New Game", for: .normal)
        nextLevelButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        nextLevelButton.backgroundColor = .systemMint
        nextLevelButton.setTitleColor(.purple, for: .normal)
        nextLevelButton.layer.cornerRadius = 10
        nextLevelButton.addTarget(self, action: #selector(startNewGame), for: .touchUpInside)
        
        // Створюєм кнопку - menu
        menuButton = UIButton(type: .system)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.setTitle("MENU", for: .normal)
        menuButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        menuButton.backgroundColor = .systemMint
        menuButton.setTitleColor(.purple, for: .normal)
        menuButton.layer.cornerRadius = 10
        menuButton.addTarget(self, action: #selector(openMenu), for: .touchUpInside)
        
        
        // Додаємо на екран
        view.addSubview(nameGameLabel)
        view.addSubview(scoreLabel)
        view.addSubview(hintLabel)
        view.addSubview(guessWordLabel)
        view.addSubview(wrongLabel)
        view.addSubview(nextLevelButton)
        view.addSubview(menuButton)
        
        // Додаємо картинку
        humanImage = UIImageView(image: UIImage(named: "hangman" ))
        humanImage.contentMode = .scaleAspectFit
        humanImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(humanImage)
        
        // Налаштовуєм обмеження для міток
        NSLayoutConstraint.activate([
            
            nameGameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameGameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scoreLabel.topAnchor.constraint(equalTo: nameGameLabel.bottomAnchor, constant: 20),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -20),
            
            nextLevelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextLevelButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 20),
            nextLevelButton.widthAnchor.constraint(equalToConstant: 150),
            
            menuButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            menuButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -20),
            menuButton.widthAnchor.constraint(equalToConstant: 150),
            
            
            // Налаштовуємо картинку (це буде розташування картинки на екрані)
            humanImage.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 50),
            humanImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            humanImage.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            humanImage.heightAnchor.constraint(equalTo: humanImage.widthAnchor),
      
            
            hintLabel.topAnchor.constraint(equalTo: humanImage.bottomAnchor, constant: 20),
            hintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            wrongLabel.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: 20),
            wrongLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            guessWordLabel.topAnchor.constraint(equalTo: wrongLabel.bottomAnchor, constant: 20),
            guessWordLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        createLetterButtons()      // Створюємо кнопки
        createLetterButtonRows()   // Розташовуємо кнопки
        
    }
    
    
    // Метод що налаштовує кнопку
    func createLabel(text: String, fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    
    // Створення кнопок з буквами
    func createLetterButtons() {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        
        for letter in letters {
            let button = UIButton(type: .system)
            button.setTitle(String(letter), for: .normal)
            button.addTarget(self, action: #selector(letterButtonTapped), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            letterButtons.append(button)
            
            // 🔹 Стиль
            button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            button.backgroundColor = UIColor.systemGray5
            button.layer.cornerRadius = 8
        }
    }
    
    
    func createLetterButtonRows() {
    
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsContainer)
        
        // Ми задаємо рамки для всієї зони, де будуть кнопки.
        NSLayoutConstraint.activate([
            buttonsContainer.topAnchor.constraint(equalTo: guessWordLabel.bottomAnchor, constant: 50),
            buttonsContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonsContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonsContainer.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        
        let rowCount = 3
        let columnCount = 9
        
        // Головний стек, що містить всі рядки
        let mainStack = UIStackView()
        mainStack.axis = .vertical                  // Розташовуй елементи вертикально (зверху вниз).
        mainStack.distribution = .fillEqually       // Всі елементи всередині (rowStack) займають однакову висоту.
        mainStack.spacing = 10                      // Встановлюємо відступ між рядками кнопок (10 пікселів).
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainer.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: buttonsContainer.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: buttonsContainer.bottomAnchor)
        ])
        
        for row in 0..<rowCount {
            
            //      формуєм індекс для кожного рядка
            //
            //      Для row = 0: startIndex = 0 * 9 = 0
            //      Для row = 1: startIndex = 1 * 9 = 9
            //      Для row = 2: startIndex = 2 * 9 = 18
            
            let startIndex = row  * columnCount
            
            
            //      це передбачуваний кінець поточного рядка
            //      min(...) потрібен, щоб не вийти за межі масиву!
            //
            //      Для row = 0: endIndex = min(1 * 9, 26) = 9
            //      Для row = 1: endIndex = min(2 * 9, 26) = 18
            //      Для row = 2: endIndex = min(3 * 9, 26) = min(27, 26) = 26
            
            let endIndex = min((row + 1) * columnCount,letterButtons.count)
            
            
            
            //      Це витягує масив кнопок для одного рядка
            //
            //      Рядок 0: letterButtons[0..<9] — кнопки A–I
            //      Рядок 1: letterButtons[9..<18] — кнопки J–R
            //      Рядок 2: letterButtons[18..<26] — кнопки S–Z
            
            let rowButtons = Array(letterButtons[startIndex..<endIndex])
            
            // Створюємо горизонтальний стек для кожного рядка кнопок.
            // Передаємо в нього масив кнопок для поточного рядка (rowButtons)
            let rowStack = UIStackView(arrangedSubviews: rowButtons)
            rowStack.axis = .horizontal                 // Розташовуй елементи по горизонталі (зліва направо)
            rowStack.distribution = .fillEqually        // Всі кнопки в рядку мають однакову ширину
            rowStack.spacing = 8
            
            mainStack.addArrangedSubview(rowStack)      // Додаємо цей рядок кнопок в головний вертикальний стек (mainStack)
        }
    }
    
    
    @objc func letterButtonTapped(_ sender: UIButton) {
        
        // "Sender — це натиснута кнопка. Guard — безпечно дістаємо текст з неї."
        guard let letter = sender.titleLabel?.text else { return }
        
        usedLetters.insert(letter)
        
        // Вимикаємо кнопку, щоб не можна було натискати вдруге
        sender.isEnabled = false
        
        if wordToGuess.contains(letter) {
            // якщо вгадав літеру — оновлюємо слово
            updatePromptWord()
            score += 1
            
        } else {
            // якщо НЕ вгадав — додаємо у масив помилок
            wrongLetters.insert(letter)
            
            // оновлюємо напис "Wrong: ..."
            wrongLabel.text = "Wrong: \(wrongLetters.sorted().joined(separator: ", "))"
            
            
            // за бажанням: збільшуємо лічильник помилок
            wrongAnswersCount += 1
            
            // зменшуєм рахунок на 1 очко
            score -= 1
            
            // оновлюєм картинку
            updateImage()
            
            if wrongAnswersCount == 6 {
                
                score = 0
                
                let alert = UIAlertController(title: "The hangman got you! 😵", message: "You made too many mistakes.\nThe correct word was: \(wordToGuess)", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { _ in self.tryAgain()}))
                alert.addAction(UIAlertAction(title: "Exit to Menu", style: .destructive, handler: { _ in self.openMenu() }))
                
                present(alert, animated: true)
            }
        }
        
    }
    
    
    func updatePromptWord() {
        
        // Зібране нове слово для показу (відкриті букви + підкреслення)
        var promptWord = ""
        
        var isWordGuessed = true  // Нове: припускаємо, що все вгадано
        
        for character in wordToGuess {
            let strChar = String(character)
            
            if usedLetters.contains(strChar) {
                promptWord += strChar + " "
            } else {
                promptWord += "_ "
                isWordGuessed = false
            }
        }
        
        // Не забудь ще оновити лейбл, інакше нічого не буде видно:
        guessWordLabel.text = promptWord
        
        // Якщо слово вгадане - то
        if isWordGuessed {
            
            score += 10
            
            let ac = UIAlertController(title: "You win! 🎉", message: "Congratulations!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Go to next level", style: .default, handler: { _ in self.startNewGame() }))
            ac.addAction(UIAlertAction(title: "Exit to Menu", style: .destructive, handler: { _ in self.openMenu() }))
            
            present(ac,animated: true)
            
        }
    }
    
    
    func updateImage() {
        let imageName = "hangman\(wrongAnswersCount)"
        humanImage.image = UIImage(named: imageName)
    }
    
    
    func tryAgain() {
        usedLetters.removeAll()
        wrongLetters.removeAll()
        wrongAnswersCount = 0
        score = 0
        
        for button in letterButtons {
            button.isEnabled = true
        }
        
        var promptWord = ""
        for _ in wordToGuess {
            promptWord += "_ "
        }
        
        guessWordLabel.text = promptWord
        
        humanImage.image = UIImage(named: "hangman")
        wrongLabel.text = "Wrong: \(wrongLetters.joined(separator: ", "))"
    }
    
    
    @objc func startNewGame() {
        usedLetters.removeAll()
        wrongLetters.removeAll()
        wrongAnswersCount = 0
        
        for button in letterButtons {
            button.isEnabled = true
        }
        
        // Вибирає випадкове слово з масиву
        wordToGuess = wordsLevel.randomElement() ?? "FORD"
        
        var promptWord = ""
        for _ in wordToGuess {
            promptWord += "_ "
        }
        
        guessWordLabel.text = promptWord
        humanImage.image = UIImage(named: "hangman")
        wrongLabel.text = "Wrong: \(wrongLetters.joined(separator: ", "))"
    }
    
    @objc func openMenu() {
        let menuVC = MenuViewController()
        menuVC.modalPresentationStyle = .fullScreen
        present(menuVC, animated: true)
    }
    
}


