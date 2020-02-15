import Foundation
@testable import LoggingSlack

class SlackSessionMock: SlackSession {
    private(set) var message: SlackMessage?
    
    var result = Result<Void, Error>.success(())
    
    func send(_ message: SlackMessage, to webhookURL: URL, completion: ((Result<Void, Error>) -> Void)?) {
        self.message = message
        
        completion?(result)
    }
    
    func reset() {
        message = nil
    }
}
