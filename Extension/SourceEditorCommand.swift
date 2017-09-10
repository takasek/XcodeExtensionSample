//
//  SourceEditorCommand.swift
//  Extension
//
//  Created by Yoshitaka Seki on 2017/09/07.
//  Copyright © 2017年 takasek. All rights reserved.
//

import Foundation
import XcodeKit
import Cocoa

final class PasteboardOutputCommand: SweetSourceEditorCommand {
    override class var commandName: String {
        return "ファイルのUTI -> PasteBoard"
    }

    override func performImpl(with textBuffer: XCSourceTextBuffer) throws -> Bool {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(textBuffer.contentUTI, forType: .string)

        return true
    }
}

final class PasteboardInputCommand: SweetSourceEditorCommand {
    override class var commandName: String {
        return "PasteBoard -> カーソル位置"
    }

    enum Error: MessagedError {
        case hasNoText
        var message: String {
            switch self {
            case .hasNoText: return "Pasteboard has no text."
            }
        }
    }
    override func performImpl(with textBuffer: XCSourceTextBuffer) throws -> Bool {
        let pasteboard = NSPasteboard.general

        guard let text = pasteboard.pasteboardItems?.first?
            .string(forType: NSPasteboard.PasteboardType(
                rawValue: "public.utf8-plain-text"
            )) else { throw Error.hasNoText }

        try textBuffer.replaceSelection(by: text)

        return true
    }
}

final class OpenAppCommand: SweetSourceEditorCommand {
    override class var commandName: String {
        return "カレンダーを開く"
    }

    override func performImpl(with textBuffer: XCSourceTextBuffer) throws -> Bool {

        NSWorkspace.shared.launchApplication("Calendar")

        return true
    }
}

final class URLSchemeCommand: SweetSourceEditorCommand {
    override class var commandName: String {
        return "選択中の行 -> twitter://post"
    }

    override func performImpl(with textBuffer: XCSourceTextBuffer) throws -> Bool {
        let text = textBuffer.selectedText(includesUnselectedStartAndEnd: false, trimsIndents: true)

        var c = URLComponents(string: "twitter://post")!
        c.queryItems = [
            URLQueryItem(name: "message", value: text)
        ]
        NSWorkspace.shared.open(c.url!)

        return true
    }
}

final class LocalCommandCommand: SweetSourceEditorCommand {
    override class var commandName: String {
        return "全体 -> trで uppercased -> 全体"
    }

    enum Error: MessagedError {
        case commandFailed(String)
        var message: String {
            switch self {
            case .commandFailed(let message): return message
            }
        }
    }

    private func runTask(command: String, arguments: [String], standardInput: Pipe? = nil) throws -> Pipe {
        let task = Process(), standardOutput = Pipe(), standardError = Pipe()
        task.launchPath = "/usr/bin/env"
        task.arguments = [command] + arguments
        task.currentDirectoryPath = NSTemporaryDirectory()
        task.standardInput = standardInput
        task.standardOutput = standardOutput
        task.standardError = standardError
        task.launch()
        task.waitUntilExit()

        guard task.terminationStatus == 0 else {
            // 異常終了
            let errorOutput = String(data: standardError.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            throw Error.commandFailed(errorOutput)
        }
        return standardOutput
    }

    override func performImpl(with textBuffer: XCSourceTextBuffer) throws -> Bool {
        let tmpFilePath = NSTemporaryDirectory().appending("inputFile")

        try textBuffer.completeBuffer.write(toFile: tmpFilePath, atomically: true, encoding: .utf8)

        let catOutput = try runTask(
            command: "cat",
            arguments: [tmpFilePath]
        )
        let trOutput = try runTask(
            command: "tr",
            arguments: ["[:lower:]", "[:upper:]"],
            standardInput: catOutput
        )
        textBuffer.completeBuffer = String(data: trOutput.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""

        return true
    }
}

final class NetworkCommand: SweetSourceEditorCommand {
    override class var commandName: String {
        return "GET example.com -> カーソル位置"
    }

    enum MyError: MessagedError {
        case timedOut
        case connectionFailed(NSError?)
        var message: String {
            switch self {
            case .timedOut: return "connection timed out."
            case .connectionFailed(let error): return error?.localizedDescription ?? "unknown error."
            }
        }
    }
    override func performImpl(with textBuffer: XCSourceTextBuffer) throws -> Bool {
        print(textBuffer.contentUTI)

        enum Result {
            case success(String)
            case fail(MyError)
        }
        let urlRequest = URLRequest(url: URL(string: "https://httpbin.org/get")!)

        let semaphore = DispatchSemaphore(value: 0)
        var result: Result = .fail(.timedOut)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
            if let res = data.flatMap({ String(data: $0, encoding: .utf8) }) {
                result = .success(res)
            } else {
                result = .fail(.connectionFailed(error as NSError?))
            }
            semaphore.signal()
        }
        task.resume()
        _ = semaphore.wait(timeout: .now() + 10)

        switch result {
        case .fail(let e): throw e
        case .success(let r): try textBuffer.replaceSelection(by: r)
        }

        return true
    }
}

final class ToDesktopCommand1: SweetSourceEditorCommand {
    override class var commandName: String {
        return "全体 -> デスクトップに書き出し(失敗する)"
    }

