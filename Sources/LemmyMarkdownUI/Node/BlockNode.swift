//
//  BlockNode.swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation
import cmark_lemmy

public enum BlockNode: Hashable, Node {
    case blockquote(blocks: [BlockNode])
    case spoiler(title: String?, blocks: [BlockNode])
    case bulletedList(isTight: Bool, items: [ListItemNode])
    case numberedList(isTight: Bool, start: Int, items: [ListItemNode])
    case codeBlock(fenceInfo: String?, content: String)
    case paragraph(inlines: [InlineNode])
    case heading(level: HeadingLevel, inlines: [InlineNode])
    case table(columnAlignments: [RawTableColumnAlignment], rows: [TableRowNode])
    case thematicBreak
    
    internal var children: [any Node] {
        switch self {
        case let .blockquote(blocks):
            return blocks
        case let .paragraph(inlines):
            return inlines
        case let .heading(_, inlines):
            return inlines
        case let .spoiler(_, blocks: blocks):
            return blocks
        case let .bulletedList(_, items: items):
            return items
        case let .numberedList(_, _, items: items):
            return items
        default:
            return []
        }
    }
    
    internal var searchChildrenForLinks: Bool {
        switch self {
        case .spoiler:
            false
        default:
            true
        }
    }
    
    public var links: [LinkData] {
        if case .spoiler = self {
            return children.links.map {
                var new = $0
                new.insideSpoiler = true
                return new
            }
        }
        return children.links
    }
    
    public var images: [LinkData] {
        if case .spoiler = self {
            return children.images.map {
                var new = $0
                new.insideSpoiler = true
                return new
            }
        }
        return children.images
    }
}

internal extension BlockNode {
    // swiftlint:disable:next cyclomatic_complexity
    init?(unsafeNode: UnsafeNode) {
        switch unsafeNode.nodeType {
        case .blockquote:
            self = .blockquote(blocks: unsafeNode.children.compactMap(BlockNode.init(unsafeNode:)))
        case .list:
            switch unsafeNode.listType {
            case CMARK_BULLET_LIST:
                self = .bulletedList(
                    isTight: unsafeNode.isTightList,
                    items: unsafeNode.children.map(ListItemNode.init(unsafeNode:))
                )
            case CMARK_ORDERED_LIST:
                self = .numberedList(
                    isTight: unsafeNode.isTightList,
                    start: unsafeNode.listStart,
                    items: unsafeNode.children.map(ListItemNode.init(unsafeNode:))
                )
            default:
                assertionFailure("cmark reported a list node without a list type.")
                self = .paragraph(inlines: [.text("???")])
            }
        case .codeBlock:
            self = .codeBlock(fenceInfo: unsafeNode.fenceInfo, content: unsafeNode.literal ?? "")
        case .paragraph:
            self = .paragraph(inlines: unsafeNode.children.compactMap(InlineNode.init(unsafeNode:)))
        case .heading:
            self = .heading(
                level: .init(rawValue: unsafeNode.headingLevel) ?? ._6,
                inlines: unsafeNode.children.compactMap(InlineNode.init(unsafeNode:))
            )
            case .table:
              self = .table(
                columnAlignments: unsafeNode.tableAlignments,
                rows: unsafeNode.children.map(TableRowNode.init(unsafeNode:))
              )
        case .spoiler:
            self = .spoiler(
                title: unsafeNode.spoilerTitle,
                blocks: unsafeNode.children.compactMap(BlockNode.init(unsafeNode:))
            )
        case .thematicBreak:
            self = .thematicBreak
        case .htmlBlock:
            self = .paragraph(inlines: [.text(unsafeNode.literal ?? "")])
        default:
            assertionFailure("Unhandled node type '\(unsafeNode.nodeType)' in BlockNode.")
            return nil
        }
    }
}
