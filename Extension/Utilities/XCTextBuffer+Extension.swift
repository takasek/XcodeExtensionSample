//
//  XCTextBuffer+Extension.swift
//  ExtensionSample
//
//  Created by Yoshitaka Seki on 2017/08/12.
//  Copyright © 2017年 takasek. All rights reserved.
//

import Foundation
import XcodeKit

extension XCSourceTextBuffer {
    var typedContentUTI: UTI {
        return UTI(value: contentUTI)
    }
    func selectedText(includesUnselectedStartAndEnd: Bool, trimsIndents: Bool) -> String {
        var texts: [NSString] = []
        var minimumIndentLength = Int.max

        selections
            .map { $0 as! XCSourceTextRange }
            .forEach { selection in
                for line in selection.start.line...selection.end.line {
                    guard line < lines.count else {
                        // if you select none and place the cursor on last line, it can be out of bound of lines
                        return
                    }
                    var text = self.lines[line] as! NSString

                    if !includesUnselectedStartAndEnd {
                        if line == selection.end.line {
                            text = text.substring(to: selection.end.column) as NSString
                        }
                        if line == selection.start.line {
                            text = text.substring(from: selection.start.column) as NSString
                        }
                    }

                    text = text.trimmingCharacters(in: CharacterSet(charactersIn: "\n")) as NSString

                    texts.append(text)

                    if text.length != 0 {
                        // race with latest indent length
                        minimumIndentLength = min(minimumIndentLength, text.indentLength)
                    }
                }
        }

        return texts
            .map {
                if trimsIndents {
                    return $0.length >= minimumIndentLength
                        ? $0.substring(from: minimumIndentLength)
                        : $0 as String
                } else {
                    return $0 as String
                }
            }
            .joined(separator: "\n")
    }

    enum Error: MessagedError {
        case noSelection
        case invalidLine

        var message: String {
            switch self {
            case .noSelection: return "no selection found."
            case .invalidLine: return "line is invalid."
            }
        }
    }

    func insertConsideringLastLineIndents(_ insertion: String, at lineNum: Int) throws {
        guard lineNum <= lines.count else {
            throw Error.invalidLine
        }

        let lastLine = lines[lineNum-1] as! NSString
        let prefix = String.init(repeating: " ", count: lastLine.indentLength)

        let fixedInsertion = insertion.split(separator: "\n").map {
            if $0.isEmpty {
                return String($0)
            } else {
                return prefix + String($0)
            }
            }.joined(separator: "\n")

        lines.insert(fixedInsertion, at: lineNum)
    }

    func replaceSelection(by insertion: String) throws {
        guard let selection = selections.firstObject as? XCSourceTextRange else { throw Error.noSelection }

        let pre = (lines[selection.start.line] as! NSString).substring(to: selection.start.column)
        let post = (lines[selection.end.line] as! NSString).substring(to: selection.end.column)

        lines.removeObjects(at: IndexSet(integersIn: selection.start.line...selection.end.line))
        lines.insert(pre + insertion + post, at: selection.start.line)
    }
}

private extension NSString {
    var indentLength: Int {
        var result = 0
        for i in 0..<length {
            guard substring(with: NSRange(location: i, length: 1)) == " " else { break }
            result += 1
        }
        return result
    }
}