    override func performImpl(with textBuffer: XCSourceTextBuffer) throws -> Bool {
        let dir = NSSearchPathForDirectoriesInDomains(
            .desktopDirectory, .userDomainMask, true
            ).first!

        try textBuffer.completeBuffer.write(
            toFile: dir + "/outputFile",
            atomically: true, encoding: .utf8
        )

        return true
    }
}

final class ToDesktopCommand2: SweetSourceEditorCommand {
    override class var commandName: String {
        return "全体 -> (XPC) -> デスクトップ"
    }

    enum Error: MessagedError {
        case connectionFailed
        case executionFailed
        var message: String {
            switch self {
            case .connectionFailed: return "Failed to make connection."
            case .executionFailed: return "Execution failed."
            }
        }
    }

    override func performImpl(with textBuffer: XCSourceTextBuffer) throws -> Bool {
        let connection = NSXPCConnection(serviceName: "io.github.takasek.XcodeExtensionSampleHelper")
        connection.remoteObjectInterface = NSXPCInterface(with: XcodeExtensionSampleHelperProtocol.self)
        defer {
            connection.invalidate()
        }
        guard let helper = connection.remoteObjectProxy as? XcodeExtensionSampleHelperProtocol else {
            throw Error.connectionFailed
        }
        connection.resume()

        let semaphore = DispatchSemaphore(value: 0)
        var isSuccess = false

        connection.invalidationHandler = {
            print("invalid!")
            semaphore.signal()
        }

        let dir = NSSearchPathForDirectoriesInDomains(
            .desktopDirectory, .userDomainMask, true
            ).first!

        helper.write(text: textBuffer.completeBuffer, to: dir) { _ in
            isSuccess = true
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + 10)

        if !isSuccess {
            throw Error.executionFailed
        }

        return true
    }
}

extension UserDefaults {
    @objc dynamic var valueFromApp: String? {
        return string(forKey: "valueFromApp")
    }
}

final class FileSelectionCommand: SweetSourceEditorCommand {
    override class var commandName: String {
        return "(App by URLScheme) -> ファイル選択 -> (Notification) -> カーソル位置"
    }

    private var _applicationWillTerminate: (() -> Void)?
    @objc private func applicationWillTerminate(notification: Notification) {
        _applicationWillTerminate?()
    }

    enum Error: MessagedError {
        case noFileSelected
        var message: String {
            switch self {
            case .noFileSelected: return "No file selected."
            }
        }
    }

    override func performImpl(with textBuffer: XCSourceTextBuffer) throws -> Bool {
        let semaphore = DispatchSemaphore(value: 0)

        var selectedResult: String?

        // The command expects that the app set selected file path to UserDefaults.
        let userDefaults = UserDefaults(suiteName: "42U7855PYX.io.github.takasek.XcodeExtensionSample")!
        userDefaults.synchronize()
        let observation = userDefaults.observe(\UserDefaults.valueFromApp, options:[.old, .new]) { ud, change in
            selectedResult = change.newValue?.flatMap { $0 }
            semaphore.signal()
        }

        // this observation also works.
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(FileSelectionCommand.applicationWillTerminate(notification:)),
            name: Notification.Name("XcodeExtensionSample.applicationWillTerminate"),
            object: nil,
            suspensionBehavior: .deliverImmediately
        )
        _applicationWillTerminate = {
            // If the app terminated by user unexpectedly, this observation signals the semaphore.
            semaphore.signal()
        }

        // Open App via URL Scheme
        var c = URLComponents(string: "xcextsample://")!
        c.queryItems = [
            URLQueryItem(name: "title", value: "text")
        ]
        NSWorkspace.shared.open(c.url!)

        _ = semaphore.wait()

        DistributedNotificationCenter.default().removeObserver(self)
        observation.invalidate()

        guard let result = selectedResult else {
            // cancel the command.
            throw Error.noFileSelected
        }

        try textBuffer.replaceSelection(by: result)

        return true
    }
}
