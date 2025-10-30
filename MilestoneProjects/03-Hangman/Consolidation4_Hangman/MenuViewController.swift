//
//  MenuViewController.swift
//  Consolidation4_Hangman
//
//  Created by mac on 29.04.2025.
//

import UIKit

class MenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.text = "Menu"
        titleLabel.font = .boldSystemFont(ofSize: 32)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50)
        ])
        
        // Кнопка Start Game
        let startButton = UIButton(type: .system)
        startButton.setTitle("Start Game", for: .normal)
        startButton.titleLabel?.font = .systemFont(ofSize: 24)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.addTarget(self, action: #selector(startGameTapped), for: .touchUpInside)
        view.addSubview(startButton)
        
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30)
        ])
        
        // Кнопка Exit
        let exitButton = UIButton(type: .system)
        exitButton.setTitle("Exit", for: .normal)
        exitButton.titleLabel?.font = .systemFont(ofSize: 24)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        view.addSubview(exitButton)
        
        NSLayoutConstraint.activate([
            exitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exitButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 20)
        ])
    }
    
    @objc func startGameTapped() {
        dismiss(animated: true)
    }
    
    @objc func exitTapped() {
        exit(0) // або: navigationController?.popToRootViewController(animated: true)
    }
}
