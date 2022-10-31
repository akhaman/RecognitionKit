//
//  ITextInputValidator.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 31.10.2022.
//

import Foundation

protocol ITextInputValidator {
    func validate(input: String) -> Bool
}
