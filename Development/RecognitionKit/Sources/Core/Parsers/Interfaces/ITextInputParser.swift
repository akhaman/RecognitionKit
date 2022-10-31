//
//  ITextInputParser.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 31.10.2022.
//

import Foundation

protocol ITextInputParser {
    func parse(input: String) -> String?
}
