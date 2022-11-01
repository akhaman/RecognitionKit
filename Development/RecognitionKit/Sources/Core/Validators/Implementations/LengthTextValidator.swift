//
//  LengthTextValidator.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 31.10.2022.
//

import Foundation

struct LengthTextValidator: ITextValidator {
    private let validLengths: Set<Int>
    
    init(_ validLengths: Set<Int>) {
        self.validLengths = validLengths
    }
    
    func validate(input: String) -> Bool {
        validLengths.contains(input.count)
    }
}

extension LengthTextValidator {
    init<S: Sequence>(_ validLengths: S) where S.Element == Int {
        self.init(Set(validLengths))
    }
    
    init(_ validLengths: Int...) {
        self.init(validLengths)
    }
}

extension ITextValidator where Self == LengthTextValidator {
    static func length<S: Sequence>(_ validLengths: S) -> LengthTextValidator where S.Element == Int {
        LengthTextValidator(validLengths)
    }
    
    static func length(_ validLengths: Int...) -> LengthTextValidator {
        LengthTextValidator(validLengths)
    }
}


