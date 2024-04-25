//
//  UnsafeNodeSequence.swift.swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation
import cmark_lemmy

internal struct UnsafeNodeSequence: Sequence {
    struct Iterator: IteratorProtocol {
        private var node: UnsafeNode?

        init(_ node: UnsafeNode?) {
            self.node = node
        }

        mutating func next() -> UnsafeNode? {
            guard let node else { return nil }
            defer { self.node = cmark_node_next(node) }
            return node
        }
    }

    private let node: UnsafeNode?

    init(_ node: UnsafeNode?) {
        self.node = node
    }

    func makeIterator() -> Iterator {
        .init(node)
    }
}
