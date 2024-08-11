//
//  ListItemNode.swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation

public struct ListItemNode: Hashable, Node {
    var searchChildrenForLinks: Bool { true }
    
    public let blocks: [BlockNode]
    
    var children: [Node] { blocks }
    public var links: [LinkData] { children.links }
    public var images: [LinkData] { children.images }
}

internal extension ListItemNode {
    init(unsafeNode: UnsafeNode) {
        guard unsafeNode.nodeType == .item else {
            fatalError("Expected a list item but got a '\(unsafeNode.nodeType)' instead.")
        }
        self.init(blocks: unsafeNode.children.compactMap(BlockNode.init(unsafeNode:)))
    }
    
    func truncate(data: TruncationData) -> ListItemNode {
        return .init(blocks: blocks.truncate(data: data))
    }
}

internal extension [ListItemNode] {
    func truncate(data: TruncationData) -> [ListItemNode] {
        var ret: [ListItemNode] = .init()
        for node in self {
            if data.linesRemaining <= 0 {
                break
            }
            ret.append(node.truncate(data: data))
        }
        return ret
    }
}
