//
//  UTI.swift
//  ExtensionSample
//
//  Created by Yoshitaka Seki on 2017/08/12.
//  Copyright © 2017年 takasek. All rights reserved.
//

import Foundation

struct UTI: Equatable {
    let value: String

    static let swiftSource = UTI(value: "public.swift-source")
    static let cHeader = UTI(value: "public.c-header")
    static let objCSource = UTI(value: "public.objective-c-source")
    static let playground = UTI(value: "com.apple.dt.playground")
    static let playgroundPage = UTI(value: "com.apple.dt.playgroundpage")
    static let storyboard = UTI(value: "com.apple.InterfaceBuilder3.Storyboard.XIB")
    static let xib = UTI(value: "com.apple.InterfaceBuilder3.Cocoa.XIB")
    static let markdown = UTI(value: "net.daringfireball.markdown")
    static let xml = UTI(value: "public.xml")
    static let json = UTI(value: "public.json")
    static let plist = UTI(value: "com.apple.xml-property-list")
    static let entitlement = UTI(value: "com.apple.xcode.entitlements-property-list")

    func conforms(to uti: UTI) -> Bool {
        return UTTypeConformsTo(value as CFString, uti.value as CFString)
    }

    static func ~= (pattern: UTI, value: UTI) -> Bool {
        return value.conforms(to: pattern)
    }

    var fileExtension: String? {
        return UTTypeCopyPreferredTagWithClass(
            value as CFString,
            kUTTagClassFilenameExtension
            )?.takeRetainedValue() as String?
    }
    static func == (lhs: UTI, rhs: UTI) -> Bool {
        return lhs.value == rhs.value
    }
}

