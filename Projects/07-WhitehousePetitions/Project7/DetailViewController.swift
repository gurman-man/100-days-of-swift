//
//  DetailViewController.swift
//  Project7
//
//  Created by mac on 13.02.2025.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    var webView: WKWebView!
    var detailItem: Petition?
    
    // Перевизначається, щоб встановити веб-сторінку як головне view
    override func loadView() {
        // Вимикаємо великий заголовок для цього екрану
        navigationItem.largeTitleDisplayMode = .never
        
        // Встановлюємо звичайний заголовок по центру
        title = "Whitehouse news"
        
        webView = WKWebView()
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Перевірка чи дані існують
        guard let detailItem = detailItem else { return }
        
        // створюємо HTML-рядок у Swift
        let html  = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style> 
            body { 
                font-size: 18px; 
                font-family: -apple-system, BlinkMacSystemFont;
                line-height: 1.6;
                padding: 20px;
                text-align: justify;
                max-width: 800px;
                margin: auto;
            }
            h1 {
                font-size: 24px;
                text-align: justify;
                color: #385;
            }
        </style>
        </head>
        <body>
            <h1>\(detailItem.title)</h1>
            <p>\(detailItem.body.replacingOccurrences(of: "\n", with: "<br>"))</p>
        </body>
        </html>
        """
        
        // Завантаження html
        webView.loadHTMLString(html, baseURL: nil)
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
