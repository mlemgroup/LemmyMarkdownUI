//
//  TableRowNode.swift
//
//
//  Created by Sjmarf on 26/04/2024.
//

import Foundation

public struct TableRowNode: Hashable, Node {
    let cells: [TableCellNode]
    
    var children: [any Node] { cells }
    
    var searchChildrenForLinks: Bool { true }
    public var links: [LinkData] { children.links }
    public var images: [LinkData] { children.images }
}

internal extension TableRowNode {
    init(unsafeNode: UnsafeNode) {
        guard unsafeNode.nodeType == .tableRow || unsafeNode.nodeType == .tableHead else {
            fatalError("Expected a table row but got a '\(unsafeNode.nodeType)' instead.")
        }
        self.init(cells: unsafeNode.children.map(TableCellNode.init(unsafeNode:)))
    }
}
