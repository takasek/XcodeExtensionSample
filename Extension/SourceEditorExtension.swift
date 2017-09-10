//
//  SourceEditorExtension.swift
//  Extension
//
//  Created by Yoshitaka Seki on 2017/09/07.
//  Copyright © 2017年 takasek. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    
    func extensionDidFinishLaunching() {
        // If your extension needs to do any work at launch, implement this optional method.
        print("launched!")
    }

    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        // If your extension needs to return a collection of command definitions that differs from those in its Info.plist, implement this optional property getter.

        return [
            PasteboardOutputCommand.commandDefinition,
            PasteboardInputCommand.commandDefinition,
            OpenAppCommand.commandDefinition,
            URLSchemeCommand.commandDefinition,
            LocalCommandCommand.commandDefinition,
            NetworkCommand.commandDefinition,
            ToDesktopCommand1.commandDefinition,
            ToDesktopCommand2.commandDefinition,
            FileSelectionCommand.commandDefinition,
        ]
    }
}
