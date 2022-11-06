//
//  PhoneNumberID.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 06.11.2022.
//

import Foundation

public struct PhoneNumberID: RawRepresentable, Hashable {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension PhoneNumberID {
    public static var phoneNumber: PhoneNumberID {
        PhoneNumberID(rawValue: "phoneNumber")
    }
}
