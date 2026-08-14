//
//  CodeBlockView.swift
//  LemmyMarkdownUI
//
//  Created by Sjmarf on 2024-10-19.
//

import SwiftUI
import HighlightSwift

internal struct CodeBlockView: View {
    let content: String
    let language: String?
    let configuration: MarkdownConfiguration

    @State private var highlightedText: AttributedString?

    @Environment(\.colorScheme) var colorScheme

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
        .task(id: colorScheme) {
            await performHighlighting(for: colorScheme)
        }
    }

    @ViewBuilder
    var contentView: some View {
        if let highlighted = highlightedText,
           configuration.enableSyntaxHighlighting {
            Text(highlighted)
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

    func performHighlighting(for scheme: ColorScheme) async {
        guard configuration.enableSyntaxHighlighting else { return }
        guard let language else { return }
        do {
            let highlight = Highlight()
            let colors: HighlightColors = scheme == .dark ? .dark(.github) : .light(.github)
            let highlighted = try await highlight.attributedText(content, language: language, colors: colors)
            guard !Task.isCancelled else { return }
            self.highlightedText = highlighted
        } catch {
            print("Syntax highlighting failed: \(error)")
        }
    }
}
