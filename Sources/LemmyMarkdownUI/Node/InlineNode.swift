//
//  InlineNode.swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation

public enum InlineNode: Hashable, Node {
    case text(String)
    case softBreak
    case lineBreak
    case code(String)
    case emphasis(children: [InlineNode])
    case strong(children: [InlineNode])
    case superscript(children: [InlineNode])
    case `subscript`(children: [InlineNode])
    case strikethrough(children: [InlineNode])
    case link(destination: String, children: [InlineNode])
    case image(source: String, children: [InlineNode], truncated: Bool = false)
    
    // Renders as an ellipsis. It can be inserted into the tree when the tree is truncated.
    // This will never be created by the markdown parser.
    case truncationTerminator
    
    internal var children: [any Node] { inlineChildren }
    
    internal var inlineChildren: [InlineNode] {
        switch self {
        case let .emphasis(children):
            return children
        case let .strong(children):
            return children
        case let .superscript(children):
            return children
        case let .subscript(children):
            return children
        case let .strikethrough(children):
            return children
        case let .link(_, children):
            return children
        case let .image(_, children, _):
            return children
        default:
            return []
        }
    }
    
    internal var string: String? {
        switch self {
        case let .text(string):
            return string
        case let .code(string):
            return string
        case .softBreak:
            return " "
        case .lineBreak:
            return "\n"
        case .truncationTerminator:
            return "..."
        default:
            return nil
        }
    }
    
    public var links: [LinkData] {
        var ret: [LinkData] = .init()
        if case let InlineNode.link(destination: destination, children: children) = self {
            if let url = URL(string: destination) {
                ret.append(.init(title: children, url: url))
            }
        }
        if self.searchChildrenForLinks {
            ret += self.inlineChildren.links
        }
        return ret
    }
    
    public var stringLiteral: String {
        if let string { return string }
        return inlineChildren.stringLiteral
    }
    
    internal var searchChildrenForLinks: Bool { true }
}

internal extension InlineNode {
    // swiftlint:disable:next cyclomatic_complexity
    init?(unsafeNode: UnsafeNode) {
        switch unsafeNode.nodeType {
        case .text:
            self = .text(unsafeNode.literal ?? "")
        case .softBreak:
            self = .softBreak
        case .lineBreak:
            self = .lineBreak
        case .code:
            self = .code(unsafeNode.literal ?? "")
        case .emphasis:
            self = .emphasis(children: unsafeNode.children.compactMap(InlineNode.init(unsafeNode:)))
        case .strong:
            self = .strong(children: unsafeNode.children.compactMap(InlineNode.init(unsafeNode:)))
        case .superscript:
            self = .superscript(children: unsafeNode.children.compactMap(InlineNode.init(unsafeNode:)))
        case .subscript:
            self = .subscript(children: unsafeNode.children.compactMap(InlineNode.init(unsafeNode:)))
        case .strikethrough:
            self = .strikethrough(children: unsafeNode.children.compactMap(InlineNode.init(unsafeNode:)))
        case .link:
            self = .link(
                destination: unsafeNode.url ?? "",
                children: unsafeNode.children.compactMap(InlineNode.init(unsafeNode:))
            )
        case .image:
            self = .image(
                source: unsafeNode.url ?? "",
                children: unsafeNode.children.compactMap(InlineNode.init(unsafeNode:))
            )
        case .htmlInline:
            self = .text(unsafeNode.literal ?? "")
        default:
            assertionFailure("Unhandled node type '\(unsafeNode.nodeType)' in InlineNode.")
            return nil
        }
    }
}
