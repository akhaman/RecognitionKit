@testable import RecognitionKit
import XCTest

final class RecognitionKitTests: XCTestCase {
    func test() throws {
        let pattern = "^[/+]?[(]?[0-9]{3}[)]?[-/s/.]?[0-9]{3}[-/s/.]?[0-9]{4,6}$"
        let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)

        let input = "Call-center: 8-800-2005-303 (6ecnnaTHbIM 3BOH"
        
        let inputRange = NSRange(input.startIndex..<input.endIndex, in: input)
        
        let match = (regex as NSRegularExpression?)
            .flatMap { $0.firstMatch(in: input, range: inputRange) }
            .flatMap(\.replacementString)
        
        XCTAssertEqual(match, "8-800-2005-303")
    }
}
