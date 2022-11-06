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
    public static func cardScannerViewController(
        receiveOn completionQueue: DispatchQueue = .main,
        _ completion: @escaping (_ result: Result<[CardTextIdentifiers: String], Error>) -> Void
    ) throws -> UIViewController {
        let captureProcess = CaptureProcess(
            bufferImageProcessor: SampleBufferImageProcessor(),
            textRecognizer: TextRecognizer(),
            recognizingBuffer: TextRecognizingBuffer<CardTextIdentifiers>.`cardScan`(
                receiveOn: completionQueue,
                completion
            )
        )
        
        return try CardScannerViewController(captureProcess: captureProcess)
    }
}

private extension TextRecognizingBuffer {
    static func cardScan(
        receiveOn completionQueue: DispatchQueue = .main,
        _ completion: @escaping (_ result: Result<[CardTextIdentifiers: String], Error>) -> Void
    ) -> TextRecognizingBuffer<CardTextIdentifiers> {
        TextRecognizingBuffer<CardTextIdentifiers>(
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
            completionQueue: completionQueue,
            completion: completion
        )
    }
}

public struct CardTextIdentifiers: RawRepresentable, Hashable {
    public static var pan: CardTextIdentifiers {
        CardTextIdentifiers(rawValue: "pan")
    }
    
    public static var validThru: CardTextIdentifiers {
        CardTextIdentifiers(rawValue: "valid")
    }
    
    public static var cvc: CardTextIdentifiers {
        CardTextIdentifiers(rawValue: "cvc")
    }
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
