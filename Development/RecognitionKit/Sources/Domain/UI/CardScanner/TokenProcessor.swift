//
//  TokenProcessor.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 05.11.2022.
//

import Foundation

struct ProcessedToken {
    let origin: TextRecognitionCandidate
    let normalizedToken: String
}

protocol ITokenProcessor {
    func resolve(
        candidate: TextRecognitionCandidate,
        context: @autoclosure () -> Set<TextRecognitionCandidate>
    ) -> ProcessedToken?
}

struct TextTokenProcessor: ITokenProcessor {
    
    
    func resolve(
        candidate: TextRecognitionCandidate,
        context: @autoclosure () -> Set<TextRecognitionCandidate>
    ) -> ProcessedToken? {
        nil
    }
}
