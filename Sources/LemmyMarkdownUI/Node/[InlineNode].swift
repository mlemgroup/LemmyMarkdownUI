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
        self.init((blocks.first?.children as? [InlineNode]) ?? [])
    }
}
