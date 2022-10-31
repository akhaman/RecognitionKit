//
//  CardData.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 31.10.2022.
//

import Foundation

struct CardData {
    let pan: String?
    let validThru: String?
    let cvc: String?
}

extension CardData: CustomDebugStringConvertible {
    var debugDescription: String {
        """
        PAN: \(pan ?? .unrecognized)
        ValidThru: \(validThru ?? .unrecognized)
        CVC: \(cvc ?? .unrecognized)
        """
    }
}

private extension String {
    static let unrecognized = "unrecognized"
}
