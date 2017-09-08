//
//  SweetSourceEditorCommand.swift
//  ExtensionSample
//
//  Created by Yoshitaka Seki on 2017/08/12.
//  Copyright © 2017年 takasek. All rights reserved.
//

import Foundation
import XcodeKit

/// Error with Message to tell the user.
protocol MessagedError: Error {
    var message: String { get }
}

class SweetSourceEditorCommand: NSObject, XCSourceEditorCommand {
    /// can override
    var validUTIs: [UTI]? {
        return nil
    }

    /// for XCSourceEditorCommandDefinitionKey.nameKey.
    /// can be overridden.
    class var commandName: String {
        return className()
    }

    /// for XCSourceEditorCommandDefinitionKey.identifierKey.
    /// can be overridden.
    class var commandIdentifier: String {
        let bundleIdentifiler = Bundle.main.bundleIdentifier!
        return bundleIdentifiler + "." + className()
    }

    /// should be overridden
    func performImpl(with textBuffer: XCSourceTextBuffer) throws -> Bool {
        fatalError("should be implemented")
    }

    // MARK: - sweet wrappers

    class var commandDefinition: [XCSourceEditorCommandDefinitionKey: String] {
        return [
            .nameKey: commandName,
            .classNameKey: className(),
            .identifierKey: commandIdentifier
        ]
    }

    enum Error: MessagedError {
        case invalidUTI
        var message: String {
            switch self {
            case .invalidUTI: return "invalid UTI"
            }
        }
    }

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Swift.Error?) -> Void ) {
        enum Closing {
            case complete(Swift.Error?)
            case cancel
        }
        var closing: Closing = .complete(nil)
        defer {
            switch closing {
            case .complete(let error):
                let returningError: Swift.Error?
                if let error = error {
                    print(error)
                    if type(of: error) == NSError.self {
                        returningError = error
                    } else if let e = error as? MessagedError {
                        returningError = NSError(domain: "MessagedError", code: 0, userInfo: [NSLocalizedDescriptionKey: e.message])
                    } else {
                        returningError = NSError(domain: "Swift.Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "\(error as Any)"])
                    }
                } else {
                    returningError = nil
                }
                completionHandler(returningError)
            case .cancel:
                print("cancelled")
                invocation.cancellationHandler()
            }
        }

        do {
            let textBuffer = invocation.buffer

            switch validUTIs?.contains(textBuffer.typedContentUTI) {
            case nil:
                () // all UTIs can execute the command.
            case true?:
                () // this UTI can execute the command.
            case false?:
                throw Error.invalidUTI
            }

            guard try performImpl(with: textBuffer) else {
                closing = .cancel
                return
            }

            // complete with no error

        } catch let caughtError {
            closing = .complete(caughtError)
            return
        }
    }
}

