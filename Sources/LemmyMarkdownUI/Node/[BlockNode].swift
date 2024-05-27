//
//  [BlockNode].swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation

public extension [BlockNode] {
    init(_ markdown: String) {
        self.init(UnsafeNode.parseMarkdown(markdown: markdown) ?? [])
    }
    
    var links: [LinkData] {
        self.reduce([], { $0 + $1.links })
    }
    
    internal func truncate(remainingLines: inout Int, charactersPerLine: Int) -> [BlockNode] {
        var ret: [BlockNode] = .init()
        for node in self {
            if remainingLines <= 0 {
                break
            }
            ret.append(node.truncate(remainingLines: &remainingLines, charactersPerLine: charactersPerLine))
        }
        switch ret.last {
        case .thematicBreak:
            return ret.dropLast()
        case .heading:
            if ret.count > 1 {
                return ret.dropLast()
            }
            return ret
        default:
            return ret
        }
    }
    
    func truncate(lineCount: Int, charactersPerLine: Int) -> [BlockNode] {
        var lineCount = lineCount
        return truncate(remainingLines: &lineCount, charactersPerLine: charactersPerLine)
    }
}
