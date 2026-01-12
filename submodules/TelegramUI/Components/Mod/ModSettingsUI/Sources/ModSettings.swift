import Foundation
import SwiftSignalKit

// MARK: - Settings Model

public struct ModSettings: Codable, Equatable {
    public var resolverEnabled: Bool
    public var antiDeleteEnabled: Bool
    
    public init(resolverEnabled: Bool = false, antiDeleteEnabled: Bool = false) {
        self.resolverEnabled = resolverEnabled
        self.antiDeleteEnabled = antiDeleteEnabled
    }
    
    public func withUpdatedResolverEnabled(_ value: Bool) -> ModSettings {
        return ModSettings(resolverEnabled: value, antiDeleteEnabled: self.antiDeleteEnabled)
    }
    
    public func withUpdatedAntiDeleteEnabled(_ value: Bool) -> ModSettings {
        return ModSettings(resolverEnabled: self.resolverEnabled, antiDeleteEnabled: value)
    }
}

// MARK: - Settings Manager

public final class ModSettingsManager {
    public static let shared = ModSettingsManager()
    
    private let key = "mod_settings_v1"
    private var currentSettings: ModSettings
    private let settingsPromise: ValuePromise<ModSettings>
    
    public var settings: Signal<ModSettings, NoError> {
        return self.settingsPromise.get()
    }
    
    public var current: ModSettings {
        return self.currentSettings
    }
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let settings = try? JSONDecoder().decode(ModSettings.self, from: data) {
            self.currentSettings = settings
        } else {
            self.currentSettings = ModSettings()
        }
        self.settingsPromise = ValuePromise(self.currentSettings, ignoreRepeated: true)
    }
    
    public func update(_ f: (ModSettings) -> ModSettings) {
        self.currentSettings = f(self.currentSettings)
        self.settingsPromise.set(self.currentSettings)
        
        if let data = try? JSONEncoder().encode(self.currentSettings) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
