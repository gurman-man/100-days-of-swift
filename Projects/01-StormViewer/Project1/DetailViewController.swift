//
//  DetailViewController.swift
//  Project1
//
//  Created by mac on 31.12.2024.
//

import UIKit

class DetailViewController: UIViewController {
    var selectedPictureNumber = 0               // кількість вибраних зображень
    var totalPictures = 0                       // кількість всіх зображень
    var selectedImage: String?
    
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(selectedImage != nil, "SelectedImage is nil - – you must set it before showing DetailViewController.")
        
        title = selectedImage
        navigationItem.largeTitleDisplayMode = .never
        
        imageView.clipsToBounds = true
        
        title = "Picture \(selectedPictureNumber) of \(totalPictures)"
        
        // Завантаження зображення
        if let selectedImage = selectedImage {
            imageView.image = UIImage(named: selectedImage)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }

}
