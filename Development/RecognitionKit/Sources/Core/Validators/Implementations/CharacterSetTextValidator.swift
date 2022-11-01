//
//  CharacterSetTextValidator.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 31.10.2022.
//

import Foundation

struct CharacterSetTextValidator: ITextValidator {
    private let validCharacters: CharacterSet
    
    init(_ validCharacters: CharacterSet) {
        self.validCharacters = validCharacters
    }
    
    func validate(input: String) -> Bool {
        CharacterSet(charactersIn: input).isSubset(of: validCharacters)
    }
}

extension ITextValidator where Self == CharacterSetTextValidator {
    static func characterSet(_ validCharacters: CharacterSet) -> CharacterSetTextValidator {
        CharacterSetTextValidator(validCharacters)
    }
}
