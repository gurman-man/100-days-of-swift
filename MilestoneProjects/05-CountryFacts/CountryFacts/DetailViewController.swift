//
//  DetailViewController.swift
//  CountryFacts
//
//  Created by mac on 08.06.2025.
//

import UIKit
import SafariServices

struct CountryInfoRow {
    let icon: String
    let title: String
    let value: String
}

class DetailViewController: UITableViewController {
    var country: Country?
    var infoRows: [CountryInfoRow] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let country = country else { return }
        
        infoRows = [
            CountryInfoRow(icon: "doc.text.fill", title: "Official Name", value: country.displayOfficialName),
            CountryInfoRow(icon: "person.3.fill", title: "Population", value: country.population.formatted()),
            CountryInfoRow(icon: "map.fill", title: "Area", value: "\(country.area) km²"),
            CountryInfoRow(icon: "phone.fill", title: "Calling code", value: country.displayCallingCode),
            CountryInfoRow(icon: "car.fill", title: "Drive side", value: country.displayDriveSide),
            CountryInfoRow(icon: "clock.fill", title: "Time zones", value: country.displayTimezones),
            CountryInfoRow(icon: "building.columns.fill", title: "Capital", value: country.displayCapital),
            CountryInfoRow(icon: "creditcard.fill", title: "Currency", value: country.displayCurrencies),
            CountryInfoRow(icon: "character.book.closed.fill", title: "Languages", value: country.displayLanguages)
        ]
        
        
        // Прапор у верхній частині
        
        if let flagURL = URL(string: country.flags.png) {
            let container = UIView()
            
            let titleLabel = UILabel()
            titleLabel.text = country.name.common
            titleLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 30, weight: .black)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.numberOfLines = 0
            
            // Прапор
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 5
            imageView.layer.borderWidth = 1
            imageView.layer.borderColor = UIColor.systemGray.cgColor
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.load(url: flagURL)
            
            container.addSubview(imageView)
            container.addSubview(titleLabel)
            
            // Авто-розмітка
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
                titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
                titleLabel.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -12),
                titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),

                imageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
                imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
                imageView.widthAnchor.constraint(equalToConstant: 90),
                imageView.heightAnchor.constraint(equalToConstant: 60),
            ])
            
            // Встановлюємо розміри container після layout
            container.layoutIfNeeded()
            let height = container.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            container.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
            
            tableView.tableHeaderView = container
        }
      
        // Заголовок
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"),                                                     style: .plain,
                                                            target: self,
                                                            action: #selector(showMoreOptions))
    }
    
    @objc func showMoreOptions() {
        let alert = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Read on Wikipedia", style: .default, handler: { [weak self] _ in self?.openWikipedia()
        }))
        
        alert.addAction(UIAlertAction(title: "Share", style: .default, handler: { [weak self] _ in
            self?.shareInfo()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoRows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let info = infoRows[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.selectionStyle = .none
        
        cell.textLabel?.text = info.title
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        cell.detailTextLabel?.text = info.value
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 18)
        cell.detailTextLabel?.textColor = .darkGray
        cell.detailTextLabel?.numberOfLines = 0
        
        cell.imageView?.image = UIImage(systemName: info.icon)
        cell.imageView?.tintColor = .systemMint
        
        return cell
    }
    
    func openWikipedia() {
        guard let country = country else { return }
        let urlString = "https://en.wikipedia.org/wiki/\(country.name.common.replacingOccurrences(of: " ", with: "_"))"
        
        if let url = URL(string: urlString) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        }
    }
    
    func shareInfo() {
        guard let country = country else { return }
        let text = """
               Country: \(country.name.common)
               Capital: \(country.displayCapital)
               Population: \(country.population.formatted())
               Area: \(country.area.formatted()) km²
               """
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = false
    }

}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}
