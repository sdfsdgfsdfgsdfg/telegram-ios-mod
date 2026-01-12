import Foundation
import SwiftSignalKit
import Postbox

// MARK: - Mod Settings Storage

public final class ModSettings: Codable, Equatable {
    public let resolverEnabled: Bool
    public let antiDeleteEnabled: Bool
    
    public init(resolverEnabled: Bool = false, antiDeleteEnabled: Bool = false) {
        self.resolverEnabled = resolverEnabled
        self.antiDeleteEnabled = antiDeleteEnabled
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.resolverEnabled = try container.decodeIfPresent(Bool.self, forKey: .resolverEnabled) ?? false
        self.antiDeleteEnabled = try container.decodeIfPresent(Bool.self, forKey: .antiDeleteEnabled) ?? false
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(resolverEnabled, forKey: .resolverEnabled)
        try container.encode(antiDeleteEnabled, forKey: .antiDeleteEnabled)
    }
    
    private enum CodingKeys: String, CodingKey {
        case resolverEnabled
        case antiDeleteEnabled
    }
    
    public static func == (lhs: ModSettings, rhs: ModSettings) -> Bool {
        return lhs.resolverEnabled == rhs.resolverEnabled &&
               lhs.antiDeleteEnabled == rhs.antiDeleteEnabled
    }
    
    public func withUpdatedResolverEnabled(_ resolverEnabled: Bool) -> ModSettings {
        return ModSettings(resolverEnabled: resolverEnabled, antiDeleteEnabled: self.antiDeleteEnabled)
    }
    
    public func withUpdatedAntiDeleteEnabled(_ antiDeleteEnabled: Bool) -> ModSettings {
        return ModSettings(resolverEnabled: self.resolverEnabled, antiDeleteEnabled: antiDeleteEnabled)
    }
}

// MARK: - UserDefaults Storage

private let modSettingsKey = "TelegramModSettings"

public func loadModSettings() -> ModSettings {
    guard let data = UserDefaults.standard.data(forKey: modSettingsKey),
          let settings = try? JSONDecoder().decode(ModSettings.self, from: data) else {
        return ModSettings()
    }
    return settings
}

public func saveModSettings(_ settings: ModSettings) {
    if let data = try? JSONEncoder().encode(settings) {
        UserDefaults.standard.set(data, forKey: modSettingsKey)
    }
}

// MARK: - Global Mod Settings Signal

public final class ModSettingsManager {
    public static let shared = ModSettingsManager()
    
    private let settingsPromise: ValuePromise<ModSettings>
    private var currentSettings: ModSettings
    
    private init() {
        self.currentSettings = loadModSettings()
        self.settingsPromise = ValuePromise(self.currentSettings, ignoreRepeated: true)
    }
    
    public var settings: Signal<ModSettings, NoError> {
        return self.settingsPromise.get()
    }
    
    public var current: ModSettings {
        return self.currentSettings
    }
    
    public func update(_ f: (ModSettings) -> ModSettings) {
        self.currentSettings = f(self.currentSettings)
        saveModSettings(self.currentSettings)
        self.settingsPromise.set(self.currentSettings)
    }
}
