//
//  LengthTextInputValidator.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 31.10.2022.
//

import Foundation

final class LengthTextInputValidator: ITextInputValidator {
    private let validLengths: Set<Int>
    
    init(validLengths: Set<Int>) {
        self.validLengths = validLengths
    }
    
    func validate(input: String) -> Bool {
        validLengths.contains(input.count)
    }
}

extension LengthTextInputValidator {
    convenience init<S: Sequence>(validLengths: S) where S.Element == Int {
        self.init(validLengths: Set(validLengths))
    }
    
    convenience init(validLengths: Int...) {
        self.init(validLengths: Set(validLengths))
    }
}
