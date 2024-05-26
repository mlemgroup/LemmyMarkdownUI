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
}
