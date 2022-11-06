//
//  Sequence+Utils.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 04.11.2022.
//

import Foundation

extension Sequence where Element: Hashable {
    func convertToSet() -> Set<Element> {
        (self as? Set<Element>) ?? Set(self)
    }
}
