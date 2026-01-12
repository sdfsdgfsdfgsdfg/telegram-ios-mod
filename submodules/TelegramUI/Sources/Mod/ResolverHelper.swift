import Foundation
import TelegramCore
import Postbox
import ModSettingsUI

// MARK: - Resolver Helper

public final class ResolverHelper {
    public static let shared = ResolverHelper()
    
    private init() {}
    
    /// Check if resolver is enabled
    public var isEnabled: Bool {
        return ModSettingsManager.shared.current.resolverEnabled
    }
    
    /// Format peer ID for display
    public func formatPeerId(_ peerId: PeerId) -> String {
        return "ID: \(peerId.id._internalGetInt64Value())"
    }
    
    /// Format peer ID with namespace info
    public func formatPeerIdDetailed(_ peerId: PeerId) -> String {
        let namespace: String
        switch peerId.namespace {
        case Namespaces.Peer.CloudUser:
            namespace = "User"
        case Namespaces.Peer.CloudGroup:
            namespace = "Group"
        case Namespaces.Peer.CloudChannel:
            namespace = "Channel"
        case Namespaces.Peer.SecretChat:
            namespace = "Secret"
        default:
            namespace = "Unknown"
        }
        return "\(namespace) ID: \(peerId.id._internalGetInt64Value())"
    }
    
    /// Get copyable ID string
    public func getCopyableId(_ peerId: PeerId) -> String {
        return "\(peerId.id._internalGetInt64Value())"
    }
    
    /// Format message ID for display
    public func formatMessageId(_ messageId: MessageId) -> String {
        return "Message ID: \(messageId.id)"
    }
}

// MARK: - Peer Extension for Resolver

public extension Peer {
    /// Get formatted ID string for resolver
    var resolverIdString: String {
        return ResolverHelper.shared.formatPeerId(self.id)
    }
    
    /// Get detailed ID string for resolver
    var resolverDetailedIdString: String {
        return ResolverHelper.shared.formatPeerIdDetailed(self.id)
    }
    
    /// Get raw numeric ID
    var numericId: Int64 {
        return self.id.id._internalGetInt64Value()
    }
}

// MARK: - EnginePeer Extension

public extension EnginePeer {
    /// Get formatted ID string for resolver
    var resolverIdString: String {
        return ResolverHelper.shared.formatPeerId(self.id)
    }
    
    /// Get raw numeric ID
    var numericId: Int64 {
        return self.id.id._internalGetInt64Value()
    }
}
