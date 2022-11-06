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
        button.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
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
        
        view.addSubview(scanCardButton)
        scanCardButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scanCardButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanCardButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
    }
    
    @objc private func startTapped() {
        let viewController = try! ScannerAssembly.cardScannerViewController { [weak self] result in
            let result = result.map { results in
                """
                PAN: \(results[.pan] ?? .unrecognized)
                ValidThru: \(results[.validThru] ?? .unrecognized)
                CVC: \(results[.cvc] ?? .unrecognized)
                """
            }
            
            let message: String
            
            switch result {
            case let .success(string):
                message = string
            case let .failure(error):
                message = "Failed with error: \(error)"
            }
            
            self?.showAlert(message: message)
        }
        
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Scan completed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default))
        present(alert, animated: true)
    }
}

private extension String {
    static let unrecognized = "unrecognized"
}
