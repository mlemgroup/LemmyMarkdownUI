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
    
    public let stubSpoilers: Bool
    public let spoilerStubIcon: String
    public let truncationTerminatorText: String?
    
    public var primaryColor: Color
    public let secondaryColor: Color
    public let spoilerHeaderBackgroundColor: Color
    public let spoilerOutlineColor: Color
    public let codeBackgroundColor: Color
    public let quoteColor: Color
    public let quoteBarColor: Color
    public var unloadedImageIcon: String
    
    public init(
        inlineImageLoader: @escaping (InlineImage) async -> Void,
        imageBlockView: @escaping (_: InlineImage) -> AnyView,
        stubSpoilers: Bool = false,
        spoilerStubIcon: String = "eye.slash.fill",
        unloadedImageIcon: String = "photo",
        truncationTerminatorText: String? = nil,
        primaryColor: Color = .primary,
        secondaryColor: Color = .secondary,
        spoilerHeaderBackgroundColor: Color = .init(uiColor: .secondarySystemBackground),
        spoilerOutlineColor: Color = Color(uiColor: .tertiaryLabel),
        codeBackgroundColor: Color = .init(uiColor: .secondarySystemBackground),
        quoteBarColor: Color = .init(uiColor: .tertiaryLabel),
        quoteColor: Color = .secondary
    ) {
        self.inlineImageLoader = inlineImageLoader
        self.imageBlockView = imageBlockView
        
        self.stubSpoilers = stubSpoilers
        self.spoilerStubIcon = spoilerStubIcon
        self.unloadedImageIcon = unloadedImageIcon
        self.truncationTerminatorText = truncationTerminatorText
        
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.spoilerHeaderBackgroundColor = spoilerHeaderBackgroundColor
        self.spoilerOutlineColor = spoilerOutlineColor
        self.codeBackgroundColor = codeBackgroundColor
        self.quoteBarColor = quoteBarColor
        self.quoteColor = quoteColor
    }
}
