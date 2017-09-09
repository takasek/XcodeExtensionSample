//
//  XcodeExtensionSampleHelper.swift
//  XcodeExtensionSampleHelper
//
//  Created by Yoshitaka Seki on 2017/09/09.
//  Copyright © 2017年 takasek. All rights reserved.
//


import Foundation
import Cocoa

@objc class XcodeExtensionSampleHelper: NSObject, XcodeExtensionSampleHelperProtocol {
    func execute(in directory: String, with arguments: [String], reply: @escaping HelperResultHandler) {

//        let task = Process(), stdout = Pipe(), stderr = Pipe()
//        task.launchPath = "/usr/bin/env"
//        task.arguments = ["/usr/local/bin/swiftlint"] + arguments
//        task.currentDirectoryPath = directory
//        task.standardOutput = stdout
//        task.standardError = stderr
//        task.launch()
//
//        let output = String(data: stdout.fileHandleForReading.readDataToEndOfFile(),
//                            encoding: .utf8) ?? ""
//        let errorOutput = String(data: stderr.fileHandleForReading.readDataToEndOfFile(),
//                                 encoding: .utf8) ?? ""
//
//        let e = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).first!
//        try? errorOutput.write(toFile: e + "/testest", atomically: true, encoding: .utf8)

        reply(0, "output", "errorOutput")
    }
}

