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
    
    internal func truncate(data: TruncationData) -> [BlockNode] {
        var ret: [BlockNode] = .init()
        for node in self {
            if data.linesRemaining <= 0 {
                break
            }
            if let output = node.truncate(data: data) {
                ret.append(output)
            } else {
                data.linesRemaining = 0
                break
            }
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
        let data: TruncationData = .init(linesRemaining: lineCount, charactersPerLine: charactersPerLine)
        let output = truncate(data: data)
        if data.linesRemaining <= 0, output.count != self.count, !data.hasInsertedTerminator {
            return output + [.truncationTerminator]
        }
        return output
    }
}
