//
//  Optional+Utils.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 31.10.2022.
//

import Foundation

extension Optional {
    func orThrow<E: Error>(_ error: @autoclosure () -> E) throws -> Wrapped {
        guard let wrapped = self else {
            throw error()
        }
        return wrapped
    }
    
    func or(_ alternativeValue: @autoclosure () throws -> Wrapped) rethrows -> Wrapped {
        guard let self = self else {
            return try alternativeValue()
        }
        return self
    }
    
    func apply(_ wrappedHandler: (_ wrapped: Wrapped) throws -> Void) rethrows {
        guard let wrapped = self else {
            return
        }
        try wrappedHandler(wrapped)
    }
}
