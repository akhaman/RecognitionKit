//
//  ValidThruTextInputParser.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 31.10.2022.
//

import Foundation

final class ValidThruTextInputParser: ITextInputParser {
    struct Options: OptionSet {
        static let saveSlash = Options(rawValue: 1 << 0)
        
        let rawValue: Int
    }
    
    private let monthValidRange = 1 ... 12
    private let yearValidRange = 0 ... 99
    private let options: Options
    
    init(options: Options = .saveSlash) {
        self.options = options
    }
    
    func parse(input: String) -> String? {
        let inputComponents = input.components(separatedBy: "/")
        
        guard inputComponents.count == 2,
              let month = inputComponents.first.flatMap({ validate(inputComponent: $0, by: monthValidRange) }),
              let year = inputComponents.last.flatMap({ validate(inputComponent: $0, by: yearValidRange) })
            else {
            return nil
        }
        
        return [month, year].joined(separator: options.contains(.saveSlash) ? "/" : "")
    }
    
    private func validate(inputComponent: String, by validRange: ClosedRange<Int>) -> String? {
        guard inputComponent.count == 2,
              let intComponent = Int(inputComponent),
              validRange.contains(intComponent) else {
            return nil
        }
        
        return inputComponent
    }
}
