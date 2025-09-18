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
        MarkdownLayout {
            ForEach(Array(blocks.enumerated()), id: \.offset) { index, block in
                Group {
                    switch block {
                    case let .paragraph(inlines: inlines):
                        MarkdownText(inlines, configuration: configuration)
                            .markdownMinimumSpacing(16)
                    case let .heading(level: level, inlines: inlines):
                        heading(level: level, inlines: inlines)
                    case let .blockquote(blocks: blocks):
                        blockQuote(blocks: blocks)
                    case let .table(columnAlignments: columnAlignments, rows: rows):
                        TableView(columnAlignments: columnAlignments, rows: rows, configuration: configuration)
                            .markdownMinimumSpacing(16)
                    case let .spoiler(title: title, blocks: blocks):
                        SpoilerView(
                            title: title,
                            blocks: blocks,
                            configuration: configuration
                        )
                        .markdownMinimumSpacing(16)
                    case let .codeBlock(fenceInfo: fenceInfo, content: content):
                        let language = fenceInfo?.split(separator: " ").first.map(String.init)
                        CodeBlockView(
                            content: content,
                            language: language?.isEmpty == true ? nil : language,
                            configuration: configuration
                        )
                            .markdownMinimumSpacing(16)
                    case .thematicBreak:
                        Rectangle()
                            .fill(Color(uiColor: .secondarySystemBackground))
                            .frame(height: 3)
                            .frame(maxWidth: .infinity)
                            .markdownMinimumSpacing(16)
                    case let .bulletedList(isTight: _, items: items):
                        bulletedList(items: items)
                            .markdownMinimumSpacing(16)
                    case let .numberedList(isTight: _, start: start, items: items):
                        numberedList(items: items, startIndex: start)
                            .markdownMinimumSpacing(16)
                    }
                }
            }
        }
        .foregroundStyle(configuration.primaryColor)
        .frame(maxWidth: .infinity, alignment: .leading)
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
            .markdownMinimumSpacing(16)
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
            .markdownMinimumSpacing(16)
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
