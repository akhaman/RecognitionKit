//
//  ICardDataParser.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 31.10.2022.
//

import Foundation

protocol ICardDataParser {
    func parse(recognizedTextLines lines: [String]) -> CardScannerOutputData
}
