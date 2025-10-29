//
//  ImageViewController.swift
//  Project_30_Challenge
//

import UIKit

/// Контролер, що відображає повнорозмірне зображення з ефектом плавної появи й періодичного масштабування.
class ImageViewController: UIViewController {
    
    // MARK: - Properties
	weak var owner: SelectionViewController?    // посилання на головний контролер для оновлення
	var image: String?                          // ім’я вибраного зображення
	var animTimer: Timer?                       // таймер для періодичної анімації
    private var imageView = UIImageView()

    // MARK: - View Lifecycle
	override func loadView() {
		super.loadView()
		view.backgroundColor = UIColor.black
        
        // Ініціалізація imageView, який займає весь екран
		imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.alpha = 0
		view.addSubview(imageView)

        NSLayoutConstraint.activate([
                 imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                 imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                 imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                 imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
             ])

        // Таймер, що раз на 5 секунд плавно масштабує зображення
		animTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
			self.imageView.transform = CGAffineTransform.identity
			UIView.animate(withDuration: 3) {
				self.imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
			}
		}
	}

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Завантаження вибраного зображення з бандлу
        guard let image = image,
              let path = Bundle.main.path(forResource: image, ofType: nil),
              let original = UIImage(contentsOfFile: path) else { return }
        
        title = image.replacingOccurrences(of: "-Large.jpg", with: "")
        
        // Малюємо еліптичну рамку для зображення
        let renderer = UIGraphicsImageRenderer(size: original.size)
        let rounded = renderer.image { ctx in
            ctx.cgContext.addEllipse(in: CGRect(origin: CGPoint.zero, size: original.size))
            ctx.cgContext.closePath()
            original.draw(at: CGPoint.zero)
        }
        imageView.image = rounded
    }

    
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        
        // Ефект плавної появи зображення
		imageView.alpha = 0
		UIView.animate(withDuration: 3) { [weak self] in
            self?.imageView.alpha = 1
		}
	}
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animTimer?.invalidate()  // Зупиняємо таймер при виході
    }

    
    // MARK: - Touch Interaction
    /// Збільшує лічильник торкань зображення.
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let imageKey = image else { return }
        let defaults = UserDefaults.standard
        var currentVal = defaults.integer(forKey: imageKey)
        currentVal += 1
        defaults.set(currentVal, forKey: imageKey)
        
        owner?.dirty = true // повідомляємо головний VC, що треба оновити таблицю
	}
    
}
