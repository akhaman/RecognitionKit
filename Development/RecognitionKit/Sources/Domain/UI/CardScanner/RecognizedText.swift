//
//  RecognizedText.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 01.11.2022.
//

import Foundation

struct RecognizedText {
    struct Bounds {
        let topLeft: CGPoint
        let topRight: CGPoint
        let bottomLeft: CGPoint
        let bottomRight: CGPoint
        let boundingBox: CGRect
    }
    
    let topCandidates: [String]
    let bounds: Bounds
}

extension RecognizedText: CustomDebugStringConvertible {
    var debugDescription: String {
        """
        topCandidates: \(topCandidates);
        """
    }
}
