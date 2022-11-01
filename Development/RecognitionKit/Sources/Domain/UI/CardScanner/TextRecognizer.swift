//
//  TextRecognizer.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 01.11.2022.
//

import Foundation
import CoreImage
import Vision

protocol ITextRecognizer {
    func recognize(textFrom image: CIImage) throws -> [RecognizedText]
}

final class TextRecognizer: ITextRecognizer {
    enum Error: Swift.Error {
        case noDataFound
    }
    
    private let maxCandidatesCount: Int
    
    init(maxCandidatesCount: Int = 20) {
        self.maxCandidatesCount = maxCandidatesCount
    }
    
    func recognize(textFrom image: CIImage) throws -> [RecognizedText] {
        let request: VNRecognizeTextRequest = .default()
        let imageRequestHandler = VNImageRequestHandler(ciImage: image)
        try imageRequestHandler.perform([request])
        
        return try request
            .results
            .orThrow(Error.noDataFound)
            .map { RecognizedText.mapped(from: $0, maxCandidatesCount: maxCandidatesCount) }        
    }
}

// MARK: - VNRecognizeTextRequest + Utils

private extension VNRecognizeTextRequest {
    static func `default`() -> VNRecognizeTextRequest {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        return request
    }
}

// MARK: - RecognizedText + Mapping {

private extension RecognizedText {
    static func mapped(
        from result: VNRecognizedTextObservation,
        maxCandidatesCount: Int
    ) -> RecognizedText {
        let candidates = result
            .topCandidates(maxCandidatesCount)
            .map(\.string)
        
        let bounds = Bounds(
            topLeft: result.topLeft,
            topRight: result.topRight,
            bottomLeft: result.bottomLeft,
            bottomRight: result.bottomRight,
            boundingBox: result.boundingBox
        )
        
        return RecognizedText(
            topCandidates: candidates,
            bounds: bounds
        )
    }
}
