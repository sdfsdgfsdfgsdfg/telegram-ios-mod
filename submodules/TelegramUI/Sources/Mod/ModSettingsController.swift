import Foundation
import UIKit
import Display
import SwiftSignalKit
import TelegramCore
import TelegramPresentationData
import AccountContext
import ItemListUI
import PresentationDataUtils

// MARK: - Entry Types

private enum ModSettingsSection: Int32 {
    case resolver
    case antiDelete
}

private enum ModSettingsEntry: ItemListNodeEntry {
    case resolverHeader(PresentationTheme, String)
    case resolverToggle(PresentationTheme, String, Bool)
    case resolverInfo(PresentationTheme, String)
    
    case antiDeleteHeader(PresentationTheme, String)
    case antiDeleteToggle(PresentationTheme, String, Bool)
    case antiDeleteInfo(PresentationTheme, String)
    
    var section: ItemListSectionId {
        switch self {
        case .resolverHeader, .resolverToggle, .resolverInfo:
            return ModSettingsSection.resolver.rawValue
        case .antiDeleteHeader, .antiDeleteToggle, .antiDeleteInfo:
            return ModSettingsSection.antiDelete.rawValue
        }
    }
    
    var stableId: Int32 {
        switch self {
        case .resolverHeader: return 0
        case .resolverToggle: return 1
        case .resolverInfo: return 2
        case .antiDeleteHeader: return 3
        case .antiDeleteToggle: return 4
        case .antiDeleteInfo: return 5
        }
    }
    
    static func < (lhs: ModSettingsEntry, rhs: ModSettingsEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }
    
    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! ModSettingsArguments
        switch self {
        case let .resolverHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .resolverToggle(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.toggleResolver(value)
            })
        case let .resolverInfo(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
            
        case let .antiDeleteHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .antiDeleteToggle(_, text, value):
            return ItemListSwitchItem(presentationData: presentationData, title: text, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.toggleAntiDelete(value)
            })
        case let .antiDeleteInfo(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        }
    }
}

// MARK: - Arguments

private final class ModSettingsArguments {
    let toggleResolver: (Bool) -> Void
    let toggleAntiDelete: (Bool) -> Void
    
    init(toggleResolver: @escaping (Bool) -> Void, toggleAntiDelete: @escaping (Bool) -> Void) {
        self.toggleResolver = toggleResolver
        self.toggleAntiDelete = toggleAntiDelete
    }
}

// MARK: - Entries Builder

private func modSettingsEntries(presentationData: PresentationData, settings: ModSettings) -> [ModSettingsEntry] {
    var entries: [ModSettingsEntry] = []
    
    // Resolver Section
    entries.append(.resolverHeader(presentationData.theme, "RESOLVER"))
    entries.append(.resolverToggle(presentationData.theme, "Enable Resolver", settings.resolverEnabled))
    entries.append(.resolverInfo(presentationData.theme, "Shows user ID when viewing profiles. Allows you to see the numeric ID of any user, group, or channel."))
    
    // Anti-Delete Section
    entries.append(.antiDeleteHeader(presentationData.theme, "ANTI-DELETE"))
    entries.append(.antiDeleteToggle(presentationData.theme, "Enable Anti-Delete", settings.antiDeleteEnabled))
    entries.append(.antiDeleteInfo(presentationData.theme, "When someone deletes a message, it will be marked as \"deleted\" instead of being removed. You can still see the original content."))
    
    return entries
}

// MARK: - Controller

public func modSettingsController(context: AccountContext) -> ViewController {
    let presentationData = context.sharedContext.currentPresentationData.with { $0 }
    
    let arguments = ModSettingsArguments(
        toggleResolver: { value in
            ModSettingsManager.shared.update { $0.withUpdatedResolverEnabled(value) }
        },
        toggleAntiDelete: { value in
            ModSettingsManager.shared.update { $0.withUpdatedAntiDeleteEnabled(value) }
        }
    )
    
    let signal = ModSettingsManager.shared.settings
    |> map { settings -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let entries = modSettingsEntries(presentationData: presentationData, settings: settings)
        
        let controllerState = ItemListControllerState(
            presentationData: ItemListPresentationData(presentationData),
            title: .text("Mod Settings"),
            leftNavigationButton: nil,
            rightNavigationButton: nil,
            backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back),
            animateChanges: false
        )
        
        let listState = ItemListNodeState(
            presentationData: ItemListPresentationData(presentationData),
            entries: entries,
            style: .blocks,
            animateChanges: false
        )
        
        return (controllerState, (listState, arguments))
    }
    
    let controller = ItemListController(context: context, state: signal)
    return controller
}
