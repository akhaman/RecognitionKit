//
//  CompoundTextValidator.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 31.10.2022.
//

import Foundation

struct CompoundTextValidator: ITextValidator {
    struct Strategy {
        typealias Validation = (_ input: String, _ validators: [ITextValidator]) -> Bool
        
        private let validateWith: Validation
        
        init(_ validateWith: @escaping Validation) {
            self.validateWith = validateWith
        }
        
        func callAsFunction(input: String, validators: [ITextValidator]) -> Bool {
            validateWith(input, validators)
        }
    }
    
    private let validators: [ITextValidator]
    private let strategy: Strategy
    
    init(_ validators: [ITextValidator], strategy: Strategy = .allSatisfy) {
        self.validators = validators
        self.strategy = strategy
    }
    
    func validate(input: String) -> Bool {
        strategy(input: input, validators: validators)
    }
}

extension CompoundTextValidator {
    init(_ validators: ITextValidator...) {
        self.init(validators)
    }
}

extension ITextValidator where Self == CompoundTextValidator {
    static func allSatisfy(_ validators: [ITextValidator]) -> CompoundTextValidator {
        CompoundTextValidator(validators, strategy: .allSatisfy)
    }
    
    static func allSatisfy(_ validators: ITextValidator...) -> CompoundTextValidator {
        CompoundTextValidator(validators, strategy: .allSatisfy)
    }
    
    static func contains(_ validators: [ITextValidator]) -> CompoundTextValidator {
        CompoundTextValidator(validators, strategy: .contains)
    }
    
    static func contains(_ validators: ITextValidator...) -> CompoundTextValidator {
        CompoundTextValidator(validators, strategy: .contains)
    }
}

extension CompoundTextValidator.Strategy {
    static var allSatisfy: CompoundTextValidator.Strategy {
        CompoundTextValidator.Strategy { input, validators in
            validators.allSatisfy { $0.validate(input: input) }
        }
    }
    
    static var contains: CompoundTextValidator.Strategy {
        CompoundTextValidator.Strategy { input, validators in
            validators.contains { $0.validate(input: input) }
        }
    }
}
