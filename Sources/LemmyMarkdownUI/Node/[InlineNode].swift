//
//  [InlineNode].swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation

public extension [InlineNode] {
    init(_ markdown: String) {
        let blocks: [BlockNode] = .init(markdown)
        self.init((blocks.first?.children as? [InlineNode]) ?? [.text(markdown)])
    }
    
    var links: [LinkData] {
        self.reduce([], { $0 + $1.links })
    }
    
    var images: [LinkData] {
        self.reduce([], { $0 + $1.images })
    }
    
    var stringLiteral: String {
        self.reduce("", { $0 + $1.stringLiteral })
    }
    
    var isSingleImage: Bool {
        var canBeSingleImage = false
        for node in self {
            switch node {
            case .image:
                canBeSingleImage = true
            default:
                if !node.stringLiteral.allSatisfy(\.isWhitespace) {
                    return false
                }
            }
        }
        return canBeSingleImage
    }
}
