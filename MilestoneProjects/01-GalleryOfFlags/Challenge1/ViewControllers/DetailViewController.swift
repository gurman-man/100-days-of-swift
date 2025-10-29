//
//  DetailViewController.swift
//  Challenge1
//
//  Created by mac on 17.01.2025.
//

import UIKit

class DetailViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet var imageView: UIImageView!
    
    // MARK: - Properties
    
    var selectedFlag: Flag? //зберігає назву прапора
   
    // MARK: - Lifecycle
    // коли UIViewController ініціалізований викликається:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray5
        navigationItem.largeTitleDisplayMode = .never
        
        // Зображення буде обрізатись, якщо воно виходить за межі видимого простору
        imageView.clipsToBounds = true
        
        // Завантаження зображення
        if let flag = selectedFlag {
            title = flag.country
            imageView.image = UIImage(named: flag.imageName)
            imageView.contentMode = .scaleAspectFit
        }
        
        // Створення кнопки - поділитися
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        navigationItem.rightBarButtonItem = shareButton
    }
    
    
    // MARK: - Navigation Bar
    
    // Ховає панель навігації при настисканні на екран
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    // Відновлює панель навігації при поверненні до іншого екрану
     override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    
    
    // MARK: - Actions
    @objc func shareTapped() {
        guard let image = imageView.image else {
            print("No image found")
            return
        }
        
        // Ініціалізація UIActivityViewController
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        present(activityVC, animated: true)
    }
}
