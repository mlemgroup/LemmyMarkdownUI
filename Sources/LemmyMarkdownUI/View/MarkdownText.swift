//
//  InlineMarkdown.swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation
import SwiftUI

public struct MarkdownText: View {
    
    private var type: InlineRenderer.InlineType
    private var configuration: MarkdownConfiguration
    private var loadImages: Bool
    
    public init(
        _ markdown: String,
        configuration: MarkdownConfiguration,
        loadImages: Bool = true
    ) {
        self.init(
            [BlockNode].init(markdown),
            configuration: configuration,
            loadImages: loadImages
        )
    }
    
    public init(
        _ inlines: [InlineNode],
        configuration: MarkdownConfiguration,
        loadImages: Bool = true
    ) {
        self.type = InlineRenderer(inlines: inlines, configuration: configuration).type
        self.configuration = configuration
        self.loadImages = loadImages
    }
    
    public init(
        _ blocks: [BlockNode],
        configuration: MarkdownConfiguration,
        loadImages: Bool = true
    ) {
        self.type = InlineRenderer(blocks: blocks, configuration: configuration).type
        self.configuration = configuration
        self.loadImages = loadImages
    }
    
    public var body: some View {
        switch type {
        case let .text(components, images):
            if configuration.allowInlineImages {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(components.grouped(), id: \.self) { group in
                        if group.count == 1, let item = group.first {
                            if case let .image(image) = item {
                                configuration.imageBlockView(image)
                            } else {
                                group.text(configuration: configuration)
                            }
                        } else {
                            group.text(configuration: configuration)
                        }
                    }
                }
                .task {
                    if loadImages {
                        for image in images {
                            await configuration.inlineImageLoader(image)
                        }
                    }
                }
                .foregroundStyle(configuration.primaryColor)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(components.enumerated()), id: \.offset) { _, item in
                        switch item {
                        case let .text(text):
                            Text(text)
                        case let .image(image):
                            configuration.imageBlockView(image)
                        }
                    }
                }
            }
        case let .singleImage(image):
            configuration.imageBlockView(image)
        }
    }
}

@available(*, deprecated, renamed: "MarkdownText")
public typealias InlineMarkdown = MarkdownText
