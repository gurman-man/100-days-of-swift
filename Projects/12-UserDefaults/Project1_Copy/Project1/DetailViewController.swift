//
//  DetailViewController.swift
//  Project1
//
//  Created by mac on 31.12.2024.
//

import UIKit

class DetailViewController: UIViewController {
    var selectedPictureNumber = 0 // the number of selected image
    var totalPictures = 0 // Total amount of pictures
    var selectedImage: String?
    
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = selectedImage
        navigationItem.largeTitleDisplayMode = .never
        
        imageView.clipsToBounds = true
        
        
        // Do any additional setup after loading the view.
        title = "Picture \(selectedPictureNumber) of \(totalPictures)"
        
        // Download picture
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
