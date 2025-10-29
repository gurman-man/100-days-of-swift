//
//  SelectionViewController.swift
//  Project_30_Challenge
//

import UIKit

/// Контролер для відображення списку зображень у вигляді таблиці.
class SelectionViewController: UITableViewController {
    
    // MARK: - Properties
	var items = [String]()              // Масив імен файлів великих зображень (*-Large.jpg)
    var dirty = false                   // Позначає, чи потрібно оновити таблицю після повернення
    var pictures = [String: UIImage]()  // ключ – назва файлу зображення

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

		title = "Reactionist"
		tableView.rowHeight = 90
		tableView.separatorStyle = .none

        // Завантажуємо всі JPEG із пакета ресурсів
		let fm = FileManager.default
		if let tempItems = try? fm.contentsOfDirectory(atPath: Bundle.main.resourcePath!) {
			for item in tempItems {
				if item.range(of: "Large") != nil {
					items.append(item)
				}
			}
            generatePictures() // Створюємо або підвантажуємо ескізи
		}
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if dirty {
            // Якщо позначено, що таблицю потрібно оновити — перезавантажуємо її
			tableView.reloadData()
		}
	}

    
    // MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Повторюємо список 10 разів для більшої кількості клітинок
        return items.count * 10
    }

    /// Створення комірки з ескізом і лічильником
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        
		let currentImage = items[indexPath.row % items.count]
        cell.imageView?.image =  pictures[currentImage]

        // Додаємо м’яку тінь під ескіз
		cell.imageView?.layer.shadowColor = UIColor.black.cgColor
		cell.imageView?.layer.shadowOpacity = 1
		cell.imageView?.layer.shadowRadius = 10
		cell.imageView?.layer.shadowOffset = CGSize.zero

        // Кількість торкань (рахується у UserDefaults)
		let defaults = UserDefaults.standard
		cell.textLabel?.text = "\(defaults.integer(forKey: currentImage))"

		return cell
    }

    
    // MARK: - TableView Delegate
        /// При виборі комірки відкриваємо повноекранне зображення.
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = ImageViewController()
		vc.image = items[indexPath.row % items.count]
		vc.owner = self
		dirty = false // позначаємо, що не потрібно оновлювати після повернення

		// add to our view controller cache and show
		navigationController!.pushViewController(vc, animated: true)
	}
    
    
    // MARK: - Image Generation
    /// Створює еліптичні ескізи (thumbs) з великих зображень і кешує їх у Documents.
    func generatePictures() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)

        for item in items where item.hasSuffix("-Large.jpg") {
            let thumbName = item.replacingOccurrences(of: "-Large.jpg", with: "-Thumb.png")
            let thumbURL = getDocumentsDirectory().appendingPathComponent(thumbName)

            // Якщо ескіз уже збережено — підвантажуємо його з кешу
            if let cachedImage = UIImage(contentsOfFile: thumbURL.path) {
                pictures[item] = cachedImage
            } else {
                // Інакше генеруємо новий
                if let original = UIImage(contentsOfFile: Bundle.main.path(forResource: item, ofType: nil)!) {
                    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 90, height: 90))
                    let rounded = renderer.image { ctx in
                        ctx.cgContext.addEllipse(in: CGRect(origin: .zero, size: CGSize(width: 90, height: 90)))
                        ctx.cgContext.clip()
                        original.draw(in: CGRect(origin: .zero, size: CGSize(width: 90, height: 90)))
                    }

                    pictures[item] = rounded
                    
                    // Зберігаємо згенерований ескіз у кеш
                    if let data = rounded.pngData() {
                        try? data.write(to: thumbURL)
                    }
                }
            }
        }
    }
    
    /// Метод для отримання шляху до Documents
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
