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
    func recognize(textFrom image: CIImage) throws -> [TextRecognitionCandidate]
}

struct TextRecognitionCandidate: Hashable {
    struct Point: RawRepresentable, Hashable {
        let rawValue: CGPoint
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue.x)
            hasher.combine(rawValue.y)
        }
    }
    
    struct Size: RawRepresentable, Hashable {
        let rawValue: CGSize
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue.height)
            hasher.combine(rawValue.width)
        }
    }
    
    struct Rect: RawRepresentable, Hashable {
        let rawValue: CGRect
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(Point(rawValue: rawValue.origin))
            hasher.combine(Size(rawValue: rawValue.size))
        }
    }
    
    struct Coordinates: Hashable {
        let topLeft: Point
        let topRight: Point
        let bottomLeft: Point
        let bottomRight: Point
        let boundingBox: Rect
    }
    
    let stringValue: String
    let coordinates: Coordinates
}

final class TextRecognizer: ITextRecognizer {
    enum Error: Swift.Error {
        case noDataFound
    }
    
    private let maxCandidatesCount: Int
    
    init(maxCandidatesCount: Int = 20) {
        self.maxCandidatesCount = maxCandidatesCount
    }
    
    func recognize(textFrom image: CIImage) throws -> [TextRecognitionCandidate] {
        let request: VNRecognizeTextRequest = .default()
        let imageRequestHandler = VNImageRequestHandler(ciImage: image)
        try imageRequestHandler.perform([request])
        
        return try request
            .results
            .orThrow(Error.noDataFound)
            .map { try TextRecognitionCandidate.mapped(from: $0) }
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

private extension TextRecognitionCandidate {
    static func mapped(from result: VNRecognizedTextObservation) throws -> TextRecognitionCandidate {
        let stringValue = try result
            .topCandidates(1)
            .first
            .map(\.string)
            .orThrow(TextRecognizer.Error.noDataFound)
        
        return TextRecognitionCandidate(
            stringValue: stringValue,
            coordinates: Coordinates(
                topLeft: Point(rawValue: result.topLeft),
                topRight: Point(rawValue: result.topRight),
                bottomLeft: Point(rawValue: result.bottomLeft),
                bottomRight: Point(rawValue: result.bottomRight),
                boundingBox: Rect(rawValue: result.boundingBox)
            )
        )
    }
}
