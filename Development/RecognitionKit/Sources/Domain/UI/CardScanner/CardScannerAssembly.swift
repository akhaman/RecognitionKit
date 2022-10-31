//
//  CardScannerAssembly.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 31.10.2022.
//

import Foundation
import UIKit

public enum CardScannerAssembly {
    public static func assemble() -> UIViewController {
        let dataParser = CardDataParser(
            panParser: ReplacingTextParserDecorator(
                replaces: .removingWhitespaces,
                parser: ValidatingTextInputParser(
                    validator: CompoundTextInputValidator(
                        LengthTextInputValidator(validLengths: 13...28),
                        CharacterSetTextInputValidator(validCharacterSet: .decimalDigits),
                        LuhnValidator()
                    )
                )
            ),
            validThruParser: ValidThruTextInputParser(options: .saveSlash),
            cvcParser: ValidatingTextInputParser(
                validator: CompoundTextInputValidator(
                    LengthTextInputValidator(validLengths: 3),
                    CharacterSetTextInputValidator(validCharacterSet: .decimalDigits)
                )
            )
        )
        
        let viewController = CardScannerViewController(cardDataParser: dataParser)!
        return viewController
    }
}
