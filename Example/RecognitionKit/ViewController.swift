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
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: Initial Configuration
    
    private func setupView() {
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .camera,
            target: self,
            action: #selector(startTapped)
        )
    }
    
    @objc private func startTapped() {
        let viewController = CardScannerAssembly.assemble()
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }
}
