//
//  AppDelegate.swift
//  XcodeExtensionSample
//
//  Created by Yoshitaka Seki on 2017/09/07.
//  Copyright © 2017年 takasek. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ aNotification: Notification) {
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(AppDelegate.handleGetURLEvent(event:replyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }

    private var selectedFileURL: URL?

    @objc func handleGetURLEvent(event: NSAppleEventDescriptor?, replyEvent: NSAppleEventDescriptor?) {
        defer {
            UserDefaults(suiteName: "42U7855PYX.io.github.takasek.XcodeExtensionSample")?.set(selectedFileURL?.absoluteString, forKey: "valueFromApp")

            DispatchQueue.main.async {
                NSApplication.shared.terminate(nil)
            }
        }
        guard
            let urlString = event?.paramDescriptor(forKeyword: keyDirectObject)?.stringValue,
            let components = URLComponents(string: urlString)
            else {
                return
        }

        guard
            let title = components.queryItems?.first(where: { $0.name == "title" })?.value,
            let url = self.selectFile(with: title)
            else {
                return
        }

        self.selectedFileURL = url
    }

    private func selectFile(with title: String) -> URL? {
        let panel = NSOpenPanel()

        panel.prompt = "Select"
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.canChooseFiles = true
        panel.title = "title"

        let url: URL?
        switch panel.runModal() {
        case .OK:
            url = panel.url
        case _:
            url = nil
        }
        return url
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        DistributedNotificationCenter.default().postNotificationName(
            Notification.Name("XcodeExtensionSample.applicationWillTerminate"),
            object: nil,
            userInfo: selectedFileURL.flatMap { ["url": $0] },
            deliverImmediately: true
        )
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        print(urls)
    }
}

