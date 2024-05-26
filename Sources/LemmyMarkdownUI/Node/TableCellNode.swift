//
//  TableCellNode.swift
//
//
//  Created by Sjmarf on 26/04/2024.
//

import Foundation

public struct TableCellNode: Hashable, Node {
    let content: [InlineNode]
    
    var children: [Node] { content }
    
    var searchChildrenForLinks: Bool { true }
    public var links: [LinkData] { children.links }
}

internal extension TableCellNode {
    init(unsafeNode: UnsafeNode) {
        guard unsafeNode.nodeType == .tableCell else {
            fatalError("Expected a table cell but got a '\(unsafeNode.nodeType)' instead.")
        }
        self.init(content: unsafeNode.children.compactMap(InlineNode.init(unsafeNode:)))
    }
}
