//
//  ViewController.swift
//  Project1
//
//  Created by mac on 23.11.2024.
//

import UIKit

class ViewController: UITableViewController {
    var pictures = [String]()
    
    // словник для підрахунку переглядів
    var viewCounts = [String: Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        // — доступ до сховища для налаштувань програми.
        let defaults = UserDefaults.standard
        
        // Намагаємося отримати збережені дані за ключем "viewCounts"
        if let savedCounts = defaults.dictionary(forKey: "ViewCounts") as? [String: Int] {
            viewCounts = savedCounts
        }

        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Створюємо кнопку рекомендації
        let recommendButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(reccomendApp))
        
        // Додаємо її у праву частину navigation bar
        navigationItem.rightBarButtonItem = recommendButton
        
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("nssl") {
                // this is a picture to load!
                pictures.append(item)
            }
        }
        
        pictures.sort()
        print(pictures)
    }
    
    @objc func reccomendApp() {
        // Текс або посилання, якими ми ділимося
        let appMessage = "I recommend this amazing app! Check it out: https://amzwallpaper.com/app"
        
        
        /* Cпособи розпакування рядка
        ---------------------       let       ---------------------------
        (1) let url = URL(string: "https://amzwallpaper.com/app")!
        
        ---------------------      if let     ---------------------------
        (2) if let url =  URL(string: "https://amzwallpaper.com/app") {
            print("Url created: \(url)")
        }
        else {
            print("Invalid URL.")
        }
         
        ---------------------    guard let    ---------------------------
        (3) guard let  url = URL(string: "https://amzwallpaper.com/app") else {
            print("Invalid URL.")
            return
        }
        
        print("Url created: \(url)")
        */
        
        
        // Ініціалізація UIActivityViewController
        let activityVC = UIActivityViewController(activityItems: [appMessage], applicationActivities: nil)
        
        // Параметри для Ipad
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        present(activityVC, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        
        // Показати кількість переглядів у таблиці
        cell.textLabel?.text = pictures[indexPath.row]
        
        let imageName = pictures[indexPath.row]
        cell.textLabel?.text = imageName
        
        // підпис під назвою картинки в таблиці
        let views = viewCounts[imageName, default: 0]
        cell.detailTextLabel?.text = "Viewed: \(views) times"
        
        return cell
    }
    
    
    // Обробка вибору рядка таблиці
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let imagaName = pictures[indexPath.row]
        // 🔸 1. Збільшуємо лічильник перегляду
        viewCounts[imagaName, default: 0] += 1
        
        // 🔸 2. Зберігаємо словник у UserDefaults
        let defaults = UserDefaults.standard
        defaults.set(viewCounts, forKey: "ViewCounts")
        
        // 🔸 3. Переходимо до перегляду картинки
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedImage = pictures[indexPath.row]
            vc.selectedPictureNumber = indexPath.row + 1
            vc.totalPictures = pictures.count
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

