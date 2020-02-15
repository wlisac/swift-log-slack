import Foundation
import Logging

/// `SlackLogHandler` is an implementation of `LogHandler` for sending
/// `Logger` output directly to Slack.
public struct SlackLogHandler: LogHandler {
    /// The global log level threshold that determines when to send log output to Slack.
    ///
    /// The `logLevel` of an individual `SlackLogHandler` is ignored when this global
    /// log level is set to a higher level.
    public static var globalLogLevelThreshold: Logger.Level = .error
    
    /// Internal for testing only.
    internal static var messageSendHandler: ((Result<Void, Error>) -> Void)?
    
    /// Internal for testing only.
    internal var slackSession: SlackSession = URLSession.shared
    
    /// The log label for the log handler.
    public var label: String
    
    /// The Slack integration's webhook URL.
    public var webhookURL: URL
    
    /// Overrides the Slack integration's default channel.
    public var channel: String?
    
    /// Overrides the Slack integration's default username.
    public var username: String?
    
    /// Override the Slack integration's default icon.
    public var icon: Icon?
    
    /// The color scheme is used to determine the color of a Slack message for a log level.
    public var colorScheme: ColorScheme
    
    public var logLevel: Logger.Level = .info
    
    public var metadata = Logger.Metadata()
    
    /// Creates a `SlackLogHandler` for sending `Logger` output directly to Slack.
    /// - Parameters:
    ///   - label: The log label for the log handler.
    ///   - webhookURL: The Slack integration's webhook URL.
    ///   - channel: Overrides the Slack integration's default channel.
    ///   - username: Overrides the Slack integration's default username.
    ///   - icon: Override the Slack integration's default icon.
    ///   - colorScheme: The color scheme is used to determine the color of a Slack message for a log level.
    public init(label: String,
                webhookURL: URL,
                channel: String? = nil,
                username: String? = nil,
                icon: Icon? = nil,
                colorScheme: ColorScheme = .default) {
        self.label = label
        self.webhookURL = webhookURL
        self.channel = channel
        self.username = username
        self.icon = icon
        self.colorScheme = colorScheme
    }
    
    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            metadata[metadataKey]
        }
        set {
            metadata[metadataKey] = newValue
        }
    }
    
    // swiftlint:disable:next function_parameter_count
    public func log(level: Logger.Level,
                    message: Logger.Message,
                    metadata: Logger.Metadata?,
                    file: String, function: String, line: UInt) {
        guard level >= SlackLogHandler.globalLogLevelThreshold else { return }
        
        let metadata = mergedMetadata(metadata)
        
        let slackMessage = makeSlackMessage(level: level,
                                            message: message,
                                            metadata: metadata)
        
        send(slackMessage)
    }
    
    private func mergedMetadata(_ metadata: Logger.Metadata?) -> Logger.Metadata {
        if let metadata = metadata {
            return self.metadata.merging(metadata, uniquingKeysWith: { _, new in new })
        } else {
            return self.metadata
        }
    }
    
    private func makeSlackMessage(level: Logger.Level,
                                  message: Logger.Message,
                                  metadata: Logger.Metadata) -> SlackMessage {
        let fields: [Field] = metadata.map { key, value in
            let stringValue = "\(value)"
            let short = key.count < 16 && stringValue.count < 16
            
            let field = Field(title: key,
                              value: stringValue,
                              short: short)
            
            return field
        }.sorted { $0.title < $1.title }
        
        let attachment = Attachment(color: colorScheme[level]?.hexValue,
                                    title: "[\(label)] [\(level)]",
                                    text: "\(message)",
                                    fields: fields)
        
        let message = SlackMessage(channel: channel,
                                   username: username,
                                   text: nil,
                                   iconEmoji: icon?.emoji,
                                   iconURL: icon?.url,
                                   attachments: [attachment])
        
        return message
    }
    
    private func send(_ slackMessage: SlackMessage) {
        slackSession.send(slackMessage, to: webhookURL) { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                print("Failed to send slack message with error: \(error)")
            }
            
            SlackLogHandler.messageSendHandler?(result)
        }
    }
}
