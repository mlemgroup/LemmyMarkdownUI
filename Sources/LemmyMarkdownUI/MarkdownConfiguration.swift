//
//  MarkdownConfiguration.swift
//
//
//  Created by Sjmarf on 26/04/2024.
//

import SwiftUI

public struct MarkdownConfiguration {
    public var inlineImageLoader: (MarkdownImage) async -> Void
    @ViewBuilder public var imageBlockView: (_ image: MarkdownImage) -> AnyView
    
    public var imagePresentationMode: ImagePresentationMode
    public var wrapCodeBlockLines: Bool
    
    public var spoilerLabel: String
    public var tableLabel: String
    public var censorLabel: String
    
    public var primaryColor: Color
    public var secondaryColor: Color
    public var spoilerHeaderBackgroundColor: Color
    public var spoilerOutlineColor: Color
    public var codeBackgroundColor: Color
    public var censorColor: Color
    public var quoteColor: Color
    public var quoteBarColor: Color
    public var unloadedImageIcon: String
    public var font: UIFont
    public var codeFontScaleFactor: Double
    
    public init(
        imagePresentationMode: ImagePresentationMode = .contextual,
        inlineImageLoader: @escaping (MarkdownImage) async -> Void,
        imageBlockView: @escaping (_: MarkdownImage) -> AnyView,
        wrapCodeBlockLines: Bool = true,
        unloadedImageIcon: String = "photo",
        spoilerLabel: String = "Spoiler",
        tableLabel: String = "Table",
        censorLabel: String = "Censored",
        primaryColor: Color = .primary,
        secondaryColor: Color = .secondary,
        spoilerHeaderBackgroundColor: Color = .init(uiColor: .secondarySystemBackground),
        spoilerOutlineColor: Color = Color(uiColor: .tertiaryLabel),
        codeBackgroundColor: Color = .init(uiColor: .secondarySystemBackground),
        censorColor: Color = .red,
        quoteBarColor: Color = .init(uiColor: .tertiaryLabel),
        quoteColor: Color = .secondary,
        font: UIFont.TextStyle = .body,
        codeFontScaleFactor: Double = 1
    ) {
        self.imagePresentationMode = imagePresentationMode
        
        self.inlineImageLoader = inlineImageLoader
        self.imageBlockView = imageBlockView
        
        self.wrapCodeBlockLines = wrapCodeBlockLines
        self.unloadedImageIcon = unloadedImageIcon
        
        self.spoilerLabel = spoilerLabel
        self.tableLabel = tableLabel
        self.censorLabel = censorLabel
        
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.spoilerHeaderBackgroundColor = spoilerHeaderBackgroundColor
        self.spoilerOutlineColor = spoilerOutlineColor
        self.codeBackgroundColor = codeBackgroundColor
        self.censorColor = censorColor
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

public enum ImagePresentationMode {
    case block, inline
    /// Images with tooltips are displayed inline, all others are displayed as blocks.
    case contextual
}
