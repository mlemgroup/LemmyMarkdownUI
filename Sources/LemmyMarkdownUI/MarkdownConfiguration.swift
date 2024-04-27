//
//  MarkdownConfiguration.swift
//
//
//  Created by Sjmarf on 26/04/2024.
//

import SwiftUI

public struct MarkdownConfiguration {
    public let inlineImageLoader: (InlineImage) async -> Void
    @ViewBuilder public let imageBlockView: (_ image: InlineImage) -> AnyView
    
    public init(inlineImageLoader: @escaping (InlineImage) async -> Void, imageBlockView: @escaping (_: InlineImage) -> AnyView) {
        self.inlineImageLoader = inlineImageLoader
        self.imageBlockView = imageBlockView
    }
}
