//
//  PaymentCardID.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 06.11.2022.
//

import Foundation

public struct PaymentCardID: RawRepresentable, Hashable {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension PaymentCardID {
    public static var pan: PaymentCardID {
        PaymentCardID(rawValue: "pan")
    }
    
    public static var validThru: PaymentCardID {
        PaymentCardID(rawValue: "validThru")
    }
    
    public static var cvc: PaymentCardID {
        PaymentCardID(rawValue: "cvc")
    }
}
