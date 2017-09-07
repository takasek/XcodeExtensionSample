//
//  SourceEditorCommand.swift
//  Extension
//
//  Created by Yoshitaka Seki on 2017/09/07.
//  Copyright © 2017年 takasek. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.

        invocation.buffer.lines.add("hello extension!")

        completionHandler(nil)
    }
    
}
