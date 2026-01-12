import Foundation
import UIKit
import Display
import AccountContext
import TelegramPresentationData

// MARK: - Mod Integration Helper
// This file provides helper functions to integrate the mod into the Telegram app

/// Creates a disclosure item for the mod settings button
/// Use this in PeerInfoScreen.swift settingsItems function
public func createModSettingsItem(presentationData: PresentationData, action: @escaping () -> Void) -> Any {
    // This would be a PeerInfoScreenDisclosureItem
    // Add to the shortcuts or extra section in settingsItems
    return (
        id: 999,
        text: "🔧 Mod Settings",
        icon: nil as UIImage?,
        action: action
    )
}

/// Opens the mod settings controller
public func openModSettings(context: AccountContext, navigationController: NavigationController?) {
    let controller = modSettingsController(context: context)
    navigationController?.pushViewController(controller)
}

// MARK: - Integration Instructions

/*
 
 ## How to integrate the mod into Telegram iOS:
 
 ### 1. Add Mod Settings Button to Profile Settings
 
 In `PeerInfoScreen.swift`, find the `SettingsSection` enum and add a new case:
 
 ```swift
 private enum SettingsSection: Int, CaseIterable {
     case edit
     case phone
     case accounts
     case myProfile
     case proxy
     case apps
     case shortcuts
     case advanced
     case payment
     case extra
     case mod        // <-- Add this
     case support
 }
 ```
 
 Then in `settingsItems` function, add after the `extra` section items:
 
 ```swift
 // Mod Settings
 items[.mod]!.append(PeerInfoScreenDisclosureItem(id: 0, text: "🔧 Mod Settings", icon: nil, action: {
     // Open mod settings
     if let controller = interaction.getController() {
         let modController = modSettingsController(context: context)
         controller.push(modController)
     }
 }))
 ```
 
 ### 2. Add openModSettings to PeerInfoSettingsSection enum
 
 Find `PeerInfoSettingsSection` enum and add:
 ```swift
 case modSettings
 ```
 
 ### 3. Handle the mod settings action
 
 In the switch statement that handles `openSettings`, add:
 ```swift
 case .modSettings:
     let controller = modSettingsController(context: context)
     push(controller)
 ```
 
 ### 4. Anti-Delete Integration
 
 In `AccountStateManagementUtils.swift` or where delete messages are processed,
 check `AntiDeleteManager.shared.shouldPreserveDeletedMessages()` before deleting.
 
 If true, instead of deleting, update the message with a `DeletedMessageAttribute`.
 
 ### 5. Resolver Integration
 
 In `PeerInfoScreen.swift` where peer info is displayed, check:
 ```swift
 if ResolverHelper.shared.isEnabled {
     // Show peer ID in the info section
     let idString = peer.resolverIdString
     // Add to displayed items
 }
 ```
 
 ### 6. Build Configuration
 
 Add the mod files to the BUILD.bazel file for TelegramUI:
 
 ```
 "Sources/Mod/ModSettings.swift",
 "Sources/Mod/ModSettingsController.swift",
 "Sources/Mod/AntiDeleteManager.swift",
 "Sources/Mod/ResolverHelper.swift",
 "Sources/Mod/ModIntegration.swift",
 ```
 
 */
