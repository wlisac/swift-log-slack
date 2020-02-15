import Foundation

struct SlackMessage: Encodable, Equatable {
    let channel: String?
    let username: String?
    let text: String?
    let iconEmoji: String?
    let iconURL: URL?
    let attachments: [Attachment]
}

struct Attachment: Encodable, Equatable {
    let color: String?
    let title: String
    let text: String
    let fields: [Field]
}

struct Field: Encodable, Equatable {
    let title: String
    let value: String
    let short: Bool
}

extension SlackMessage {
    enum CodingKeys: String, CodingKey {
        case channel
        case username
        case text
        case iconEmoji = "icon_emoji"
        case iconURL = "icon_url"
        case attachments
    }
}
