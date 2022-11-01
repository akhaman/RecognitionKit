//
//  LuhnValidator.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 31.10.2022.
//

import Foundation

/// Валидация номера карты с помощью алгоритма вычисления контрольной цифры
/// номера в соответствии со стандартом `ISO/IEC 7812`
///
/// [Validation with Luhn's algorithm from GitHub](https://gist.github.com/J-L/e2294d19677bbb34c6e1)
struct LuhnValidator: ITextValidator {
    func validate(input: String) -> Bool {
        var luhnSum = 0
        var digitCount = 0
        
        for c in input.reversed() {
            let thisDigit = Int(String(c as Character)) ?? 0
            digitCount += 1
            if digitCount % 2 == 0 {
                if thisDigit * 2 > 9 {
                    luhnSum += thisDigit * 2 - 9
                } else {
                    luhnSum += thisDigit * 2
                }
            } else {
                luhnSum += thisDigit
            }
        }
        if luhnSum % 10 == 0 {
            return true
        }
        return false
    }
}

extension ITextValidator where Self == LuhnValidator {
    static var luhnAlgorithm: LuhnValidator {
        LuhnValidator()
    }
}
