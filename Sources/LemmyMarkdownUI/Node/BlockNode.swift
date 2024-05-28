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
    case bulletedList(isTight: Bool, items: [ListItemNode], truncatedRows: Int = 0)
    case numberedList(isTight: Bool, start: Int, items: [ListItemNode], truncatedRows: Int = 0)
    case codeBlock(fenceInfo: String?, content: String, truncatedRows: Int = 0)
    case paragraph(inlines: [InlineNode])
    case heading(level: Int, inlines: [InlineNode])
    case table(columnAlignments: [RawTableColumnAlignment], rows: [TableRowNode], truncatedRows: Int = 0)
    case thematicBreak
    
    // Renders as an ellipsis. It can be inserted into the tree when the tree is truncated.
    // This will never be created by the markdown parser.
    case truncationTerminator
    
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
        case let .bulletedList(_, items: items, _):
            return items
        case let .numberedList(_, _, items: items, _):
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
    
    internal func truncate(data: TruncationData) -> BlockNode? {
        switch self {
        case let .blockquote(blocks):
            return .blockquote(
                blocks: blocks.truncate(data: data)
            )
        case let .spoiler(title, blocks):
            data.linesRemaining -= 1
            return .spoiler(title: title, blocks: blocks)
        case let .bulletedList(isTight, items, _):
            if data.linesRemaining < 2 { return nil }
            let newItems = items.truncate(data: data)
            let truncatedRows = data.hasInsertedTerminator ? 0 : items.count - newItems.count
            if items.count != newItems.count {
                data.hasInsertedTerminator = true
            }
            return .bulletedList(
                isTight: isTight,
                items: newItems,
                truncatedRows: truncatedRows
            )
        case let .numberedList(isTight, start, items, _):
            if data.linesRemaining < 2 { return nil }
            let newItems = items.truncate(data: data)
            let truncatedRows = data.hasInsertedTerminator ? 0 : items.count - newItems.count
            if items.count != newItems.count {
                data.hasInsertedTerminator = true
            }
            return .numberedList(
                isTight: isTight,
                start: start,
                items: newItems,
                truncatedRows: truncatedRows
            )
        case let .codeBlock(fenceInfo, content, _):
            if data.linesRemaining < 2 { return nil }
            let lines = content.split(separator: "\n")
            let newLines = lines.prefix(data.linesRemaining)
            data.linesRemaining -= newLines.count
            let truncatedRows = data.hasInsertedTerminator ? 0 : lines.count - newLines.count
            if newLines.count != lines.count {
                data.hasInsertedTerminator = true
            }
            return .codeBlock(
                fenceInfo: fenceInfo,
                content: newLines.joined(separator: "\n"),
                truncatedRows: truncatedRows
            )
        case let .paragraph(inlines):
            return .paragraph(
                inlines: inlines.truncate(data: data)
            )
        case let .heading(level, inlines):
            return .heading(
                level: level,
                inlines: inlines.truncate(data: data)
            )
        case let .table(columnAlignments, rows, _):
            if data.linesRemaining < 2 { return nil }
            let newRows = rows.prefix(data.linesRemaining)
            data.linesRemaining -= newRows.count
            if data.linesRemaining <= 0 {
                data.hasInsertedTerminator = true
            }
            return .table(
                columnAlignments: columnAlignments,
                rows: Array(newRows),
                truncatedRows: rows.count - newRows.count
            )
        default:
            return self
        }
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
                level: unsafeNode.headingLevel,
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
        default:
            assertionFailure("Unhandled node type '\(unsafeNode.nodeType)' in BlockNode.")
            return nil
        }
    }
}
