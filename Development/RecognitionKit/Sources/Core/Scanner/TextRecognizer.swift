//
//  TextRecognizer.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 01.11.2022.
//

import Foundation
import CoreImage
import Vision

public struct TextRecognitionCandidate: Hashable {
    public struct Point: RawRepresentable, Hashable {
        public let rawValue: CGPoint
        
        public init(rawValue: CGPoint) {
            self.rawValue = rawValue
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue.x)
            hasher.combine(rawValue.y)
        }
    }
    
    public struct Size: RawRepresentable, Hashable {
        public let rawValue: CGSize
        
        public init(rawValue: CGSize) {
            self.rawValue = rawValue
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue.height)
            hasher.combine(rawValue.width)
        }
    }
    
    public struct Rect: RawRepresentable, Hashable {
        public let rawValue: CGRect
        
        public init(rawValue: CGRect) {
            self.rawValue = rawValue
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(Point(rawValue: rawValue.origin))
            hasher.combine(Size(rawValue: rawValue.size))
        }
    }
    
    public struct Coordinates: Hashable {
        public let topLeft: Point
        public let topRight: Point
        public let bottomLeft: Point
        public let bottomRight: Point
        public let boundingBox: Rect
        
        public init(
            topLeft: Point,
            topRight: Point,
            bottomLeft: Point,
            bottomRight: Point,
            boundingBox: Rect
        ) {
            self.topLeft = topLeft
            self.topRight = topRight
            self.bottomLeft = bottomLeft
            self.bottomRight = bottomRight
            self.boundingBox = boundingBox
        }
        
    }
    
    public let stringValue: String
    public let coordinates: Coordinates
    
    public init(stringValue: String, coordinates: Coordinates) {
        self.stringValue = stringValue
        self.coordinates = coordinates
    }
}

protocol ITextRecognizer {
    func recognize(textFrom image: CIImage) throws -> [TextRecognitionCandidate]
}

final class TextRecognizer: ITextRecognizer {
    enum Error: Swift.Error {
        case noDataFound
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
