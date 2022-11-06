//
//  ViewController.swift
//  RecognitionKit
//
//  Created by akhaman on 10/30/2022.
//  Copyright (c) 2022 akhaman. All rights reserved.
//

import UIKit
import RecognitionKit

class ViewController: UIViewController {
    // MARK: UI
    
    private lazy var scanCardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Scan card", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.addTarget(self, action: #selector(scanCardTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var scanPhoneNumberButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Scan phone number", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.addTarget(self, action: #selector(scanPhoneNumberTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: Initial Configuration
    
    private func setupView() {
        view.backgroundColor = .white
        navigationItem.title = "RecognitionKit Example"
        navigationItem.largeTitleDisplayMode = .always
        
        let stack = UIStackView(arrangedSubviews: [scanCardButton, scanPhoneNumberButton])
        stack.axis = .vertical
        stack.spacing = 16
        
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func scanCardTapped() {
        let viewController = try! ScannerAssembly.cardScannerViewController { [weak self] result in
            let result = result.map { results in
                """
                PAN: \(results[.pan] ?? .unrecognized)
                ValidThru: \(results[.validThru] ?? .unrecognized)
                CVC: \(results[.cvc] ?? .unrecognized)
                """
            }
            
            self?.showAlert(messageResult: result)
        }
        
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }
    
    @objc private func scanPhoneNumberTapped() {
        let viewController = try! ScannerAssembly.phoneNumberScannerViewController { [weak self] result in
            let result = result.map { results in
                """
                PhoneNumber: \(results[.phoneNumber] ?? .unrecognized)
                """
            }
            
            self?.showAlert(messageResult: result)
        }
        
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }
    
    private func showAlert(messageResult: Result<String, Error>) {
        let message: String
        
        switch messageResult {
        case let .success(string):
            message = string
        case let .failure(error):
            message = "Failed with error: \(error)"
        }
        
        let alert = UIAlertController(title: "Scan completed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default))
        present(alert, animated: true)
    }
}

private extension String {
    static let unrecognized = "unrecognized"
}
