//
//  DetailViewController.swift
//  Consolidation5_PhotoList
//
//  Created by mac on 15.05.2025.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    var selectedImageName: String?
    var selectedCaption: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = selectedCaption
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backButtonTitle = ""

        // Завантажуємо зображення
        if let imageName = selectedImageName {
            let path = getDocumentDirectory().appendingPathComponent(imageName)
            imageView.image = UIImage(contentsOfFile: path.path)
            imageView.clipsToBounds = true
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(editCaption))
        
    }
    
    @objc func editCaption() {
        let ac = UIAlertController(title: "Edit caption", message: nil, preferredStyle: .alert)
        ac.addTextField { textField in
            textField.text = self.selectedCaption
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let newCaption = ac.textFields?.first?.text else { return }
            self?.selectedCaption = newCaption
            self?.title = newCaption
            
            // Оновимо у PhotosViewController
            if let navVC = self?.navigationController?.viewControllers.first as?  PhotosViewController,
               let selectedImageName = self?.selectedImageName {
                if let index = navVC.photos.firstIndex(where: { $0.imageName == selectedImageName }) {
                    navVC.photos[index].imageCaption = newCaption
                    
                    // Зберегти у UserDefaults
                    let encoder = JSONEncoder()
                    if let data = try? encoder.encode(navVC.photos) {
                        UserDefaults.standard.set(data, forKey: "photos")
                    }
                    
                    navVC.tableView.reloadData()
                }
            }
        }
        
        ac.addAction(saveAction)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    

    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    // Приховуєм навігаційну панель при тапі, перед тим, як екран стане видимим.
    override func viewWillAppear(_ animated: Bool) {
        // щоб зберегти стандартну поведінку UIViewController
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }

}
