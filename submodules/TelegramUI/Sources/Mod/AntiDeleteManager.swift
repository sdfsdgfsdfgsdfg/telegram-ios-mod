import Foundation
import SwiftSignalKit
import Postbox
import TelegramCore
import ModSettingsUI

// MARK: - Anti-Delete Message Attribute

public final class DeletedMessageAttribute: MessageAttribute, Equatable {
    public let deletedTimestamp: Int32
    public let deletedByPeerId: PeerId?
    
    public init(deletedTimestamp: Int32, deletedByPeerId: PeerId? = nil) {
        self.deletedTimestamp = deletedTimestamp
        self.deletedByPeerId = deletedByPeerId
    }
    
    public init(decoder: PostboxDecoder) {
        self.deletedTimestamp = decoder.decodeInt32ForKey("dt", orElse: 0)
        self.deletedByPeerId = decoder.decodeOptionalInt64ForKey("dp").flatMap { PeerId($0) }
    }
    
    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeInt32(self.deletedTimestamp, forKey: "dt")
        if let deletedByPeerId = self.deletedByPeerId {
            encoder.encodeInt64(deletedByPeerId.toInt64(), forKey: "dp")
        }
    }
    
    public static func == (lhs: DeletedMessageAttribute, rhs: DeletedMessageAttribute) -> Bool {
        return lhs.deletedTimestamp == rhs.deletedTimestamp && lhs.deletedByPeerId == rhs.deletedByPeerId
    }
}

// MARK: - Anti-Delete Manager

public final class AntiDeleteManager {
    public static let shared = AntiDeleteManager()
    
    private init() {}
    
    /// Check if anti-delete is enabled
    public var isEnabled: Bool {
        return ModSettingsManager.shared.current.antiDeleteEnabled
    }
    
    /// Mark messages as deleted instead of removing them
    /// Returns true if messages should be preserved, false if they should be deleted normally
    public func shouldPreserveDeletedMessages() -> Bool {
        return isEnabled
    }
    
    /// Create a deleted message attribute with current timestamp
    public func createDeletedAttribute(deletedByPeerId: PeerId? = nil) -> DeletedMessageAttribute {
        return DeletedMessageAttribute(
            deletedTimestamp: Int32(Date().timeIntervalSince1970),
            deletedByPeerId: deletedByPeerId
        )
    }
}

// MARK: - Message Extension

public extension Message {
    /// Check if this message was marked as deleted by anti-delete
    var isMarkedAsDeleted: Bool {
        return self.attributes.contains(where: { $0 is DeletedMessageAttribute })
    }
    
    /// Get the deleted attribute if present
    var deletedAttribute: DeletedMessageAttribute? {
        return self.attributes.first(where: { $0 is DeletedMessageAttribute }) as? DeletedMessageAttribute
    }
}

// MARK: - Deleted Message Text Formatter

public func formatDeletedMessageText(originalText: String) -> String {
    if originalText.isEmpty {
        return "🗑 [deleted message]"
    }
    return "🗑 \(originalText)"
}

public func deletedMessageTimestampString(timestamp: Int32) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return "Deleted: \(formatter.string(from: date))"
}
