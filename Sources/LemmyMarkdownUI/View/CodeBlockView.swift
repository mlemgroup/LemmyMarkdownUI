//
//  CodeBlockView.swift
//  LemmyMarkdownUI
//
//  Created by Sjmarf on 2024-10-19.
//

import SwiftUI
import HighlightSwift

internal struct CodeBlockView: View {
    @Environment(\.colorScheme) var colorScheme

    let content: String
    let language: String?
    let configuration: MarkdownConfiguration

    struct HighlightedText {
        let light: AttributedString
        let dark: AttributedString

        subscript(_ scheme: ColorScheme) -> AttributedString {
            switch scheme {
            case .light: light
            case .dark: dark
            default: dark
            }
        }
    }

    @State private var highlightedText: HighlightedText?

    init(content: String, language: String? = nil, configuration: MarkdownConfiguration) {
        self.content = content.trimmingCharacters(in: .newlines)
        self.language = language
        self.configuration = configuration
    }

    var body: some View {
        Group {
            if configuration.wrapCodeBlockLines {
                contentView
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ScrollView(.horizontal) { contentView }
            }
        }
        .background(configuration.codeBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .task {
            await performHighlighting()
        }
    }

    @ViewBuilder
    var contentView: some View {
        if let highlighted = highlightedText,
           configuration.enableSyntaxHighlighting {
            Text(highlighted[colorScheme])
                .font(codeFont)
                .padding(10)
        } else {
            Text(content)
                .font(codeFont)
                .foregroundColor(configuration.primaryColor)
                .padding(10)
        }
    }

    var codeFont: Font {
        Font(
            configuration.font.withSize(configuration.font.pointSize * configuration.codeFontScaleFactor)
        ).monospaced()
    }

    func performHighlighting() async {
        guard configuration.enableSyntaxHighlighting else { return }
        guard let language else { return }
        do {
            let highlight = Highlight()
            async let light = highlight.attributedText(content, language: language, colors: .light(.github))
            async let dark = highlight.attributedText(content, language: language, colors: .dark(.github))
            let highlightedText: HighlightedText = try await .init(light: light, dark: dark)
            guard !Task.isCancelled else { return }
            self.highlightedText = highlightedText
        } catch {
            print("Syntax highlighting failed: \(error)")
        }
    }
}
