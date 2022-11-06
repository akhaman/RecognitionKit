//
//  TextValidator.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 05.11.2022.
//

import Foundation

struct TextValidator: ITextValidator {
    struct Strategy {
        private let validate: (String) -> Bool
        
        init(_ validate: @escaping (String) -> Bool) {
            self.validate = validate
        }
        
        func callAsFunction(_ input: String) -> Bool {
            validate(input)
        }
    }
    
    private let strategy: Strategy
    
    init(strategy: Strategy) {
        self.strategy = strategy
    }
    
    func validate(input: String) -> Bool {
        strategy(input)
    }
}

extension ITextValidator where Self == TextValidator {
    static func length<S: Sequence>(in validLength: S) -> TextValidator where S.Element == Int {
        TextValidator(strategy: .length(in: validLength))
    }
    
    static func length(in validLength: Int...) -> TextValidator {
        TextValidator(strategy: .length(in: validLength))
    }
    
    static func length<S: Sequence>(out invalidLength: S) -> TextValidator where S.Element == Int {
        TextValidator(strategy: .length(out: invalidLength))
    }
    
    static func length(out invalidLength: Int...) -> TextValidator {
        TextValidator(strategy: .length(out: invalidLength))
    }
    
    static func characters(in validCharacters: CharacterSet) -> TextValidator {
        TextValidator(strategy: .characters(in: validCharacters))
    }
    
    static func matches(withRegex pattern: String) -> TextValidator {
        TextValidator(strategy: .matches(withRegex: pattern))
    }
}

extension TextValidator.Strategy {
    static func length<S: Sequence>(in validLength: S) -> TextValidator.Strategy where S.Element == Int {
        TextValidator.Strategy { input in
            validLength.contains(input.count)
        }
    }
    
    static func length(in validLength: Int...) -> TextValidator.Strategy {
        length(in: validLength)
    }
    
    static func length<S: Sequence>(out invalidLength: S) -> TextValidator.Strategy where S.Element == Int {
        TextValidator.Strategy { input in
            !invalidLength.contains(input.count)
        }
    }
    
    static func length(out invalidLength: Int...) -> TextValidator.Strategy {
        length(out: invalidLength)
    }
    
    static func characters(in validCharacters: CharacterSet) -> TextValidator.Strategy {
        TextValidator.Strategy { input in
            CharacterSet(charactersIn: input).isSubset(of: validCharacters)
        }
    }
    
    static func matches(withRegex pattern: String) -> TextValidator.Strategy {
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        
        return TextValidator.Strategy { input in
            let inputRange = NSRange(input.startIndex..<input.endIndex, in: input)

            return regex
                .flatMap { $0.firstMatch(in: input, range: inputRange) }
                .map(\.range)
                .map { $0 == inputRange }
                .or(false)
        }
    }
}
