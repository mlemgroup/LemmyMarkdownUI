//
//  ListItemNode.swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation

public struct ListItemNode: Hashable, Node {
    var searchChildrenForLinks: Bool { true }
    
    let blocks: [BlockNode]
    
    var children: [Node] { blocks }
    public var links: [LinkData] { children.links }
}

internal extension ListItemNode {
    init(unsafeNode: UnsafeNode) {
        guard unsafeNode.nodeType == .item else {
            fatalError("Expected a list item but got a '\(unsafeNode.nodeType)' instead.")
        }
        self.init(blocks: unsafeNode.children.compactMap(BlockNode.init(unsafeNode:)))
    }
    
    func truncate(remainingLines: inout Int, charactersPerLine: Int) -> ListItemNode {
        return .init(blocks: blocks.truncate(remainingLines: &remainingLines, charactersPerLine: charactersPerLine))
    }
}

internal extension [ListItemNode] {
    func truncate(remainingLines: inout Int, charactersPerLine: Int) -> [ListItemNode] {
        var ret: [ListItemNode] = .init()
        for node in self {
            if remainingLines <= 0 {
                break
            }
            ret.append(node.truncate(remainingLines: &remainingLines, charactersPerLine: charactersPerLine))
        }
        return ret
    }
}
