//
//  PANParser.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 31.10.2022.
//

import Foundation

final class ValidatingTextInputParser: ITextInputParser {
    private let validator: ITextValidator
    
    init(validator: ITextValidator) {
        self.validator = validator
    }
    
    func parse(input: String) -> String? {
        validator.validate(input: input) ? input : nil
    }
}
