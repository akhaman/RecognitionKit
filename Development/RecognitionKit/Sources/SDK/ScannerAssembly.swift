//
//  ScannerAssembly.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 31.10.2022.
//

import Foundation
import UIKit
import AVFoundation

public enum ScannerAssembly {
    public static func scannerViewController(recognizingBuffer: ITextRecognizingBuffer) throws -> UIViewController {
        let captureProcess = CaptureProcess(
            bufferImageProcessor: SampleBufferImageProcessor(),
            textRecognizer: TextRecognizer(),
            recognizingBuffer: recognizingBuffer
        )
        
        return try ScannerViewController(captureProcess: captureProcess)
    }
    
    
    public static func cardScannerViewController(
        _ completion: @escaping (_ result: Result<[PaymentCardID: String], Error>) -> Void
    ) throws -> UIViewController {
        let recognizingBuffer = TextRecognizingBuffer<PaymentCardID>(
            processors: [
                .pan: .textPipeline(
                    .temporaryMutation(
                        .replaceOccurrences(" ", with: ""),
                        .validate(
                            .allSatisfy(
                                .length(in: 13...28),
                                .characters(in: .decimalDigits),
                                .luhnAlgorithm
                            )
                        )
                    )
                ),
                .validThru: .textPipeline(
                    .validate(
                        .matches(withRegex: "(0[1-9]|1[0-2])/[0-9]{2}")
                    )
                ),
                .cvc: .textPipeline(
                    .validate(
                        .matches(withRegex: "[0-9]{3}")
                    )
                )
            ],
            requiredRecognitionsCount: [
                .pan: 5,
                .validThru: 5,
                .cvc: 0
            ],
            completion: completion
        )
        
        return try scannerViewController(recognizingBuffer: recognizingBuffer)
    }
    
    public static func phoneNumberScannerViewController(
        _ completion: @escaping (_ result: Result<[PhoneNumberID: String], Error>) -> Void
    ) throws -> UIViewController {
        let recognizingBuffer = TextRecognizingBuffer<PhoneNumberID>(
            processors: [
                .phoneNumber: .textPipeline(
                    .firstMatch(withRegex: "^[/\\+]?[(]?[0-9]{3}[)]?[-\\s\\.]?[0-9]{3}[-\\s\\.]?[0-9]{4,6}$")
                )
            ],
            requiredRecognitionsCount: [.phoneNumber: 5],
            completion: completion
        )
        
        return try scannerViewController(recognizingBuffer: recognizingBuffer)
    }
}
