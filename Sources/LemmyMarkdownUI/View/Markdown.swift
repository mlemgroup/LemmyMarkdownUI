//
//  Markdown.swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation
import SwiftUI

public struct Markdown: View {
    var blocks: [BlockNode]
    var configuration: MarkdownConfiguration
    
    public init(
        _ markdown: String,
        configuration: MarkdownConfiguration
    ) {
        self.init(
            .init(markdown),
            configuration: configuration
        )
    }
    
    public init(
        _ blocks: [BlockNode],
        configuration: MarkdownConfiguration
    ) {
        self.blocks = blocks
        self.configuration = configuration
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { index, block in
                Group {
                    switch block {
                    case let .paragraph(inlines: inlines):
                        inlineMarkdown(inlines)
                    case let .heading(level: level, inlines: inlines):
                        heading(level: level, inlines: inlines)
                    case let .blockquote(blocks: blocks):
                        blockQuote(blocks: blocks)
                    case let .table(columnAlignments: columnAlignments, rows: rows):
                        TableView(columnAlignments: columnAlignments, rows: rows, configuration: configuration)
                    case let .spoiler(title: title, blocks: blocks):
                        SpoilerView(
                            title: title,
                            blocks: blocks,
                            configuration: configuration
                        )
                    case let .codeBlock(fenceInfo: _, content: content):
                        CodeBlockView(content: content, configuration: configuration)
                    case .thematicBreak:
                        Rectangle()
                            .fill(Color(uiColor: .secondarySystemBackground))
                            .frame(height: 3)
                            .frame(maxWidth: .infinity)
                    case let .bulletedList(isTight: _, items: items):
                        bulletedList(items: items)
                    case let .numberedList(isTight: _, start: start, items: items):
                        numberedList(items: items, startIndex: start)
                    }
                }
                .padding(.top, (index == 0) ? 0 : blockPadding(block, edge: .top))
                .padding(.bottom, (index == blocks.count - 1) ? 0 : blockPadding(block, edge: .bottom))
            }
        }
        .foregroundStyle(configuration.primaryColor)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }
    
    func blockPadding(_ block: BlockNode, edge: VerticalEdge) -> CGFloat {
        return 8
    }
    
    @ViewBuilder
    func inlineMarkdown(_ inlines: [InlineNode]) -> some View {
        MarkdownText(
            inlines,
            configuration: configuration
        )
    }
    
    @ViewBuilder
    func heading(level: HeadingLevel, inlines: [InlineNode]) -> some View {
            VStack(alignment: .leading, spacing: 0) {
                MarkdownText(
                    inlines,
                    configuration: configuration.withFont(level.font)
                )
                .fontWeight(.semibold)
                if level == ._1 {
                    Divider()
                }
            }
    }
    
    @ViewBuilder
    func blockQuote(blocks: [BlockNode]) -> some View {
        Markdown(blocks, configuration: configuration)
            .padding(.leading, 15)
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(Color(uiColor: .tertiaryLabel))
                    .frame(width: 5)
                    .frame(maxHeight: .infinity)
            }
    }
    
    @ViewBuilder
    func bulletedList(items: [ListItemNode]) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 8) {
                    Text(" ")
                        .overlay {
                            Circle()
                                .fill(Color(uiColor: .tertiaryLabel))
                        }
                    Markdown(item.blocks, configuration: configuration)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    func numberedList(items: [ListItemNode], startIndex: Int = 1) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 7) {
                    Text("\(startIndex + index).")
                        .foregroundStyle(configuration.secondaryColor)
                    Markdown(item.blocks, configuration: configuration)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var fadeGradient: some View {
        LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
    }
}
