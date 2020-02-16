@testable import LoggingSlack
import XCTest

class IconTests: XCTestCase {
    func testEmoji() {
        let emojiIcon: SlackLogHandler.Icon = .emoji("smile")
        XCTAssertNil(emojiIcon.url)
        XCTAssertEqual("smile", emojiIcon.emoji)
    }
    
    func testURL() {
        let url = URL(string: "https://google.com/logo.png")!
        let urlIcon: SlackLogHandler.Icon = .url(url)
        XCTAssertNil(urlIcon.emoji)
        XCTAssertEqual(url, urlIcon.url)
    }
}
