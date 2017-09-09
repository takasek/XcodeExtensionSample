//
//  XcodeExtensionSampleHelper.swift
//  XcodeExtensionSampleHelper
//
//  Created by Yoshitaka Seki on 2017/09/09.
//  Copyright © 2017年 takasek. All rights reserved.
//


import Foundation

@objc class XcodeExtensionSampleHelper: NSObject, XcodeExtensionSampleHelperProtocol {
    func write(text: String, to directory: String, reply: @escaping HelperResultHandler) {

        try? text.write(
            toFile: directory + "/outputFile",
            atomically: true, encoding: .utf8
        )

        reply(0)
    }
}

