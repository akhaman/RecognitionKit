//
//  CompoundTokenProcessor.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 05.11.2022.
//

import Foundation

struct ProcessedToken {
    let origin: TextRecognitionCandidate
    let result: String
}

protocol ITokenProcessor {
    func process(
        candidate: TextRecognitionCandidate,
        context: @autoclosure () -> Set<TextRecognitionCandidate>
    ) -> String?
}

protocol ITextProcessor {
    func process(_ text: String) -> String?
}

struct CompoundTokenProcessor: ITokenProcessor {
    struct Strategy {
        typealias Process = (
            _ processors: [ITextProcessor],
            _ initialValue: String
        ) -> String?
        
        private let process: Process
        
        init(_ process: @escaping Process) {
            self.process = process
        }
        
        func callAsFunction(
            _ processors: [ITextProcessor],
            _ candidate: TextRecognitionCandidate,
            _ context: () -> Set<TextRecognitionCandidate>
        ) -> String? {
            process(processors, candidate.stringValue)
        }
    }
    
    private let processors: [ITextProcessor]
    private let strategy: Strategy
    
    init(processors: [ITextProcessor], strategy: Strategy) {
        self.processors = processors
        self.strategy = strategy
    }
    
    func process(
        candidate: TextRecognitionCandidate,
        context: @autoclosure () -> Set<TextRecognitionCandidate>
    ) -> String? {
        strategy(processors, candidate, context)
    }
}

extension ITokenProcessor where Self == CompoundTokenProcessor {
    static func textPipeline(_ processors: [ITextProcessor]) -> CompoundTokenProcessor {
        CompoundTokenProcessor(processors: processors, strategy: .textPipeline())
    }
    
    static func textPipeline(_ processors: ITextProcessor...) -> CompoundTokenProcessor {
        CompoundTokenProcessor(processors: processors, strategy: .textPipeline())
    }
}

extension CompoundTokenProcessor.Strategy {
    static func textPipeline() -> CompoundTokenProcessor.Strategy {
        CompoundTokenProcessor.Strategy { processors, initialValue in
            try? processors.reduce(initialValue) { partialResult, processor in
                processor.process(try partialResult.orThrow(EmptyError()))
            }
        }
    }
}

struct TextProcessor: ITextProcessor {
    struct Strategy {
        private let process: (_ text: String) -> String?
        
        init(_ process: @escaping (_ text: String) -> String?) {
            self.process = process
        }
        
        func callAsFunction(_ text: String) -> String? {
            process(text)
        }
    }
    
    private let strategy: Strategy
    
    init(strategy: Strategy) {
        self.strategy = strategy
    }
    
    func process(_ text: String) -> String? {
        strategy(text)
    }
}

extension ITextProcessor where Self == TextProcessor {
    static func temporaryMutation(_ processors: ITextProcessor...) -> TextProcessor {
        TextProcessor(strategy: .temporaryMutation(processors))
    }
    
    static func normalize(_ normalizer: ITextProcessor) -> TextProcessor {
        TextProcessor(strategy: .normalize(normalizer))
    }
    
    static func validate(_ validator: ITextValidator) -> TextProcessor {
        TextProcessor(strategy: .validate(validator))
    }
    
    static func replaceOccurrences(_ characters: String, with newCharacters: String) -> TextProcessor {
        TextProcessor(strategy: .replaceOccurrences(of: characters, with: newCharacters))
    }
    
    static func trimCharacters(in set: CharacterSet) -> TextProcessor {
        TextProcessor(strategy: .trimCharacters(in: set))
    }
}

extension TextProcessor.Strategy {
    static func temporaryMutation(_ processors: [ITextProcessor]) -> TextProcessor.Strategy {
        TextProcessor.Strategy { text in
            let processed = try? processors.reduce(text) { partialResult, processor in
                processor.process(try partialResult.orThrow(EmptyError()))
            }
            
            return processed.map { _ in text }
        }
    }
    
    static func temporaryMutation(_ processors: ITextProcessor...) -> TextProcessor.Strategy {
        temporaryMutation(processors)
    }
    
    static func normalize(_ normalizer: ITextProcessor) -> TextProcessor.Strategy {
        TextProcessor.Strategy { text in
            normalizer.process(text)
        }
    }
    
    static func validate(_ validator: ITextValidator) -> TextProcessor.Strategy {
        TextProcessor.Strategy { text in
            validator.validate(input: text) ? text : nil
        }
    }
    
    static func replaceOccurrences(of characters: String, with newCharacters: String) -> TextProcessor.Strategy {
        TextProcessor.Strategy { text in
            text.replacingOccurrences(of: characters, with: newCharacters)
        }
    }
    
    static func trimCharacters(in set: CharacterSet) -> TextProcessor.Strategy {
        TextProcessor.Strategy { text in
            text.trimmingCharacters(in: set)
        }
    }
}

private struct EmptyError: Swift.Error {}
