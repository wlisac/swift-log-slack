@testable import LoggingSlack
import XCTest

class ColorSchemeTests: XCTestCase {
    func testColor() {
        let color: SlackLogHandler.Color = "#ffffff"
        XCTAssertEqual("#ffffff", "\(color)")
        XCTAssertEqual("#ffffff", color.hexValue)
    }
}
