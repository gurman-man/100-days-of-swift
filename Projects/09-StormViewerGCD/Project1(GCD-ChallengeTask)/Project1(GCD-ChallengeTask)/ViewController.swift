//
//  ViewController.swift
//  Project1
//
//  Created by mac on 23.11.2024.
//

import UIKit

class ViewController: UITableViewController {
    var pictures = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Створюємо кнопку рекомендації
        let recommendButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(reccomendApp))
        
        // Додаємо її у праву частину navigation bar
        navigationItem.rightBarButtonItem = recommendButton
        
        // Запускає код у фоновому потоці, щоби не блокувати основний UI.
        DispatchQueue.global(qos: .utility).async {
            [weak self] in
            
            // Це — захист від retain cycle.
            guard let self = self else { return }
            
            // Отримуємо список файлів з ресурсу програми (Bundle.main.resourcePath!), тобто файлів, які були додані до проєкту (наприклад, nssl001.jpg, nssl002.jpg тощо).
            let fm = FileManager.default
            let path = Bundle.main.resourcePath!
            let items = try! fm.contentsOfDirectory(atPath: path)
            
            // Ми створюємо тимчасовий масив, щоб працювати з даними у фоні, не чіпаючи self.pictures, який пов'язаний із UI.
            var tempPictures = [String]()
            
            for item in items {
                if item.hasPrefix("nssl") {
                    // this is a picture to load!
                    tempPictures.append(item)
                }
            }
            
            tempPictures.sort()
            
            DispatchQueue.main.async {
                // Ми змінюємо self.pictures, який впливає на UI.
                self.pictures = tempPictures
                // Ми викликаємо self.tableView.reloadData(), а UI завжди треба оновлювати лише з головного потоку
                self.tableView.reloadData()
            }
        }
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
        cell.textLabel?.text = pictures[indexPath.row]
        return cell
    }
    
    
    // Обробка вибору рядка таблиці
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedImage = pictures[indexPath.row]
            vc.selectedPictureNumber = indexPath.row + 1
            vc.totalPictures = pictures.count
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

