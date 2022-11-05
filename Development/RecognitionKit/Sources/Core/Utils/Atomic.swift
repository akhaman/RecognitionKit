//
//  Atomic.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 01.11.2022.
//

import Foundation

final class Atomic<Wrapped> {
    private let lock = NSLock()
    private var wrapped: Wrapped
    
    init(_ wrapped: Wrapped) {
        self.wrapped = wrapped
    }
    
    func around<T>(_ block: (inout Wrapped) throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try block(&wrapped)
    }
}
