//
//  Markdown.swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation
import SwiftUI

public struct Markdown<ImageView: View>: View {
    
    var blocks: [BlockNode]
    var inlineImageLoader: (InlineImage) async -> Void
    @ViewBuilder var imageBlockView: (_ image: InlineImage) -> ImageView
    
    public init(
        _ markdown: String,
        inlineImageLoader: @escaping (InlineImage) async -> Void,
        @ViewBuilder imageBlockView: @escaping (_ image: InlineImage) -> ImageView
    ) {
        self.init(
            .init(markdown),
            inlineImageLoader: inlineImageLoader,
            imageBlockView: imageBlockView
        )
    }
    
    public init(
        _ blocks: [BlockNode],
        inlineImageLoader: @escaping (InlineImage) async -> Void,
        @ViewBuilder imageBlockView: @escaping (_ image: InlineImage) -> ImageView
    ) {
        self.blocks = blocks
        self.inlineImageLoader = inlineImageLoader
        self.imageBlockView = imageBlockView
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
                    case let .spoiler(title: title, blocks: blocks):
                        SpoilerView(
                            title: title,
                            blocks: blocks,
                            inlineImageLoader: inlineImageLoader,
                            imageBlockView: imageBlockView
                        )
                    case let .codeBlock(fenceInfo: _, content: content):
                        codeBlock(content: content)
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
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func blockPadding(_ block: BlockNode, edge: VerticalEdge) -> CGFloat {
        8
    }
    
    @ViewBuilder
    func inlineMarkdown(_ inlines: [InlineNode]) -> some View {
        InlineMarkdown(
            inlines,
            inlineImageLoader: inlineImageLoader,
            imageBlockView: imageBlockView
        )
    }
    
    @ViewBuilder
    func heading(level: Int, inlines: [InlineNode]) -> some View {
        Group {
            switch level {
            case 1:
                VStack(alignment: .leading, spacing: 0) {
                    inlineMarkdown(inlines)
                        .font(.title)
                        .fontWeight(.bold)
                    Divider()
                }
            case 2:
                inlineMarkdown(inlines)
                    .font(.title2)
                    .fontWeight(.bold)
            case 3:
                inlineMarkdown(inlines)
                    .font(.title3)
                    .fontWeight(.semibold)
            default:
                inlineMarkdown(inlines)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
        }
    }
    
    @ViewBuilder
    func blockQuote(blocks: [BlockNode]) -> some View {
        Markdown(blocks, inlineImageLoader: inlineImageLoader, imageBlockView: imageBlockView)
            .padding(.leading, 15)
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(Color(uiColor: .tertiaryLabel))
                    .frame(width: 5)
                    .frame(maxHeight: .infinity)
            }
    }
    
    @ViewBuilder
    func codeBlock(content: String) -> some View {
        ScrollView(.horizontal) {
            Text(content.trimmingCharacters(in: .newlines))
                .font(.body.monospaced())
                .padding(10)
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    @ViewBuilder
    func bulletedList(items: [ListItemNode]) -> some View {
        VStack(spacing: 3) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .center, spacing: 8) {
                    Circle()
                        .fill(Color(uiColor: .tertiaryLabel))
                        .frame(width: 6, height: 6)
                    Markdown(item.blocks, inlineImageLoader: inlineImageLoader, imageBlockView: imageBlockView)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func numberedList(items: [ListItemNode], startIndex: Int = 1) -> some View {
        VStack(spacing: 3) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .center, spacing: 7) {
                    Text("\(startIndex + index).")
                        .foregroundStyle(.secondary)
                    Markdown(item.blocks, inlineImageLoader: inlineImageLoader, imageBlockView: imageBlockView)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
