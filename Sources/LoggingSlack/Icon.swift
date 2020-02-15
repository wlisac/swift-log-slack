import Foundation

extension SlackLogHandler {
    /// An icon for a Slack integration.
    public enum Icon {
        /// An [emoji code](https://www.webpagefx.com/tools/emoji-cheat-sheet) string to use in place of the default icon.
        ///
        ///     .emoji("smile")
        case emoji(String)
        
        /// An icon image URL to use in place of the default icon.
        case url(URL)
        
        internal var emoji: String? {
            switch self {
            case let .emoji(emoji):
                return emoji
            default:
                return nil
            }
        }
        
        internal var url: URL? {
            switch self {
            case let .url(url):
                return url
            default:
                return nil
            }
        }
    }
}
