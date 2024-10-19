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
    
    var images: [LinkData] {
        self.reduce([], { $0 + $1.images })
    }
    
    var isSimpleParagraphs: Bool {
        for node in self {
            switch node {
            case let .paragraph(inlines: inlines):
                if inlines.isSingleImage { return false }
            default:
                return false
            }
        }
        return true
    }
}
