@testable import RecognitionKit
import XCTest

final class RecognitionKitTests: XCTestCase {
    func test() {
        let values = ["03/24", "03/24", "03/24", "10/24", "10/24", "10/24"]
        
        let value = Dictionary(grouping: values) { $0 }
            .max(by: { $0.value.count < $1.value.count })
            .map(\.key)
        
        print("DEBUG: \(value)")
        
        XCTAssertEqual(value, "03/24")
    }
}
