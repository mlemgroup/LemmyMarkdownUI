//
//  MarkdownConfiguration.swift
//
//
//  Created by Sjmarf on 26/04/2024.
//

import SwiftUI

public struct MarkdownConfiguration {
    public var inlineImageLoader: (InlineImage) async -> Void
    @ViewBuilder public var imageBlockView: (_ image: InlineImage) -> AnyView
    
    public var allowInlineImages: Bool
    public var stubSpoilers: Bool
    public var wrapCodeBlockLines: Bool
    public var spoilerStubIcon: String
    public var truncationTerminatorText: String?
    
    public var primaryColor: Color
    public var secondaryColor: Color
    public var spoilerHeaderBackgroundColor: Color
    public var spoilerOutlineColor: Color
    public var codeBackgroundColor: Color
    public var quoteColor: Color
    public var quoteBarColor: Color
    public var unloadedImageIcon: String
    public var font: UIFont
    public var codeFontScaleFactor: Double
    
    public init(
        allowInlineImages: Bool = true,
        inlineImageLoader: @escaping (InlineImage) async -> Void,
        imageBlockView: @escaping (_: InlineImage) -> AnyView,
        stubSpoilers: Bool = false,
        wrapCodeBlockLines: Bool = true,
        spoilerStubIcon: String = "eye.slash.fill",
        unloadedImageIcon: String = "photo",
        truncationTerminatorText: String? = nil,
        primaryColor: Color = .primary,
        secondaryColor: Color = .secondary,
        spoilerHeaderBackgroundColor: Color = .init(uiColor: .secondarySystemBackground),
        spoilerOutlineColor: Color = Color(uiColor: .tertiaryLabel),
        codeBackgroundColor: Color = .init(uiColor: .secondarySystemBackground),
        quoteBarColor: Color = .init(uiColor: .tertiaryLabel),
        quoteColor: Color = .secondary,
        font: UIFont.TextStyle = .body,
        codeFontScaleFactor: Double = 1
    ) {
        self.allowInlineImages = allowInlineImages
        
        self.inlineImageLoader = inlineImageLoader
        self.imageBlockView = imageBlockView
        
        self.stubSpoilers = stubSpoilers
        self.wrapCodeBlockLines = wrapCodeBlockLines
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
        
        self.font = .preferredFont(forTextStyle: font)
        self.codeFontScaleFactor = codeFontScaleFactor
    }
    
    internal func withFont(_ font: UIFont) -> Self {
        var new = self
        new.font = font
        return new
    }
}
