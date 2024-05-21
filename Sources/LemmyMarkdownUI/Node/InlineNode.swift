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
    case lemmyLink(type: LemmyLinkType, content: String, name: String, domain: String)
    case link(destination: String, children: [InlineNode])
    case image(source: String, children: [InlineNode])
    
    internal var children: [any Node] { inlineChildren }
    
    var inlineChildren: [InlineNode] {
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
        case let .image(_, children):
            return children
        default:
            return []
        }
    }
    
    var string: String? {
        switch self {
        case let .text(string):
            return string
        case let .code(string):
            return string
        case .softBreak:
            return " "
        case .lineBreak:
            return "\n"
        case let .lemmyLink(type: _, content: content, name: _, domain: _):
            return content
        default:
            return nil
        }
    }
    
    var searchChildrenForLinks: Bool { true }
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
        case .lemmyLink:
            self = .lemmyLink(
                type: unsafeNode.lemmyLinkIsCommunity ? .community : .person,
                content: unsafeNode.lemmyLinkContent ?? "",
                name: unsafeNode.lemmyLinkName ?? "",
                domain: unsafeNode.lemmyLinkDomain ?? ""
            )
        default:
            assertionFailure("Unhandled node type '\(unsafeNode.nodeType)' in InlineNode.")
            return nil
        }
    }
}
