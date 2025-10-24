//
//  ViewController.swift
//  Project7
//
//  Created by mac on 12.02.2025.
//

import UIKit

class ViewController: UITableViewController {
    
    // Масив що зберігатиме всі отримані петиції
    var petitions = [Petition]()
    // Масив що зберігатиме відфільровані петиції
    var filteredPetitions = [Petition]()
    var isFiltering = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Whitehouse news"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        
        tableView.rowHeight = 80
        
        // Оголошення кнопки Credits
        let creditsButton = UIBarButtonItem(image: UIImage(systemName: "book"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(buttonTapped))
        // Оголошення конопки для фільтрації
        let filterButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"),
                                           style: .plain,
                                           target: self,
                                           action: #selector(filterTapped))
        
        navigationItem.rightBarButtonItem = creditsButton
        navigationItem.leftBarButtonItem = filterButton
        
        // Визначаємо URL – звідки будемо отримувати дані
        let urlString: String
    
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString =
            "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        // Завантаження JSON у фоновому потоці:
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            // Перевіряємо, чи можна створити URL
            if let url = URL(string: urlString) {
                
                // завантажує JSON
                if let data = try? Data(contentsOf: url) {
                    
                    // Викликаємо функцію parse(), щоб обробити JSON
                    self?.parse(json: data)
                } else {
                    DispatchQueue.main.async {
                        self?.showError()
                    }
                }
            }
        }
    }
    
    func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your conection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    // обробка настискання кнопки
    @objc func buttonTapped() {
        // створюєм сповіщення (змінну)
        let alert = UIAlertController(title: "CREDITS", message: "These data were obtained from the 'We The People API of the Whitehouse'", preferredStyle: .alert)
        
        // Додаємо кнопку - OK для закриття сповіщення
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        alert.popoverPresentationController?.barButtonItem =
        navigationItem.rightBarButtonItem
        
        present(alert, animated: true)
    }
    
        // Реалізація пошуку по ключовому слову
    @objc func filterTapped() {
        let ac = UIAlertController(title: "Filter petitions", message: "Enter a keyword..", preferredStyle: .alert)
        // додаєм текстове поле
        ac.addTextField()
        
        // Створення кнопки Search
        let submitAction = UIAlertAction(title: "Search", style: .default) { [weak self, weak ac] _ in
            // Наше введене слово - ac?.textFields?[0].text - яке зберігається у константі
            guard let filterText = ac?.textFields?[0].text else { return }
            
            // Передаємо введене слово в метод фільтрації
            self?.filterResults(by: filterText)
        }
        
        // Створення кнопки Reset
        let resetAction = UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            self?.resetFilter()
        }
        
        ac.addAction(submitAction)
        ac.addAction(resetAction)
        present(ac, animated: true)
    }

    // Метод фільтрації
    func filterResults (by keyword: String) {
        
        // Фільтрація петицій у фоновому потоці:
        DispatchQueue.global(qos: .userInitiated).async {
            
            // Відбираємо петиції, де заголовок (title) або текст (body) містить введене слово (keyword)
            let filtered = self.petitions.filter {
                $0.title.localizedCaseInsensitiveContains(keyword) ||
                $0.body.localizedCaseInsensitiveContains(keyword) }
            
            DispatchQueue.main.async {
                
                // Фільтруємо петиції
                self.filteredPetitions = filtered
                
                // Вмикаємо режим фільтрації
                self.isFiltering = true
                
                // Оновлюємо таблицю для відфільтрованих результатів
                self.tableView.reloadData()
            }
        }
    }
    
    // Метод очищення фільтра
    func resetFilter() {
        isFiltering = false
        // повертаєио поаний список петицій
        filteredPetitions = petitions
        tableView.reloadData()
    }
    // Обробка (парсингу) отриманого JSON
    func parse(json: Data) {
        
        // Створюємо екземпляр JSONDecoder для перетворення JSON-даних у наші структури Swift
        let decoder = JSONDecoder()
        
        // Спробуємо розпарсити JSON у структуру Petitions
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            
            //  Якщо розбір успішний, оновлюємо масив
            petitions = jsonPetitions.results
            filteredPetitions = petitions
            
            // Оскільки зміна UI (оновлення таблиці) має відбуватись на головному потоці —
            // переходимо на головний потік і оновлюємо таблицю
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            //  Якщо парсинг не вдався — також переходимо на головний потік і показуємо помилку
            DispatchQueue.main.async {
                self.showError()
            }
        }
    }
    
    // Встановлюємо кількість рядків таблиці відповідно до кількості петицій.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Якщо isFiltering  активний - повертає кількість відфільтрованих петицій. Інакше - загальні петиції.
        return isFiltering ? filteredPetitions.count : petitions.count
    }
    
    // Метод що відображає заголовок та опис петиції у відповідній комірці
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Створення комірки
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // Отримуємо відповідну петицію
        let petition = isFiltering ? filteredPetitions[indexPath.row] : petitions[indexPath.row]
    
        // Заповнюємо комірку текстом
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    // Цей метод дозволяє натискати на рядок у таблиці та відкривати екран із деталями.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        // Визначає, який масив використовувати
        vc.detailItem = isFiltering ? filteredPetitions[indexPath.row] : petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

