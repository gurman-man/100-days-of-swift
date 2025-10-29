//
//  ViewController.swift
//  Challenge1
//
//  Created by mac on 16.01.2025.
//

import UIKit

struct Flag {
    let country: String
    let imageName: String
}

class ViewController: UITableViewController {
    
    // MARK: Properties
    
    var flags = [Flag]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Gallery Of Flags"
        tableView.rowHeight = 65
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.backButtonTitle = "" // ← прибирає текст у кнопці «Назад»
        
        loadImages()
    }
    
    // MARK: - Loading Data
    
    // Метод, який шукає всі файли прапорів у ресурсах програми
    private func loadImages() {
        let fm = FileManager.default                                                         // Об’єкт для роботи з файлами
        guard let path = Bundle.main.resourcePath else { return }                            // Шлях до ресурсів програми
        guard let filenames = try? fm.contentsOfDirectory(atPath: path) else { return }      // Імена всіх файлів у ресурсах
        
        let locale = Locale.current // Використовується для локалізації назв країн
        
        // Перебираємо всі знайдені файли
        for filename in filenames where filename.hasSuffix("-lg.png") {
            let code = filename.replacingOccurrences(of: "-lg.png", with: "")
            
            // Підставляємо код країни, щоб отримати її локалізовану назву
            if let countryName = locale.localizedString(forRegionCode: code) {
                // Створюємо новий прапор і додаємо у масив
                let flag = Flag(country: countryName, imageName: filename)
                flags.append(flag)
            } else {
                // Якщо країну не вдалося визначити — просто додаємо код у верхньому регістрі
                flags.append(Flag(country: code.uppercased(), imageName: filename))
            }
        }
        
        // Сортуємо прапори за назвою країни в алфавітному порядку
        flags.sort { $0.country.localizedCaseInsensitiveCompare($1.country) == .orderedAscending }
        tableView.reloadData()
    }
    
    // MARK: - Image Scaling
    
    // Метод для масштабування зображення до потрібного розміру
    private func scale(image: UIImage, to size: CGSize) -> UIImage {
        // UIGraphicsImageRenderer — сучасний спосіб створити зображення нового розміру
        let renderer = UIGraphicsImageRenderer(size: size)
        
        // Малюємо старе зображення у новому розмірі
        let newImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        
        // Повертаємо нове зображення без системного тонування (оригінальні кольори)
        return newImage.withRenderingMode(.alwaysOriginal)
    }
    
    
    // MARK: - Table view data source
    
    // Метод визначає кількість рядків у таблиці
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flags.count
    }
    
    // Заповнення кожної комірки таблиці вмістом
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Country", for: indexPath)
        let flag = flags[indexPath.row]         // Отримуємо відповідний прапор з масиву
        
        cell.textLabel?.text = flag.country     // Встановлюємо назву країни у текстовий лейбл комірки
        
        // Додаємо зображення прапора
        if let img = UIImage(named: flag.imageName) {
            cell.imageView?.image = scale(image: img, to: CGSize(width: 65, height: 40))
        } else {
            cell.imageView?.image = nil
        }
        
        // Налаштування розміру зображення
        cell.imageView?.clipsToBounds = true
        cell.imageView?.layer.masksToBounds = true
        cell.imageView?.layer.borderColor = UIColor.darkGray.cgColor
        cell.imageView?.layer.borderWidth = 1
        cell.imageView?.layer.cornerRadius = 5.0
        
        // Додає маленьку стрілочку справа (означає, що комірка натискається)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    // Метод що виконує певну дію, коли користувач натисне на рядок
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            
            vc.selectedFlag = flags[indexPath.row] // передаємо Flag
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
