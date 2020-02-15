import Foundation
import Logging

extension SlackLogHandler {
    /// A color scheme is used to determine the color of a Slack message for a log level.
    public typealias ColorScheme = [Logger.Level: Color]
    
    /// A color represented by a hex string.
    public struct Color: ExpressibleByStringLiteral, CustomStringConvertible {
        internal var hexValue: String
        
        public init(stringLiteral hexValue: String) {
            self.hexValue = hexValue
        }
        
        public var description: String {
            hexValue
        }
    }
}

extension SlackLogHandler.ColorScheme {
    /// The default color scheme.
    public static let `default`: SlackLogHandler.ColorScheme = [
        .trace: "#18ed50",
        .debug: "#18ed50",
        .info: "#1f95c1",
        .notice: "#1f95c1",
        .warning: "#fecb57",
        .error: "#fc4349",
        .critical: "#fc4349"
    ]
}
