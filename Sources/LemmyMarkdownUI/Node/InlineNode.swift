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
    case link(destination: String, tooltip: String?, children: [InlineNode])
    case image(source: String, tooltip: String?, children: [InlineNode])
    case censored
    
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
        case let .link(_, _, children):
            return children
        case let .image(_, _, children):
            return children
        default:
            return []
        }
    }
    
    internal func mutatingChildren(_ mutator: ([InlineNode]) -> [InlineNode]) -> InlineNode {
        switch self {
        case let .emphasis(children):
            return .emphasis(children: mutator(children))
        case let .strong(children):
            return .strong(children: mutator(children))
        case let .superscript(children):
            return .superscript(children: mutator(children))
        case let .subscript(children):
            return .subscript(children: mutator(children))
        case let .strikethrough(children):
            return .strikethrough(children: mutator(children))
        case let .link(destination, tooltip, children):
            return .link(destination: destination, tooltip: tooltip, children: mutator(children))
        case let .image(source, tooltip, children):
            return .image(source: source, tooltip: tooltip, children: mutator(children))
        default:
            return self
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
        default:
            return nil
        }
    }
    
    public var links: [LinkData] {
        var ret: [LinkData] = .init()
        if case let InlineNode.link(destination: destination, _, children: children) = self {
            if let url = URL(string: destination) {
                ret.append(.init(title: children, url: url))
            }
        }
        if self.searchChildrenForLinks {
            ret += self.inlineChildren.links
        }
        return ret
    }
    
    public var images: [LinkData] {
        var ret: [LinkData] = .init()
        if case let InlineNode.image(source, _, children) = self {
            if let url = URL(string: source) {
                ret.append(.init(title: children, url: url))
            }
        }
        if self.searchChildrenForLinks {
            ret += self.inlineChildren.images
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
            let children = unsafeNode.children.compactMap(InlineNode.init(unsafeNode:))
            // This isn't currently localized on the backend; it's always in English
            // https://github.com/LemmyNet/lemmy/blob/d1eff9084b6c7fe2629699a12452c38fe5d84cf7/crates/utils/src/utils/slurs.rs#L6
            if children == [.text("removed")] {
                self = .censored
            } else {
                self = .emphasis(children: children)
            }
        case .strong:
            self = .strong(children: unsafeNode.children.compactMap(InlineNode.init(unsafeNode:)))
        case .superscript:
            self = .superscript(children: unsafeNode.children.compactMap(InlineNode.init(unsafeNode:)))
        case .subscript:
            self = .subscript(children: unsafeNode.children.compactMap(InlineNode.init(unsafeNode:)))
        case .strikethrough:
            self = .strikethrough(children: unsafeNode.children.compactMap(InlineNode.init(unsafeNode:)))
        case .link:
            let tooltip = unsafeNode.title
            self = .link(
                destination: unsafeNode.url ?? "",
                tooltip: (tooltip?.isEmpty ?? true) ? nil : tooltip,
                children: unsafeNode.children.compactMap(InlineNode.init(unsafeNode:))
            )
        case .image:
            let tooltip = unsafeNode.title
            self = .image(
                source: unsafeNode.url ?? "",
                tooltip: (tooltip?.isEmpty ?? true) ? nil : tooltip,
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
