//
//  CardScannerAssembly.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 31.10.2022.
//

import Foundation
import UIKit
import AVFoundation

public enum CardScannerAssembly {
    public static func assemble() -> UIViewController {
        let dataParser = CardDataParser(
            panParser: ReplacingTextParserDecorator(
                replaces: .removingWhitespaces,
                parser: ValidatingTextInputParser(
                    validator: .allSatisfy(
                        .length(13...28),
                        .characterSet(.decimalDigits),
                        .luhnAlgorithm
                    )
                )
            ),
            validThruParser: ValidThruTextInputParser(options: .saveSlash),
            cvcParser: ValidatingTextInputParser(
                validator: .allSatisfy(
                    .length(3),
                    .characterSet(.decimalDigits)
                )
            )
        )
        
        let imageProcessor = SampleBufferImageProcessor()
        let textRecognizer = TextRecognizer()
        
        let processor = try! CaptureProcess(
            bufferImageProcessor: imageProcessor,
            textRecognizer: textRecognizer
        )
        
        let viewController = CardScannerViewController(cardDataParser: dataParser, captureProcessor: processor)!
        
        return viewController
    }
}
