//
//  CardDataParser.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 31.10.2022.
//

import Foundation

final class CardDataParser: ICardDataParser {
    private let panParser: ITextInputParser
    private let validThruParser: ITextInputParser
    private let cvcParser: ITextInputParser
    
    init(
        panParser: ITextInputParser,
        validThruParser: ITextInputParser,
        cvcParser: ITextInputParser
    ) {
        self.panParser = panParser
        self.validThruParser = validThruParser
        self.cvcParser = cvcParser
    }
    
    func parse(recognizedTextLines lines: [String]) -> CardData {
        var pan: String?
        var validThru: String?
        var cvc: String?
        
        for line in lines {
            if pan == nil {
                pan = panParser.parse(input: line)
            }
            
            if validThru == nil {
                validThru = validThruParser.parse(input: line)
            }
            
            if cvc == nil {
                cvc = cvcParser.parse(input: line)
            }

            if [pan, validThru, cvc].allSatisfy(\.hasText) {
                break
            }
        }
        
        return CardData(pan: pan, validThru: validThru, cvc: cvc)
    }
}

// MARK: - Helpers

private extension Optional where Wrapped == String {
    var hasText: Bool {
        map { !$0.isEmpty } ?? false
    }
}
