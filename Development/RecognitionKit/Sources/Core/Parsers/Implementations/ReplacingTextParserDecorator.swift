//
//  ReplacingTextParserDecorator.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 31.10.2022.
//

import Foundation

final class ReplacingTextParserDecorator: ITextInputParser {
    struct Replace {
        private let action: (String) -> String
        
        init(_ action: @escaping (String) -> String) {
            self.action = action
        }
        
        func callAsFunction(_ string: String) -> String {
            action(string)
        }
    }
    
    private let replaces: [Replace]
    private let parser: ITextInputParser
    
    init(replaces: [Replace], parser: ITextInputParser) {
        self.replaces = replaces
        self.parser = parser
    }
    
    func parse(input: String) -> String? {
        let input: String = replaces.reduce(into: input) { partialResult, replace in
            partialResult = replace(partialResult)
        }
        
        return parser.parse(input: input)
    }
}

extension ReplacingTextParserDecorator {
    convenience init(replaces: Replace..., parser: ITextInputParser) {
        self.init(replaces: replaces, parser: parser)
    }
}

extension ReplacingTextParserDecorator.Replace {
    static var removingWhitespaces: ReplacingTextParserDecorator.Replace {
        ReplacingTextParserDecorator.Replace {
            $0.replacingOccurrences(of: " ", with: "")
        }
    }
}
