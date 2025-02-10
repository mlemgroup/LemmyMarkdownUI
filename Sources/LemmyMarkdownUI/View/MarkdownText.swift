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
    private var images: [MarkdownImage]
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
        let groupedComponents = components.grouped(configuration: configuration)
        Group {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(groupedComponents.enumerated()), id: \.offset) { _, group in
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
        .task {
            for image in images {
                await configuration.inlineImageLoader(image)
            }
        }
        .foregroundStyle(configuration.primaryColor)
    }
}
