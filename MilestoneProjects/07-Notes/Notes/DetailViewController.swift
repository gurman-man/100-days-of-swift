//
//  DetailViewController.swift
//  Notes
//
//  Created by mac on 05.07.2025.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    var note: Note?
    var onSave: ((Note?) -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemIndigo.withAlphaComponent(0.99)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareNote))
        
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped)),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(confirmDelete))
        ]
        
        configureTextView()
        
        // Gesture для сховання клавіатури при тапі поза textView
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    
    func configureTextView() {
        textView.text = note?.text
        textView.font = UIFont(name: "Noteworthy-Bold", size: 20)
        textView.textColor = .black
        textView.backgroundColor = .white
        textView.textContainerInset = .zero
        textView.contentInset = .zero
        textView.contentInsetAdjustmentBehavior = .never
        textView.layer.cornerRadius = 12
        textView.layer.borderWidth = 2
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    // MARK: - Actions
    
    @objc func shareNote() {
        guard let text = textView.text, !text.isEmpty else { return }
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(vc, animated: true)
    }
    
    @objc func doneTapped() {
        guard var updatedNote = note else { return }
        updatedNote.text = textView.text
        updatedNote.date = Date()
        onSave?(updatedNote)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func confirmDelete() {
        let ac = UIAlertController(title: "Delete Note", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.onSave?(nil)
            self?.navigationController?.popViewController(animated: true)
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true) // ховає клавіатуру з будь-якого активного поля
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    // MARK: - Збереження нотатки при виході
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if var updatedNote = note, updatedNote.text != textView.text {
            updatedNote.text = textView.text
            updatedNote.date = Date()
            onSave?(updatedNote)
        }
    }
    
}
