//
//  CharacterSetTextInputValidator.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 31.10.2022.
//

import Foundation

final class CharacterSetTextInputValidator: ITextInputValidator {
    private let validCharacterSet: CharacterSet
    
    init(validCharacterSet: CharacterSet) {
        self.validCharacterSet = validCharacterSet
    }
    
    func validate(input: String) -> Bool {
        CharacterSet(charactersIn: input).isSubset(of: validCharacterSet)
    }
}
