//
//  ViewController.swift
//  CountryFacts
//
//  Created by mac on 06.06.2025.
//

import UIKit

class ViewController: UITableViewController, UISearchResultsUpdating {
    
    
    // Масив що зберігатиме всі вказані країни
    var countries = [Country]()
    
    // Сюди будемо записувати ті країни, які відповідають пошуковому запиту
    var filteredCoutries = [Country]()
    
    // Контроллер, який додає пошуковий рядок у навігаційну панель
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Зареєстрували нашу кастомну клітинку
        tableView.register(FlagCell.self, forCellReuseIdentifier: "FlagCell")
        
        
        // Заголовок
        navigationItem.title = "Country Facts"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
        // Пошук
        searchController.searchResultsUpdater = self
        
        searchController.obscuresBackgroundDuringPresentation = false
        // Чи має затемнювати вміст прри пошуку (false - ні)
        searchController.searchBar.placeholder = "Search country..."
        // Підказка в полі пошуку
        navigationItem.searchController = searchController
        // Додаємо пошуковий контроллер у навігаційний бар
        definesPresentationContext = true
        // Вказуємо, що пошуковий рядок прив'язаний до поточного екрану
        
        fetchData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        // Беремо текст з пошуку або порожній рядок, якщо тексту немає
        
        filteredCoutries = countries.filter {
            $0.name.common.lowercased().contains(searchText.lowercased())
        }
        // Фільтруємо список країн: якщо назва містить текст з пошуку - залишаємо
        tableView.reloadData()
    }
    
    
    // Загрузка даних
    func fetchData() {
        // Визначаємо URL – звідки будемо отримувати дані
        let urlString = "https://restcountries.com/v3.1/all?fields=name,flags,capital,population,area,currencies,languages,timezones,idd,car"
        
        // Перевіряємо, чи можна створити URL
        if let url = URL(string: urlString) {
            
            DispatchQueue.global(qos: .userInitiated).async {
                if let data = try? Data(contentsOf: url) {
                    
                    // Викликаємо функцію parse(), щоб обробити JSON
                    self.parse(json: data)
                } else {
                    DispatchQueue.main.async {
                        self.showError()
                    }
                }
            }
        }
    }
    
    
    // Обробка, щоб отримати потрібну інформацію в зручному форматі
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        // Спробуємо розпарсити JSON у структуру Country
        if let decodedCountries = try? decoder.decode([Country].self, from: json) {
            countries = decodedCountries.sorted {
                $0.name.common.localizedCaseInsensitiveCompare($1.name.common) == .orderedAscending
            }
            
            // Якщо розбір успішний, оновлюємо масив в головному потоці
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            DispatchQueue.main.async {
                self.showError()
            }
        }
    }
    
    
    func showError() {
        let ac = UIAlertController(title: "Error", message: "There was a problem loading; please check your conection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return "ALL COUNTRIES AND TERRITORIES"
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Щоб показувати або повний список, або лише відфільтровані країни
        return searchController.isActive ? filteredCoutries.count : countries.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FlagCell", for: indexPath) as! FlagCell
        
        let list = searchController.isActive ? filteredCoutries : countries
        let country = list[indexPath.row]
        // Отримуємо відповідну країну
        cell.countryLabel.text = country.displayName
        
        let urlString = country.flags.png
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.flagImageView.image = UIImage(data: data)
                    }
                }
            }
            task.resume()
        }
        
        // Заповнюємо комірку текстом
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    
    // Зроби вищу клітинку (опціонально):
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = searchController.isActive ? filteredCoutries : countries
        let vc = DetailViewController()
        vc.country = list[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

}

