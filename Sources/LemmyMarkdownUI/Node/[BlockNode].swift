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
    
    var links: [(title: [InlineNode], url: URL)] {
        var ret: [(title: [InlineNode], url: URL)] = .init()
        var stack: [any Node] = self
        while !stack.isEmpty {
            let node = stack.removeFirst()
            if node.searchChildrenForLinks {
                stack.append(contentsOf: node.children)
            }
            if case let InlineNode.link(destination: destination, children: children) = node {
                if let url = URL(string: destination) {
                    ret.append((title: children, url: url))
                }
            }
        }
        return ret
    }
}
