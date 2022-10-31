//
//  CompoundTextInputValidator.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 31.10.2022.
//

import Foundation

final class CompoundTextInputValidator: ITextInputValidator {
    private let validators: [ITextInputValidator]
    
    init(validators: [ITextInputValidator]) {
        self.validators = validators
    }
    
    func validate(input: String) -> Bool {
        validators.allSatisfy { $0.validate(input: input) }
    }
}

extension CompoundTextInputValidator {
    convenience init(_ validators: ITextInputValidator...) {
        self.init(validators: validators)
    }
}
