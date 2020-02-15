import Logging
@testable import LoggingSlack
import XCTest

let mockSession = SlackSessionMock()

var useMockSession = true

// We can only bootstrap the logging system once.
// This makes the setup more complicated since we want to test
// using a mock session and a real session.
let isLoggingConfigured: Bool = {
    LoggingSystem.bootstrap { label in
        let webhookURL: URL
        
        if useMockSession {
            // swiftlint:disable:next force_unwrapping
            webhookURL = URL(string: "https://hooks.slack.com/services/test")!
        } else {
            guard let url = ProcessInfo.processInfo.environment["WEBHOOK_URL"].flatMap({ URL(string: $0) }) else {
                fatalError("WEBHOOK_URL must be set to a valid URL.")
            }
            webhookURL = url
        }
        
        var handler = SlackLogHandler(label: label,
                                      webhookURL: webhookURL,
                                      channel: "swift-log-test-channel",
                                      username: "TestApp",
                                      icon: .emoji("smile"))
        
        if useMockSession {
            handler.slackSession = mockSession
        }
        
        return handler
    }
    return true
}()

final class SlackLogHandlerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        XCTAssert(isLoggingConfigured)
        
        useMockSession = true
        
        mockSession.reset()
        
        SlackLogHandler.globalLogLevelThreshold = .error
        SlackLogHandler.messageSendHandler = nil
    }
    
    func testError() {
        let logger = Logger(label: "test-logger")
        
        logger.error("This is an error log")
        
        let attachment = Attachment(color: "#fc4349",
                                    title: "[test-logger] [error]",
                                    text: "This is an error log",
                                    fields: [])
        
        let message = SlackMessage(channel: "swift-log-test-channel",
                                   username: "TestApp",
                                   text: nil,
                                   iconEmoji: "smile",
                                   iconURL: nil,
                                   attachments: [attachment])
        
        XCTAssertEqual(mockSession.message, message)
    }
    
    func testCritical() {
        let logger = Logger(label: "test-logger")
        
        logger.critical("This is a critical log")
        
        let attachment = Attachment(color: "#fc4349",
                                    title: "[test-logger] [critical]",
                                    text: "This is a critical log",
                                    fields: [])
        
        let message = SlackMessage(channel: "swift-log-test-channel",
                                   username: "TestApp",
                                   text: nil,
                                   iconEmoji: "smile",
                                   iconURL: nil,
                                   attachments: [attachment])
        
        XCTAssertEqual(mockSession.message, message)
    }
    
    func testMetadata() {
        var logger = Logger(label: "test-logger")
        logger[metadataKey: "logger-key"] = "logger-value"
        
        logger.error("This is an error with metadata", metadata: ["log-key": "log-value"])
        
        let attachment = Attachment(color: "#fc4349",
                                    title: "[test-logger] [error]",
                                    text: "This is an error with metadata",
                                    fields: [Field(title: "log-key", value: "log-value", short: true),
                                             Field(title: "logger-key", value: "logger-value", short: true)])
        
        XCTAssertEqual(mockSession.message?.attachments, [attachment])
    }
    
    func testInfo() {
        let logger = Logger(label: "test-logger")
        
        logger.info("This is an info log")
        
        XCTAssertNil(mockSession.message)
        
        SlackLogHandler.globalLogLevelThreshold = .info
        
        logger.info("This is an info log")
        
        let attachment = Attachment(color: "#1f95c1",
                                    title: "[test-logger] [info]",
                                    text: "This is an info log",
                                    fields: [])
        
        let message = SlackMessage(channel: "swift-log-test-channel",
                                   username: "TestApp",
                                   text: nil,
                                   iconEmoji: "smile",
                                   iconURL: nil,
                                   attachments: [attachment])
        
        XCTAssertEqual(mockSession.message, message)
    }
    
    func testSendingRealMessageIfConfigured() {
        guard ProcessInfo.processInfo.environment["WEBHOOK_URL"] != nil else {
            print("Skipping sending real message since WEBHOOK_URL is not configured.")
            return
        }
        
        useMockSession = false
        
        let logger = Logger(label: "test-logger")
        
        let messageSentExpectation = expectation(description: "Expected message to send.")
        
        SlackLogHandler.messageSendHandler = { result in
            switch result {
            case .success:
                messageSentExpectation.fulfill()
            case let .failure(error):
                XCTFail("Failed to send Slack message with error: \(error)")
            }
        }
        
        let metadata: Logger.Metadata = [
            "identifier": "\(UUID())",
            "name": "test-name"
        ]
        
        logger.error("This is an error with metadata", metadata: metadata)
        
        wait(for: [messageSentExpectation], timeout: 10)
    }
}
