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
        
        return try ScannerViewController(captureProcess: captureProcess)
    }
    
    public static func phoneNumberScannerViewController(
        receiveOn completionQueue: DispatchQueue = .main,
        _ completion: @escaping (_ result: Result<[PhoneNumberIdentifier: String], Error>) -> Void
    ) throws -> UIViewController {
        let captureProcess = CaptureProcess(
            bufferImageProcessor: SampleBufferImageProcessor(),
            textRecognizer: TextRecognizer(),
            recognizingBuffer: TextRecognizingBuffer<PhoneNumberIdentifier>.phoneNumberScan(
                receiveOn: completionQueue,
                completion
            )
        )
        
        return try ScannerViewController(captureProcess: captureProcess)
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
    
    static func phoneNumberScan(
        receiveOn completionQueue: DispatchQueue,
        _ completion:  @escaping (_ result: Result<[PhoneNumberIdentifier: String], Error>) -> Void
    ) -> TextRecognizingBuffer<PhoneNumberIdentifier> {
        TextRecognizingBuffer<PhoneNumberIdentifier>(
            processors: [
                .phoneNumber: .textPipeline(
                    .firstMatch(withRegex: "^[/\\+]?[(]?[0-9]{3}[)]?[-\\s\\.]?[0-9]{3}[-\\s\\.]?[0-9]{4,6}$")
                )
            ],
            requiredRecognitionsCount: [.phoneNumber: 5],
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
        CardTextIdentifiers(rawValue: "validThru")
    }
    
    public static var cvc: CardTextIdentifiers {
        CardTextIdentifiers(rawValue: "cvc")
    }
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public struct PhoneNumberIdentifier: RawRepresentable, Hashable {
    public static var phoneNumber: PhoneNumberIdentifier {
        PhoneNumberIdentifier(rawValue: "phoneNumber")
    }
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
