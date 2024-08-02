//
//  InlineMarkdown.swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation
import SwiftUI

public struct MarkdownText: View {
    
    private var components: [InlineRenderer.Component]
    private var images: [InlineImage]
    private var configuration: MarkdownConfiguration
    
    public init(
        _ markdown: String,
        configuration: MarkdownConfiguration
    ) {
        self.init(
            [BlockNode].init(markdown),
            configuration: configuration
        )
    }
    
    public init(
        _ inlines: [InlineNode],
        configuration: MarkdownConfiguration
    ) {
        let renderer = InlineRenderer(inlines: inlines, configuration: configuration)
        self.components = renderer.components
        self.images = renderer.images
        self.configuration = configuration
    }
    
    public init(
        _ blocks: [BlockNode],
        configuration: MarkdownConfiguration
    ) {
        let renderer = InlineRenderer(blocks: blocks, configuration: configuration)
        self.components = renderer.components
        self.images = renderer.images
        self.configuration = configuration
    }
    
    public var body: some View {
        if configuration.allowInlineImages {
            Group {
                let groupedComponents = components.grouped()
                if groupedComponents.count == 1, let group = groupedComponents.first {
                    group.text(configuration: configuration)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(groupedComponents, id: \.self) { group in
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
                }
            }
            .task {
                for image in images {
                    await configuration.inlineImageLoader(image)
                }
            }
            .foregroundStyle(configuration.primaryColor)
        } else {
            if images.isEmpty {
                components.text(configuration: configuration)
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
        }
    }
}

@available(*, deprecated, renamed: "MarkdownText")
public typealias InlineMarkdown = MarkdownText
