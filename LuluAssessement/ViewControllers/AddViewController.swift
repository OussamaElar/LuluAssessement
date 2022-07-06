//
//  AddViewController.swift
//  LuluAssessement
//
//  Created by Ouss Elar on 7/1/22.
//

import UIKit
import Foundation

class AddViewController: UIViewController {

    
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Garment Name:"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private let textField: UITextField = {
        let input = UITextField()
        input.translatesAutoresizingMaskIntoConstraints = false
        input.layer.cornerRadius = 5
        input.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: input.frame.height))
        input.leftViewMode = .always
        input.layer.borderWidth = 0.7
        input.borderStyle = .roundedRect
        return input
    }()
    
    
    private func configNaVBar() {
        let save = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveAction))
        navigationItem.rightBarButtonItem = save
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "ADD"
        view.addSubview(nameLabel)
        view.addSubview(textField)
        configNaVBar()
        addConstraints()
    }

    @objc func saveAction() {
        guard let name = textField.text else {
           return
        }

        PersistData().addToList(with: Garment(name: name, dateAdded: Date.now)) { result in
            switch result {
            case .success(()):
                print("Saved successfully: ", Date.now)
                NotificationCenter.default.post(name: NSNotification.Name("saved"), object: nil)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        dismiss(animated: true )
    }
    
    private func addConstraints() {
        let labelConstraints = [
            nameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        ]
        let inputConstraints = [
            textField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ]
        NSLayoutConstraint.activate(labelConstraints)
        NSLayoutConstraint.activate(inputConstraints)
    }
}
