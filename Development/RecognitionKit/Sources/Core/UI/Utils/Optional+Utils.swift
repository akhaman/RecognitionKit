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
}
