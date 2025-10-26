//
//  WebViewController.swift
//  Project16
//
//  Created by mac on 09.06.2025.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate  {
    var webView: WKWebView!
    var city: String?
    
    // Додали змінну, щоб передавати тип URL
    var urlType: URLType = .wikipedia
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        title = city
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Переконайся, що city не nil
        guard let city = city else { return }
        
        // Перетворює назву міста у правильний формат для URL-адреси.
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        // Перевірка для спеціальних назв
        let pageTitle: String

        if city == "Fortnum & Mason" {
            pageTitle = "Fortnum_%26_Mason"
        } else {
            pageTitle = encodedCity ?? city
        }
        
        var urlString: String
        
        switch urlType {
        case .wikipedia:
            urlString = "https://en.wikipedia.org/wiki/\(pageTitle)"
        case .googleMaps:
            urlString = "https://www.google.com/maps/search/?api=1&query=\(encodedCity ?? city)"
        }
        
        // Створи URL і завантаж у WKWebView
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
    }
    
    
    // Це дозволяє нам розрізняти, яку саме URL потрібно завантажити
    enum URLType {
        case wikipedia
        case googleMaps
    }

    // Обробка помилок завантаження сторінки
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        let alert = UIAlertController(title: "Error", message: "Failed to load page", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnSwipe = false
    }

}
