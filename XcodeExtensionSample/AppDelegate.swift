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

        print(UserDefaults(suiteName: "Hogehoge")?.integer(forKey: "date"))
        UserDefaults(suiteName: "Hogehoge")?.set(Date().timeIntervalSince1970, forKey: "date")
    }

    private var selectedFileURL: URL?

    @objc func handleGetURLEvent(event: NSAppleEventDescriptor?, replyEvent: NSAppleEventDescriptor?) {
        defer {
            DistributedNotificationCenter.default().postNotificationName(
                Notification.Name("XcodeExtensionSample.fileSelectionFinished"),
                object: nil,
                userInfo: selectedFileURL.flatMap { ["url": $0] },
                deliverImmediately: true
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
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
        var url: URL?
        let panel = NSOpenPanel()

        panel.prompt = "Select"
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.canChooseFiles = true
        panel.title = "title"

        let response = panel.runModal()
        switch response {
        case .OK:
            url = panel.url
        case _:
            url = nil
        }
        return url
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        print(urls)
    }
}

