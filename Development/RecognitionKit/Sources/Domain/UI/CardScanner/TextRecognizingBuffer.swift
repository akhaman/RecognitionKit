//
//  TextRecognizingBuffer.swift
//  RecognitionKit
//
//  Created by Руслан Ахмадеев on 31.10.2022.
//

import Foundation

protocol ITextRecognizingBufferDelegate: AnyObject {
    func recognizingBuffer(
        _ buffer: ITextRecognizingBuffer,
        received receivedCandidates: Set<TextRecognitionCandidate>,
        updatedWith candidates: Set<TextRecognitionCandidate>,
        completelyFilled: Bool
    )
}

protocol ITextRecognizingBuffer {
    func setup(with delegate: ITextRecognizingBufferDelegate)
    func update(with candidates: Set<TextRecognitionCandidate>)
    func complete()
    func complete(with error: Error)
}

final class TextRecognizingBuffer<TokenID: Hashable> {
    typealias Completion = (_ result: Result<[TokenID: String], Error>) -> Void
    
    // MARK: Dependencies
    
    private let processors: [TokenID: ITokenProcessor]
    private let requiredRecognitionsCount: [TokenID: Int]
    private let completionQueue: DispatchQueue
    
    // MARK: State
    
    private weak var delegate: ITextRecognizingBufferDelegate?
    private var completion: Completion?
    private var bufferedNormalizedTokens: [TokenID: [String]] = [:]
    
    init(
        processors: [TokenID: ITokenProcessor],
        requiredRecognitionsCount: [TokenID: Int],
        completionQueue: DispatchQueue,
        completion: @escaping Completion
    ) {
        self.processors = processors
        self.requiredRecognitionsCount = requiredRecognitionsCount
        self.completionQueue = completionQueue
        self.completion = completion
    }
    
    private func unfilledTokens() -> Set<TokenID> {
        let result = processors
            .filter { tokenID, _ in
                bufferedNormalizedTokens[tokenID, default: []].count
                < requiredRecognitionsCount[tokenID, default: .zero]
            }
            .keys
            .convertToSet()
        
        return result
    }
}

// MARK: - ITextRecognizingBuffer

extension TextRecognizingBuffer: ITextRecognizingBuffer {
    func setup(with delegate: ITextRecognizingBufferDelegate) {
        self.delegate = delegate
    }
    
    func update(with candidates: Set<TextRecognitionCandidate>) {
        let processedTokens: [TokenID: [ProcessedToken]] = candidates
            .map { candidate in
                processors.compactMapValues { processor in
                    processor
                        .process(candidate: candidate, context: candidates.subtracting(candidate))
                        .map { ProcessedToken(origin: candidate, result: $0) }
                    }
            }
            .reduce(into: [:]) { partialResult, processedTokens in
                processedTokens.forEach { tokenID, processedToken in
                    partialResult[tokenID, default: []].append(processedToken)
                }
            }
        
        processedTokens.forEach { tokenID, tokens in
            bufferedNormalizedTokens[tokenID, default: []]
                .append(contentsOf: tokens.map(\.result))
        }
        
        delegate?.recognizingBuffer(
            self,
            received: candidates,
            updatedWith: processedTokens
                .flatMap { $1.map(\.origin) }
                .convertToSet(),
            completelyFilled: unfilledTokens().isEmpty
        )
    }
    
    func complete() {
        complete(with: .success(()))
    }
    
    func complete(with error: Error) {
        complete(with: .failure(error))
    }
        
    private func complete(with result: Result<Void, Error>) {
        guard let completion = completion else { return }
        self.completion = nil
        
        let result = result.map {
            bufferedNormalizedTokens.compactMapValues(\.mostFrequentElement)
        }
        bufferedNormalizedTokens.removeAll()
        
        completionQueue.async {
            completion(result)
        }
    }
}

// MARK: - Sequence + Utils

private extension Sequence where Element: Hashable {
    var mostFrequentElement: Element? {
        Dictionary(grouping: self) { $0 }
            .max(by: { $0.value.count < $1.value.count })
            .map(\.key)
    }
}

// MARK: - Set + Utils

private extension Set {
    func subtracting(_ element: Element) -> Set<Element> {
        subtracting(CollectionOfOne(element))
    }
}
